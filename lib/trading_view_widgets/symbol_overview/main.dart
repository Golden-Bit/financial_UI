import 'package:flutter/material.dart';
import 'package:flutter_financials/trading_view_widgets/symbol_overview/symbol_overview.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TradingView Symbol Overview Demo',
      theme: ThemeData.dark(),
      home: Scaffold(
        appBar: AppBar(
          title: Text('Symbol Overview Widget Demo'),
        ),
        body: Center(
          child: TradingViewSymbolOverview(
            symbols: [
              ["Apple", "AAPL|1D"],
              ["Google", "GOOGL|1D"],
              ["Microsoft", "MSFT|1D"],
            ],
            chartOnly: false,
            width: "100%",
            height: "100%",
            locale: "en",
            colorTheme: "dark",
            autosize: true,
            showVolume: true,
            showMA: true,
            hideDateRanges: false,
            hideMarketStatus: false,
            hideSymbolLogo: false,
            scalePosition: "right",
            scaleMode: "Normal",
            fontFamily:
                "-apple-system, BlinkMacSystemFont, Trebuchet MS, Roboto, Ubuntu, sans-serif",
            fontSize: "10",
            noTimeScale: false,
            valuesTracking: "1",
            changeMode: "price-and-percent",
            chartType: "area",
            maLineColor: "#2962FF",
            maLineWidth: 1,
            maLength: 9,
            headerFontSize: "medium",
            lineWidth: 2,
            lineType: 0,
            compareSymbol: {
              "symbol": "AMEX:SPY",
              "lineColor": "#FF9800",
              "lineWidth": 2,
              "showLabels": true,
            },
            dateRanges: ["1d|1", "1m|30", "3m|60", "12m|1D", "60m|1W", "all|1M"],
          ),
        ),
      ),
    );
  }
}
