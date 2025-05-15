//import 'package:flutter/material.dart';
//import 'package:flutter_application_1/pages/settings/settings.dart';
///import '../user/nav.dart';
//import '../settings/refer_earn_page.dart';
//import '../settings/rate_us_page.dart';
//import '../settings/about_page.dart';
//import '../home/login_page.dart'; // Ensure you have a login page for logout
//import 'package:flutter_application_1/BackendServices/backend_service.dart';

//class ProfilePage extends StatelessWidget {
 // const ProfilePage({super.key});

 // @override
 // Widget build(BuildContext context) {
 //   return NavPage(
 //     currentIndex: 3, // Profile tab highlighted
  //    child: _ProfileContent(),
  //  );
 // }
//}

//class _ProfileContent extends StatelessWidget {
  //Future<User> _fetchUserData() async {
    // Fetch user data from the backend
    //final userData = await BackendService.fetchUserDetails(
      //email: 'user@example.com', // Replace with the actual user email
      //householdName: 'household_name', // Replace with the actual household name
   // );
    //if (userData != null) {
      //return User(name: userData['name'], email: userData['email']);
    //} else {
      //throw Exception('Failed to load user data');
   // }
  //}

  //@override
  //Widget build(BuildContext context) {
    //return SafeArea(
      //child: SingleChildScrollView(
        //child: Column(
          //crossAxisAlignment: CrossAxisAlignment.start,
          //children: [
            //const Padding(
              //padding: EdgeInsets.only(left: 20, top: 20, bottom: 20),
              //child: Text(
                //'Profile',
                //style: TextStyle(
                  //fontSize: 24,
                  //fontWeight: FontWeight.bold,
                //),
              //),
            //),
            //Container(
              //padding: const EdgeInsets.all(20),
              //decoration: const BoxDecoration(
                //border: Border(
                  //bottom: BorderSide(color: Color(0xFFEEEEEE), width: 1),
                //),
              //),
              //child: Row(
                //children: [
                  //Container(
                    //width: 70,
                    //height: 70,
                    //decoration: BoxDecoration(
                      //color: const Color(0xFFD6E4FF),
                      //borderRadius: BorderRadius.circular(35),
                    //),
                    //child: ClipRRect(
                      //borderRadius: BorderRadius.circular(35),
                      //child: Image.network(
                        //'https://images.unsplash.com/photo-1511367461989-f85a21fda167?q=80&w=100&h=100&fit=crop',
                        //width: 70,
                        //height: 70,
                        //fit: BoxFit.cover,
                        //errorBuilder: (context, error, stackTrace) => const Icon(
                          //Icons.person,
                          //size: 40,
                          //color: Color.fromARGB(255, 165, 202, 232),
                        //),
                      //),
                    //),
                  //),
                  //const SizedBox(width: 15),
                  //Expanded(
                    //child: Column(
                      //crossAxisAlignment: CrossAxisAlignment.start,
                      //children: [
                        //FutureBuilder<User>(
                          //future: _fetchUserData(), // Fetch user data from database
                          //builder: (context, snapshot) {
                           // if (snapshot.connectionState == ConnectionState.waiting) {
                            //  return const CircularProgressIndicator();
                            //} else if (snapshot.hasError) {
                              //return const Text('Error loading user data');
                            //} else if (!snapshot.hasData) {
                              //return const Text('No user data found');
                            //} else {
                             // final user = snapshot.data!;
                              //return Column(
                                //crossAxisAlignment: CrossAxisAlignment.start,
                                //children: [
                                  //Text(
                                    //user.name,
                                    //style: const TextStyle(
                                      //fontSize: 18,
                                      //fontWeight: FontWeight.w600,
                                    ///),
                                  ///),
                                  //const SizedBox(height: 4),
                                  //Text(
                                    //user.email,
                                    //style: const TextStyle(
                                      //fontSize: 14,
                                      //color: Colors.grey,
                                   // ),
                                 // ),
                               // ],
                              //);
                           // }
                          //},
                   // ),],
                      
                    //),
                  //),
                 // Container(
                   // width: 40,
                    //height: 40,
                    //decoration: BoxDecoration(
                     // color: const Color.fromARGB(255, 145, 159, 248),
                     // borderRadius: BorderRadius.circular(20),
                   // ),
                    //child: const Icon(
                      //Icons.edit,
                      //color: Colors.white,
                     // size: 20,
                    //),
                 // ),
              //  ],
  //            ),
    //        ),
      //      _buildMenuItem(
        //      icon: Icons.settings,
          //    iconColor: const Color.fromARGB(255, 36, 21, 116),
            //  title: 'Settings',
 //             ///showArrow: true,
   //           onTap: () => _navigateTo(context, const SettingsPage()),
     //       ),
       //     _buildMenuItem(
         //     icon: Icons.share,
           //   iconColor: const Color.fromARGB(255, 36, 21, 116),
             // title: 'Refer & Earn',
