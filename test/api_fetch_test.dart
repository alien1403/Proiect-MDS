import 'package:crypto_tutorial/Model/coinData.dart';
import 'package:flutter_test/flutter_test.dart';


void main() {
  group('Coin API fetch test', () {

    test('   Bitcoin - symbol should be "BTC"', () async {
      CoinData cd_btc = new CoinData(id: "bitcoin");
      await cd_btc.getCoinData();
      expect(cd_btc.symbol, "btc");
    });

    test('   Ethereum - value should be a positive number', () async {
      CoinData cd_eth = new CoinData(id: "ethereum");
      await cd_eth.getCoinData();

      expect((cd_eth.value > 0), true);
    });

    test('   Ripple - price change% in 24h (cap) should be >= -100', () async {
      CoinData cd_xrp = new CoinData(id: "ripple");
      await cd_xrp.getCoinData();
      expect((cd_xrp.cap >= -100), true);
    });

  });
}
