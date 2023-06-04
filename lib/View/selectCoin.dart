import 'dart:convert';

import 'package:crypto_tutorial/View/sell.dart';
import 'package:crypto_tutorial/View/buy.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:url_launcher/url_launcher.dart';
import '../Model/chartModel.dart';

class SelectCoin extends StatefulWidget {
  var selectItem;

  SelectCoin({this.selectItem});

  @override
  State<SelectCoin> createState() => _SelectCoinState();
}

class _SelectCoinState extends State<SelectCoin> {
  late TrackballBehavior trackballBehavior;


  @override
  void initState() {
    getChart();
    getNews();
    trackballBehavior = TrackballBehavior(
        enable: true, activationMode: ActivationMode.singleTap);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {


    double myHeight = MediaQuery.of(context).size.height;
    double myWidth = MediaQuery.of(context).size.width;



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
                              child: Image.network(widget.selectItem.image)
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
                                widget.selectItem.id,
                                style: TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.bold),
                              ),
                              SizedBox(
                                height: myHeight * 0.01,
                              ),

// ----------------------------------- Abreviere moneda -----------------------------------
                              Text(
                                widget.selectItem.symbol,
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
                            '\$' + widget.selectItem.currentPrice.toString(),
                            style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.normal,
                                color: Colors.black),
                          ),
                          SizedBox(
                            height: myHeight * 0.01,
                          ),
                          Text(
                            widget.selectItem.marketCapChangePercentage24H.toString() + '%',
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.normal,
                                color: widget.selectItem
                                    .marketCapChangePercentage24H >=
                                    0
                                    ? Colors.green
                                    : Colors.red),
                          ),
                        ],
                      ),


                    ],
                  ),
                ),


// ----------------------------------- _______________ -----------------------------------
                Divider(),

                Expanded(
                    child: Column(
                      children: [
                        Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: myWidth * 0.05, vertical: myHeight * 0.02),

// ----------------------------------- LOW, HIGH & VOL -----------------------------------
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [

// ----------------------------------- LOW (1/3) -----------------------------------
                              Column(
                                children: [
                                  Text(
                                    'Low',
                                    style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.normal,
                                        color: Colors.grey),
                                  ),
                                  SizedBox(
                                    height: myHeight * 0.01,
                                  ),
                                  Text(
                                    '\$' + widget.selectItem.low24H.toString(),
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.normal,
                                        color: Colors.black),
                                  ),
                                ],
                              ),

// ----------------------------------- HIGH (2/3) -----------------------------------
                              Column(
                                children: [
                                  Text(
                                    'High',
                                    style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.normal,
                                        color: Colors.grey),
                                  ),
                                  SizedBox(
                                    height: myHeight * 0.01,
                                  ),
                                  Text(
                                    '\$' + widget.selectItem.high24H.toString(),
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.normal,
                                        color: Colors.black),
                                  ),
                                ],
                              ),

// ----------------------------------- VOL (3/3) -----------------------------------
                              Column(
                                children: [
                                  Text(
                                    'Vol',
                                    style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.normal,
                                        color: Colors.grey),
                                  ),
                                  SizedBox(
                                    height: myHeight * 0.01,
                                  ),
                                  Text(
                                    '\$' +
                                        widget.selectItem.totalVolume.toString() +
                                        'M',
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.normal,
                                        color: Colors.black),
                                  ),
                                ],
                              ),

                            ],
                          ),
                        ),



                        SizedBox(
                          height: myHeight * 0.015,
                        ),


