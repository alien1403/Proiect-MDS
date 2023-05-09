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

class BuyPage extends StatefulWidget {

  BuyPage({super.key, required this.coin_id});
  String coin_id = "";

  String image = "";
  String symbol = "";
  num value = 0;
  num cap = 0;

  var _done = null;

  @override
  State<BuyPage> createState() => _BuyPageState();
}

class _BuyPageState extends State<BuyPage> {
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
                    await updateCrypto(doubleVar);
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => NavBar()),
                    );
                  }
                  ,
                  child: Text('Buy'),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.black, backgroundColor: Colors.yellow,
                  ),
                ),

              ],
            ),
          ),
        ));

  }


  Future<void> updateCrypto(num value) async
  {
    final FirebaseAuth auth = FirebaseAuth.instance;
    User? user = auth.currentUser;
    var uid = user?.uid;

    final db = FirebaseFirestore.instance;

    num current = 0;



    final CollectionReference userDataRef =
    FirebaseFirestore.instance.collection('UserData');

    final QuerySnapshot querySnapshot = await userDataRef.get();


    if (querySnapshot.docs.isNotEmpty) {
      print("ce e in query-ul asta?");
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
    } else {
      print('No documents found in the "UserData" collection.');
    }


    current += value;
    db.collection("UserData").doc(uid.toString()).set({widget.coin_id : current});
    return;
  }



}
