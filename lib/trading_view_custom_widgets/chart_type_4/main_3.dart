import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_financials/trading_view_custom_widgets/chart_type_4/chart_type_4.dart';

void main() {
  runApp(const MyApp());
}

/// App Flutter
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Demo Forecast + Confidence Interval',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const Scaffold(
        body: SafeArea(child: DemoPage()),
      ),
    );
  }
}

/// Questa pagina crea e mostra il widget con:
///  - 2 serie per la curva principale (2010-2015 solida, 2015-2020 tratteggiata)
///  - 2 serie line per lower/upper bound
///  - 1 serie area (opzionale) per "riempire" tra lower e upper
class DemoPage extends StatelessWidget {
  const DemoPage({super.key});

  @override
  Widget build(BuildContext context) {
    // 1) Generiamo dati:
    //    A) curve main-line su 2010..2020
    //    B) lower e upper bounding line su 2015..2020
    //    C) area di confidenza tra lower e upper
    // Per semplificare, i dati 2010..2015 e 2015..2020 sono uniti in un'unica lista,
    // ma useremo due SeriesData differenti con subrange.

    final allMainData = _generateMonthlySingleValue(2010, 2020, 100.0);
    // Dividiamo a livello logico in 2 fasi:
    //  - Fase1: time < '2015-01-01'
    //  - Fase2: time >= '2015-01-01'

    // A) parte "solid" => 2010.. fine 2014 (dicembre)
    final mainDataSolid = allMainData.where((p) => p.time.compareTo('2015-01-01') < 0).toList();
    // B) parte "dashed" => da 2015 compreso a 2020
    final mainDataDashed = allMainData.where((p) => p.time.compareTo('2015-01-01') >= 0).toList();

    // generiamo 2 linee "upper" e "lower" solo dal 2015..2020
    final rangeData = mainDataDashed; // dal 2015..2020
    final lowerData = <ChartDataPoint>[];
    final upperData = <ChartDataPoint>[];
    for (final dp in rangeData) {
      final midVal = dp.value ?? 0;
      // generiamo un +/- random 10% come forecast conf.
      final dev = 0.1 * midVal;
      final rnd = Random().nextDouble() * dev; // 0..dev
      final lowerVal = midVal - (dev / 2 + rnd); // approssimiamo
      final upperVal = midVal + (dev / 2 + rnd);
      lowerData.add(ChartDataPoint(time: dp.time, value: lowerVal));
      upperData.add(ChartDataPoint(time: dp.time, value: upperVal));
    }

    // 2) Se vogliamo disegnare un'area tra le due curve
    //    useremo un "area series" con baseValue= lowerVal. (Trick)
    //    In realtà, baseValue non può cambiare punto a punto. Quindi è
    //    un "falso" area. Mostriamo la logica, ma in pratica
    //    dovresti implementare un "baseline series" custom.
    //    Per semplicità, ipotizziamo che la differenza lower-upper
    //    non sia troppo variabile, e mettiamo baseValue = 80
    //    (opzione semplificata). Oppure ci accontentiamo di un "riempimento"
    //    che può non combaciare perfettamente col lower.

    final confidenceAreaData = <ChartDataPoint>[];
    for (final dp in upperData) {
      confidenceAreaData.add(ChartDataPoint(time: dp.time, value: dp.value));
    }

    // 3) Creiamo la lista di 5 serie:
    //    (1) main solid line  (2010..2015)
    //    (2) main dashed line (2015..2020)
    //    (3) lower line
    //    (4) upper line
    //    (5) area "confidence" (fake approach)
    final seriesList = <SeriesData>[
      // Serie #1: main line (solid) - 2010..2015
      SeriesData(
        label: 'MainLine(2010..2015 solid)',
        colorHex: '#0000ff', // blu
        seriesType: SeriesType.line,
        visible: true,
        customOptions: {
          'lineStyle': 0,  // 0 => Solid
          'lineWidth': 2,
        },
        data: mainDataSolid,
      ),

      // Serie #2: main line (dashed) - 2015..2020
      SeriesData(
        label: 'MainLine(2015..2020 dashed)',
        colorHex: '#0000ff',
        seriesType: SeriesType.line,
        visible: true,
        customOptions: {
          'lineStyle': 2,  // 2 => Dashed
          'lineWidth': 2,
        },
        data: mainDataDashed,
      ),

      // Serie #3: lower bound (line)
      SeriesData(
        label: 'Lower Bound',
        colorHex: '#ff0000',
        seriesType: SeriesType.line,
        visible: true,
        customOptions: {
          'lineStyle': 1, // dotted
          'lineWidth': 1,
        },
        data: lowerData,
      ),

      // Serie #4: upper bound (line)
      SeriesData(
        label: 'Upper Bound',
        colorHex: '#ff0000',
        seriesType: SeriesType.line,
        visible: true,
        customOptions: {
          'lineStyle': 1, // dotted
          'lineWidth': 1,
        },
        data: upperData,
      ),

      // Serie #5: area "confidence"
      //  => disegna un'area dal baseValue=80 (es) a value= upper.
      //  => NON combacia perfettamente con lower, ma dimostra la logica
      SeriesData(
        label: 'ConfidenceArea(approx.)',
        colorHex: '#ff0000',
        seriesType: SeriesType.area,
        visible: true,
        customOptions: {
          'baseValue': 80,
          'topColor': '#ff000033',
          'bottomColor': '#ff000000',
          'lineColor': '#ff000000', // invisibile
        },
        data: confidenceAreaData,
      ),
    ];

    // 4) Nessun vertical divider, o se vuoi, aggiungine:
    final verticalDividers = <VerticalDividerData>[
      VerticalDividerData(
        time: '2015-01-01',
        colorHex: '#808080',
        leftLabel: 'Real =>',
        rightLabel: 'Forecast =>',
      ),
    ];

    // 5) Creiamo e ritorniamo il widget
    return SingleChildScrollView(
      child: Column(
        children: [
          MultiSeriesLightweightChartWidget(
            title: 'Main line: 2010..2015(solid), 2015..2020(dashed) + ConfidenceArea (approx.)',
            seriesList: seriesList,
            // Non generiamo noi i dati, già passati
            simulateIfNoData: false,
            width: 1100,
            height: 600,
            verticalDividers: verticalDividers,
          ),
          const SizedBox(height: 20),
          const Text(
            'Esempio di curva che passa da solida (2010..2015) '
            'a tratteggiata (2015..2020), con due curve bounding e '
            'un area di “confidence” (fake) tra baseValue=80 e upper line.'
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  /// Genera dati mensili single-value da [startYear] a [endYear]
  /// con [baseVal], usando pseudo-random per variazioni.
  List<ChartDataPoint> _generateMonthlySingleValue(int startYear, int endYear, double baseVal) {
    final result = <ChartDataPoint>[];
    var current = DateTime(startYear, 1, 1);
    final limit = DateTime(endYear, 12, 31);
    double val = baseVal;

    while (!current.isAfter(limit)) {
      final y = current.year;
      final m = current.month;
      final timeStr = '${y.toString().padLeft(4,'0')}-${m.toString().padLeft(2,'0')}-01';
      result.add(ChartDataPoint(time: timeStr, value: val));
      val += (Random().nextDouble() - 0.5) * 8; // +/-4
      if (val < 0) val = 0;

      m < 12 ? m+1 : 1;
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
