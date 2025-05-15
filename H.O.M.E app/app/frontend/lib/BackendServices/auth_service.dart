Future<bool> login(String email, String password) async {
  try {
    // ...existing code...

    // Fetch user data after successful login
    var userData = await FirebaseFirestore.instance
        .collection("Users")
        .doc(email)
        .get();

    if (userData.exists) {
      // Retrieve householdName from the database
      String? fetchedHouseholdName = userData.data()?['householdName'];

      if (fetchedHouseholdName != null && fetchedHouseholdName.isNotEmpty) {
        // Set householdName in BackendService.session
        BackendService.session.householdName = fetchedHouseholdName;
        print("Household Name Set: ${BackendService.session.householdName}");
      } else {
        print("Error: Household name is missing or invalid.");
        return false; // Return false if householdName is invalid
      }
    } else {
      print("Error: User data not found.");
      return false; // Return false if user data is not found
    }

    return true;
  } catch (e) {
    print("Login Error: $e");
    return false;
  }
}