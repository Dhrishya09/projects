import os
import base64
import json
from flask import Flask, request, jsonify, make_response
from flask_cors import CORS
import firebase_admin
from firebase_admin import credentials, firestore
import bcrypt  # pip install bcrypt
import smtplib
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart
import random
import string
import time

app = Flask(__name__)
# Allow all origins for all routes. This is valid but consider restricting origins in production.
# To restrict origins, use: CORS(app, resources={r"/*": {"origins": "https://example.com"}})
CORS(app, resources={r"/*": {"origins": "*"}})

# Add this new /status endpoint near the top
@app.route('/status', methods=['GET'])
def status():
    return jsonify({"status": "OK"}), 200

# Get the base64-encoded service account key from the environment variable
service_account_key_base64 = os.getenv('SERVICE_ACCOUNT_KEY_BASE64')

if service_account_key_base64 is None:
    raise ValueError("The SERVICE_ACCOUNT_KEY_BASE64 environment variable is not set.")

# Decode the service account key
service_account_key_json = base64.b64decode(service_account_key_base64).decode('utf-8')

# Convert the JSON string to a dictionary
service_account_key_dict = json.loads(service_account_key_json)

# Initialize Firebase Admin SDK
cred = credentials.Certificate(service_account_key_dict)
firebase_admin.initialize_app(cred)
db = firestore.client()

# API key for authentication
API_KEY = os.getenv('FIRESTORE_API_KEY')

@app.before_request
def before_request():
    if request.method == 'OPTIONS':
        return  # Skip API key check for preflight requests
    print(f"Incoming request: {request.method} {request.path}")
    print(f"Headers: {request.headers}")
    print(f"Body: {request.get_data()}")
    if request.path != '/' and request.headers.get('X-API-KEY') != API_KEY:
        return jsonify({"error": "Unauthorized"}), 401

@app.route('/')
def index():
    return jsonify({"message": "Welcome to the API!"})

def hash_password(password):
    return bcrypt.hashpw(password.encode('utf-8'), bcrypt.gensalt()).decode('utf-8')

def verify_password(password, hashed):
    return bcrypt.checkpw(password.encode('utf-8'), hashed.encode('utf-8'))

def get_house_by_name(household_name):
    # Query the Houses collection based on the "household_name" field
    query = db.collection("Houses").where("household_name", "==", household_name).limit(1).get()
    if query:
        doc = query[0]
        return doc.to_dict(), doc.id
    else:
        return None, None

def generate_new_house_id():
    counter_ref = db.collection("Counters").document("house_counter")
    counter_doc = counter_ref.get()
    if counter_doc.exists:
        new_count = counter_doc.to_dict()["count"] + 1
        counter_ref.update({"count": new_count})
    else:
        new_count = 1
        counter_ref.set({"count": new_count})
    return f"house_{new_count:03d}"

def generate_new_room_id(house_id):
    counter_ref = db.collection("Houses").document(house_id).collection("Counter").document("room_counter")
    counter_doc = counter_ref.get()
    if counter_doc.exists:
        new_count = counter_doc.to_dict().get("count", 0) + 1
        counter_ref.update({"count": new_count})
    else:
        new_count = 1
        counter_ref.set({"count": new_count})
    return f"room_{new_count:03d}"

# Utility function to send email
def send_email(to_email, subject, body):
    from_email = "heuristical0me.app.services@gmail.com"
    from_password = "xqvv ypnf mdmd sgdq"  # Ensure this App Password is correct
    print("Preparing to send email to:", to_email)
    msg = MIMEMultipart()
    msg['From'] = f"Home App Services <{from_email}>"
    msg['To'] = to_email
    msg['Subject'] = subject
    msg.attach(MIMEText(body, 'plain'))
    try:
        server = smtplib.SMTP('smtp.gmail.com', 587)
        server.starttls()
        print("Logging in to SMTP server...")
        server.login(from_email, from_password)
        text = msg.as_string()
        print("Sending email...")
        server.sendmail(from_email, to_email, text)
        print("Email sent successfully to:", to_email)
    except smtplib.SMTPAuthenticationError as e:
        print("SMTP Authentication Error:", e)
        raise
    except Exception as e:
        print("Error sending email:", e)
        raise
    finally:
        server.quit()

# Generate a random verification code
def generate_verification_code(length=6):
    return ''.join(random.choices(string.ascii_uppercase + string.digits, k=length))

# New helper: store verification code in Firestore
def store_verification_code(email, code):
    data = {
        "code": code,
        "timestamp": time.time()
    }
    db.collection("VerificationCodes").document(email.lower().strip()).set(data)

def get_verification_code(email):
    doc = db.collection("VerificationCodes").document(email.lower().strip()).get()
    if doc.exists:
        return doc.to_dict()
    return None

def delete_verification_code(email):
    db.collection("VerificationCodes").document(email.lower().strip()).delete()

