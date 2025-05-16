import 'package:flutter/material.dart';
import 'package:flutter_financials/trading_view_widgets/symbol_info/symbol_info.dart';


void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TradingView Symbol Info Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: TradingViewDemoPage(),
    );
  }
}

class TradingViewDemoPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('TradingView Symbol Info Demo'),
      ),
      body: Center(
        child: TradingViewSymbolInfo(
          symbol: "NASDAQ:AAPL",
          width: "550",
          locale: "en",
          colorTheme: "dark",
          isTransparent: false,
          height: 400.0,
        ),
      ),
    );
  }
}
