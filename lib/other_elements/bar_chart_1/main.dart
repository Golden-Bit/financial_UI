import 'package:flutter/material.dart';
import 'package:flutter_financials/other_elements/bar_chart_1/bar_chart_1.dart';

void main() {
  runApp(
    MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text("MultiGroup BarChart Example")),
        body: Center(
          child: MultiGroupBarChartWidget(
            title: "Sales by Region (2019-2021)",
            widthPx: 800,
            heightPx: 400,
            isStacked: false,      // Metti true se vuoi barre impilate
            isHorizontal: false,   // Metti true se vuoi il grafico orizzontale
            categories: ["2019", "2020", "2021"],
            seriesList: [
              BarChartSeriesData(
                seriesName: "North America",
                values: [120, 150, 180],
                colorHex: "#4a90e2", // blu
                borderWidth: 1,
                borderColorHex: "#333",
              ),
              BarChartSeriesData(
                seriesName: "Europe",
                values: [90, 130, 160],
                colorHex: "#f5b941", // giallo/arancione
              ),
              BarChartSeriesData(
                seriesName: "Asia",
                values: [200, 240, 280],
                colorHex: "#3AA76D", // verde
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
