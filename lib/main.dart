import 'package:crypto_tutorial/Home/Home.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

import 'package:workmanager/workmanager.dart';
import 'Model/coinModel.dart';
import 'Model/notificationAPI.dart';
import 'dart:math';

import 'package:http/http.dart' as http;

// ========================== NOTIFICARI ==========================

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

bool isRefreshingNotif = true;

List<CoinModel>? coinMarketNotif = [];
var coinMarketListNotif;

Future<List<CoinModel>?> getCoinMarketNotif() async {
  const url =
      'https://api.coingecko.com/api/v3/coins/markets?vs_currency=usd&sparkline=true';

  isRefreshingNotif = true;

  print("Awaiting URL");

  var response = await http.get(Uri.parse(url), headers: {
    "Content-Type": "application/json",
    "Accept": "application/json",
  });

  print("BODY");
  print(response.body.toString());
  isRefreshingNotif = false;

  print("Notif code " + response.statusCode.toString());
  if (response.statusCode == 200)
  {
    print("Coin market response OK in notification task");
    var x = response.body;
    coinMarketListNotif = coinModelFromJson(x);
    coinMarketNotif = coinMarketListNotif;
  }
  else
    print(response.statusCode);

  return coinMarketNotif!;
}

void coinForNotification()
{
  List topCoins = [];
  for (var coin in coinMarketNotif!) {
    // double volatility = checkVolatility(coin);

    if (coin.marketCapRank <= 25 && coin.marketCapChangePercentage24H.abs() > 2)
        topCoins.add(coin);
  }

  print("Found top coin out of ${topCoins.length} options");

  var notifCoin = topCoins[Random().nextInt(topCoins.length)];
  var notifAction = notifCoin.marketCapChangePercentage24H > 0 ?
                    "Price rose to \$${notifCoin.currentPrice}!" :
                    "Price dropped to \$${notifCoin.currentPrice}!";

  print("Chosen coin: " + notifCoin.id);
  NotificationAPI.showNotification
  (
    title: "${notifCoin.id}",
    body: "${notifAction}",
    payload: "${notifCoin.id}"
  );
}

// "Mandatory if the App is obfuscated or using Flutter 3.1+"
@pragma('vm:entry-point')
void callbackDispatcher() async
{
  Workmanager().executeTask((task, inputData)
  async {
    print("Native called background task: $task");
    if (task == "fetchCoins")
    {
      print("Fetching...");

      coinMarketNotif = await getCoinMarketNotif();
      print("Length of market in main: ${coinMarketNotif!.length}");

      print("Fetched!");

      coinForNotification();
      print("Notify check done");
    }
    return Future.value(true);
  });
}

// =============================================================================




void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(const MyApp());

  if (navigatorKey.currentState == null)
    // print("navigatorKey nu trebuie sa aiba currentstate null, dar nu asteapta construirea widget tree-ului.");
    print("-");

  await NotificationAPI(navigatorKey).initializeNotifications();

  Workmanager().initialize(callbackDispatcher);
  Workmanager().registerPeriodicTask
    (
      "fetchCoinsID",
      "fetchCoins",
      initialDelay: Duration(seconds: 10),
      frequency: Duration(minutes: 15)
  );
}

class MyApp extends StatelessWidget{
  const MyApp({super.key});

  @override
  Widget build (BuildContext context){
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomePage(),
    );
  }
}