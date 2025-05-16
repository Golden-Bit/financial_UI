import 'package:flutter/material.dart';
import 'package:flutter_financials/trading_view_widgets/single_ticker/single_ticker.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TradingView Single Ticker Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: SingleTickerDemoPage(),
    );
  }
}

class SingleTickerDemoPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Single Ticker Widget Demo'),
      ),
      body: Center(
        child: TradingViewSingleQuote(
          symbol: "FX:EURUSD",
          width: 400,
          isTransparent: false,
          colorTheme: "dark",
          locale: "en",
          largeChartUrl: "https://mylargechart",
          height: 200.0, // imposta l'altezza che preferisci
        ),
      ),
    );
  }
}
