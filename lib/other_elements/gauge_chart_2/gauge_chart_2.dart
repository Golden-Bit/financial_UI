import 'dart:html' as html;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';

/// Widget Flutter che mostra un "PE Gauge Striped" con due lancette (Current PE e Fair PE)
/// e un pulsante DATA che permette di visualizzare la tabella dei valori e scaricarli in CSV.
///
/// Il gauge utilizza ECharts per disegnare:
/// - Un arco con segmenti colorati (verde fino a 62, oltre pattern rosso).
/// - Due lancette: la prima (blu) per "Current PE", la seconda (arancione) per "Fair PE".
/// - Tooltip che mostrano il valore al passaggio del mouse.
/// Le label relative ai valori (visualizzate sotto il gauge) sono mostrate in due "pie" fittizie.
/// Il pulsante DATA, posizionato esattamente in alto a destra, scompare quando si visualizza la tabella
/// e riappare al suo chiudersi. Nella tabella, vengono riportati solo "Label" e "Value" (senza unità).
class StripedPEGaugeWidget extends StatelessWidget {
  final String title;
  final double minVal;
  final double maxVal;
  final double currentPE;
  final double fairPE;
  final double widthPx;
  final double heightPx;
  // Unità di misura (ad es. "x", "USD", ecc.) per le lancette (mostrata nelle label gauge)
  final String unit = 'x';

  late final String _viewId;