// --------------------------------------------------------------------------------------------
// ----------------------------------- GRAFIC DE TIP CANDLE -----------------------------------
// --------------------------------------------------------------------------------------------
                        Container(
                          height: myHeight * 0.4,
                          width: myWidth,
                          // color: Colors.amber,
                          child: isRefresh == true
                              ? Center(
                            child: CircularProgressIndicator(
                              color: Color(0xffFBC700),
                            ),
                          )
                              : itemChart == null
                              ? Padding(
                            padding: EdgeInsets.all(myHeight * 0.06),
                            child: Center(
                              child: Text(
                                'too many requests 😔',
                                style: TextStyle(fontSize: 18),
                              ),
                            ),
                          )
                              : SfCartesianChart(
                            trackballBehavior: trackballBehavior,
                            zoomPanBehavior: ZoomPanBehavior(
                                enablePinching: true, zoomMode: ZoomMode.x),
                            series: <CandleSeries>[
                              CandleSeries<ChartModel, int>(
                                  enableSolidCandles: true,
                                  enableTooltip: true,
                                  bullColor: Colors.green,
                                  bearColor: Colors.red,
                                  dataSource: itemChart!,
                                  xValueMapper: (ChartModel sales, _) =>
                                  sales.time,
                                  lowValueMapper: (ChartModel sales, _) =>
                                  sales.low,
                                  highValueMapper: (ChartModel sales, _) =>
                                  sales.high,
                                  openValueMapper: (ChartModel sales, _) =>
                                  sales.open,
                                  closeValueMapper: (ChartModel sales, _) =>
                                  sales.close,
                                  animationDuration: 55)
                            ],
                          ),
                        ),

                        // SizedBox(
                        //   height: myHeight * 0.01,
                        // ),
// --------------------------------------------------------------------------------------------
// ------------------- Vizualizare in ultima zi / sapt. / luna / 3 luni ... -------------------
// --------------------------------------------------------------------------------------------
                        Center(
                          child: Container(
                            height: myHeight * 0.03,
                            child: ListView.builder(
                              shrinkWrap: true,
                              scrollDirection: Axis.horizontal,
                              itemCount: text.length,
                              itemBuilder: (context, index) {
                                return Padding(
                                  padding:
                                  EdgeInsets.symmetric(horizontal: myWidth * 0.02),
                                  child: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        textBool = [
                                          false,
                                          false,
                                          false,
                                          false,
                                          false,
                                          false
                                        ];
                                        textBool[index] = true;
                                      });
                                      setDays(text[index]);
                                      getChart();
                                    },
                                    child: Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: myWidth * 0.03,
                                      ),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(5),
                                        color: textBool[index] == true
                                            ? Color(0xffFBC700).withOpacity(0.3)
                                            : Colors.transparent,
                                      ),
                                      child: Text(
                                        text[index],
                                        style: TextStyle(fontSize: 18),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),


                        SizedBox(
                          height: myHeight * 0.02,
                        ),



// --------------------------------------------------------------------------------------------
// ------------------------------------------- NEWS -------------------------------------------
// --------------------------------------------------------------------------------------------
                        Expanded(
                            child: ListView(
                              children: [
                                Padding(
                                  padding: EdgeInsets.symmetric(horizontal: myWidth * 0.06),
                                  child: Text(
                                    'News',
                                    style: TextStyle(fontSize: 25),
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: myWidth * 0.06,
                                      vertical: myHeight * 0.01),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: Html(
                                          data: descriptionEn,
                                          onLinkTap:(url, _, __, ___)
                                          {
                                            _launchURLfun(url);
                                          },
                                          style: {
                                            'p': Style(textAlign: TextAlign.justify),
                                          },
                                        ),
                                      ),
                                      Container(
                                        width: myWidth * 0.25,
                                        child: CircleAvatar(
                                          radius: myHeight * 0.045,
                                          backgroundImage:
                                          AssetImage('assets/image/elonmusk.png'),
                                        ),
                                      )
                                    ],
                                  ),
                                )
                              ],
                            ))
                      ],

                    )),




