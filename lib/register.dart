import 'package:flutter/material.dart';
import 'package:myapp/project.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';


class Register extends StatefulWidget {
  const Register({super.key});

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  // Create an instance of FlutterSecureStorage
  

  void registerUser() async {
    
    if (passwordController.text == confirmPasswordController.text) {
      // สร้างข้อมูลที่ต้องส่งไปยังเซิร์ฟเวอร์
      final userData = {
        'username': usernameController.text,
        'email': emailController.text, // เพิ่มอีเมลที่นี่
        'password': passwordController.text,
        'role': 'Student', // ระบุบทบาท
      };

      // ทำการ POST ข้อมูลไปยัง API
      final response = await http.post(
        Uri.parse('http://192.168.1.6:3000/register'), // เปลี่ยน URL ตามที่คุณใช้งาน
        headers: {
          'Content-Type': 'application/json',
          
        },
        body: json.encode(userData), // เข้ารหัสข้อมูลเป็น JSON
      );

      if (response.statusCode == 201) {
        // เมื่อการลงทะเบียนสำเร็จ
        
        final responseBody = json.decode(response.body);

        // ตรวจสอบว่า response มี 'token' หรือไม่
        if (responseBody['token'] != null) {
          // เก็บ JWT Token ใน secure storage
          final prefs = await SharedPreferences.getInstance();
           await prefs.setString('token', responseBody['token']);

          // แสดงข้อความ success
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Registration Successful!')),
          );

          // เปลี่ยนเส้นทางไปยัง FirstPage
          Future.delayed(const Duration(seconds: 3), () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const FirstPage(),
              ),
            );
          });
        } else {
          // ถ้าไม่มี token ใน response
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Token not received!')),
          );
        }
      } else {
        // แสดงข้อความผิดพลาด
        final responseBody = json.decode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(responseBody['message'])),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Passwords do not match')),
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
          padding: const EdgeInsets.all(30.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text('Create Account Now!',
                  style: Theme.of(context).textTheme.headlineLarge!.copyWith(
                      color: const Color(0xFF01082D),
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Column(
                    children: [
                      TextField(
                        controller: usernameController,
                        decoration: InputDecoration(
                          hintText: 'UserName',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        controller: emailController,
                        decoration: InputDecoration(
                          hintText: 'abc@gmail.com',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        controller: passwordController,
                        obscureText: true,
                        decoration: InputDecoration(
                          hintText: 'Password',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        controller: confirmPasswordController,
                        obscureText: true,
                        decoration: InputDecoration(
                          hintText: 'Confirm Password',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                      const SizedBox(height: 50),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            backgroundColor: const Color(0xFF01082D),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                          onPressed: registerUser,
                          child: const Text('Register',
                              style:
                                  TextStyle(fontSize: 18, color: Colors.white)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      backgroundColor: Colors.white,
    );
  }
}
