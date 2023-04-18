import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class Home extends StatefulWidget{
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context){
    double myHeight = MediaQuery.of(context).size.height;
    double myWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      body: Container(
        height: myHeight,
        width: myWidth,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xbaffffdb),
              Color(0xffFBC700),
            ]
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding:  EdgeInsets.symmetric(horizontal: myWidth * 0.05, vertical: myHeight * 0.03),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: myWidth * 0.02, vertical: myHeight * 0.005),
                    decoration:
                      BoxDecoration(color: Colors.white.withOpacity(0.5), borderRadius: BorderRadius.circular(5) ),
                    child:
                      Text(
                          'Main Portfolio ',
                          style: TextStyle(fontSize: 18),
                      ),
                  ),
                  Text(
                    'Top 10 coins   ',
                    style: TextStyle(fontSize: 18),
                  ),
                  Text(
                    'Experimental',
                    style: TextStyle(fontSize: 18),
                  ),
                ],
              ),
            ),
            Row(
              children: [
                Text(
                  'Main Portfolio ',
                  style: TextStyle(fontSize: 18),
                ),
              ],
            ),
            Container(
              height: myHeight * 0.7,
              width: myWidth,
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(50),
                    topRight: Radius.circular(50)
                  )
              ),
            )
          ],
        ),
      ),
    );
  }
}