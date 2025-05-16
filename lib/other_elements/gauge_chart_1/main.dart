import 'package:flutter/material.dart';
import 'package:flutter_financials/other_elements/gauge_chart_1/gauge_chart_1.dart';

/// Esempio di uso in main: crea il widget gauge con più lancette personalizzabili.
void main() {
  // Esempio di configurazione di due lancette:
  // - Lancetta 1: "Company" in blu, valore 50 (50.0%), unità "x".
  // - Lancetta 2: "Industry" in azzurro, valore 11.9 (11.9%), unità condivisa.
  final pointers = [
    GaugePointerData(
      label: "Company",
      value: 50,
      pointerColor: "#0055ff",
      pointerWidth: 6,
      // Non specificato detailOffset: verrà calcolato automaticamente.
    ),
    GaugePointerData(
      label: "Industry",
      value: 11.9,
      pointerColor: "#4abffd",
      pointerWidth: 6,
    ),
  ];

  runApp(
    MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text("Multi-Pointer Gauge Example")),
        body: Center(
          child: MultiPointerGaugeWidget(
            title: "Future ROE (3yrs)",
            unitOfMeasure: "x",
            maxValue: 100,
            pointers: pointers,
            width: 600,
            height: 400,
          ),
        ),
      ),
    ),
  );
}
