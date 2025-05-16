import 'dart:math';
import 'package:flutter/material.dart';
// Assicurati che il path sia corretto in base alla tua struttura di progetto.
import 'package:flutter_financials/trading_view_custom_widgets/chart_type_2/chart_type_2.dart';

void main() {
  runApp(const MyApp());
}

/// Genera dati giornalieri dal [startDate] al [endDate] partendo da [startValue]
/// con una volatilità definita da [volatility]. I valori sono generati in modo
/// casuale (usando un seme fisso per garantire riproducibilità) e rappresentano
/// i prezzi in un formato realistico (formato 'yyyy-MM-dd').
List<PricePoint> generateDailyData(String startDate, String endDate, double startValue, double volatility) {
  final List<PricePoint> data = [];
  DateTime current = DateTime.parse(startDate);
  final DateTime end = DateTime.parse(endDate);
  double value = startValue;
  final Random rng = Random(12345); // seme fisso per riproducibilità
  while (!current.isAfter(end)) {
    // Formattiamo la data come 'yyyy-MM-dd'
    final String dateStr = '${current.year.toString().padLeft(4, '0')}-'
        '${current.month.toString().padLeft(2, '0')}-'
        '${current.day.toString().padLeft(2, '0')}';
    // Aggiorniamo il valore aggiungendo una variazione casuale
    value += (rng.nextDouble() - 0.5) * volatility;
    // Garantiamo che il valore non diventi troppo basso
    if (value < 1) value = 1;
    data.add(PricePoint(dateStr, value));
    current = current.add(const Duration(days: 1));
  }
  return data;
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Generiamo dati realistici per due anni (dal 1° gennaio 2020 al 31 dicembre 2021)
    final List<PricePoint> debtData = generateDailyData('2020-01-01', '2021-12-31', 100.0, 2.0);
    final List<PricePoint> equityData = generateDailyData('2020-01-01', '2021-12-31', 150.0, 3.0);
    final List<PricePoint> cashData = generateDailyData('2020-01-01', '2021-12-31', 50.0, 1.5);

    // Creiamo le serie con i dati generati.
    // Ogni serie è definita con:
    // - label: nome della serie (es. "Debt")
    // - colorHex: colore in formato HEX (es. "#d9534f")
    // - data: lista di PricePoint generati
    // - visible: se la serie è inizialmente visibile
    final List<SeriesData> seriesList = [
      SeriesData(label: 'Debt',   colorHex: '#d9534f', data: debtData, visible: true),
      SeriesData(label: 'Equity', colorHex: '#5bc0de', data: equityData, visible: true),
      SeriesData(label: 'Cash',   colorHex: '#5cb85c', data: cashData, visible: true),
    ];

    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Multi-Series Demo')),
        body: Center(
          child: SingleChildScrollView(
            // Usa lo scroll orizzontale per consentire la visualizzazione se il contenuto supera la larghezza
            scrollDirection: Axis.horizontal,
            child: MultiSeriesLightweightChartWidget(
              title: 'Storia dei prezzi e prestazioni (Multi-Series)',
              seriesList: seriesList,
              simulateIfNoData: false, // Abbiamo già fornito dati
              width: 2000,
              height: 1000,
            ),
          ),
        ),
      ),
    );
  }
}
