import 'package:flutter/material.dart';
import 'package:flutter_financials/trading_view_widgets/company_profile/company_profile.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TradingView Company Profile Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
      appBar: AppBar(
        title: Text('TradingView Company Profile Demo'),
      ),
      body: Center(
        child: TradingViewCompanyProfile(
          width: 400,
          height: 550,
          isTransparent: false,
          colorTheme: "dark",
          symbol: "NASDAQ:AAPL",
          locale: "en",
          largeChartUrl: "https://mylargechart",
        ),
      ),
    ));
  }
}
