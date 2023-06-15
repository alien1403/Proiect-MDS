import 'package:crypto_tutorial/View/selectCoin.dart';
import 'package:flutter/material.dart';
import 'package:crypto_tutorial/Model/coinModel.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:crypto_tutorial/Model/coinData.dart';
import 'package:flutter/services.dart';
import 'package:crypto_tutorial/View/splash.dart';
import 'package:crypto_tutorial/View/navBar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SellPage extends StatefulWidget {

  SellPage({super.key, required this.coin_id});
  String coin_id = "";

  String image = "";
  String symbol = "";
  num value = 0;
  num cap = 0;

  var _done = null;

  @override
  State<SellPage> createState() => _SellPageState();
}

class _SellPageState extends State<SellPage> {
  @override
  void initState()
  {

    super.initState();
    CoinData coin = new CoinData(id:widget.coin_id);
    coin.getCoinData().then((_)
    {
      setState(() {
        widget.image = coin.img_link;
        widget.symbol = coin.symbol;
        widget.value = coin.value;
        widget.cap = coin.cap;
        widget._done = true;
      });
    });



  }


  @override
  Widget build(BuildContext context) {
    double myHeight = MediaQuery.of(context).size.height;
    double myWidth = MediaQuery.of(context).size.width;

    if(widget._done == null)
      {
        return CircularProgressIndicator();
      }
    double doubleVar = 0;

    return SafeArea(
      child: Scaffold(
      body: Container(
      height: myHeight,
      width: myWidth,

      child: Column(
          children: [

          Padding(
      padding: EdgeInsets.symmetric(
      horizontal: myWidth * 0.05, vertical: myHeight * 0.02
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
// ----------------------------------- IMAGINE, NUME & ABREVIERE -----------------------------------
// ----------------------------------- (stanga sus) -----------------------------------
          Row(
            children: [
// ----------------------------------- Imagine -----------------------------------
              Container(
                  height: myHeight * 0.08,
                  child: Image.network(widget.image)
              ),
              SizedBox(
                width: myWidth * 0.03,
              ),

// ----------------------------------- Nume & abreviere -----------------------------------
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
// ----------------------------------- Nume moneda -----------------------------------
                  Text(
                    widget.coin_id,
                    style: TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(
                    height: myHeight * 0.01,
                  ),

// ----------------------------------- Abreviere moneda -----------------------------------
                  Text(
                    widget.symbol,
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.normal,
                        color: Colors.grey),
                  ),

                ],
              ),

            ],
          ),


// -----------------------------------Pret actual & modif. in ultimele 24H -----------------------------------
// ----------------------------------- (dreapta sus) -----------------------------------
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '\$' + widget.value.toString(),
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.normal,
                    color: Colors.black),
              ),
              SizedBox(
                height: myHeight * 0.01,
              ),
              Text(
                widget.cap.toString() + '%',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.normal,
                    color: widget.cap >= 0
                        ? Colors.green
                        : Colors.red),
              ),
            ],
          ),


        ],
      ),
      ),

            SizedBox(
              height: myHeight * 0.05,
            ),

            Container(
              width : myWidth * 0.7,
              height: myHeight * 0.1,
              child:new TextField(
                controller: TextEditingController(text: "0"),
                decoration: new InputDecoration(labelText: "Enter your number"),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                ],
                onChanged: (value) => doubleVar = double.parse(value),// Only numbers can be entered
              ),

            ),

            ElevatedButton(
              onPressed: () async {
                bool ok = await updateCrypto(doubleVar);

                if(ok)
                {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => NavBar()),
                  );
                }
                else
                {
                  showDialog(context: context,
                      builder: (BuildContext context)
                      {
                        return AlertDialog(
                          title: Text("Error"),
                          content: Text("Not enough ammount"),
                          actions: <Widget>[
                            TextButton(
                              child: Text("OK"),
                              onPressed: ()
                              {
                                Navigator.of(context).pop();
                              },
                            ),
                          ],
                        );
                      }
                  );
                }
              },
              child: Text('Sell'),
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.black, backgroundColor: Colors.yellow,
              ),
            ),

          ],
      ),
      ),
      ));

  }

  Future<void> updatePurchaseHistory(String email, String coinName, double quantity) async {
    final DateTime purchaseDate = DateTime.now();

    final FirebaseFirestore firestore = FirebaseFirestore.instance;

    // Get the current purchase history for the user
    final DocumentSnapshot userSnapshot = await firestore.collection('PurchaseHistory').doc(email).get();
    Map<String, dynamic> userPurchaseHistory = userSnapshot.data() as Map<String, dynamic>? ?? {};

    // Create a new purchase entry
    final Map<String, dynamic> newPurchaseEntry = {
      'purchaseDate': purchaseDate.toString(),
      'quantity': quantity,
      'coinName': coinName,
      'type' : 'SELL'
    };

    // Append the new purchase entry to the user's purchase history list
    userPurchaseHistory.update(email, (dynamic value) {
      final List<dynamic> purchaseEntries = value as List<dynamic>;
      purchaseEntries.add(newPurchaseEntry);
      return purchaseEntries;
    }, ifAbsent: () => [newPurchaseEntry]);

    // Update the purchase history in Firestore
    await firestore.collection('PurchaseHistory').doc(email).set(userPurchaseHistory);
  }



  Future<void> printAllPurchaseActions() async {
    final FirebaseAuth auth = FirebaseAuth.instance;
    final User? user = auth.currentUser;
    final String? email = user?.email;

    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    final DocumentSnapshot userSnapshot = await firestore.collection('PurchaseHistory').doc(email).get();

    if (userSnapshot.exists) {
      final Map<String, dynamic>? userPurchaseHistory = userSnapshot.data() as Map<String, dynamic>?;

      if (userPurchaseHistory != null) {
        final List<dynamic>? purchaseEntries = userPurchaseHistory[email] as List<dynamic>?;

        if (purchaseEntries != null && purchaseEntries.isNotEmpty) {
          print('Purchase History for User: $email');
          for (var entry in purchaseEntries) {
            final Map<String, dynamic> purchaseEntry = entry as Map<String, dynamic>;

            final String purchaseDate = purchaseEntry['purchaseDate'] as String;
            final double quantity = purchaseEntry['quantity'] as double;
            final String coinName = purchaseEntry['coinName'] as String;
            final String type = purchaseEntry['type'] as String;

            print('=================================================================');
            print('Purchase Date: $purchaseDate');
            print('Quantity: $quantity');
            print('Coin Name: $coinName');
            print('Type: $type');
            print('=================================================================');
          }
          return;
        }
      }
    }

    print('No purchase history found for the user: $email');
  }


  Future<bool> updateCrypto(num ammount) async
  {
    if(ammount < 0.0)
      return false;


    final FirebaseAuth auth = FirebaseAuth.instance;
    User? user = auth.currentUser;
    var uid = user?.uid;

    final db = FirebaseFirestore.instance;

    num current = 0;

    final CollectionReference userDataRef =
    FirebaseFirestore.instance.collection('UserData');

    final QuerySnapshot querySnapshot = await userDataRef.get();


    if(querySnapshot.docs.isEmpty)
        return false;

    double balance = 0;
    for (QueryDocumentSnapshot documentSnapshot in querySnapshot.docs) {
      if(documentSnapshot.id != uid)
        continue;
      Map<String,dynamic>? harta = documentSnapshot.data() as Map<String, dynamic>?;
      for (var item in harta!.entries)
      {
        if(item.key == "balance")
          balance = item.value.toDouble();
        else
          continue;

      }
    }

    CoinData cd = new CoinData(id: widget.coin_id);
    await cd.getCoinData();

    double coin_value = cd.value.toDouble();
    double total_cost = ammount.toDouble() * coin_value;



    for (QueryDocumentSnapshot documentSnapshot in querySnapshot.docs) {
      if(documentSnapshot.id != uid)
        continue;

      Map<String,dynamic>? harta = documentSnapshot.data() as Map<String, dynamic>?;

      for (var item in harta!.entries)
      {
        if(item.key != widget.coin_id)
          continue;

        current = item.value;
      }

      print('Document ID: ${documentSnapshot.id}');
      print('Data: ${documentSnapshot.data()}');

    }

    if(current - ammount < 0.0)
      return false;


    current -= ammount;
    balance += total_cost;

    db.collection("UserData").doc(uid.toString()).update({widget.coin_id : current});
    db.collection("UserData").doc(uid.toString()).update({"balance" : balance});

    await updatePurchaseHistory(user!.email!, widget.coin_id, ammount.toDouble());
    print(">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>");
    await printAllPurchaseActions();
    print(">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>");

    return true;
  }



}
