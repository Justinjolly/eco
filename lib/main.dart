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

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MyHomePage(),
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
      backgroundColor: Colors.black,
      body: Stack(
        children: [
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
                    primary: Colors.blue, // Change the color to your preference
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(60),
                    ),
                  ),
                  child: Container(
                    width: 150,
                    height: 45,
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
                    primary: Colors.blue, // Change the color to your preference
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(60),
                    ),
                  ),
                  child: Container(
                    width: 150,
                    height: 45,
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


// import 'package:flutter/material.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'pages/loginpage.dart';

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await Firebase.initializeApp(
//     options: FirebaseOptions(
//       apiKey: "AIzaSyAf2bVIAxMPsWksVSIM3SMUEi5FAVsB3iw",
//       authDomain: "ecoexpense-1cde6.firebaseapp.com",
//       projectId: "ecoexpense-1cde6",
//       storageBucket: "ecoexpense-1cde6.appspot.com",
//       messagingSenderId: "409083412762",
//       appId:
//           "1:409083412762:web:6f28d8a9153c03b687eca3", // Replace with your actual web app ID
//     ),
//   );
//   runApp(MyApp());
// }

// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       home: LoginPage(),
//     );
//   }
// }


///hellooo