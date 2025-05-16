import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_financials/trading_view_custom_widgets/chart_type_5/chart_type_5.dart';
// Importa il file dove hai definito MultiSeriesLightweightChartWidget, SeriesData, SeriesType, etc.
// ipotizziamo si chiami: multi_series_chart_extended.dart

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
    // 1) Creiamo i dati per ~10 anni su base mensile
    // dal 2013-01 al 2022-12
    // useremo due generatori: uno per "single value" (line, area, histogram)
    // e uno per "OHLC" (bar, candlestick)
    final lineData = _generateValueData(startYear: 2013, endYear: 2022, baseValue: 50.0);
    final areaData = _generateValueData(startYear: 2013, endYear: 2022, baseValue: 80.0);
    final histogramData = _generateValueData(startYear: 2013, endYear: 2022, baseValue: 20.0);

    final barData = _generateOhlcData(startYear: 2013, endYear: 2022, baseValue: 30.0);
    final candleData = _generateOhlcData(startYear: 2013, endYear: 2022, baseValue: 100.0);

    // 2) Definiamo 5 serie, ciascuna con un "SeriesType" diverso
    final seriesList = <SeriesData>[
      // A) Serie di tipo line
      SeriesData(
        label: 'Line Series',
        colorHex: '#FFA500', // arancione
        seriesType: SeriesType.line,
        data: lineData,
        visible: true,
        // customOptions: { 'lineWidth': 3, 'lineStyle': 2, ... } se vuoi
      ),
      // B) Serie di tipo area
      SeriesData(
        label: 'Area Series',
        colorHex: '#5bc0de', // un azzurrino
        seriesType: SeriesType.area,
        data: areaData,
        visible: true,
        customOptions: {
          // ad es. 'lineWidth': 2, 'topColor': '#5bc0deAA', ...
        },
      ),
      // C) Serie di tipo bar
      SeriesData(
        label: 'Bar Series',
        colorHex: '#d9534f',
        seriesType: SeriesType.bar,
        data: barData,
        visible: true,
        customOptions: {
          // ad es. 'thinBars': true,
        },
      ),
      // D) Serie di tipo candlestick con custom colors
      SeriesData(
        label: 'Candlestick Series',
        colorHex: '#ffffff', // qui potremmo ignorare
        seriesType: SeriesType.candlestick,
        data: candleData,
        visible: true,
        customOptions: {
          'upColor': '#00ff00',
          'downColor': '#ff0000',
          'borderUpColor': '#00ff00',
          'borderDownColor': '#ff0000',
          'wickUpColor': '#00ff00',
          'wickDownColor': '#ff0000',
        },
      ),
      // E) Serie di tipo histogram
      SeriesData(
        label: 'Histogram Series',
        colorHex: '#5cb85c', // un verde
        seriesType: SeriesType.histogram,
        data: histogramData,
        visible: true,
        customOptions: {
          // 'base': 50, 'color': '#5cb85c', ...
        },
      ),
    ];

    // 3) Creiamo divisori verticali
    // mettiamo, ad es, uno al 2017-06-01 e uno al 2020-01-01
    final verticalDividers = <VerticalDividerData>[
      VerticalDividerData(
        time: '2017-06-01',
        colorHex: '#ff00ff', // viola
        leftLabel: 'PAST',
        rightLabel: 'FUTURE',
      ),
      VerticalDividerData(
        time: '2020-01-01',
        colorHex: '#ffff00', // giallino
        leftLabel: 'MID',
        rightLabel: '...',
      ),
    ];

    // 4) Infine costruiamo il widget
    return SingleChildScrollView(
      child: Column(
        children: [
          MultiSeriesLightweightChartWidget(
            title: 'Multi-series (10 anni) + Tipi diversi (line, area, bar, candle, histogram)',
            seriesList: seriesList,
            simulateIfNoData: false, // generiamo noi i dati
            width: 1100,
            height: 600,
            verticalDividers: verticalDividers,
          ),
          const SizedBox(height: 20),
          const Text('Esempio di un grafico con 5 serie, 10 anni, e divisori verticali.'),
          const SizedBox(height: 50),
        ],
      ),
    );
  }

  /// Genera dati mensili single-value da [startYear] a [endYear],
  /// con un [baseValue] e oscillazioni pseudo-casuali
  List<ChartDataPoint> _generateValueData({
    required int startYear,
    required int endYear,
    required double baseValue,
  }) {
    final List<ChartDataPoint> result = [];
    DateTime current = DateTime(startYear, 1, 1);
    final limit = DateTime(endYear, 12, 31);
    double val = baseValue;

    while (!current.isAfter(limit)) {
      final y = current.year;
      final m = current.month;

      final timeStr = '${y.toString().padLeft(4, '0')}-${m.toString().padLeft(2, '0')}-01';
      result.add(ChartDataPoint(time: timeStr, value: val));

      // aggiorniamo val
      val += (Random().nextDouble() - 0.5) * 10;
      if (val < 0) val = 0;

      // incrementiamo di 1 mese
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

  /// Genera dati mensili OHLC da [startYear] a [endYear],
  /// con un [baseValue] e oscillazioni pseudo-casuali
  List<ChartDataPoint> _generateOhlcData({
    required int startYear,
    required int endYear,
    required double baseValue,
  }) {
    final List<ChartDataPoint> result = [];
    DateTime current = DateTime(startYear, 1, 1);
    final limit = DateTime(endYear, 12, 31);

    double currentVal = baseValue;

    while (!current.isAfter(limit)) {
      final y = current.year;
      final m = current.month;
      final timeStr = '${y.toString().padLeft(4, '0')}-${m.toString().padLeft(2, '0')}-01';

      // generiamo O/H/L/C
      final open = currentVal + (Random().nextDouble() - 0.5) * 5;
      final close = open + (Random().nextDouble() - 0.5) * 5;
      final high = (open > close ? open : close) + Random().nextDouble() * 2;
      final low  = (open < close ? open : close) - Random().nextDouble() * 2;

      result.add(ChartDataPoint(
        time: timeStr,
        open: open,
        high: high,
        low: low,
        close: close,
      ));

      // aggiorniamo currentVal
      currentVal = close;

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
