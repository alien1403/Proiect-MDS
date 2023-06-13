import 'dart:ffi';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CoinData
{
  String img_link = "";
  String symbol = "";
  num value = 0;
  num cap = 0;
  String id;


  CoinData({required this.id});

  Future<void> getCoinData() async
  {
    var uri = new Uri.https("api.coingecko.com", ("/api/v3/coins/" + this.id) );
    print(uri.toString());

    var headers = {
      "Content-Type": "application/json",
      "Accept": "application/json",
    };

    var response = await http.get(uri, headers: headers);


    if (response.statusCode == 200) {
      var x = response.body;
      Map<String, dynamic> mapped = json.decode(x);

      this.img_link = mapped["image"]["small"];
      this.symbol = mapped["symbol"];
      this.value = mapped["market_data"]["current_price"]["usd"];
      this.cap = mapped["market_data"]["price_change_percentage_24h"];

    } else {
      print("eroare???");
      print(response.statusCode);
    }

    return;
  }



}


