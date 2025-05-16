import 'dart:html' as html;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

/// Dati per una singola lancetta del gauge.
class GaugePointerData {
  /// Label della lancetta (es. "Company", "Industry", "Market", ecc.)
  final String label;

  /// Valore della lancetta (0 <= value <= [maxValue]).
  final double value;

  /// Colore della lancetta (usato anche in label esterna).
  final String pointerColor;

  /// Larghezza della lancetta (in pixel).
  final double pointerWidth;

  GaugePointerData({
    required this.label,
    required this.value,
    required this.pointerColor,
    this.pointerWidth = 6,
  });
}

/// Widget Flutter che mostra un gauge con più lancette, ma **senza** label interne:
/// - Le lancette (stessa scala da 0 a [maxValue]) sono sovrapposte.
/// - I valori e le label delle lancette compaiono **sotto** il widget, da sinistra a destra (flex-wrap).
/// - Un pulsante “DATA” mostra una tabella dei dati e un pulsante “Download CSV”.
class MultiPointerGaugeWidget extends StatelessWidget {
  /// Titolo del grafico.
  final String title;

  /// Unità di misura comune (es. "%", "x", "units", ecc.).
  final String unitOfMeasure;

  /// Valore massimo del gauge (default 100).
  final double maxValue;

  /// Lista di lancette (label, valore, colore, larghezza).
  final List<GaugePointerData> pointers;

  /// Dimensioni del widget (pixel).
  final double width;
  final double height;

  late final String _viewId;