# ---------------- Registration Endpoints ----------------
@app.route('/register_manager', methods=['POST'])
def register_manager():
    data = request.get_json()
    household_name = data.get("household_name")
    address = data.get("address")
    manager_name = data.get("manager_name")
    manager_email = data.get("manager_email")
    manager_password = data.get("manager_password")
    manager_dob = data.get("manager_dob")
    manager_phone = data.get("manager_phone")

    if not all([household_name, address, manager_name, manager_email, manager_password, manager_dob, manager_phone]):
        return jsonify({"error": "All fields are required"}), 400

    house_doc, house_id = get_house_by_name(household_name)
    if house_doc:
        return jsonify({"error": "Household already exists"}), 400
    else:
        house_id = generate_new_house_id()
        house_ref = db.collection("Houses").document(house_id)
        house_ref.set({
            "household_name": household_name,
            "address": address
        })
        # Initialize room counter for the new house
        house_ref.collection("Counter").document("room_counter").set({"count": 0})

    verification_code = generate_verification_code()
    store_verification_code(manager_email, verification_code)
    send_email(manager_email, "Email Verification Code", f"Your verification code is: {verification_code}")

    return jsonify({"message": "Verification code sent to email", "house_id": house_id}), 201

# Resend verification code
@app.route('/resend_verification_code', methods=['POST'])
def resend_verification_code():
    try:
        data = request.get_json()
        email = data.get("email")
        if not email:
            return jsonify({"error": "Email is required"}), 400

        verification_code = generate_verification_code()
        store_verification_code(email, verification_code)
        send_email(email, "Email Verification Code", f"Your verification code is: {verification_code}")
        return jsonify({"message": "Verification code resent"}), 200
    except Exception as e:
        print("Error in /resend_verification_code:", e)
        return jsonify({"error": "Internal server error", "details": str(e)}), 500

@app.route('/verify_manager', methods=['POST'])
def verify_manager():
    data = request.get_json()
    manager_email = data.get("manager_email")
    verification_code = data.get("verification_code")

    saved = get_verification_code(manager_email)
    if not saved:
        return jsonify({"error": "Verification code not found"}), 400

    if time.time() - saved["timestamp"] > 300:
        return jsonify({"error": "Verification code expired"}), 400

    if verification_code != saved["code"]:
        return jsonify({"error": "Invalid verification code"}), 400

    manager_name = data.get("manager_name")
    manager_password = data.get("manager_password")
    manager_dob = data.get("manager_dob")
    manager_phone = data.get("manager_phone")
    house_id = data.get("house_id")

    manager_data = {
        "manager_name": manager_name,
        "manager_email": manager_email,
        "manager_password": hash_password(manager_password),
        "manager_dob": manager_dob,
        "manager_phone": manager_phone,
        "is_logged_in": False
    }
    house_ref = db.collection("Houses").document(house_id)
    manager_ref = house_ref.collection("house_manager").document()
    manager_data["manager_id"] = manager_ref.id
    manager_ref.set(manager_data)

    delete_verification_code(manager_email)
    
    # (Optionally) Return manager name so the client can update its session.
    return jsonify({
      "message": "Manager verified and registered successfully",
      "manager": {
         "manager_name": manager_name,
         "manager_email": manager_email,
         "household_name": house_ref.get().to_dict().get("household_name")
      }
    }), 201

@app.route('/register_user', methods=['POST'])
def register_user():
    data = request.get_json()
    input_household_name = data.get("household_name")
    user_name = data.get("user_name")
    user_email = data.get("user_email")
    user_password = data.get("user_password")
    user_dob = data.get("user_dob")
    user_phone = data.get("user_phone")
    if not all([input_household_name, user_name, user_email, user_password, user_dob, user_phone]):
        return make_response(jsonify({"error": "Missing required fields"}), 400)
    
    # Find the house document by household_name
    house_doc, house_id = get_house_by_name(input_household_name)
    if not house_doc:
        return make_response(jsonify({"error": "House not found"}), 404)
    
    # Create the new user in the house_user subcollection
    user_ref = db.collection("Houses").document(house_id).collection("house_user").document()
    user_data = {
        "user_name": user_name,
        "user_email": user_email,
        "user_password": hash_password(user_password),
        "user_dob": user_dob,
        "user_phone": user_phone,
        "is_logged_in": False,
        "profile_pic": "",
        "user_id": user_ref.id,
        "household_name": house_doc.get("household_name")
    }
    user_ref.set(user_data)
    
    # Create the user_devices subcollection under the new user document.
    # (Seeding with an init document to ensure the subcollection exists.)
    user_ref.collection("user_devices").document("init").set({"created": True})
    
    # Create the rooms subcollection at the household level (if not already present)
    room_counter_ref = db.collection("Houses").document(house_id).collection("rooms").document("room_counter")
    room_counter_ref.set({"count": 0}, merge=True)
    
    # Generate & send verification code
    verification_code = generate_verification_code()
    store_verification_code(user_email, verification_code)
    send_email(user_email, "Email Verification Code", f"Your verification code is: {verification_code}")
    
    return make_response(jsonify({"message": "Verification code sent to email", "house_id": house_id, "user_id": user_ref.id}), 201)

