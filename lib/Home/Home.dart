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

  void _loadSync()
  {
    _signOut().then((_) => _checkAuthState());
  }

  ///
  ///
  ///
  ///

  Future<void> _checkAuthState() async {

      if (FirebaseAuth.instance.currentUser != null) {
        // User is signed in, redirect to Splash function
        if (kDebugMode) {
          print("?");
        }
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => Splash()),
        );
      }

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
        backgroundColor: Colors.black,
      ),
      body: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: () {
                // Redirect to sign-in page
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SignInPage()),
                );
              },
              child: Text('Sign In'),
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.black, backgroundColor: Colors.yellow,
              ),
            ),
            SizedBox(width: 16),
            ElevatedButton(
              onPressed: () {
                // Redirect to login page
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => LoginPage()),
                );
              },
              child: Text('Log In'),
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.black, backgroundColor: Colors.yellow,
              ),
            ),
          ],
        ),
      ),
    );
  }
}