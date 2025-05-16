import 'package:flutter/material.dart';
// Assumendo che la definizione di LightweightChartsWidget, PricePoint, DateEvent
// sia in questo import, oppure sostituisci col percorso reale:
import 'package:flutter_financials/trading_view_custom_widgets/chart_type_1/chart_type_1.dart';

void main() {
  runApp(MyApp());
}

/// Applicazione principale Flutter, con una sola pagina (MyChartsPage)
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Esempio Lightweight Charts',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyChartsPage(),
    );
  }
}

class MyChartsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Creiamo dei dati di esempio (più lunghi) per dailyData
    final dailyData = [
      PricePoint('2020-01-01', 100.0),
      PricePoint('2020-01-02', 101.3),
      PricePoint('2020-01-03', 99.8),
      PricePoint('2020-01-06', 102.5),
      PricePoint('2020-01-07', 105.2),
      PricePoint('2020-01-08', 104.0),
      PricePoint('2020-01-09', 106.7),
      PricePoint('2020-01-10', 108.3),
      PricePoint('2020-01-11', 107.1),
      PricePoint('2020-01-12', 106.4),
      PricePoint('2020-01-13', 107.8),
      PricePoint('2020-01-14', 110.1),
      PricePoint('2020-01-15', 109.4),
      PricePoint('2020-01-16', 111.2),
      PricePoint('2020-01-17', 112.8),
      PricePoint('2020-01-20', 110.7),
      PricePoint('2020-01-21', 113.5),
      PricePoint('2020-01-22', 114.2),
      PricePoint('2020-01-23', 112.9),
      PricePoint('2020-01-24', 111.6),
      PricePoint('2020-01-27', 112.3),
      PricePoint('2020-01-28', 113.9),
      PricePoint('2020-01-29', 115.0),
      PricePoint('2020-01-30', 114.7),
      PricePoint('2020-01-31', 116.2),
      // Aggiungi altre date se vuoi, per simulare un periodo più lungo
    ];

    // Eventi di esempio su alcune date
    final events = [
      DateEvent('2020-01-01', 'Dividendo: Annuncio inizio anno'),
      DateEvent('2020-01-03', 'Finanziario: Risultati Q4'),
      DateEvent('2020-01-07', 'Gestione: Cambio CEO'),
      DateEvent('2020-01-09', 'Strategia: Nuovo piano industriale'),
      DateEvent('2020-01-14', 'Altro: Fusione societaria'),
      DateEvent('2020-01-15', 'Gestione: Riorganizzazione interna'),
      DateEvent('2020-01-21', 'Finanziario: Aumento di capitale'),
      DateEvent('2020-01-28', 'Dividendo: Pagamento straordinario'),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text('Esempio Chart con Più Dati'),
      ),
      body: Center(
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal, // se la larghezza eccede lo schermo
          child: LightweightChartsWidget(
            title: 'Storia dei prezzi e prestazioni (con dati simulati)',
            dailyData: dailyData,
            events: events,
            width: 2000,  // dimensioni del riquadro IFrame
            height: 800,
          ),
        ),
      ),
    );
  }
}