// --------------------------------------------------------------------------------------------
// ---------------------------------- ADD TO PORTFOLIO, BELL ----------------------------------
// --------------------------------------------------------------------------------------------
                Container(
                  height: myHeight * 0.1,
                  width: myWidth,
                  // color: Colors.amber,
                  child: Column(
                    children: [
                      Divider(),
                      SizedBox(
                        height: myHeight * 0.01,
                      ),
                      Row(
                        children: [

                          SizedBox(
                            width: myWidth * 0.05,
                          ),
// ---------------------------------- ADD TO PORTFOLIO (1/2) ----------------------------------
                         /// BUY
                          Expanded(
                            flex: 2,
                            child: InkWell
                              (
                              onTap: () {Navigator.push(context, MaterialPageRoute(builder: (context) => BuyPage(coin_id: widget.selectItem.id,)),); },
                              child: Container(
                                padding:
                                EdgeInsets.symmetric(vertical: myHeight * 0.015),
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(50),
                                    color: Color(0xffFBC700)),
                                child: Row(

                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      'BUY',
                                      style: TextStyle(fontSize: 20),

                                    ),
                                  ],
                                ),
                              ),
                            ),

                          ),


                          SizedBox(
                            width: myWidth * 0.05,
                          ),

                      /// SELL
                          Expanded(
                            flex: 2,
                            child: InkWell
                              (
                              onTap: () {Navigator.push(context, MaterialPageRoute(builder: (context) => SellPage(coin_id: widget.selectItem.id,)),); },
                              child: Container(

                                padding:
                                EdgeInsets.symmetric(vertical: myHeight * 0.015),
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(50),
                                    color: Color(0xffFBC700)),
                                child: Row(

                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      'SELL',
                                      style: TextStyle(fontSize: 20),

                                    ),
                                  ],
                                ),
                              ),
                            ),

                          ),

                          SizedBox(
                            width: myWidth * 0.05,
                          ),


// ---------------------------------- BELL (2/2) ----------------------------------
                          Expanded(
                            flex: 1,
                            child: Container(
                              padding:
                              EdgeInsets.symmetric(vertical: myHeight * 0.015),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(50),
                                  color: Colors.grey.withOpacity(0.2)),
                              child: Image.asset(
                                'assets/icons/3.1.png',
                                height: myHeight * 0.03,
                                color: Colors.black,
                              ),
                            ),
                          ),


                          SizedBox(
                            width: myWidth * 0.05,
                          ),

                        ],
                      )
                    ],
                  ),
                )



              ],
            ),
          ),
        ));
  }





// ============================================================================================
// ----------------------------------------- BACK END -----------------------------------------
// ============================================================================================

  List<String> text = ['D', 'W', 'M', '3M', '6M', 'Y'];
  List<bool> textBool = [false, false, true, false, false, false];

  int days = 30;

  setDays(String txt) {
    if (txt == 'D') {
      setState(() {
        days = 1;
      });
    } else if (txt == 'W') {
      setState(() {
        days = 7;
      });
    } else if (txt == 'M') {
      setState(() {
        days = 30;
      });
    } else if (txt == '3M') {
      setState(() {
        days = 90;
      });
    } else if (txt == '6M') {
      setState(() {
        days = 180;
      });
    } else if (txt == 'Y') {
      setState(() {
        days = 365;
      });
    }
  }

  List<ChartModel>? itemChart;

  bool isRefresh = true;
  String descriptionEn = "news to be added";

  Future<void> getNews() async
  {
    String url = 'https://api.coingecko.com/api/v3/coins/bitcoin';
    setState(() {
      isRefresh = true;
    });
    var response = await http.get(Uri.parse(url), headers: {
      "Content-Type": "application/json",
      "Accept": "application/json",
    });
    setState(() {
      isRefresh = false;
    });
    if (response.statusCode == 200) {
      var jsonResponse = json.decode(response.body);
      descriptionEn = jsonResponse["description"]["en"];
    } else {
      print(response.statusCode);
    }
  }

  Future<void> getChart() async {
    String url = 'https://api.coingecko.com/api/v3/coins/' +
        widget.selectItem.id +
        '/ohlc?vs_currency=usd&days=' +
        days.toString();

    setState(() {
      isRefresh = true;
    });

    var response = await http.get(Uri.parse(url), headers: {
      "Content-Type": "application/json",
      "Accept": "application/json",
    });

    setState(() {
      isRefresh = false;
    });
    if (response.statusCode == 200) {
      Iterable x = json.decode(response.body);
      List<ChartModel> modelList =
      x.map((e) => ChartModel.fromJson(e)).toList();
      setState(() {
        itemChart = modelList;
      });
    } else {
      print(response.statusCode);
    }
  }

  void _launchURLfun(String? url) async
  {
    if(url == null)
      throw "no $url";

    await launch(url);

  }

}