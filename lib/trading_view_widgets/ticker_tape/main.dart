import 'package:flutter/material.dart';
import 'package:flutter_financials/trading_view_widgets/ticker_tape/ticker_tape.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TradingView Ticker Tape Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: TickerTapeDemoPage(),
    );
  }
}

class TickerTapeDemoPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Definisci una lista di simboli come richiesto dal widget
    final List<Map<String, String>> symbols = [
      {"proName": "FOREXCOM:SPXUSD", "title": "S&P 500 Index"},
      {"proName": "FOREXCOM:NSXUSD", "title": "US 100 Cash CFD"},
      {"proName": "FX_IDC:EURUSD", "title": "EUR to USD"},
      {"proName": "BITSTAMP:BTCUSD", "title": "Bitcoin"},
      {"proName": "BITSTAMP:ETHUSD", "title": "Ethereum"},
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text('Ticker Tape Widget Demo'),
      ),
      body: Center(
        child: TradingViewTickerTape(
          symbols: symbols,
          showSymbolLogo: true,
          isTransparent: false,
          largeChartUrl: "https://mylargechart",
          displayMode: "adaptive", // può essere "adaptive", "regular" o "compact"
          colorTheme: "dark",
          locale: "en",
          height: 75.0,
        ),
      ),
    );
  }
}
