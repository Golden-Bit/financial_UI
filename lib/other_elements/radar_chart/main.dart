import 'package:flutter/material.dart';
import 'package:flutter_financials/other_elements/radar_chart/radar_chart.dart';

/// MAIN: mostra due radar chart
void main() {
  runApp(
    MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text("Radar Chart Examples")),
        body: SingleChildScrollView(
          child: Column(
            children: [
              // Primo radar chart: esattamente come l'esempio fornito (5 vertici)
              RadarChartWidget(
                title: "Radar Chart (5 Vertici)",
                width: 500,
                height: 500,
                indicators: [
                  RadarIndicatorData(name: "Dividend", max: 10, value: 7),
                  RadarIndicatorData(name: "Value", max: 10, value: 8),
                  RadarIndicatorData(name: "Future", max: 10, value: 6),
                  RadarIndicatorData(name: "Past", max: 10, value: 5),
                  RadarIndicatorData(name: "Health", max: 10, value: 9),
                ],
              ),
              const SizedBox(height: 40),
              // Secondo radar chart: con 8 vertici di fantasia
              RadarChartWidget(
                title: "Radar Chart (8 Vertici)",
                width: 600,
                height: 600,
                indicators: [
                  RadarIndicatorData(name: "Metric 1", max: 20, value: 12),
                  RadarIndicatorData(name: "Metric 2", max: 20, value: 15),
                  RadarIndicatorData(name: "Metric 3", max: 20, value: 8),
                  RadarIndicatorData(name: "Metric 4", max: 20, value: 18),
                  RadarIndicatorData(name: "Metric 5", max: 20, value: 10),
                  RadarIndicatorData(name: "Metric 6", max: 20, value: 16),
                  RadarIndicatorData(name: "Metric 7", max: 20, value: 14),
                  RadarIndicatorData(name: "Metric 8", max: 20, value: 9),
                ],
              ),
            ],
          ),
        ),
      ),
    ),
  );
}