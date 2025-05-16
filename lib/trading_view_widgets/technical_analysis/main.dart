import 'package:flutter/material.dart';
import 'package:flutter_financials/trading_view_widgets/technical_analysis/technical_analysis.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TradingView Technical Analysis Demo',
      home: Scaffold(
        appBar: AppBar(
          title: Text('Technical Analysis Widget Demo'),
        ),
        body: Center(
          child: TradingViewTechnicalAnalysis(
            interval: "1m",
            symbol: "NASDAQ:AAPL",
            width: 425,
            height: 450,
            isTransparent: false,
            showIntervalTabs: true,
            displayMode: "multiple",
            locale: "en",
            colorTheme: "dark",
            largeChartUrl: "http://mylargecharturl",
          ),
        ),
      ),
    );
  }
}
