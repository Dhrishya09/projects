import 'package:flutter/material.dart';
import 'package:flutter_application_1/pages/settings/help_support.dart';
import 'package:flutter_application_1/pages/home/login_page.dart';
import 'package:flutter_application_1/pages/home/terms_conditions.dart';
import 'package:flutter_application_1/pages/notifications.dart';
import 'package:flutter_application_1/widget/settings_item.dart';
import 'package:flutter_application_1/widget/settings_section.dart';
import '../user/nav.dart';
import 'package:flutter_application_1/pages/settings/refer_earn_page.dart';
import 'package:flutter_application_1/pages/settings/rate_us_page.dart';
import 'package:flutter_application_1/pages/settings/about_page.dart';
import 'security_page.dart';
import 'package:flutter_application_1/pages/home/sign_up_user_manager.dart';
import 'package:flutter_application_1/BackendServices/backend_service.dart';
import 'package:flutter_application_1/pages/settings/edit_profile_user.dart';
import 'package:flutter_application_1/pages/user/homeuser_main.dart';

// Renamed class to SettingsUserPage for house users.
class SettingsUserPage extends StatelessWidget {
  const SettingsUserPage({super.key});

  @override
  Widget build(BuildContext context) {
    return NavPage(
      currentIndex: 3,
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () async {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => HomeuserMain(email: '',)),
              );
            },
          ),
          title: Text(
            "Settings",
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          ),
          backgroundColor: Colors.white,
          elevation: 0,
        ),
        body: ListView(
          padding: EdgeInsets.all(16),
          children: [
            SettingsSection(
              title: "Account",
              items: [
                SettingsItem(
                  icon: Icons.person,
                  text: "Edit Profile",
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const EditProfileUser()),
                    );
                  },
                ),
                SettingsItem(
                  icon: Icons.security,
                  text: "Security",
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => SecurityPage()),
                    );
                  },
                ),
                SettingsItem(
                  icon: Icons.notifications,
                  text: "Notifications",
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => NotificationsScreen()),
                    );
                  },
                ),
                SettingsItem(icon: Icons.lock, text: "Privacy"),
              ],
            ),
            SettingsSection(
              title: "Support & About",
              items: [
                SettingsItem(icon: Icons.credit_card, text: "My Subscription"),
                SettingsItem(
                  icon: Icons.share,
                  text: "Refer & Earn",
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const ReferAndEarnPage()),
                    );
                  },
                ),
                SettingsItem(
                  icon: Icons.star,
                  text: "Rate Us",
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const RateUsPage()),
                    );
                  },
                ),
                SettingsItem(
                  icon: Icons.info_outline,
                  text: "About mHome Services",
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const AboutPage()),
                    );
                  },
                ),
                SettingsItem(
                  icon: Icons.help_outline,
                  text: "Help & Support",
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const HelpSupportScreen()),
                    );
                  },
                ),
                SettingsItem(
                  icon: Icons.info_outline,
                  text: "Terms and Policies",
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const PrivacyPolicyPage()),
                    );
                  },
                ),
              ],
            ),
            SettingsSection(
              title: "Actions",
              items: [
                SettingsItem(icon: Icons.report_problem, text: "Report a problem"),
                SettingsItem(icon: Icons.person_add, text: "Add account"),
                SettingsItem(
                  icon: Icons.logout,
                  text: "Log out",
                  onTap: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => const LoginPage()),
                      (route) => false, 
                    );
                  },
                ),
                SettingsItem(
                  icon: Icons.delete,
                  text: "Delete Account",
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text("Confirm Account Deletion"),
                          content: Text("Are you sure you want to delete your account? This action cannot be undone."),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context); 
                              },
                              child: Text("Cancel"),
                            ),
                            TextButton(
                              onPressed: () async {
                                // Replace with actual email and household name
                                String email = 'user@example.com';
                                String householdName = 'Household A';
                                bool success = await BackendService.deleteAccount({
                                  'email': email,
                                  'household_name': householdName,
                                  'account_type': 'manager',
                                });

                                if (success) {
                                  Navigator.pop(context); 
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(builder: (context) => SignUpPage()),
                                  );
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Failed to delete account. Please try again.')),
                                  );
                                }
                              },
                              child: Text("Yes, Delete"),
                              style: TextButton.styleFrom(foregroundColor: Colors.red),
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}