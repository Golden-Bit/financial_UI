import 'dart:html' as html;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

/// Rappresenta i dati di una serie di barre.
/// Ogni "serie" corrisponde a un gruppo di barre (es. "2019", "2020", "2021").
class BarChartSeriesData {
  /// Nome della serie (es. "2019", "USA", "Forecast", ecc.).
  final String seriesName;

  /// Lista di valori corrispondenti a ciascuna categoria.
  /// La lunghezza di [values] deve corrispondere al numero di categorie (xAxis).
  final List<double> values;

  /// Colore principale delle barre.
  final String colorHex;

  /// (Opzionale) Spessore del bordo di ciascuna barra.
  final double borderWidth;

  /// (Opzionale) Colore del bordo di ciascuna barra.
  final String borderColorHex;

  /// Se l'utente vuole personalizzare altro (per es. pattern, ecc.),
  /// si potrebbero aggiungere altri campi.
  BarChartSeriesData({
    required this.seriesName,
    required this.values,
    this.colorHex = "#4a90e2",
    this.borderWidth = 0,
    this.borderColorHex = "#000",
  });
}


/// Widget che mostra un bar chart con possibilità di:
/// - più serie (gruppi di barre) affiancate o impilate
/// - asse orizzontale o verticale
/// - tabella dei dati con pulsante "DATA" e "Download CSV"
class MultiGroupBarChartWidget extends StatelessWidget {
  /// Titolo del grafico.
  final String title;

  /// Larghezza in pixel (circa).
  final double widthPx;

  /// Altezza in pixel (circa).
  final double heightPx;

  /// Lista di categorie (asse X in caso di [isHorizontal] = false,
  /// oppure asse Y in caso di [isHorizontal] = true).
  ///
  /// Esempio: ["Q1", "Q2", "Q3", "Q4"] o ["2019", "2020", "2021"].
  final List<String> categories;

  /// Lista di serie (gruppi). Ognuna deve avere lo stesso
  /// numero di valori di [categories.length].
  final List<BarChartSeriesData> seriesList;

  /// Se true, disegna barre impilate (stacked). Se false, barre affiancate (grouped).
  final bool isStacked;

  /// Se true, ruota il grafico in orizzontale (categorie su asse Y).
  /// Se false, grafico verticale (categorie su asse X).
  final bool isHorizontal;

  /// (Opzionale) Colore di sfondo del grafico
  final String backgroundColorHex;

  late final String _viewId;

