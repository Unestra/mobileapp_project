import 'package:flutter/material.dart';
import 'package:myapp/register.dart';
import 'package:myapp/staff/homeforstaff.dart';
import 'package:myapp/staff_lender/Homeforlen.dart';
import 'package:myapp/student/Homeforstu.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final Uri _uri = Uri.parse('http://192.168.1.6:3000/login');
  bool rememberMe = false;

  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUserCredentials();
  }

  Future<void> _loadUserCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      rememberMe = prefs.getBool('rememberMe') ?? false;
      if (rememberMe) {
        usernameController.text = prefs.getString('username') ?? '';
        passwordController.text = prefs.getString('password') ?? '';
      }
    });
  }

  Future<void> _saveUserCredentials(String username, String password) async {
    final prefs = await SharedPreferences.getInstance();
    if (rememberMe) {
      await prefs.setString('username', username);
      await prefs.setString('password', password);
      await prefs.setBool('rememberMe', true);
    } else {
      await prefs.remove('username');
      await prefs.remove('password');
      await prefs.setBool('rememberMe', false);
    }
  }

// ฟังก์ชันสำหรับเก็บ token ลงใน SharedPreferences
  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token); // เก็บ token
  }

  Future<void> loginUser(String username, String password) async {
    if (username.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter Username and Password')),
      );
      return;
    }

    try {
      final response = await http.post(
        _uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username,
          'password': password,
          'rememberMe': rememberMe, // Sending rememberMe as well
        }),
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200 && responseData['token'] != null) {
        final token = responseData['token'];

        // Save the token
        await saveToken(token);

        // Decode JWT to get the role and username
        final jwt = JWT.decode(token); // Use the 'dart_jsonwebtoken' package
        Map payload = jwt.payload;
        // ส่ง token ใน header แบบ Bearer สำหรับการใช้งาน API อื่นๆ
        final authHeader = {'Authorization': 'Bearer $token'};
        // You can now access the payload and check for the role
        print(payload); // This will print the payload to check the structure
        if (payload.containsKey('role')) {
          String role = payload['role'];
          print('Role: $role'); // Print the role value
        } else {
          print('Role not found');
        }

        // Save user credentials if rememberMe is true
        await _saveUserCredentials(username, password);

        // Navigate based on role
        switch (responseData['role']) {
          case 'Student':
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => StudentPage()),
            );
            break;
          case 'Staff':
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => StaffPage()),
            );
            break;
          case 'Lender':
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => LenderPage()),
            );
            break;
          default:
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Role not found')),
            );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(responseData['message'] ?? 'Login failed')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          iconSize: 30,
          color: Color(0xFF01082D),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        backgroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text('Welcome Back!',
                  style: Theme.of(context).textTheme.headlineLarge!.copyWith(
                      color: Color(0xFF01082D), fontWeight: FontWeight.bold)),
              SizedBox(height: 10),
              Text('Login to continue',
                  style: Theme.of(context)
                      .textTheme
                      .bodyLarge!
                      .copyWith(color: Color(0xFF01082D))),
              SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Container(
                  padding: EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Column(
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text('UserName', style: TextStyle(fontSize: 18)),
                      ),
                      SizedBox(height: 10),
                      TextField(
                        controller: usernameController,
                        decoration: InputDecoration(
                          labelText: 'UserName',
                          hintText: 'UserName',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text('Password', style: TextStyle(fontSize: 18)),
                      ),
                      SizedBox(height: 10),
                      TextField(
                        controller: passwordController,
                        obscureText: true,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          hintText: 'Password',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Checkbox(
                                value: rememberMe,
                                onChanged: (value) {
                                  setState(() {
                                    rememberMe = value!;
                                  });
                                },
                              ),
                              Text('Remember me',
                                  style: TextStyle(color: Color(0xFF1B305B))),
                            ],
                          ),
                          TextButton(
                            onPressed: () {
                              // Handle forget password action here
                            },
                            child: Text(
                              'Forget password?',
                              style: TextStyle(color: Color(0xFF01082D)),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 50),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.symmetric(vertical: 15),
                            backgroundColor: Color(0xFF01082D),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                          onPressed: () {
                            loginUser(usernameController.text,
                                passwordController.text);
                          },
                          child: Text('Login',
                              style:
                                  TextStyle(fontSize: 18, color: Colors.white)),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text("Don't have an account? "),
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const Register(),
                                ),
                              );
                            },
                            child: Text('Register',
                                style: TextStyle(color: Colors.blue)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20),
              Image.asset('assets/images/sports.png')
            ],
          ),
        ),
      ),
      backgroundColor: Colors.white,
    );
  }
}
