import 'package:flutter/material.dart';
import 'package:flutter_financials/trading_view_widgets/economic_calendar/economic_calendar.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TradingView Economic Calendar Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: EconomicCalendarDemoPage(),
    );
  }
}

class EconomicCalendarDemoPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Economic Calendar Widget Demo'),
      ),
      body: Center(
        child: Container(
          // Imposta dimensioni fisse o usa layout responsive
          width: 800,
          height: 600, // Altezza sufficiente per mostrare tutto il contenuto
          child: TradingViewEconomicCalendar(
            width: "100%",
            height: 600,
            colorTheme: "dark",
            isTransparent: false,
            locale: "en",
            importanceFilter: "-1,0,1",
            countryFilter: "ar,au,br,ca,cn,fr,de,in,id,it,jp,kr,mx,ru,sa,za,tr,gb,us,eu",
          ),
        ),
      ),
    );
  }
}
