import 'package:flutter/material.dart';
import 'package:flutter_financials/other_elements/gauge_chart_2/gauge_chart_2.dart';

void main() {
  runApp(
    MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text("Test Striped PE Gauge")),
        body: Center(
          child: StripedPEGaugeWidget(
            title: "PE Gauge Striped con Label in Basso",
            minVal: 0,
            maxVal: 122,
            currentPE: 38.7,  // Valore "Current PE"
            fairPE: 61.0,     // Valore "Fair PE"
            widthPx: 900,     // Larghezza widget
            heightPx: 900,    // Altezza widget (più grande per la tabella
          ),
        ),
      ),
    ),
  );
}