  MultiGroupBarChartWidget({
    Key? key,
    required this.title,
    required this.categories,
    required this.seriesList,
    this.widthPx = 800,
    this.heightPx = 400,
    this.isStacked = false,
    this.isHorizontal = false,
    this.backgroundColorHex = "#2c2c3a",
  }) : super(key: key) {
    // 1) Creiamo un id univoco per l’IFrame.
    final String viewId = 'multi-group-bar-${DateTime.now().millisecondsSinceEpoch}';
    _viewId = viewId;

    // 2) Convertiamo i dati in stringhe JS
    final String categoriesJs = _buildCategoriesJs(categories);
    final String seriesJs = _buildSeriesJs(seriesList);

    // 3) Creiamo l’HTML completo
    final String htmlContent = _buildHtmlContent(
      title,
      categoriesJs,
      seriesJs,
      backgroundColorHex,
      isStacked,
      isHorizontal,
    );

    // 4) Creiamo un Blob + URL
    final blob = html.Blob([htmlContent], 'text/html');
    final url = html.Url.createObjectUrlFromBlob(blob);

    // 5) Creiamo l’IFrame
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
      width: widthPx,
      height: heightPx,
      child: HtmlElementView(viewType: _viewId),
    );
  }

  /// Converte la lista di categorie in un array JS.
  String _buildCategoriesJs(List<String> categories) {
    final sb = StringBuffer();
    sb.write('[');
    for (int i = 0; i < categories.length; i++) {
      final cat = categories[i];
      sb.write('"${_escapeJs(cat)}"');
      if (i < categories.length - 1) sb.write(',');
    }
    sb.write(']');
    return sb.toString();
  }

  /// Crea la stringa che rappresenta un array di "series" ECharts.
  String _buildSeriesJs(List<BarChartSeriesData> seriesList) {
    // Esempio di un oggetto "series" in ECharts:
    // {
    //   name: 'Serie 1',
    //   type: 'bar',
    //   data: [120, 200, 150, 80],
    //   itemStyle: { color: '#4a90e2', borderColor: '#000', borderWidth: 1 },
    //   stack: 'total' // se vogliamo impilare
    // }

    final sb = StringBuffer();
    sb.write('[');
    for (int i = 0; i < seriesList.length; i++) {
      final s = seriesList[i];
      // costruiamo la parte "data"
      final dataStr = s.values.map((v) => '$v').join(',');

      sb.write('{ ');
      sb.write('name: "${_escapeJs(s.seriesName)}", ');
      sb.write('type: "bar", ');
      sb.write('data: [$dataStr], ');
      // itemStyle
      sb.write('itemStyle: { ');
      sb.write('color: "${_escapeJs(s.colorHex)}", ');
      sb.write('borderColor: "${_escapeJs(s.borderColorHex)}", ');
      sb.write('borderWidth: ${s.borderWidth} ');
      sb.write('}, ');
      // stack se isStacked
      if (isStacked) {
        sb.write('stack: "total", ');
      }
      sb.write('}');
      if (i < seriesList.length - 1) sb.write(', ');
    }
    sb.write(']');
    return sb.toString();
  }

  /// Costruisce l'HTML completo con ECharts
  String _buildHtmlContent(
    String title,
    String categoriesJs,
    String seriesJs,
    String bgColorHex,
    bool isStacked,
    bool isHorizontal,
  ) {
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
      max-width: 1200px;
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
      height: 500px;
      background-color: ${_escapeHtml(bgColorHex)};
      border: 1px solid #333;
      box-shadow: 0 0 8px rgba(0,0,0,0.5);
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

    <div id="data-table-container">
      <div id="data-table-header">
        <span class="title">Data Table</span>
        <button id="btn-close-table">X</button>
      </div>
      <div id="data-table-scroll">
        <table class="data-table" id="data-table">
          <thead>
            <tr>
              <th>Category</th>
              <th>Series</th>
              <th>Value</th>
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
      const categories = $categoriesJs;
      const seriesData = $seriesJs;

      // Configurazione degli assi in base a isHorizontal
      // Se isHorizontal=true => l'asseX è "value", l'asseY è "category"
      // Altrimenti (verticale) => asseX è "category", asseY è "value".
      const isHorizontal = ${isHorizontal ? 'true' : 'false'};
      let optionAxes = {};
      if (isHorizontal) {
        optionAxes = {
          xAxis: { type: 'value' },
          yAxis: {
            type: 'category',
            data: categories
          }
        };
      } else {
        optionAxes = {
          xAxis: {
            type: 'category',
            data: categories
          },
          yAxis: { type: 'value' }
        };
      }

      // Opzione base ECharts
      const option = {
        backgroundColor: '${_escapeJs(bgColorHex)}',
        tooltip: {
          trigger: 'axis',
          // se vogliamo un formatter custom, potremmo farlo qui
        },
        legend: {
          show: true,
          top: 10
        },
        // L'animazione in ECharts di default è abilitata
        animationDuration: 1500,
        animationEasing: 'cubicOut',
        ...optionAxes,
        series: seriesData
      };

      const chartEl = document.getElementById('chart');
      const myChart = echarts.init(chartEl);
      myChart.setOption(option);

      // ---------------------
      // Sezione TABELLARE + CSV
      // ---------------------
      const dataTableContainer = document.getElementById('data-table-container');
      const btnShowData = document.getElementById('btn-show-data');
      const btnCloseTable = document.getElementById('btn-close-table');
      const btnDownloadCsv = document.getElementById('btn-download-csv');

      btnShowData.addEventListener('click', () => {
        chartEl.style.display = 'none';
        dataTableContainer.style.display = 'block';
      });
      btnCloseTable.addEventListener('click', () => {
        dataTableContainer.style.display = 'none';
        chartEl.style.display = 'block';
      });

      // Costruiamo i dati per la tabella
      // Per ogni categoria e per ogni serie
      // righe: Category, Series, Value
      let tableRows = [];
      for(let s=0; s<seriesData.length; s++){
        const serie = seriesData[s];
        const name = serie.name;
        const dataArr = serie.data; // array di valori (numeri)
        for(let c=0; c<categories.length; c++){
          let cat = categories[c];
          let val = dataArr[c];
          tableRows.push({
            category: cat,
            series: name,
            value: val
          });
        }
      }

      // Popoliamo la tabella
      const tbody = document.getElementById('data-table-body');
      tableRows.forEach(row => {
        const tr = document.createElement('tr');
        tr.innerHTML = '<td>' + _escapeHtml(row.category) + '</td>'
                     + '<td>' + _escapeHtml(row.series)   + '</td>'
                     + '<td>' + row.value + '</td>';
        tbody.appendChild(tr);
      });

      // Download CSV
      btnDownloadCsv.addEventListener('click', () => {
        let csv = 'Category,Series,Value\\n';
        tableRows.forEach(row => {
          // escapare eventuali "...
          csv += '"' + row.category.replace(/"/g,'\\"') + '","'
                       + row.series.replace(/"/g,'\\"') + '","'
                       + row.value + '"\\n';
        });
        const blob = new Blob([csv], { type:'text/csv;charset=utf-8;' });
        const url = URL.createObjectURL(blob);
        const a = document.createElement('a');
        a.href = url;
        a.setAttribute('download', 'bar_chart_data.csv');
        document.body.appendChild(a);
        a.click();
        document.body.removeChild(a);
        URL.revokeObjectURL(url);
      });

      function _escapeHtml(s){
        return s.replace(/&/g,'&amp;')
                .replace(/</g,'&lt;')
                .replace(/>/g,'&gt;')
                .replace(/"/g,'&quot;')
                .replace(/'/g,'&#39;');
      }
    })();
  </script>
</body>
</html>
''';
  }

  /// Utility per sfuggire caratteri in JS.
  static String _escapeJs(String s) {
    return s
        .replaceAll('\\', '\\\\')
        .replaceAll('"', '\\"')
        .replaceAll("'", "\\'");
  }

  static String _escapeHtml(String s) => s
      .replaceAll('&', '&amp;')
      .replaceAll('<', '&lt;')
      .replaceAll('>', '&gt;')
      .replaceAll('"', '&quot;')
      .replaceAll("'", '&#39;');
}