@app.route('/verify_user', methods=['POST'])
def verify_user():
    data = request.get_json()
    user_email = data.get("user_email")
    verification_code = data.get("verification_code")
    if not all([user_email, verification_code]):
        return jsonify({"error": "Missing email or verification code"}), 400

    saved = get_verification_code(user_email)
    if not saved:
        return jsonify({"error": "Verification not found"}), 404

    if time.time() - saved["timestamp"] > 300:  # 5 minutes expiration
        return jsonify({"error": "Verification code expired"}), 400

    if verification_code != saved["code"]:
        return jsonify({"error": "Invalid verification code"}), 401

    user_name = data.get("user_name")
    user_password = data.get("user_password")
    user_dob = data.get("user_dob")
    user_phone = data.get("user_phone")
    house_id = data.get("house_id")
    if not all([user_name, user_password, user_dob, user_phone, house_id]):
        return jsonify({"error": "Missing data to complete registration"}), 400

    # Retrieve household_name from the house document
    house_doc = db.collection("Houses").document(house_id).get()
    household_name = house_doc.to_dict().get("household_name") if house_doc.exists else ""

    user_data = {
        "user_name": user_name,
        "user_email": user_email,
        "user_password": hash_password(user_password),
        "user_dob": user_dob,
        "user_phone": user_phone,
        "is_logged_in": False,
        "household_name": household_name  # added field so user is linked to this house
    }
    house_ref = db.collection("Houses").document(house_id)
    user_ref = house_ref.collection("house_user").document()
    user_data["user_id"] = user_ref.id
    user_ref.set(user_data)

    delete_verification_code(user_email)

    return jsonify({"message": "User verified and registered successfully"}), 201

# ---------------- Login Endpoints ----------------
@app.route('/login_manager', methods=['POST'])
def login_manager():
    data = request.get_json()
    input_household_name = data.get("household_name")
    manager_email = data.get("manager_email")
    manager_password = data.get("manager_password")

    if not all([input_household_name, manager_email, manager_password]):
        return jsonify({"error": "All fields are required"}), 400

    house_doc, house_id = get_house_by_name(input_household_name)
    if not house_doc:
        print(f"House not found: {household_name}")
        return jsonify({"error": "House not found"}), 404

    print(f"House found: {house_id}")

    house_ref = db.collection("Houses").document(house_id)
    manager_query = house_ref.collection("house_manager").where("manager_email", "==", manager_email).limit(1).stream()
    manager_doc = None
    for doc in manager_query:
        manager_doc = doc
        break

    if not manager_doc:
        print(f"Manager not found: {manager_email}")
        return jsonify({"error": "Manager not found"}), 404

    manager_data = manager_doc.to_dict()
    if not verify_password(manager_password, manager_data["manager_password"]):
        print(f"Invalid password for manager: {manager_email}")
        return jsonify({"error": "Invalid password"}), 400

    manager_ref = house_ref.collection("house_manager").document(manager_doc.id)
    manager_ref.update({"is_logged_in": True})

    print("Manager login payload:", data)
    return jsonify({
        "message": "Manager logged in successfully",
        "manager": {
            "manager_name": manager_data["manager_name"],
            "manager_email": manager_email,
            "household_name": house_doc.get("household_name"),
            "is_logged_in": True
        }
    }), 200

@app.route('/login_user', methods=['POST'])
def login_user():
    data = request.get_json()
    input_household_name = data.get("household_name")
    user_email = data.get("user_email")
    user_password = data.get("user_password")

    if not all([input_household_name, user_email, user_password]):
        return jsonify({"error": "All fields are required"}), 400

    house_doc, house_id = get_house_by_name(input_household_name)
    if not house_doc:
        return jsonify({"error": "House not found"}), 404

    house_ref = db.collection("Houses").document(house_id)
    user_query = house_ref.collection("house_user").where("user_email", "==", user_email).limit(1).stream()
    user_doc = None
    for doc in user_query:
        user_doc = doc
        break

    if not user_doc:
        return jsonify({"error": "User not found"}), 404

    user_data = user_doc.to_dict()
    if not verify_password(user_password, user_data["user_password"]):
        return jsonify({"error": "Invalid password"}), 400

    user_ref = house_ref.collection("house_user").document(user_doc.id)
    user_ref.update({"is_logged_in": True})

    return jsonify({
        "message": "User logged in successfully",
        "user": {
            "user_name": user_data["user_name"],
            "user_email": user_email,
            "household_name": user_data.get("household_name", input_household_name),
            "is_logged_in": True
        }
    }), 200

@app.route('/login', methods=['POST'])
def login():
    data = request.get_json()
    email = data.get("email")
    password = data.get("password")

    if not all([email, password]):
        return jsonify({"error": "Email and password are required"}), 400

    # Check house_manager collection
    manager_query = db.collection_group("house_manager").where("manager_email", "==", email).limit(1).stream()
    manager_doc = None
    for doc in manager_query:
        manager_doc = doc
        break

    if manager_doc:
        manager_data = manager_doc.to_dict()
        if verify_password(password, manager_data["manager_password"]):
            manager_ref = manager_doc.reference
            manager_ref.update({"is_logged_in": True})
            return jsonify({
                "message": "Manager logged in successfully",
                "account_type": "manager",
                "manager": {
                    "manager_name": manager_data["manager_name"],
                    "manager_email": email,
                    "household_name": manager_data.get("household_name"),
                    "is_logged_in": True
                }
            }), 200
        else:
            return jsonify({"error": "Invalid password"}), 400

    # Check house_user collection
    user_query = db.collection_group("house_user").where("user_email", "==", email).limit(1).stream()
    user_doc = None
    for doc in user_query:
        user_doc = doc
        break

    if user_doc:
        user_data = user_doc.to_dict()
        if verify_password(password, user_data["user_password"]):
            user_ref = user_doc.reference
            user_ref.update({"is_logged_in": True})
            return jsonify({
                "message": "User logged in successfully",
                "account_type": "user",
                "user": {
                    "user_name": user_data["user_name"],
                    "user_email": email,
                    "household_name": user_data.get("household_name"),
                    "is_logged_in": True
                }
            }), 200
        else:
            return jsonify({"error": "Invalid password"}), 400

    return jsonify({"error": "Account not found"}), 404

