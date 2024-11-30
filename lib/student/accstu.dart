import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:myapp/project.dart';
 // Make sure FirstPage is imported correctly
import 'package:shared_preferences/shared_preferences.dart';

class AccountStudent extends StatefulWidget {
  @override
  _AccountStudentState createState() => _AccountStudentState();
}

class _AccountStudentState extends State<AccountStudent> {
  final Color primaryColor = Color(0xFF1A237E);
  Map<String, dynamic>? userData;
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    fetchUserProfile();
  }

  // Fetch the user profile data
  Future<void> fetchUserProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) {
      print("No token found");
      setState(() {
        isLoading = false;
        errorMessage = 'No token found. Please log in again.';
      });
      return;
    }

    try {
      final response = await http.get(
        Uri.parse('http://192.168.1.6:3000/profile'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        setState(() {
          userData = json.decode(response.body);
          isLoading = false;
        });
      } else {
        print("Failed to load user data: ${response.statusCode}");
        setState(() {
          isLoading = false;
          errorMessage = 'Failed to load user data. Please try again later.';
        });
      }
    } catch (e) {
      print("Error: $e");
      setState(() {
        isLoading = false;
        errorMessage = 'Error: Unable to fetch data. Please check your connection.';
      });
    }
  }

  // Show the logout confirmation dialog
  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Log out now?'),
          content: const Text('Are you sure you want to log out?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                final prefs = await SharedPreferences.getInstance();
                await prefs.remove('token');
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => FirstPage()), // Ensure FirstPage is correctly named
                );
              },
              child: const Text('Log out'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: Center(
          child: const Text(
            'SPORT APP',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontFamily: 'Arial',
              fontSize: 28,
            ),
          ),
        ),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: isLoading
            ? const Center(child: CircularProgressIndicator()) // show loading indicator
            : Center(
                child: Padding(
                  padding: const EdgeInsets.all(35.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.only(top: 0.0),
                        child: const CircleAvatar(
                          radius: 60,
                          backgroundColor: Color.fromARGB(255, 104, 117, 180),
                          child: Icon(
                            Icons.account_circle_outlined,
                            size: 120,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      userData == null
                          ? Text(
                              errorMessage.isEmpty ? 'Loading...' : errorMessage,
                              style: const TextStyle(fontSize: 18, color: Colors.red),
                            )
                          : Text(
                              '${userData?['username']?.toUpperCase() ?? 'Default Username'}',
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF01082D),
                              ),
                            ),
                      const SizedBox(height: 10),
                      userData != null
                          ? Card(
                              elevation: 4,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              margin: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(30.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'About Me',
                                      style: TextStyle(
                                        fontSize: 23,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF01082D),
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      'User Name: ${userData?['username']}',
                                      style: const TextStyle(fontSize: 18),
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      'User ID: ${userData?['user_id']}',
                                      style: const TextStyle(fontSize: 18),
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      'Email: ${userData?['email']}',
                                      style: const TextStyle(fontSize: 18),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          : const SizedBox.shrink(), // Hide if no user data
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () => _showLogoutDialog(context),
                        child: const Text(
                          'Log Out',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF01082D),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}