  MultiPointerGaugeWidget({
    Key? key,
    required this.title,
    required this.unitOfMeasure,
    this.maxValue = 100,
    required this.pointers,
    this.width = 600,
    this.height = 400,
  }) : super(key: key) {
    // 1) Generiamo un ID univoco per l'iFrame
    final String viewId = 'multi-pointer-gauge-${DateTime.now().millisecondsSinceEpoch}';
    _viewId = viewId;

    // 2) Convertiamo la lista di lancette in JS
    final String pointersJsArray = _buildPointersJsArray(pointers);

    // 3) Costruiamo l'HTML
    final String htmlContent = _buildHtmlContent(
      title,
      unitOfMeasure,
      maxValue,
      pointersJsArray,
    );

    // 4) Creiamo un Blob + URL
    final blob = html.Blob([htmlContent], 'text/html');
    final url = html.Url.createObjectUrlFromBlob(blob);

    // 5) Creiamo l'IFrame
    final html.IFrameElement iFrameElement = html.IFrameElement()
      ..src = url
      ..style.border = 'none'
      ..width = '100%'
      ..height = '100%';

    // 6) Registriamo la view
    ui.platformViewRegistry.registerViewFactory(viewId, (int viewId) => iFrameElement);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: HtmlElementView(viewType: _viewId),
    );
  }

  /// Converte la lista di GaugePointerData in stringa JSON per JS.
  String _buildPointersJsArray(List<GaugePointerData> pointers) {
    final sb = StringBuffer();
    sb.write('[');
    for (int i = 0; i < pointers.length; i++) {
      final p = pointers[i];
      sb.write('{ ');
      sb.write('"label":"${_escapeJs(p.label)}", ');
      sb.write('"value":${p.value}, ');
      sb.write('"pointerColor":"${_escapeJs(p.pointerColor)}", ');
      sb.write('"pointerWidth":${p.pointerWidth} ');
      sb.write('}');
      if (i < pointers.length - 1) sb.write(', ');
    }
    sb.write(']');
    return sb.toString();
  }

  /// Costruisce l'HTML + script ECharts + sezione "pointers-labels" sotto la chart.
  String _buildHtmlContent(String title, String unit, double maxValue, String pointersJsArray) {
    return '''
<!DOCTYPE html>
<html lang="it">
<head>
  <meta charset="UTF-8">
  <title>${_escapeHtml(title)}</title>
  <script src="https://cdn.jsdelivr.net/npm/echarts@5/dist/echarts.min.js"></script>
  <style>
    body {
      margin: 0;
      padding: 0;
      background-color: #1f1f2e;
      font-family: Arial, sans-serif;
      color: #fff;
    }
    #app-container {
      width: 95%;
      max-width: 800px;
      margin: 0 auto;
      padding: 20px 0;
      position: relative;
    }
    h1 {
      margin: 0 0 20px 0;
      font-size: 20px;
    }
    #chart {
      width: 100%;
      height: 400px;
      background-color: #2c2c3a;
      border: 1px solid #333;
      box-shadow: 0 0 8px rgba(0,0,0,0.5);
      position: relative;
    }
    /* Contenitore per le label delle lancette, sotto il chart */
    #pointers-labels-container {
      display: flex;
      flex-wrap: wrap;
      justify-content: center;
      gap: 20px;
      margin-top: 10px;
    }
    .pointer-label-item {
      background: #2b333d;
      border: 1px solid #444;
      border-radius: 4px;
      padding: 6px 10px;
      font-size: 14px;
      display: inline-flex;
      align-items: center;
      gap: 6px;
    }
    .pointer-color-box {
      width: 12px;
      height: 12px;
      border-radius: 2px;
      display: inline-block;
    }
    /* Pulsante DATA */
    #data-button-container {
      text-align: right;
      margin: 10px 0;
    }
    #btn-show-data {
      background: #2b333d;
      color: #fff;
      border: 1px solid #444;
      padding: 8px 12px;
      cursor: pointer;
      border-radius: 4px;
      font-size: 14px;
    }
    #btn-show-data:hover {
      background: #3e464f;
    }
    /* Data table container */
    #data-table-container {
      display: none;
      margin-top: 20px;
      background: #1e242c;
      border: 1px solid #444;
      border-radius: 4px;
      position: relative;
    }
    #data-table-header {
      display: flex;
      justify-content: space-between;
      align-items: center;
      padding: 8px 12px;
      border-bottom: 1px solid #444;
    }
    #data-table-header .title {
      font-size: 16px;
      font-weight: bold;
    }
    #btn-close-table {
      background: transparent;
      color: #fff;
      border: none;
      font-size: 18px;
      cursor: pointer;
    }
    #download-button-container {
      width: 100%;
      margin-top: 10px;
      text-align: left;
      padding: 0 12px 12px 12px;
    }
    #btn-download-csv {
      background: #2b333d;
      color: #fff;
      border: 1px solid #444;
      padding: 8px 12px;
      cursor: pointer;
      border-radius: 4px;
      font-size: 14px;
    }
    #btn-download-csv:hover {
      background: #3e464f;
    }
    #data-table-scroll {
      max-height: 300px;
      overflow-y: auto;
    }
    table.data-table {
      width: 100%;
      border-collapse: collapse;
    }
    table.data-table thead {
      background: #2b333d;
      position: sticky;
      top: 0;
      z-index: 1;
    }
    table.data-table th,
    table.data-table td {
      padding: 8px 12px;
      border-bottom: 1px solid #444;
      text-align: left;
    }
    table.data-table tbody tr:hover {
      background: #2b333d;
    }
    table.data-table tbody tr:nth-child(even) {
      background: #242a31;
    }
  </style>
</head>
<body>
  <div id="app-container">
    <h1>${_escapeHtml(title)}</h1>

    <div id="data-button-container">
      <button id="btn-show-data">DATA</button>
    </div>

    <div id="chart"></div>

    <!-- Container per le label delle lancette (sotto il widget) -->
    <div id="pointers-labels-container"></div>

    <!-- Container per la tabella dati -->
    <div id="data-table-container">
      <div id="data-table-header">
        <span class="title">Data Table</span>
        <button id="btn-close-table">X</button>
      </div>
      <div id="data-table-scroll">
        <table class="data-table" id="data-table">
          <thead>
            <tr>
              <th>Label</th>
              <th>Value</th>
              <th>Unit</th>
            </tr>
          </thead>
          <tbody id="data-table-body"></tbody>
        </table>
      </div>
      <div id="download-button-container">
        <button id="btn-download-csv">Download CSV</button>
      </div>
    </div>
  </div>

  <script>
    (function(){
      const pointers = $pointersJsArray;
      const maxValue = $maxValue;
      const unit = "${_escapeJs(unit)}";

      // Creiamo una serie gauge per ogni lancetta.
      // Non usiamo label "detail" interno: detail.show=false per tutti.
      // Mostriamo asse e segmenti solo nella prima lancetta (isFirst).
      const series = [];
      pointers.forEach((p, i) => {
        const isFirst = (i === 0);
        series.push({
          name: p.label,
          type: 'gauge',
          center: ['50%', '55%'],
          radius: '80%',
          min: 0,
          max: maxValue,
          splitNumber: 5,
          startAngle: 200,
          endAngle: -20,
          axisLine: isFirst ? {
            lineStyle: {
              width: 20,
              color: [
                [0.25, '#f44336'],
                [0.50, '#ff9800'],
                [0.75, '#ffeb3b'],
                [1.00, '#4caf50']
              ]
            }
          } : { show: false },
          axisTick: isFirst ? {
            length: 8,
            lineStyle: { color: '#fff' }
          } : { show: false },
          splitLine: isFirst ? {
            length: 15,
            lineStyle: { color: '#fff', width: 2 }
          } : { show: false },
          axisLabel: isFirst ? {
            color: '#fff',
            fontSize: 10,
            formatter: function (value) {
              return value + unit;
            }
          } : { show: false },
          pointer: {
            length: '70%',
            width: p.pointerWidth,
            itemStyle: {
              color: p.pointerColor
            }
          },
          anchor: {
            show: true,
            size: 10,
            showAbove: true,
            itemStyle: { color: '#9e9e9e' }
          },
          detail: { show: false },
          data: [{ value: 0 }]
        });
      });

      const option = {
        backgroundColor: '#2c2c3a',
        animationDuration: 2000,
        animationEasing: 'cubicOut',
        tooltip: {
          trigger: 'item',
          formatter: function(params) {
            const rawVal = params.data ? params.data.value : 0;
            return '<strong>' + params.name + '</strong><br/>Value: ' + rawVal.toFixed(1) + unit;
          }
        },
        series: series
      };

      const chartEl = document.getElementById('chart');
      const myChart = echarts.init(chartEl);
      myChart.setOption(option);

      // Dopo un breve delay, aggiorniamo i valori delle lancette.
      setTimeout(function(){
        myChart.setOption({
          series: pointers.map((p) => {
            return { data: [{ value: p.value }] };
          })
        });
      }, 300);

      // Creiamo i label sottostanti (da sinistra a destra, in "pointers-labels-container")
      const pointersLabelsContainer = document.getElementById('pointers-labels-container');
      pointers.forEach(p => {
        const itemDiv = document.createElement('div');
        itemDiv.className = 'pointer-label-item';
        // Creiamo un box colorato
        const colorBox = document.createElement('div');
        colorBox.className = 'pointer-color-box';
        colorBox.style.backgroundColor = p.pointerColor;
        itemDiv.appendChild(colorBox);

        // Creiamo il testo
        // Esempio: "Company: 50.0 <unit>"
        const labelSpan = document.createElement('span');
        labelSpan.textContent = p.label + ': ' + p.value.toFixed(1) + unit;
        itemDiv.appendChild(labelSpan);

        pointersLabelsContainer.appendChild(itemDiv);
      });

      // Tabella dati + CSV
      const tableRows = pointers.map(p => ({
        label: p.label,
        value: p.value,
        unit: unit
      }));
      const tbody = document.getElementById('data-table-body');
      tableRows.forEach(row => {
        const tr = document.createElement('tr');
        tr.innerHTML = '<td>' + _escapeHtml(row.label) + '</td>'
                     + '<td>' + row.value.toFixed(1) + '</td>'
                     + '<td>' + _escapeHtml(row.unit) + '</td>';
        tbody.appendChild(tr);
      });

      // Pulsanti "DATA" e "Download CSV"
      const btnShowData = document.getElementById('btn-show-data');
      const dataTableContainer = document.getElementById('data-table-container');
      const btnCloseTable = document.getElementById('btn-close-table');
      const btnDownloadCsv = document.getElementById('btn-download-csv');

      btnShowData.addEventListener('click', () => {
        chartEl.style.display = 'none';
        pointersLabelsContainer.style.display = 'none';
        dataTableContainer.style.display = 'block';
      });
      btnCloseTable.addEventListener('click', () => {
        dataTableContainer.style.display = 'none';
        chartEl.style.display = 'block';
        pointersLabelsContainer.style.display = 'flex';
      });
      btnDownloadCsv.addEventListener('click', () => {
        let csv = 'Label,Value,Unit\\n';
        tableRows.forEach(row => {
          csv += '"' + row.label.replace(/"/g, '\\"') + '","'
               + row.value.toFixed(1) + '","'
               + row.unit + '"\\n';
        });
        const blob = new Blob([csv], { type: 'text/csv;charset=utf-8;' });
        const url = URL.createObjectURL(blob);
        const a = document.createElement('a');
        a.href = url;
        a.setAttribute('download', 'gauge_data.csv');
        document.body.appendChild(a);
        a.click();
        document.body.removeChild(a);
        URL.revokeObjectURL(url);
      });

      function _escapeHtml(s){
        return s.replace(/&/g, '&amp;')
                .replace(/</g, '&lt;')
                .replace(/>/g, '&gt;')
                .replace(/"/g, '&quot;')
                .replace(/'/g, '&#39;');
      }
    })();
  </script>
</body>
</html>
''';
  }

  /// Funzione per sfuggire caratteri in JS.
  static String _escapeJs(String s) {
    return s.replaceAll('\\', '\\\\')
            .replaceAll('"', '\\"')
            .replaceAll("'", "\\'");
  }

  /// Funzione per sfuggire caratteri in HTML.
  static String _escapeHtml(String s) => s
      .replaceAll('&', '&amp;')
      .replaceAll('<', '&lt;')
      .replaceAll('>', '&gt;')
      .replaceAll('"', '&quot;')
      .replaceAll("'", '&#39;');
}