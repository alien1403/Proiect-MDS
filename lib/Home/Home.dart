import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:crypto_tutorial/View/splash.dart';
import 'package:crypto_tutorial/Authentication/SignInPage.dart';
import 'package:crypto_tutorial/Authentication/LogInPage.dart';
import 'package:crypto_tutorial/View/navBar.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    _loadSync();
  }

  Future<void> _signOut() async {
    try {
      await FirebaseAuth.instance.signOut();
      // TODO: Navigate to login screen
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
      // TODO: Handle error
    }
  }

  void _loadSync() {
    _signOut().then((_) => _checkAuthState());
  }

  Future<void> _checkAuthState() async {
    if (FirebaseAuth.instance.currentUser != null) {
      // User is signed in, redirect to Splash function
      if (kDebugMode) {
        print("?");
      }
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => Splash()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Define a custom color for the buttons (golden-yellow with a brown hue)
    Color customButtonColor = Color.fromRGBO(255, 204, 0, 1.0); // Adjust the RGB values as needed

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Welcome to Crypto001',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.black,
      ),
      backgroundColor: Colors.white,
      body: Center(
        child: Container(
          padding: EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF053e61),
                Color(0xFF1597bb),
              ],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(
                Icons.account_balance_wallet,
                size: 64,
                color: Colors.white,
              ),
              SizedBox(height: 16),
              Text(
                'Welcome to Crypto001',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 16),
              Text(
                'Your personal crypto manager tool',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  // Redirect to sign-in page
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => SignInPage()),
                  );
                },
                child: Text(
                  'Sign In',
                  style: TextStyle(fontSize: 20),
                ),
                style: ElevatedButton.styleFrom(
                  primary: customButtonColor,
                  onPrimary: Colors.black,
                  minimumSize: Size(200, 60),
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  // Add hover effects or animated transitions
                  // You can use the AnimatedContainer or InkWell widget for that
                ),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  // Redirect to login page
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => LoginPage()),
                  );
                },
                child: Text(
                  'Log In',
                  style: TextStyle(fontSize: 20),
                ),
                style: ElevatedButton.styleFrom(
                  primary: customButtonColor,
                  onPrimary: Colors.black,
                  minimumSize: Size(200, 60),
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  // Add hover effects or animated transitions
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