# ---------------- Sign Out Endpoints ----------------
@app.route('/logout_manager', methods=['POST'])
def logout_manager():
    data = request.get_json()
    manager_email = data.get("manager_email")
    household_name = data.get("household_name")

    house_doc, house_id = get_house_by_name(household_name)
    if not house_doc:
        return jsonify({"error": "Household not found"}), 404

    house_ref = db.collection("Houses").document(house_id)
    manager_query = house_ref.collection("house_manager").where("manager_email", "==", manager_email).limit(1).stream()
    manager_doc = None
    for doc in manager_query:
        manager_doc = doc
        break
    if not manager_doc:
        return jsonify({"error": "Manager not found"}), 404

    manager_ref = house_ref.collection("house_manager").document(manager_doc.id)
    manager_ref.update({"is_logged_in": False})

    return jsonify({"message": "Manager logged out successfully"}), 200

@app.route('/logout_user', methods=['POST'])
def logout_user():
    data = request.get_json()
    user_email = data.get("user_email")
    household_name = data.get("household_name")

    house_doc, house_id = get_house_by_name(household_name)
    if not house_doc:
        return jsonify({"error": "Household not found"}), 404

    house_ref = db.collection("Houses").document(house_id)
    user_query = house_ref.collection("house_user").where("user_email", "==", user_email).limit(1).stream()
    user_doc = None
    for doc in user_query:
        user_doc = doc
        break
    if not user_doc:
        return jsonify({"error": "User not found"}), 404

    user_ref = house_ref.collection("house_user").document(user_doc.id)
    user_ref.update({"is_logged_in": False})

    return jsonify({"message": "User logged out successfully"}), 200

# ---------------- Device Endpoints ----------------
@app.route('/register_device', methods=['POST'])
def register_device():
    data = request.get_json()
    household_name = data.get("household_name")
    account_type = data.get("account_type")
    email = data.get("email")
    device_name = data.get("device_name")
    device_type = data.get("device_type")
    device_location = data.get("device_location")
    device_status = "off"  # default

    if not all([household_name, account_type, email, device_name, device_type, device_location]):
        return jsonify({"error": "Missing required fields"}), 400

    house_doc, house_id = get_house_by_name(household_name)
    if not house_doc:
        return jsonify({"error": "House not found"}), 404

    house_ref = db.collection("Houses").document(house_id)

    if account_type.lower() == "manager":
        manager_query = house_ref.collection("house_manager").where("manager_email", "==", email).limit(1).stream()
        manager_doc = None
        for doc in manager_query:
            manager_doc = doc
            break
        if not manager_doc:
            return jsonify({"error": "Manager not found. Please login or register as a manager."}), 401
        devices_ref = house_ref.collection("house_manager").document(manager_doc.id).collection("manager_devices")
    elif account_type.lower() == "user":
        user_query = house_ref.collection("house_user").where("user_email", "==", email).limit(1).stream()
        user_doc = None
        for doc in user_query:
            user_doc = doc
            break
        if not user_doc:
            return jsonify({"error": "User not found. Please login or register as a user."}), 401
        devices_ref = house_ref.collection("house_user").document(user_doc.id).collection("user_devices")
    else:
        return jsonify({"error": "Invalid account_type"}), 400

    # Check if the device already exists
    existing_device_query = db.collection_group("manager_devices").where("device_name", "==", device_name).where("device_type", "==", device_type).where("device_location", "==", device_location).limit(1).stream()
    existing_device_doc = None
    for doc in existing_device_query:
        existing_device_doc = doc
        break

    if existing_device_doc:
        device_data = existing_device_doc.to_dict()
        device_id = existing_device_doc.id
    else:
        new_device = {
            "device_name": device_name,
            "device_type": device_type,
            "device_location": device_location,
            "device_status": device_status
        }
        device_doc = devices_ref.document()
        new_device["device_id"] = device_doc.id
        device_doc.set(new_device)
        device_id = device_doc.id

    return jsonify({"message": "Device registered successfully", "device_id": device_id}), 201

