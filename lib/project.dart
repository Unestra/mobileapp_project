import 'package:flutter/material.dart';
import 'package:myapp/Login.dart';
import 'package:myapp/register.dart';


class FirstPage extends StatefulWidget {
  const FirstPage({super.key});

  @override
  State<FirstPage> createState() => _FirstPageState();
}

class _FirstPageState extends State<FirstPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(  
      body: SafeArea(
       
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'Hello, Welcome!',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1B305B),
                ),
              ),
              SizedBox(height: 20),
              Image.asset(
                'assets/images/sport.png', // Add your image asset here
                height: 150,
              ),
              SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.only(left: 30.0,right: 30.0),
                child: Text(
                  'Welcome to Borrow Sports! Reserve and borrow sports equipment easily for your next game!',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 15, color: Color(0xFF1B305B)),
                ),
              ),
              SizedBox(height: 40),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const Login(),
                      
                    ),);
                  // Handle login button press
                },
                style: ElevatedButton.styleFrom(
                
                  backgroundColor: Color(0xFF1B305B), // Background color
                  padding: EdgeInsets.symmetric(vertical: 15, horizontal: 100),
                ),
                child: Text('  Login   ', style: TextStyle(fontSize: 16, color: Colors.white)),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                   Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const Register(),
                      
                    ),
                  );
                  // Handle register button press
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF1B305B), // Background color
                  padding: EdgeInsets.symmetric(vertical: 15, horizontal: 100),
                ),
                child: Text('Register', style: TextStyle(fontSize: 16,color: Colors.white)),
              ),
              SizedBox(height: 40),
              Text(
                'Or via social media',
                style: TextStyle(fontSize: 14, color: Color(0xFF1B305B)),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: Icon(Icons.facebook),
                    color: Color(0xFF1B305B),
                    iconSize: 25,
                    onPressed: () {
                      // Handle Facebook login
                    },
                  ),
                  Image(image: AssetImage('assets/images/social.png'),
                  color:Color(0xFF1B305B) ,
                  width: 20,height: 30 ,),
                  SizedBox(width: 20,),
                   Image(image: AssetImage('assets/images/linkedin.png'),
                  color:Color(0xFF1B305B) ,
                  width: 20,height: 30 ,),
                ],
              ),
            ],
          ),
        ),
      ),
       backgroundColor:Colors.white,
    );
  }
}
