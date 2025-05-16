import 'package:flutter/material.dart';
import 'package:flutter_financials/trading_view_widgets/foundamental_data/foundamental_data.dart';


void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TradingView Fundamental Data Demo',
      home: Scaffold(
        appBar: AppBar(
          title: Text('Fundamental Data Widget Demo'),
        ),
        body: Center(
          child: TradingViewFundamentalData(
            isTransparent: false,
            largeChartUrl: "https://mylargechart",
            displayMode: "regular",
            width: 400,
            height: 550,
            colorTheme: "dark",
            symbol: "NASDAQ:AAPL",
            locale: "en",
          ),
        ),
      ),
    );
  }
}