@app.route('/fetch_devices', methods=['POST'])
def fetch_devices():
    data = request.get_json()
    household_name = data.get("household_name")
    account_type = data.get("account_type")
    email = data.get("email")
    password = data.get("password")

    print(f"Received request: household_name={household_name}, account_type={account_type}, email={email}")

    if not all([household_name, account_type, email, password]):
        return jsonify({"error": "All fields are required"}), 400

    house_doc, house_id = get_house_by_name(household_name)
    if not house_doc:
        return jsonify({"error": "House not found"}), 404

    house_ref = db.collection("Houses").document(house_id)
    devices = []
    user_info = {}

    if account_type.lower() == "manager":
        manager_query = house_ref.collection("house_manager").where("manager_email", "==", email).limit(1).stream()
        manager_doc = None
        for doc in manager_query:
            manager_doc = doc
            break
        if not manager_doc:
            return jsonify({"error": "Manager not found. Please register!"}), 401
        if not verify_password(password, manager_doc.to_dict().get("manager_password")):
            return jsonify({"error": "Incorrect password"}), 401

        user_info = {
            "name": manager_doc.to_dict().get("manager_name"),
            "email": manager_doc.to_dict().get("manager_email"),
            "household_name": household_name
        }
        manager_devices_ref = house_ref.collection("house_manager").document(manager_doc.id).collection("manager_devices").stream()
        for doc in manager_devices_ref:
            d = doc.to_dict()
            d["id"] = doc.id
            devices.append(d)

    elif account_type.lower() == "user":
        user_query = house_ref.collection("house_user").where("user_email", "==", email).limit(1).stream()
        user_doc = None
        for doc in user_query:
            user_doc = doc
            break
        if not user_doc:
            return jsonify({"error": "User not found. Please register!"}), 401
        if not verify_password(password, user_doc.to_dict().get("user_password")):
            return jsonify({"error": "Incorrect password"}), 401

        user_info = {
            "name": user_doc.to_dict().get("user_name"),
            "email": user_doc.to_dict().get("user_email"),
            "household_name": household_name
        }
        user_devices_ref = house_ref.collection("house_user").document(user_doc.id).collection("user_devices").stream()
        for doc in user_devices_ref:
            d = doc.to_dict()
            d["id"] = doc.id
            devices.append(d)

        manager_query = house_ref.collection("house_manager").limit(1).stream()
        for doc in manager_query:
            manager_devices_ref = house_ref.collection("house_manager").document(doc.id).collection("manager_devices").stream()
            for dev in manager_devices_ref:
                d = dev.to_dict()
                d["id"] = dev.id
                devices.append(d)

    else:
        print(f"Invalid account_type: {account_type}")
        return jsonify({"error": "Invalid account_type"}), 400

    return jsonify({"devices": devices, "user_info": user_info}), 200

@app.route('/toggle_device_status', methods=['POST'])
def toggle_device_status():
    data = request.get_json()
    household_name = data.get("household_name")
    account_type = data.get("account_type")
    email = data.get("email")
    device_name = data.get("device_name")
    device_location = data.get("device_location")

    if not all([household_name, account_type, email, device_name, device_location]):
        return jsonify({"error": "All fields are required"}), 400

    house_doc, house_id = get_house_by_name(household_name)
    if not house_doc:
        return jsonify({"error": "House not found"}), 404

    house_ref = db.collection("Houses").document(house_id)
    device_doc = None

    if account_type.lower() == "manager":
        manager_query = house_ref.collection("house_manager").where("manager_email", "==", email).limit(1).stream()
        manager_doc = None
        for doc in manager_query:
            manager_doc = doc
            break
        if not manager_doc:
            return jsonify({"error": "Manager not found"}), 404

        devices_ref = house_ref.collection("house_manager").document(manager_doc.id).collection("manager_devices")
        device_query = devices_ref.where("device_name", "==", device_name).where("device_location", "==", device_location).limit(1).stream()
        for doc in device_query:
            device_doc = doc
            break

    elif account_type.lower() == "user":
        user_query = house_ref.collection("house_user").where("user_email", "==", email).limit(1).stream()
        user_doc = None
        for doc in user_query:
            user_doc = doc
            break
        if not user_doc:
            return jsonify({"error": "User not found"}), 404

        devices_ref = house_ref.collection("house_user").document(user_doc.id).collection("user_devices")
        device_query = devices_ref.where("device_name", "==", device_name).where("device_location", "==", device_location).limit(1).stream()
        for doc in device_query:
            device_doc = doc
            break

    if not device_doc:
        return jsonify({"error": "Device not found"}), 404

    device_data = device_doc.to_dict()
    new_status = "on" if device_data["device_status"] == "off" else "off"
    device_doc.reference.update({"device_status": new_status})

    # Update status for all users who have the same device
    manager_devices_ref = house_ref.collection("house_manager").stream()
    for manager_doc in manager_devices_ref:
        manager_devices_query = manager_doc.reference.collection("manager_devices").where("device_name", "==", device_name).where("device_location", "==", device_location).stream()
        for doc in manager_devices_query:
            doc.reference.update({"device_status": new_status})

    user_devices_ref = house_ref.collection("house_user").stream()
    for user_doc in user_devices_ref:
        user_devices_query = user_doc.reference.collection("user_devices").where("device_name", "==", device_name).where("device_location", "==", device_location).stream()
        for doc in user_devices_query:
            doc.reference.update({"device_status": new_status})

    return jsonify({"message": "Device status toggled successfully", "new_status": new_status}), 200

@app.route('/remove_device', methods=['POST'])
def remove_device():
    data = request.get_json()
    household_name = data.get("household_name")
    account_type = data.get("account_type")
    email = data.get("email")
    device_name = data.get("device_name")
    device_location = data.get("device_location")

    if not all([household_name, account_type, email, device_name, device_location]):
        return jsonify({"error": "All fields are required"}), 400

    house_doc, house_id = get_house_by_name(household_name)
    if not house_doc:
        return jsonify({"error": "House not found"}), 404

    house_ref = db.collection("Houses").document(house_id)

    if account_type.lower() == "manager":
        manager_query = house_ref.collection("house_manager").where("manager_email", "==", email).limit(1).stream()
        manager_doc = None
        for doc in manager_query:
            manager_doc = doc
            break
        if not manager_doc:
            return jsonify({"error": "Manager not found"}), 404

        devices_ref = house_ref.collection("house_manager").document(manager_doc.id).collection("manager_devices")
        device_query = devices_ref.where("device_name", "==", device_name).where("device_location", "==", device_location).limit(1).stream()
        device_doc = None
        for doc in device_query:
            device_doc = doc
            break
        if not device_doc:
            return jsonify({"error": "Device not found"}), 404

        device_doc.reference.delete()

    elif account_type.lower() == "user":
        user_query = house_ref.collection("house_user").where("user_email", "==", email).limit(1).stream()
        user_doc = None
        for doc in user_query:
            user_doc = doc
            break
        if not user_doc:
            return jsonify({"error": "User not found"}), 404

        devices_ref = house_ref.collection("house_user").document(user_doc.id).collection("user_devices")
        device_query = devices_ref.where("device_name", "==", device_name).where("device_location", "==", device_location).limit(1).stream()
        device_doc = None
        for doc in device_query:
            device_doc = doc
            break
        if not device_doc:
            return jsonify({"error": "Device not found"}), 404

        device_doc.reference.delete()

    return jsonify({"message": "Device removed successfully"}), 200

