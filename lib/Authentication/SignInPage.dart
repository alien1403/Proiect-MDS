import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto_tutorial/Model/coinModel.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:crypto_tutorial/View/splash.dart';
import 'package:http/http.dart' as http;


class SignInPage extends StatefulWidget {
  @override
  _SignInPageState createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create Account'),
        backgroundColor: Colors.black,
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: <Widget>[
            TextFormField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Email'),
              validator: (value) {
                if (value!.isEmpty) {
                  return 'Please enter your email';
                }
                return null;
              },
            ),
            TextFormField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
              validator: (value) {
                if (value!.isEmpty) {
                  return 'Please enter your password';
                }
                return null;
              },
            ),
            ElevatedButton(
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  try {
                    UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
                      email: _emailController.text,
                      password: _passwordController.text,
                    );
                    if (userCredential.user != null) {
                      await setDefaultValues();
                      print("chiar a asteptat???");
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => Splash()),
                      );
                    }
                  } catch (e) {
                    // Handle error
                    print('Error: $e');
                  }
                }
              },
              child: Text('Create Account'),
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.black, backgroundColor: Colors.yellow,
              ),
            ),
          ],
        ),
      ),
    );
  }





  Future<void> setDefaultValues() async
  {
      final FirebaseAuth auth = FirebaseAuth.instance;
      User? user = auth.currentUser;
      var uid = user?.uid;

      Map<String,num> dictionar = new Map<String,num>();
      dictionar["balance"] = 10000;

      final db = FirebaseFirestore.instance;


      List<CoinModel>? listaReturnata = await getAllCoins();
      for (var coin in listaReturnata!)
      {
        print(coin.id);
        dictionar[coin.id] = 0;
      }
      db.collection("UserData").doc(uid.toString()).set(dictionar);
      
  }

  Future<List<CoinModel>?> getAllCoins() async
  {
    const url =
        'https://api.coingecko.com/api/v3/coins/markets?vs_currency=usd&sparkline=true';

    var response = await http.get(Uri.parse(url), headers: {
      "Content-Type": "application/json",
      "Accept": "application/json",
    });

    List<CoinModel>? coinMarketList = null;
    if (response.statusCode == 200) {
      var x = response.body;
      coinMarketList = coinModelFromJson(x);
    } else {
      print(response.statusCode);
    }


    return coinMarketList;
  }






}