  StripedPEGaugeWidget({
    Key? key,
    required this.title,
    this.minVal = 0,
    this.maxVal = 122,
    required this.currentPE,
    required this.fairPE,
    this.widthPx = 600,
    this.heightPx = 400,
  }) : super(key: key) {
    // 1) Creiamo un ID univoco per l'IFrame.
    final String viewId = 'striped-pe-gauge-${DateTime.now().millisecondsSinceEpoch}';
    _viewId = viewId;

    // 2) Costruiamo l'HTML completo.
    final String htmlContent = _buildHtmlContent(title, minVal, maxVal, unit, currentPE, fairPE);

    // 3) Creiamo un Blob + URL.
    final blob = html.Blob([htmlContent], 'text/html');
    final url = html.Url.createObjectUrlFromBlob(blob);

    // 4) Creiamo l'IFrame.
    final html.IFrameElement iFrameElement = html.IFrameElement()
      ..src = url
      ..style.border = 'none'
      ..width = '100%'
      ..height = '100%';

    // 5) Registriamo la view nell'ambiente Flutter.
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

  /// Costruisce l'HTML con ECharts, DATA button, tabella e CSV download.
  String _buildHtmlContent(String title, double minVal, double maxVal, String unit, double currentPE, double fairPE) {
    // Creiamo una variabile "unitStr" per usare nel JS (escapata)
    final String unitStr = _escapeJs(unit);
    return '''
<!DOCTYPE html>
<html lang="it">
<head>
  <meta charset="UTF-8">
  <title>${_escapeHtml(title)}</title>
  <script src="https://cdn.jsdelivr.net/npm/echarts@5/dist/echarts.min.js"></script>
  <style>
    body {
      margin: 20px;
      background-color: #1f1f2e;
      font-family: Arial, sans-serif;
      color: #fff;
    }
    /* Aumentato il margine sotto il titolo per maggiore distacco */
    h1 {
      text-align: center;
      margin-bottom: 60px;
    }
    #app-container {
      position: relative;
      width: 600px;
      margin: 0 auto;
    }
    #chart {
      width: 600px;
      height: 400px;
      background-color: #2c2c3a;
      border: 1px solid #333;
      box-shadow: 0 0 8px rgba(0,0,0,0.5);
      position: relative;
    }
    /* Pulsante DATA: allineato esattamente al bordo destro del widget */
    #data-button-container {
      position: absolute;
      top: 50px;
      right: 0px;
      z-index: 10;
    }
    #btn-show-data {
      background: #2b333d;
      color: #fff;
      border: 1px solid #444;
      padding: 6px 10px;
      cursor: pointer;
      border-radius: 4px;
      font-size: 12px;
    }
    #btn-show-data:hover {
      background: #3e464f;
    }
    /* Container per le label sottostanti, disposte da sinistra a destra con wrapping */
    #label-container {
      display: flex;
      flex-wrap: wrap;
      justify-content: center;
      gap: 20px;
      margin-top: 10px;
    }
    .label-item {
      background: #2b333d;
      padding: 4px 8px;
      border-radius: 4px;
      text-align: center;
      font-size: 14px;
      font-weight: bold;
    }
    /* Tabella dati */
    #data-table-container {
      display: none;
      margin-top: 20px;
      background: #1e242c;
      border: 1px solid #444;
      border-radius: 4px;
      width: 600px;
      margin-left: auto;
      margin-right: auto;
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
      padding: 6px 10px;
      cursor: pointer;
      border-radius: 4px;
      font-size: 12px;
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
              <th>Label</th>
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
      var minVal = ${minVal};
      var maxVal = ${maxVal};
      var currentPE = ${currentPE};
      var fairPE = ${fairPE};
      var unit = "${unitStr}"; // unitStr definito in Dart via _escapeJs(unit)

      // Creiamo un canvas per la parte rossa con linee diagonali
      var stripeCanvas = document.createElement('canvas');
      stripeCanvas.width = 20;
      stripeCanvas.height = 20;
      var ctx = stripeCanvas.getContext('2d');
      ctx.fillStyle = '#F04E4E';
      ctx.fillRect(0, 0, 20, 20);
      ctx.strokeStyle = '#2c2c3a';
      ctx.lineWidth = 3;
      ctx.beginPath();
      ctx.moveTo(0, 0);
      ctx.lineTo(20, 20);
      ctx.stroke();
      ctx.beginPath();
      ctx.moveTo(20, 0);
      ctx.lineTo(0, 20);
      ctx.stroke();
      var stripePattern = {
        image: stripeCanvas,
        repeat: 'repeat'
      };

      // Colori per l'arco: da 0 a 62 in verde, da 62 a maxVal in pattern rosso.
      var colorStops = [
        [62 / maxVal, '#3AA76D'],
        [1, stripePattern]
      ];

      function customAxisLabel(val) {
        if (val === 0)    return '0x';
        if (val === 30.5) return '30.5x';
        if (val === 61)   return '61x';
        if (val === 91.5) return '91.5x';
        if (val === 122)  return '122x';
        return '';
      }

      var option = {
        backgroundColor: '#2c2c3a',
        animationDuration: 2000,
        animationEasing: 'cubicOut',
        series: [
          {
            name: 'Current PE Gauge',
            type: 'gauge',
            startAngle: 180,
            endAngle: 0,
            center: ['50%', '70%'],
            min: minVal,
            max: maxVal,
            axisLine: {
              lineStyle: {
                width: 20,
                color: colorStops
              }
            },
            axisTick: { show: false },
            splitLine: { show: false },
            axisLabel: {
              color: '#fff',
              fontSize: 10,
              distance: -30,
              formatter: customAxisLabel
            },
            pointer: {
              show: true,
              length: '60%',
              width: 5,
              itemStyle: { color: '#4a90e2' }
            },
            anchor: {
              show: true,
              size: 12,
              showAbove: true,
              itemStyle: { color: '#666' }
            },
            detail: { show: false },
            data: [{ value: 0 }]
          },
          {
            name: 'Fair PE Gauge',
            type: 'gauge',
            startAngle: 180,
            endAngle: 0,
            center: ['50%', '70%'],
            min: minVal,
            max: maxVal,
            axisLine: { show: false },
            axisTick: { show: false },
            splitLine: { show: false },
            axisLabel: { show: false },
            pointer: {
              show: true,
              length: '95%',
              width: 2,
              itemStyle: { color: '#f5b941' }
            },
            anchor: {
              show: true,
              size: 12,
              showAbove: true,
              itemStyle: { color: '#666' }
            },
            detail: { show: false },
            data: [{ value: 0 }]
          },
          {
            type: 'pie',
            center: ['35%', '80%'],
            radius: [0, 0],
            label: {
              show: true,
              position: 'center',
              formatter: function(){
                return '{box|Current PE ' + currentPE.toFixed(1) + unit + '}';
              },
              rich: {
                box: {
                  backgroundColor: '#4a90e2',
                  color: '#fff',
                  padding: [4, 8],
                  borderRadius: 4,
                  align: 'center',
                  fontSize: 12,
                  fontWeight: 'bold'
                }
              }
            },
            data: [100]
          },
          {
            type: 'pie',
            center: ['65%', '80%'],
            radius: [0, 0],
            label: {
              show: true,
              position: 'center',
              formatter: function(){
                return '{box|Fair PE ' + fairPE.toFixed(1) + unit + '}';
              },
              rich: {
                box: {
                  backgroundColor: '#f5b941',
                  color: '#fff',
                  padding: [4, 8],
                  borderRadius: 4,
                  align: 'center',
                  fontSize: 12,
                  fontWeight: 'bold'
                }
              }
            },
            data: [100]
          }
        ]
      };

      var myChart = echarts.init(document.getElementById('chart'));
      myChart.setOption(option);

      setTimeout(function(){
        myChart.setOption({
          series: [
            { data: [{ value: currentPE }] },
            { data: [{ value: fairPE }] }
          ]
        });
      }, 300);

      // Gestione tabella dati e CSV.
      var rows = [
        { label: "Current PE", value: currentPE },
        { label: "Fair PE",    value: fairPE }
      ];
      var tbody = document.getElementById('data-table-body');
      rows.forEach(function(r){
        var tr = document.createElement('tr');
        tr.innerHTML = '<td>' + _escapeHtml(r.label) + '</td>'
                     + '<td>' + r.value.toFixed(1) + '</td>';
        tbody.appendChild(tr);
      });

      var chartEl = document.getElementById('chart');
      var dataTableContainer = document.getElementById('data-table-container');
      var btnShowData = document.getElementById('btn-show-data');
      var btnCloseTable = document.getElementById('btn-close-table');
      var btnDownloadCsv = document.getElementById('btn-download-csv');

btnShowData.addEventListener('click', function(){
  chartEl.style.display = 'none';
  dataTableContainer.style.display = 'block';
  btnShowData.style.display = 'none'; // Nascondi il pulsante DATA
});
btnCloseTable.addEventListener('click', function(){
  dataTableContainer.style.display = 'none';
  chartEl.style.display = 'block';
  btnShowData.style.display = 'block'; // Riporta il pulsante DATA
});
      btnDownloadCsv.addEventListener('click', function(){
        var csv = 'Label,Value\\n';
        rows.forEach(function(r){
          csv += '"' + r.label.replace(/"/g,'\\"') + '","' + r.value.toFixed(1) + '"\\n';
        });
        var blob = new Blob([csv], { type:'text/csv;charset=utf-8;' });
        var url = URL.createObjectURL(blob);
        var a = document.createElement('a');
        a.href = url;
        a.setAttribute('download', 'pe_gauge_data.csv');
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

  static String _escapeHtml(String s) => s
      .replaceAll('&', '&amp;')
      .replaceAll('<', '&lt;')
      .replaceAll('>', '&gt;')
      .replaceAll('"', '&quot;')
      .replaceAll("'", '&#39;');

  static String _escapeJs(String s) {
    return s.replaceAll('\\', '\\\\')
            .replaceAll('"', '\\"')
            .replaceAll("'", "\\'");
  }
}