//              showArrow: true,
  //            onTap: () => _navigateTo(context, const ReferAndEarnPage()),
    //        ),
      //      _buildMenuItem(
        //      icon: Icons.star,
          //    iconColor: const Color.fromARGB(255, 36, 21, 116),
            //  title: 'Rate us',
//              showArrow: true,
  //            onTap: () => _navigateTo(context, const RateUsPage()),
    ///        ),
       //     _buildMenuItem(
         //     icon: Icons.info_outline,
           //   iconColor: const Color.fromARGB(255, 36, 21, 116),
             // title: 'About mHome Services',
//              showArrow: true,
  //            onTap: () => _navigateTo(context, const AboutPage()),
    //        ),
      //      _buildMenuItem(
        //      icon: Icons.logout,
          //    iconColor: const Color.fromARGB(255, 36, 21, 116),
            ///  title: 'Logout',
             // showArrow: true,
             // onTap: () {
//                // Clear navigation stack and go to login page
  //              Navigator.pushAndRemoveUntil(
    ///              context,
       //           MaterialPageRoute(builder: (context) => const LoginPage()),
         //         (route) => false,
           //     );
             // },
 //           ),
   //       ],
     //   ),
//      ),
  //  );
 // }

  //Widget _buildMenuItem({
    //required IconData icon,
    //required Color iconColor,
 //   required String title,
   // required VoidCallback onTap,
  //  bool showArrow = false,
  //}) {
    //return InkWell(
      //onTap: onTap, // Navigation function
      ///child: Container(
       /// padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        //decoration: const BoxDecoration(
          //border: Border(
            //bottom: BorderSide(color: Color(0xFFEEEEEE), width: 1),
          //),
        //),
//        child: Row(
  //        children: [
    //        Container(
      ///        width: 40,
         //     height: 40,
           //   decoration: BoxDecoration(
             //   color: iconColor.withOpacity(0.1),
               // borderRadius: BorderRadius.circular(8),
 ///             ),
    //          child: Icon(
      //          icon,
        //        color: iconColor,
          //      size: 24,
            //  ),
          //  ),
            //const SizedBox(width: 15),
            //Expanded(
              //child: Text(
                //title,
//                style: const TextStyle(
  //                fontSize: 16,
    //              fontWeight: FontWeight.w500,
      //          ),
        //      ),
          //  ),
            //if (showArrow)
//              const Icon(
  //              Icons.arrow_forward_ios,
    //            color: Colors.grey,
      //          size: 16,
        //      ),
          //],
      //  ),
    //  ),
  //  );
 // }

  //void _navigateTo(BuildContext context, Widget page) {
    //Navigator.push(
      //context,
     // MaterialPageRoute(builder: (context) => page),
   // );
  //}
//}

//class User {
  //final String name;
  //final String email;

  //User({required this.name, required this.email});

  //factory User.fromJson(Map<String, dynamic> json) {
    //return User(
      //name: json['name'],
      //email: json['email'],
    //);
 // }
//}
