import 'package:flutter/material.dart';
import 'package:flutter_financials/trading_view_widgets/screener/screener.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TradingView Screener Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: ScreenerDemoPage(),
    );
  }
}

class ScreenerDemoPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('TradingView Screener Widget Demo'),
      ),
      body: Center(
        // Puoi incapsulare in un Container con dimensioni fisse
        child: Container(
          width: 800,
          height: 600, 
          child: TradingViewScreener(
            width: "100%",
            height: 600,
            defaultColumn: "overview",   // Esempi: "overview", "performance", "oscillators", "moving_averages"
            defaultScreen: "general",    // Esempi: "general", "top_gainers", "top_losers", "ath", ...
            market: "forex",            // Esempi: "forex", "crypto", "america", "germany", "india", ...
            showToolbar: true,
            colorTheme: "dark",         // "light" o "dark"
            locale: "en",               // Esempi: "en", "it", "de_DE", "fr", "es", ...
            largeChartUrl: "http://hhtps://mylargechart", 
            isTransparent: false,
          ),
        ),
      ),
    );
  }
}
