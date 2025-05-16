import 'package:flutter/material.dart';
import 'package:flutter_financials/trading_view_widgets/crypto_screener/crypto_screener.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TradingView Crypto Market Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: CryptoMarketDemoPage(),
    );
  }
}

class CryptoMarketDemoPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Cryptocurrency Market Widget Demo'),
      ),
      body: Center(
        // Incapsula in un Container con dimensioni fisse
        child: Container(
          width: 800,
          height: 600,
          child: TradingViewCryptoMarket(
            width: "100%",
            height: 600,
            defaultColumn: "overview",   // "overview", "performance", "oscillators", "moving_averages"
            displayCurrency: "USD",      // "USD" o "BTC"
            colorTheme: "dark",          // "dark" o "light"
            locale: "en",                // Esempi: "en", "it", "de_DE", "fr", ...
            isTransparent: false,
            largeChartUrl: "",           // Opzionale, se vuoi reindirizzare a un tuo chart
          ),
        ),
      ),
    );
  }
}
