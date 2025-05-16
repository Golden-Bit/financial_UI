import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_financials/trading_view_custom_widgets/chart_type_3/chart_type_3.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Demo MultiSeriesLightweightChart',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const Scaffold(
        body: SafeArea(
          child: DemoPage(),
        ),
      ),
    );
  }
}

class DemoPage extends StatelessWidget {
  const DemoPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Generiamo dati mensili dal 2010 al 2025 per tre serie:
    final List<PricePoint> debtData   = _generateMonthlyData(startYear: 2010, endYear: 2025, baseValue: 300.0);
    final List<PricePoint> equityData = _generateMonthlyData(startYear: 2010, endYear: 2025, baseValue: 150.0);
    final List<PricePoint> cashData   = _generateMonthlyData(startYear: 2010, endYear: 2025, baseValue: 50.0);

    // Creiamo alcune serie con dati simulati
    final seriesList = <SeriesData>[
      SeriesData(
        label: 'Debt',
        colorHex: '#d9534f',
        data: debtData,
        visible: true,
      ),
      SeriesData(
        label: 'Equity',
        colorHex: '#5bc0de',
        data: equityData,
        visible: true,
      ),
      SeriesData(
        label: 'Cash',
        colorHex: '#5cb85c',
        data: cashData,
        visible: true,
      ),
    ];

    // Creiamo una lista di divisori verticali di esempio
    final verticalDividers = <VerticalDividerData>[
      VerticalDividerData(
        time: '2022-01-01',
        colorHex: '#ff0000',
        leftLabel: 'PAST',
        rightLabel: 'FUTURE',
      ),
      VerticalDividerData(
        time: '2023-06-01',
        colorHex: '#ffa500',
        leftLabel: 'MID',
        rightLabel: '...',
      ),
    ];

    return SingleChildScrollView(
      child: Column(
        children: [
          // Il widget con le 3 serie e i divisori
          MultiSeriesLightweightChartWidget(
            title: 'Multi-series + Vertical Dividers (2010 - 2025)',
            seriesList: seriesList,
            simulateIfNoData: false, // non usiamo la simulazione 'interna'
            width: 1000,
            height: 600,
            verticalDividers: verticalDividers,
          ),
          const SizedBox(height: 40),
          const Text('Sotto c\'è altro contenuto, volendo...'),
        ],
      ),
    );
  }

  /// Genera dati mensili da [startYear] a [endYear], partendo
  /// da [baseValue] e applicando oscillazioni pseudo-casuali.
  List<PricePoint> _generateMonthlyData({
    required int startYear,
    required int endYear,
    required double baseValue,
  }) {
    final List<PricePoint> result = [];
    final random = Random();

    double currentValue = baseValue;
    DateTime current = DateTime(startYear, 1, 1);
    final limit = DateTime(endYear, 12, 31);

    while (!current.isAfter(limit)) {
      final y = current.year;
      final m = current.month;
      final dayStr = '01'; // ci basta il primo giorno del mese
      final monthStr = (m < 10) ? '0$m' : '$m';
      final timeStr = '$y-$monthStr-$dayStr';

      // Aggiungiamo un PricePoint
      result.add(
        PricePoint(timeStr, currentValue),
      );

      // Aggiorniamo currentValue pseudo-random
      // es. +/- 10% intorno a baseValue
      final variation = 0.85 + (random.nextDouble() * 0.3); // tra 0.85 e 1.15
      currentValue = currentValue * variation;
      if (currentValue < 0) currentValue = 0;

      // Passiamo al mese successivo
      int newMonth = m + 1;
      int newYear = y;
      if (newMonth > 12) {
        newMonth = 1;
        newYear++;
      }
      current = DateTime(newYear, newMonth, 1);
    }

    return result;
  }
}
