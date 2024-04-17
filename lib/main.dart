import 'package:app/pages/homepage.dart';
import 'package:app/pages/navbar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:app/pages/loginpage.dart'; // Import the LoginPage
import 'package:app/pages/signupPage.dart'; // Import the SignupPage

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: FirebaseOptions(
      apiKey: "AIzaSyAf2bVIAxMPsWksVSIM3SMUEi5FAVsB3iw",
      authDomain: "ecoexpense-1cde6.firebaseapp.com",
      projectId: "ecoexpense-1cde6",
      storageBucket: "ecoexpense-1cde6.appspot.com",
      messagingSenderId: "409083412762",
      appId:
          "1:409083412762:web:6f28d8a9153c03b687eca3", // Replace with your actual web app ID
    ),
  );
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
    bool isLoggin = false;

  checkState() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    auth.authStateChanges().listen((User? user) {
      if (user != null && mounted) {
        setState(() {
          isLoggin = true;
        });
      } else {
        setState(() {
          isLoggin = false;
        });
      }
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    checkState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.dark(),
      home: isLoggin? HomePage():MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: YourMainWidget(), // Your main widget containing the buttons
    );
  }
}

class YourMainWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color.fromARGB(252, 26, 27, 27),
                  Color.fromARGB(252, 26, 27, 27)
                ],
              ),
            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  height: 200,
                  width: 200,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('lib/assets/logo.jpg'),
                      fit: BoxFit.fill,
                    ),
                    shape: BoxShape.circle,
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  'ECO EXPENSE',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontFamily: 'YourCustomFont',
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 150),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => LoginPage()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(
                        255, 40, 42, 45), // Change the color to your preference
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50),
                      side: BorderSide(
                        color: Color.fromARGB(255, 255, 255,
                            255), // Change the color to your preference
                        width: 1, // Adjust the width as needed
                      ),
                    ),
                  ),
                  child: Container(
                    width: 300,
                    height: 50,
                    child: Center(
                      child: Text('Login', style: TextStyle(fontSize: 20)),
                    ),
                  ),
                ),
                SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => SignUpPage()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(
                        255, 40, 42, 45), // Change the color to your preference
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50),
                      side: BorderSide(
                        color: Color.fromARGB(255, 255, 255,
                            255), // Change the color to your preference
                        width: 1, // Adjust the width as needed
                      ),
                    ),
                  ),
                  child: Container(
                    width: 300,
                    height: 50,
                    child: Center(
                      child: Text('Signup', style: TextStyle(fontSize: 18)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