@app.route('/forget_password', methods=['POST'])
def forget_password():
  data = request.get_json()
  email = data.get('email')
  if not email:
    return jsonify({"error": "Email is required"}), 400

  # Check if the email exists in the database
  user_query = db.collection_group('house_user').where('user_email', '==', email).limit(1).stream()
  manager_query = db.collection_group('house_manager').where('manager_email', '==', email).limit(1).stream()
  user_doc = next(user_query, None)
  manager_doc = next(manager_query, None)

  if not user_doc and not manager_doc:
    return jsonify({"error": "Email not found"}), 404

  verification_code = generate_verification_code()
  if user_doc:
    user_ref = user_doc.reference
    user_ref.update({"verification_code": verification_code})
  if manager_doc:
    manager_ref = manager_doc.reference
    manager_ref.update({"verification_code": verification_code})

  # Send email with verification code
  send_email(email, "Password Reset Verification Code", f"Your verification code is: {verification_code}")

  return jsonify({"message": "Verification code sent to email"}), 200

@app.route('/reset_password', methods=['POST'])
def reset_password():
    data = request.get_json()
    email = data.get('email')
    verification_code = data.get('verification_code')
    new_password = data.get('new_password')

    if not all([email, verification_code, new_password]):
        return jsonify({"error": "All fields are required"}), 400

    user_query = db.collection_group('house_user').where('user_email', '==', email).where('verification_code', '==', verification_code).limit(1).stream()
    manager_query = db.collection_group('house_manager').where('manager_email', '==', email).where('verification_code', '==', verification_code).limit(1).stream()
    user_doc = next(user_query, None)
    manager_doc = next(manager_query, None)

    if not user_doc and not manager_doc:
        return jsonify({"error": "Invalid verification code"}), 400

    hashed_password = hash_password(new_password)
    if user_doc:
        user_ref = user_doc.reference
        user_ref.update({"user_password": hashed_password, "verification_code": None})
    if manager_doc:
        manager_ref = manager_doc.reference
        manager_ref.update({"manager_password": hashed_password, "verification_code": None})

    return jsonify({"message": "Password reset successfully"}), 200

@app.route('/add_room', methods=['POST'])
def add_room():
    data = request.get_json()
    household_name = data.get("household_name")
    account_type = data.get("account_type")
    email = data.get("email")
    room_name = data.get("room_name")

    if not all([household_name, account_type, email, room_name]):
        return jsonify({"error": "All fields are required"}), 400

    house_doc, house_id = get_house_by_name(household_name)
    if not house_doc:
        return jsonify({"error": "House not found"}), 404

    house_ref = db.collection("Houses").document(house_id)

    if account_type.lower() == "manager":
        manager_query = house_ref.collection("house_manager").where("manager_email", "==", email).limit(1).stream()
        manager_doc = None
        for doc in manager_query:
            manager_doc = doc
            break
        if not manager_doc:
            return jsonify({"error": "Manager not found"}), 404

    elif account_type.lower() == "user":
        user_query = house_ref.collection("house_user").where("user_email", "==", email).limit(1).stream()
        user_doc = None
        for doc in user_query:
            user_doc = doc
            break
        if not user_doc:
            return jsonify({"error": "User not found"}), 404

    # Generate a new room ID
    room_id = generate_new_room_id(house_id)

    rooms_ref = house_ref.collection("rooms")
    new_room = {
        "room_name": room_name,
        "room_id": room_id,
        "added_by": email
    }
    room_doc = rooms_ref.document(room_id)
    room_doc.set(new_room)

    return jsonify({"message": "Room added successfully", "room": new_room}), 201

@app.route('/remove_room', methods=['POST'])
def remove_room():
    data = request.get_json()
    household_name = data.get("household_name")
    account_type = data.get("account_type")
    email = data.get("email")
    room_name = data.get("room_name")

    if not all([household_name, account_type, email, room_name]):
        return jsonify({"error": "All fields are required"}), 400

    house_doc, house_id = get_house_by_name(household_name)
    if not house_doc:
        return jsonify({"error": "House not found"}), 404

    house_ref = db.collection("Houses").document(house_id)

    if account_type.lower() == "manager":
        manager_query = house_ref.collection("house_manager").where("manager_email", "==", email).limit(1).stream()
        manager_doc = None
        for doc in manager_query:
            manager_doc = doc
            break
        if not manager_doc:
            return jsonify({"error": "Manager not found"}), 404

    elif account_type.lower() == "user":
        user_query = house_ref.collection("house_user").where("user_email", "==", email).limit(1).stream()
        user_doc = None
        for doc in user_query:
            user_doc = doc
            break
        if not user_doc:
            return jsonify({"error": "User not found"}), 404

    rooms_ref = house_ref.collection("rooms")
    room_query = rooms_ref.where("room_name", "==", room_name).limit(1).stream()
    room_doc = None
    for doc in room_query:
        room_doc = doc
        break
    if not room_doc:
        return jsonify({"error": "Room not found"}), 404

    room_doc.reference.delete()

    return jsonify({"message": "Room removed successfully"}), 200

