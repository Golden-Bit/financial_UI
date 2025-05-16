import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_financials/trading_view_custom_widgets/chart_type_5/chart_type_5.dart';
// Importa la definizione di MultiSeriesLightweightChartWidget, SeriesData, SeriesType, etc.


void main() {
  runApp(const MyApp());
}

/// App base
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Demo Fill Between Two Lines + Forecast',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const Scaffold(
        body: SafeArea(child: DemoPage()),
      ),
    );
  }
}

/// Pagina demo
class DemoPage extends StatelessWidget {
  const DemoPage({super.key});

  @override
  Widget build(BuildContext context) {
    // 1) Generiamo i dati per la curva principale 2010..2020
    //    - 2010..2015 => solido
    //    - 2015..2020 => tratteggiato
    final allMainData = _generateValueData(2010, 2020, 50.0);
    final mainSolid = allMainData.where((p) => p.time.compareTo('2015-01-01')<0).toList();
    final mainDashed= allMainData.where((p) => p.time.compareTo('2015-01-01')>=0).toList();

    // 2) Generiamo upper e lower lines per 2015..2020
    //    e applichiamo "area fill" SOLO tra le due linee
    final rangeData = mainDashed;
    final upperLine = <ChartDataPoint>[];
    final lowerLine = <ChartDataPoint>[];

    for (final dp in rangeData) {
      final midVal = dp.value ?? 0;
      final dev = midVal * 0.2; // +/-20%
      final devRand = Random().nextDouble() * dev; // 0..dev
      final half = dev/2;
      final lo = (midVal - half - devRand).clamp(0, 1e9);
      final hi = (midVal + half + devRand).clamp(0, 1e9);
      lowerLine.add(ChartDataPoint(time: dp.time, value: lo as double));
      upperLine.add(ChartDataPoint(time: dp.time, value: hi as double));
    }

    // 3) Creiamo due area series per "riempire" tra lower e upper:
    //   - Area_Upper => baseline= 0, data= upperLine, colore semitrasparente es. #00ff0033
    //   - Area_Lower => baseline= 0, data= lowerLine, color= background => cancella la parte < lower
    // in modo che rimanga colorato SOLO tra lower e upper.

    // Nota: Se vuoi definire un color background identico a #1e242c, lo puoi fare,
    // o un colore semitrasparente per un effetto "cut-out".
    const backgroundHex = '#1e242c'; // colore identico al body BG
    // se preferisci un effetto "semi" puoi usare #1e242cff, etc.

    // 4) Serie finali
    final seriesList = <SeriesData>[
      // 4.1) Main line 2010..2015 (solid)
      SeriesData(
        label: 'MainLine(2010..2015 solid)',
        colorHex: '#0000ff', // blu
        seriesType: SeriesType.line,
        visible: true,
        customOptions: {
          'lineStyle': 0,
          'lineWidth': 2,
        },
        data: mainSolid,
      ),

      // 4.2) Main line 2015..2020 (dashed)
      SeriesData(
        label: 'MainLine(2015..2020 dashed)',
        colorHex: '#0000ff',
        seriesType: SeriesType.line,
        visible: true,
        customOptions: {
          'lineStyle': 2, // dashed
          'lineWidth': 2,
        },
        data: mainDashed,
      ),

      // 4.3) Area_Upper => baseline=0, data= upperLine, colore semitrasparente
      SeriesData(
        label: 'Area_Upper( fill )',
        colorHex: '#00ff00', // un verde
        seriesType: SeriesType.area,
        visible: true,
        customOptions: {
          'baseValue': 0,
          'topColor': '#00ff0033',    // semitrasp
          'bottomColor': '#00ff0000', // trasparente
          'lineWidth': 0,
          'lineColor': '#00000000',   // invisibile
        },
        data: upperLine,
      ),

      // 4.4) Area_Lower => baseline=0, data= lowerLine, colore= background => “taglia” la parte bassa
      SeriesData(
        label: 'Area_Lower( cut )',
        colorHex: backgroundHex, // “sfondo” => di fatto cancella
        seriesType: SeriesType.area,
        visible: true,
        customOptions: {
          'baseValue': 0,
          'topColor': '${backgroundHex}ff',    // colore pieno
          'bottomColor': '${backgroundHex}ff', // uguale => area unicolore
          'lineWidth': 0,
          'lineColor': '#00000000', // invisibile
        },
        data: lowerLine,
      ),

      // 4.5) se vuoi, potresti aggiungere la "upper line" e "lower line" vere e proprie
      // come line series, se desideri visualizzare i contorni.
      // Eccole, con line dotted:
      SeriesData(
        label: 'UpperBound line',
        colorHex: '#00ff00',
        seriesType: SeriesType.line,
        visible: true,
        customOptions: {
          'lineStyle': 1, // dotted
          'lineWidth': 1,
        },
        data: upperLine,
      ),
      SeriesData(
        label: 'LowerBound line',
        colorHex: '#00ff00',
        seriesType: SeriesType.line,
        visible: true,
        customOptions: {
          'lineStyle': 1, // dotted
          'lineWidth': 1,
        },
        data: lowerLine,
      ),
    ];

    // Divisori verticali: ad es. uno al 2015-01-01
    final verticalDividers = <VerticalDividerData>[
      VerticalDividerData(
        time: '2015-01-01',
        colorHex: '#808080',
        leftLabel: 'Real =>',
        rightLabel: 'Forecast =>',
      ),
    ];

    // 5) Costruiamo widget
    return SingleChildScrollView(
      child: Column(
        children: [
          MultiSeriesLightweightChartWidget(
            title: 'FillBetween(Upper, Lower) + main line con transizione 2015 solid->dashed',
            seriesList: seriesList,
            width: 1100,
            height: 600,
            verticalDividers: verticalDividers,
            simulateIfNoData: false,
          ),
          const SizedBox(height: 20),
          const Text(
            'In questo esempio, usiamo 2 area series per riempire tra upper e 0, '
            'poi disegniamo un\'area con colore = background tra lower e 0, tagliando la parte bassa.\n'
            'Risultato: area colorata tra le due curve, e la parte bassa / alta coperta.',
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  /// Genera dati mensili single-value [startYear]..[endYear]
  List<ChartDataPoint> _generateValueData(int startYear, int endYear, double base) {
    final result = <ChartDataPoint>[];
    DateTime current = DateTime(startYear, 1, 1);
    final limit = DateTime(endYear, 12, 31);
    double val = base;
    final rnd = Random();

    while (!current.isAfter(limit)) {
      final y = current.year;
      final m = current.month;
      final d = '01';
      final timeStr = '${y.toString().padLeft(4,'0')}-${m.toString().padLeft(2,'0')}-$d';

      result.add(ChartDataPoint(time: timeStr, value: val));
      // aggiorna val
      val += (rnd.nextDouble() - 0.5)*5;
      if (val<0) val=0;

      // next month
      int newMonth = m+1;
      int newYear = y;
      if (newMonth>12) {
        newMonth =1;
        newYear++;
      }
      current = DateTime(newYear, newMonth, 1);
    }
    return result;
  }
}
