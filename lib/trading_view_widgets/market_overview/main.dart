import 'package:flutter/material.dart';
import 'package:flutter_financials/trading_view_widgets/market_overview/market_overview.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TradingView Market Overview Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MarketOverviewDemoPage(),
    );
  }
}

class MarketOverviewDemoPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Market Overview Widget Demo'),
      ),
      body: Center(
        child: Container(
          width: 800,
          height: 700, // Usa un'altezza sufficiente per visualizzare l'intero widget
          child: TradingViewMarketOverview(
            colorTheme: "dark",
            dateRange: "12M",
            showChart: true,
            locale: "en",
            width: "100%",
            height: 700,
            largeChartUrl: "",
            isTransparent: false,
            showSymbolLogo: true,
            showFloatingTooltip: true,
            plotLineColorGrowing: "rgba(41, 98, 255, 1)",
            plotLineColorFalling: "rgba(41, 98, 255, 1)",
            gridLineColor: "rgba(42, 46, 57, 0)",
            scaleFontColor: "rgba(219, 219, 219, 1)",
            belowLineFillColorGrowing: "rgba(41, 98, 255, 0.12)",
            belowLineFillColorFalling: "rgba(41, 98, 255, 0.12)",
            belowLineFillColorGrowingBottom: "rgba(41, 98, 255, 0)",
            belowLineFillColorFallingBottom: "rgba(41, 98, 255, 0)",
            symbolActiveColor: "rgba(41, 98, 255, 0.12)",
          ),
        ),
      ),
    );
  }
}