# Duplicate route definition removed
    data = request.get_json()
    household_name = data.get("household_name")
    room_name = data.get("room_name")
    account_type = data.get("account_type")
    email = data.get("email")

    if not all([household_name, room_name, account_type, email]):
        return jsonify({"error": "All fields are required"}), 400

    house_doc, house_id = get_house_by_name(household_name)
    if not house_doc:
        return jsonify({"error": "House not found"}), 404

    house_ref = db.collection("Houses").document(house_id)
    devices = []

    if account_type.lower() == "manager":
        manager_query = house_ref.collection("house_manager").where("manager_email", "==", email).limit(1).stream()
        manager_doc = None
        for doc in manager_query:
            manager_doc = doc
            break
        if not manager_doc:
            return jsonify({"error": "Manager not found"}), 404

        devices_ref = house_ref.collection("house_manager").document(manager_doc.id).collection("manager_devices")
        devices_query = devices_ref.where("device_location", "==", room_name).stream()
        for doc in devices_query:
            devices.append(doc.to_dict())

    elif account_type.lower() == "user":
        user_query = house_ref.collection("house_user").where("user_email", "==", email).limit(1).stream()
        user_doc = None
        for doc in user_query:
            user_doc = doc
            break
        if not user_doc:
            return jsonify({"error": "User not found"}), 404

        devices_ref = house_ref.collection("house_user").document(user_doc.id).collection("user_devices")
        devices_query = devices_ref.where("device_location", "==", room_name).stream()
        for doc in devices_query:
            devices.append(doc.to_dict())

        manager_devices_ref = house_ref.collection("house_manager").stream()
        for manager_doc in manager_devices_ref:
            manager_devices_query = manager_doc.reference.collection("manager_devices").where("device_location", "==", room_name).stream()
            for doc in manager_devices_query:
                devices.append(doc.to_dict())

    return jsonify({"devices": devices}), 200

@app.route('/add_device', methods=['POST'])
def add_device():
    data = request.get_json()
    # Expected: household_name, user_id, room_id, device_name, device_type, device_location, device_status
    household_name = data.get("household_name")
    user_id = data.get("user_id")
    room_id = data.get("room_id")
    device_name = data.get("device_name")
    device_type = data.get("device_type")
    device_location = data.get("device_location")
    device_status = data.get("device_status", False)
    
    if not all([household_name, user_id, room_id, device_name, device_type, device_location]):
        return make_response(jsonify({"error": "Missing required device fields"}), 400)
    
    house_doc, house_id = get_house_by_name(household_name)
    if not house_doc:
        return make_response(jsonify({"error": "House not found"}), 404)
    
    # Retrieve user document via user_id and create a new device in user_devices subcollection.
    user_ref = db.collection("Houses").document(house_id).collection("house_user").document(user_id)
    if not user_ref.get().exists:
        return make_response(jsonify({"error": "User not found"}), 404)
    
    device_ref = user_ref.collection("user_devices").document()
    device_data = {
        "device_name": device_name,
        "device_type": device_type,
        "device_location": device_location,
        "device_status": device_status,
        "device_id": device_ref.id,
        "room_id": room_id
    }
    device_ref.set(device_data)
    
    return make_response(jsonify({"message": "Device added successfully", "device_id": device_ref.id}), 201)

@app.route('/fetch_managed_households', methods=['POST'])
def fetch_managed_households():
    data = request.get_json()
    manager_email = data.get("manager_email")
    
    if not manager_email:
        return jsonify({"error": "manager_email is required"}), 400

    managed_households = set()
    
    # Collection-group query across all house_manager subcollections
    managers = db.collection_group("house_manager").where("manager_email", "==", manager_email).stream()
    for manager_doc in managers:
        # Get the parent House document reference (the parent of the subcollection)
        house_doc_ref = manager_doc.reference.parent.parent
        if house_doc_ref:
            house_data = house_doc_ref.get().to_dict()
            if house_data and "household_name" in house_data:
                managed_households.add(house_data["household_name"])
    
    return jsonify({"managed_households": list(managed_households)}), 200

@app.route('/fetch_user_details', methods=['POST'])
def fetch_user_details():
    data = request.get_json()
    email = data.get("email")
    household_name = data.get("household_name")

    house_doc, house_id = get_house_by_name(household_name)
    if not house_doc:
        return jsonify({"error": "Household not found"}), 404

    house_ref = db.collection("Houses").document(house_id)

    manager_query = house_ref.collection("house_manager").where("manager_email", "==", email).limit(1).stream()
    for doc in manager_query:
        return jsonify({"user_details": doc.to_dict()}), 200

    user_query = house_ref.collection("house_user").where("user_email", "==", email).limit(1).stream()
    for doc in user_query:
        return jsonify({"user_details": doc.to_dict()}), 200

    return jsonify({"error": "User not found"}), 404

