import 'package:flutter/material.dart';
import 'package:flutter_financials/trading_view_widgets/advanced_chart/advanced_chart.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TradingView Advanced Chart Demo',
      home: Scaffold(
        appBar: AppBar(
          title: Text('Advanced Real-Time Chart Widget'),
        ),
        body: Center(
          child: TradingViewAdvancedChart(
            symbol: "NASDAQ:AAPL",
            width: 800,
            height: 600,
            autosize: true,
            timezone: "Etc/UTC",
            theme: "dark",
            style: "1",
            locale: "en",
            withDateRanges: true,
            range: "YTD",
            hideSideToolbar: false,
            allowSymbolChange: true,
            watchlist: ["OANDA:XAUUSD"],
            details: true,
            hotlist: true,
            calendar: false,
            studies: ["STD;Accumulation_Distribution"],
            showPopupButton: true,
            popupWidth: "1000",
            popupHeight: "650",
            supportHost: "https://www.tradingview.com",
          ),
        ),
      ),
    );
  }
}
