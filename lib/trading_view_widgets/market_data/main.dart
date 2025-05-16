import 'package:flutter/material.dart';
import 'package:flutter_financials/trading_view_widgets/market_data/market_data.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TradingView Market Data Widget Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MarketDataDemoPage(),
    );
  }
}

class MarketDataDemoPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Definizione della stringa JSON per i gruppi di simboli
    final String symbolsGroupsJson = '''[
      {
        "name": "Indices",
        "originalName": "Indices",
        "symbols": [
          {"name": "FOREXCOM:SPXUSD", "displayName": "S&P 500 Index"},
          {"name": "FOREXCOM:NSXUSD", "displayName": "US 100 Cash CFD"},
          {"name": "FOREXCOM:DJI", "displayName": "Dow Jones Industrial Average Index"},
          {"name": "INDEX:NKY", "displayName": "Japan 225"},
          {"name": "INDEX:DEU40", "displayName": "DAX Index"},
          {"name": "FOREXCOM:UKXGBP", "displayName": "FTSE 100 Index"}
        ]
      },
      {
        "name": "Futures",
        "originalName": "Futures",
        "symbols": [
          {"name": "CME_MINI:ES1!", "displayName": "S&P 500"},
          {"name": "CME:6E1!", "displayName": "Euro"},
          {"name": "COMEX:GC1!", "displayName": "Gold"},
          {"name": "NYMEX:CL1!", "displayName": "WTI Crude Oil"},
          {"name": "NYMEX:NG1!", "displayName": "Gas"},
          {"name": "CBOT:ZC1!", "displayName": "Corn"}
        ]
      },
      {
        "name": "Bonds",
        "originalName": "Bonds",
        "symbols": [
          {"name": "CBOT:ZB1!", "displayName": "T-Bond"},
          {"name": "CBOT:UB1!", "displayName": "Ultra T-Bond"},
          {"name": "EUREX:FGBL1!", "displayName": "Euro Bund"},
          {"name": "EUREX:FBTP1!", "displayName": "Euro BTP"},
          {"name": "EUREX:FGBM1!", "displayName": "Euro BOBL"}
        ]
      },
      {
        "name": "Forex",
        "originalName": "Forex",
        "symbols": [
          {"name": "FX:EURUSD", "displayName": "EUR to USD"},
          {"name": "FX:GBPUSD", "displayName": "GBP to USD"},
          {"name": "FX:USDJPY", "displayName": "USD to JPY"},
          {"name": "FX:USDCHF", "displayName": "USD to CHF"},
          {"name": "FX:AUDUSD", "displayName": "AUD to USD"},
          {"name": "FX:USDCAD", "displayName": "USD to CAD"}
        ]
      }
    ]''';

    return Scaffold(
      appBar: AppBar(
        title: Text('Market Data Widget Demo'),
      ),
      body: Center(
        child: Container(
          width: 800,
          height: 700, // Assicurati che l'altezza sia sufficiente per mostrare tutto
          child: TradingViewMarketData(
            width: "100%",
            height: 700,
            symbolsGroups: symbolsGroupsJson,
            showSymbolLogo: true,
            isTransparent: false,
            colorTheme: "dark",
            locale: "en",
            backgroundColor: "#131722",
            largeChartUrl: "https://mylargechart",
          ),
        ),
      ),
    );
  }
}