@app.route('/delete_account', methods=['POST'])
def delete_account():
    data = request.get_json()
    email = data.get("email")
    household_name = data.get("household_name")
    account_type = data.get("account_type")

    house_doc, house_id = get_house_by_name(household_name)
    if not house_doc:
        return jsonify({"error": "Household not found"}), 404

    house_ref = db.collection("Houses").document(house_id)

    if account_type.lower() == "manager":
        # Delete the entire household
        house_ref.delete()
        return jsonify({"message": "Household and all associated data deleted successfully"}), 200

    elif account_type.lower() == "user":
        # Delete the user account and associated data
        user_query = house_ref.collection("house_user").where("user_email", "==", email).limit(1).stream()
        user_doc = None
        for doc in user_query:
            user_doc = doc
            break
        if not user_doc:
            return jsonify({"error": "User not found"}), 404

        user_ref = house_ref.collection("house_user").document(user_doc.id)
        user_ref.delete()

        # Delete user's rooms and devices
        rooms_query = house_ref.collection("rooms").where("added_by", "==", email).stream()
        for room_doc in rooms_query:
            room_ref = house_ref.collection("rooms").document(room_doc.id)
            room_ref.delete()

        devices_query = house_ref.collection("devices").where("added_by", "==", email).stream()
        for device_doc in devices_query:
            device_ref = house_ref.collection("devices").document(device_doc.id)
            device_ref.delete()

        return jsonify({"message": "User account and all associated data deleted successfully"}), 200

    return jsonify({"error": "Invalid account type"}), 400

@app.route('/send_invite', methods=['POST'])
def send_invite():
    data = request.get_json()
    manager_email = data.get("manager_email")
    household_name = data.get("household_name")
    user_name = data.get("user_name")
    user_email = data.get("user_email")

    if not all([manager_email, household_name, user_name, user_email]):
        return jsonify({"error": "All fields are required"}), 400

    house_doc, house_id = get_house_by_name(household_name)
    if not house_doc:
        return jsonify({"error": "Household not found"}), 404

    invite_link = f"https://home-app-06fba5e133bf.herokuapp.com/signup?household_name={household_name}"

    email_subject = "Invitation to Join Household"
    email_body = f"Dear {user_name},\n\nYou have been invited to join the household '{household_name}'. Please click the link below to sign up:\n\n{invite_link}\n\nBest regards,\nHome App Team"

    send_email(user_email, email_subject, email_body)

    return jsonify({"message": "Invitation sent successfully"}), 200

@app.route('/fetch_rooms', methods=['POST'])
def fetch_rooms():
    data = request.get_json()
    household_name = data.get("household_name")
    account_type = data.get("account_type")
    email = data.get("email")

    if not all([household_name, account_type, email]):
        return jsonify({"error": "All fields are required"}), 400

    house_doc, house_id = get_house_by_name(household_name)
    if not house_doc:
        return jsonify({"error": "House not found"}), 404

    house_ref = db.collection("Houses").document(house_id)
    rooms = []

    rooms_query = house_ref.collection("rooms").stream()
    for doc in rooms_query:
        rooms.append(doc.to_dict())

    return jsonify({"rooms": rooms}), 200

    # This function is now removed to avoid duplication

@app.route('/fetch_notifications', methods=['POST', 'OPTIONS'])
def fetch_notifications():
    if request.method == 'OPTIONS':
        response = make_response()
        response.headers.add("Access-Control-Allow-Origin", "*")
        response.headers.add("Access-Control-Allow-Headers", "Content-Type, X-API-KEY")
        response.headers.add("Access-Control-Allow-Methods", "POST, GET, OPTIONS")
        return response, 200
    data = request.get_json()
    email = data.get('email')
    household_name = data.get('household_name')
    # ...logic to fetch notifications from Firestore or other source...
    notifications = []  # Replace with actual data
    return jsonify({'notifications': notifications}), 200

@app.route('/fetch_household_users', methods=['POST', 'OPTIONS'])
def fetch_household_users():
    if request.method == 'OPTIONS':
        # Return a valid preflight response
        response = make_response()
        response.status_code = 200
        return response
    data = request.get_json()
    manager_email = data.get('manager_email')
    household_name = data.get('household_name')
    if not (manager_email and household_name):
        return jsonify({"error": "Missing required fields"}), 400
    house_doc, house_id = get_house_by_name(household_name)
    if not house_doc:
        return jsonify({"error": "House not found"}), 404
    users = []
    # Query the 'house_user' subcollection for the given house
    user_docs = db.collection("Houses").document(house_id).collection("house_user").stream()
    for doc in user_docs:
        users.append(doc.to_dict())
    return jsonify({"users": users}), 200

@app.route('/update_manager_profile', methods=['POST'])
def update_manager_profile():
    data = request.get_json()
    manager_email = data.get('manager_email')
    house_id = data.get('house_id')
    update_fields = data.copy()
    # Remove keys that aren't meant for Firestore update (if needed)
    # Update the specific house_manager document corresponding to this manager.
    manager_ref = db.collection("Houses").document(house_id).collection("house_manager").where("manager_email", "==", manager_email).limit(1).get()
    if manager_ref:
        doc = manager_ref[0]
        doc.reference.update(update_fields)
        return jsonify({"message": "Profile updated"}), 200
    else:
        return jsonify({"error": "Manager not found"}), 404

# ---------------- Run the App ----------------
if __name__ == "__main__":
    app.run(host="0.0.0.0", port=int(os.environ.get("PORT", 5000)), debug=True)
