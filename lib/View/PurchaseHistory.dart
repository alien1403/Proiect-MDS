import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class PurchaseHistory extends StatefulWidget {
  const PurchaseHistory({Key? key}) : super(key: key);

  @override
  _PurchaseHistoryState createState() => _PurchaseHistoryState();
}

class _PurchaseHistoryState extends State<PurchaseHistory> {
  final FirebaseAuth auth = FirebaseAuth.instance;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  List<Map<String, dynamic>> purchaseEntries = [];

  @override
  void initState() {
    super.initState();
    getAllPurchaseActions();
  }

  Future<void> getAllPurchaseActions() async {
    final User? user = auth.currentUser;
    final String? email = user?.email;

    final DocumentSnapshot userSnapshot =
    await firestore.collection('PurchaseHistory').doc(email).get();

    if (userSnapshot.exists) {
      final Map<String, dynamic>? userPurchaseHistory =
      userSnapshot.data() as Map<String, dynamic>?;

      if (userPurchaseHistory != null) {
        final List<dynamic>? entries =
        userPurchaseHistory[email] as List<dynamic>?;

        if (entries != null && entries.isNotEmpty) {
          setState(() {
            purchaseEntries = entries
                .map((entry) => entry as Map<String, dynamic>)
                .toList()
              ..sort((a, b) => (b['purchaseDate'] as String)
                  .compareTo(a['purchaseDate'] as String));
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Purchase History'),
        backgroundColor: Colors.yellow[700],
      ),
      body: purchaseEntries.isEmpty
          ? Center(
        child: Text(
          'No transactions',
          style: TextStyle(fontSize: 18),
        ),
      )
          : ListView.builder(
        itemCount: purchaseEntries.length,
        itemBuilder: (context, index) {
          final entry = purchaseEntries[index];
          final String purchaseDate = entry['purchaseDate'] as String;
          final double quantity = entry['quantity'] as double;
          final String coinName = entry['coinName'] as String;
          final String type = entry['type'] as String;

          return PurchaseHistoryItem(
            purchaseDate: purchaseDate,
            quantity: quantity,
            coinName: coinName,
            type: type,
          );
        },
      ),
    );
  }
}

class PurchaseHistoryItem extends StatelessWidget {
  const PurchaseHistoryItem({
    Key? key,
    required this.purchaseDate,
    required this.quantity,
    required this.coinName,
    required this.type,
  }) : super(key: key);

  final String purchaseDate;
  final double quantity;
  final String coinName;
  final String type;

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('yyyy/MM/dd : h:m:s');
    final formattedDate = dateFormat.format(DateTime.parse(purchaseDate));

    return Card(
      child: ListTile(
        leading: Icon(
          Icons.check_circle_outline,
          color: Colors.green,
        ),
        title: Text('$coinName | $type'),
        subtitle: Text('$formattedDate | $quantity'),
      ),
    );
  }
}
//Folosit chatgpt pentru corectare, refactorizare si putin generare