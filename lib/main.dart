import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_financials/trading_view_custom_widgets/chart_type_4/chart_type_4.dart';
// Importa il file dove hai il MultiSeriesLightweightChartWidget
// ipotizziamo si chiami multi_series_chart_extended.dart:

void main() {
  runApp(const MyApp());
}

/// App principale
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MultiSeriesChart Demo',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const Scaffold(
        body: SafeArea(child: DemoPage()),
      ),
    );
  }
}

/// Pagina di esempio che crea e mostra il nostro widget `MultiSeriesLightweightChartWidget`.
///
/// - 5 serie diverse:
///   1) line
///   2) area
///   3) bar
///   4) candlestick
///   5) histogram
///
/// - 2 divisori verticali con personalizzazioni
class DemoPage extends StatelessWidget {
  const DemoPage({super.key});

  @override
  Widget build(BuildContext context) {
    // 1) Creiamo i dati per le diverse tipologie di serie

    // a) Serie line (singolo value) generata per 2016..2022
    final lineData = _generateValueData(startYear: 2016, endYear: 2022, baseVal: 50);

    // b) Serie area
    final areaData = _generateValueData(startYear: 2016, endYear: 2022, baseVal: 80);

    // c) Serie bar (OHLC)
    final barData = _generateOhlcData(startYear: 2016, endYear: 2022, baseVal: 30);

    // d) Serie candlestick (OHLC)
    final candleData = _generateOhlcData(startYear: 2016, endYear: 2022, baseVal: 100);

    // e) Serie histogram
    final histData = _generateValueData(startYear: 2016, endYear: 2022, baseVal: 20);

    // 2) Creiamo le definizioni delle serie, con SeriesType e customOptions

    final seriesList = <SeriesData>[
      // 2.1) line
      SeriesData(
        label: 'Line Series',
        colorHex: '#FF8000', // arancione
        seriesType: SeriesType.line,
        data: lineData,
        visible: true,
        customOptions: {
          // Esempio: lineWidth=3, lineStyle=2 => dashed
          'lineWidth': 3,
          'lineStyle': 2,
          // Esempio: se vogliamo mostrare l'asse a dx con unita' USD
          //'priceFormat':
          //    '{\"type\":\"custom\",\"minMove\":0.01,\"formatter\":\"function(price){return price.toFixed(2)+\\\" USD\\\";}\"}'
        },
      ),

      // 2.2) area
      SeriesData(
        label: 'Area Series',
        colorHex: '#5bc0de', // azzurrino
        seriesType: SeriesType.area,
        data: areaData,
        visible: true,
        customOptions: {
          // ad es. baseValue se vuoi, topColor, bottomColor
          // in doc: https://tradingview.github.io/lightweight-charts/docs/api#areaseriesoptions
          'lineWidth': 2,
          // Esempio: definire unita' "B$"
          //'priceFormat':
          //    '{\"type\":\"custom\",\"minMove\":0.01,\"formatter\":\"function(price){return price.toFixed(2)+\\\" B Dollar\\\";}\"}',
        },
      ),

      // 2.3) bar
      SeriesData(
        label: 'Bar Series(OHLC)',
        colorHex: '#d9534f',
        seriesType: SeriesType.bar,
        data: barData,
        visible: true,
        customOptions: {
          // es. upColor, downColor se vuoi
          'thinBars': true,
          // es. unit "€"
          //'priceFormat':
          //    '{\"type\":\"custom\",\"minMove\":0.01,\"formatter\":\"function(price){return price.toFixed(2)+\\\" €\\\";}\"}',
        },
      ),

      // 2.4) candlestick
      SeriesData(
        label: 'Candlestick(OHLC)',
        colorHex: '#ffffff', // per candlestick ignorato
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

      // 2.5) histogram
      SeriesData(
        label: 'Histogram Series',
        colorHex: '#5cb85c',
        seriesType: SeriesType.histogram,
        data: histData,
        visible: true,
        customOptions: {
          // potresti definire 'base': 30
          // e definire unita'
          //'priceFormat':
          //    '{\"type\":\"custom\",\"minMove\":0.01,\"formatter\":\"function(price){return price.toFixed(2)+\\\" un.\\\";}\"}',
        },
      ),
    ];

    // 3) Definiamo i divisori verticali
    // Mettiamo 2 linee (2018-01-01, 2020-06-01) con label semitrasparenti
    // Nel nostro widget, per spessore e tratteggio, modificheremo in _buildHtmlContent (già fatto).
    final verticalDividers = <VerticalDividerData>[
      VerticalDividerData(
        time: '2018-01-01',
        colorHex: '#ffff00', // giallino
        leftLabel: 'OLD PHASE',
        rightLabel: 'NEW PHASE',
      ),
      VerticalDividerData(
        time: '2020-06-01',
        colorHex: '#ff00ff', // violet
        leftLabel: 'MID',
        rightLabel: 'FUTURE??',
      ),
    ];

    // 4) Creiamo il widget
    return SingleChildScrollView(
      child: Column(
        children: [
          MultiSeriesLightweightChartWidget(
            title: 'Multi-series + Dividers + Custom Units + Asse dx',
            seriesList: seriesList,
            width: 1100,
            height: 600,
            verticalDividers: verticalDividers,
            simulateIfNoData: false,
          ),
          const SizedBox(height: 20),
          const Text(
            'Abbiamo 5 serie: line, area, bar, candlestick, histogram, con differenze opzioni.\n'
            'Divisori verticali con label, e asse dei prezzi su line/area/bar/histogram personalizzato. '
            'Puoi notare la definizione del priceFormat in customOptions per mostrare ad es. “USD”, “€”, ecc.',
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  /// Generiamo dati single-value mensili dal [startYear]..[endYear], baseVal circa
  List<ChartDataPoint> _generateValueData({
    required int startYear,
    required int endYear,
    required double baseVal,
  }) {
    final result = <ChartDataPoint>[];
    DateTime current = DateTime(startYear, 1, 1);
    final limit = DateTime(endYear, 12, 31);
    double val = baseVal;
    final rnd = Random();

    while (!current.isAfter(limit)) {
      final y = current.year;
      final m = current.month;
      final timeStr = '${y.toString().padLeft(4,'0')}-${m.toString().padLeft(2,'0')}-01';
      result.add(ChartDataPoint(time: timeStr, value: val));

      // aggiorna val random
      val += (rnd.nextDouble() - 0.5) * 5;
      if (val<0) val=0;

      int newMonth = m+1;
      int newYear = y;
      if (newMonth>12) {
        newMonth=1; newYear++;
      }
      current = DateTime(newYear, newMonth, 1);
    }
    return result;
  }

  /// Generiamo dati OHLC mensili
  List<ChartDataPoint> _generateOhlcData({
    required int startYear,
    required int endYear,
    required double baseVal,
  }) {
    final result = <ChartDataPoint>[];
    DateTime current = DateTime(startYear, 1, 1);
    final limit = DateTime(endYear, 12, 31);
    double val = baseVal;
    final rnd = Random();

    while (!current.isAfter(limit)) {
      final y = current.year;
      final m = current.month;
      final timeStr = '${y.toString().padLeft(4,'0')}-${m.toString().padLeft(2,'0')}-01';

      final open = val + (rnd.nextDouble() - 0.5) * 4;
      final close = open + (rnd.nextDouble() - 0.5) * 6;
      final hi = (open>close ? open : close) + 3;
      final lo = (open<close ? open : close) - 3;

      result.add(ChartDataPoint(time: timeStr, open: open, high: hi, low: lo, close: close));

      val = close;
      int newMonth = m+1;
      int newYear = y;
      if (newMonth>12) {
        newMonth=1; newYear++;
      }
      current = DateTime(newYear, newMonth, 1);
    }
    return result;
  }
}
