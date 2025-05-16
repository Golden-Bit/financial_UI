import 'package:flutter/material.dart';
import 'package:flutter_financials/trading_view_widgets/news/news.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TradingView Top Stories Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: TopStoriesDemoPage(),
    );
  }
}

class TopStoriesDemoPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Puoi cambiare il feedMode a seconda della configurazione desiderata:
    // Esempio 1: feedMode "symbol"
    // Esempio 2: feedMode "market"
    // Esempio 3: feedMode "all_symbols"
    return Scaffold(
      appBar: AppBar(
        title: Text('Top Stories Widget Demo'),
      ),
      body: Center(
        child: Container(
          width: 800,
          height: 600, // Altezza sufficiente per visualizzare tutto il contenuto
          child: TradingViewTopStories(
            feedMode: "symbol", // oppure "market" o "all_symbols"
            symbol: "BITSTAMP:BTCUSD", // Usato se feedMode è "symbol"
            // market: "crypto", // Usa questo se feedMode è "market"
            isTransparent: false,
            largeChartUrl: "https://mylargechart",
            displayMode: "adaptive", // oppure "regular" per altre configurazioni
            width: "100%",
            height: 600,
            colorTheme: "dark",
            locale: "en",
          ),
        ),
      ),
    );
  }
}
