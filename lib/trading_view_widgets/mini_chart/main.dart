import 'package:flutter/material.dart';
import 'package:flutter_financials/trading_view_widgets/mini_chart/mini_chart.dart';


void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TradingView Mini Symbol Overview Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MiniChartDemoPage(),
    );
  }
}

class MiniChartDemoPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mini Chart Widget Demo'),
      ),
      body: Center(
        child: TradingViewMiniSymbolOverview(
          symbol: "FX:EURUSD",
          widgetWidth: "100%",
          widgetHeight: "100%",
          locale: "en",
          dateRange: "12M",
          colorTheme: "dark",
          isTransparent: false,
          autosize: true,
          largeChartUrl: "https://mylargechart",
          containerWidth: 400.0,
          containerHeight: 300.0,
        ),
      ),
    );
  }
}
