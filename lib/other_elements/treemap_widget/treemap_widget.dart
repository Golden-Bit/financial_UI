import 'dart:html' as html;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

/// Rappresenta un elemento del treemap.
class TreemapItemData {
  /// Nome dell’elemento (es. "Cash & Short Term Investments")
  final String name;

  /// Valore numerico (se negativo, appare in rosso e in valore assoluto sul riquadro).
  final double value;

  /// Colore di default (es. "#3AA76D").
  /// Se [value] è negativo e non vuoi usare questo colore, setta un colore rosso custom.
  final String colorHex;

  /// Colore del bordo (es. "#000").
  final String borderColorHex;

  /// Spessore del bordo (default 1).
  final double borderWidth;

  /// Colore del testo interno (default "#fff").
  final String textColorHex;

  TreemapItemData({
    required this.name,
    required this.value,
    this.colorHex = "#3AA76D",
    this.borderColorHex = "#000",
    this.borderWidth = 1,
    this.textColorHex = "#fff",
  });
}

/// Rappresenta un “gruppo” (es. “Assets” o “Liabilities + Equity”) da disegnare
/// come un treemap su una porzione orizzontale della vista.
class TreemapGroupData {
  /// Nome del gruppo (verrà mostrato come “radice”).
  final String groupName;

  /// Posizione orizzontale di inizio (es. "0%", "50%", "10px", ecc.).
  final String left;

  /// Larghezza orizzontale (es. "50%", "calc(100% - 10px)", ecc.).
  final String width;

  /// Elenco di item (figli) da mostrare in questo gruppo.
  final List<TreemapItemData> items;

  TreemapGroupData({
    required this.groupName,
    required this.left,
    required this.width,
    required this.items,
  });
}

/// Widget Flutter che incorpora un IFrame con ECharts per disegnare un treemap
/// con più “gruppi” affiancati (es. “Assets” a sinistra, “Liabilities + Equity” a destra).
///
/// Supporta:
/// - Valori negativi (in rosso, con valore assoluto nel riquadro).
/// - Bordo personalizzato, colore testo, ecc.
/// - Tooltip con valore con segno (se negativo).
/// - Pulsante “DATA” per mostrare i dati in tabella, con pulsante “Download CSV”.
class TreemapEchartsWidget extends StatelessWidget {
  final String title;
  final double widthPx;
  final double heightPx;

  /// Elenco di “gruppi” (ciascuno con un “left” e “width”, e una lista di item).
  final List<TreemapGroupData> groups;

  late final String _viewId;

  TreemapEchartsWidget({
    Key? key,
    required this.title,
    required this.groups,
    this.widthPx = 800,
    this.heightPx = 500,
  }) : super(key: key) {
    // 1) Creiamo un id univoco
    final String viewId = 'treemap-charts-${DateTime.now().millisecondsSinceEpoch}';
    _viewId = viewId;

    // 2) Convertiamo groups e items in stringhe JS
    final String groupsJsArray = _buildGroupsJs(groups);

    // 3) Costruiamo l’HTML
    final String htmlContent = _buildHtmlContent(title, groupsJsArray);

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

  /// Genera la stringa JS per definire i gruppi e i children
  String _buildGroupsJs(List<TreemapGroupData> groups) {
    final sb = StringBuffer();
    sb.write('[');
    for (int i = 0; i < groups.length; i++) {
      final g = groups[i];
      final itemsJs = _buildItemsJs(g.items);
      sb.write('{ ');
      sb.write('"groupName":"${_escapeJs(g.groupName)}", ');
      sb.write('"left":"${_escapeJs(g.left)}", ');
      sb.write('"width":"${_escapeJs(g.width)}", ');
      sb.write('"items": $itemsJs ');
      sb.write('}');
      if (i < groups.length - 1) sb.write(', ');
    }
    sb.write(']');
    return sb.toString();
  }

  /// Genera l’array di item (children)
  String _buildItemsJs(List<TreemapItemData> items) {
    final sb = StringBuffer();
    sb.write('[');
    for (int i = 0; i < items.length; i++) {
      final it = items[i];
      sb.write('{ ');
      sb.write('"name":"${_escapeJs(it.name)}", ');
      sb.write('"value":${it.value}, ');
      sb.write('"colorHex":"${_escapeJs(it.colorHex)}", ');
      sb.write('"borderColorHex":"${_escapeJs(it.borderColorHex)}", ');
      sb.write('"borderWidth":${it.borderWidth}, ');
      sb.write('"textColorHex":"${_escapeJs(it.textColorHex)}" ');
      sb.write('}');
      if (i < items.length - 1) sb.write(', ');
    }
    sb.write(']');
    return sb.toString();
  }

  /// Costruisce l’HTML + script ECharts
  String _buildHtmlContent(String title, String groupsJsArray) {
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
      background-color: #2c2c3a;
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
              <th>Group</th>
              <th>Name</th>
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
      const groups = $groupsJsArray;

      // costruiamo la serie ECharts e i dati per la tabella
      const series = [];
      const tableRows = [];

      groups.forEach((g)=>{
        // costruiamo i children
        const children = g.items.map(item => {
          const val = item.value;
          const absVal = Math.abs(val);
          // tooltip mostrerà segno se < 0
          return {
            rawValue: val,
            name: item.name,
            value: absVal,
            label: {
              formatter: item.name + '\\nUS\$' + absVal.toFixed(1) + 'b'
            },
            itemStyle: {
              color: (val<0 ? '#f04e4e' : item.colorHex),
              borderColor: item.borderColorHex,
              borderWidth: item.borderWidth
            }
          };
        });

        series.push({
          name: g.groupName,
          type: 'treemap',
          left: g.left,
          top: 0,
          bottom: 0,
          width: g.width,
          roam: false,
          nodeClick: false,
          breadcrumb: { show: false },
          label: {
            show: true,
            position: 'insideTopLeft',
            color: '#fff',
            fontSize: 14
          },
          data: [
            {
              name: g.groupName,
              children: children
            }
          ]
        });

        // Riempiamo la tabella
        children.forEach(ch => {
          tableRows.push({
            group: g.groupName,
            name: ch.name,
            rawValue: ch.rawValue
          });
        });
      });

      // Config ECharts
      const option = {
        backgroundColor: '#2c2c3a',
        tooltip: {
          trigger: 'item',
          formatter: function(params) {
            const rawVal = params.data.rawValue;
            const signStr = (rawVal < 0) ? '-' : '';
            const absVal  = Math.abs(rawVal).toFixed(1);
            return (
              '<strong>' + params.name + '</strong><br/>' +
              'Value: US\$' + signStr + absVal + 'b'
            );
          }
        },
        series: series
      };

      const chartEl = document.getElementById('chart');
      const myChart = echarts.init(chartEl);
      myChart.setOption(option);

      // Tabella e pulsanti
      const btnShowData = document.getElementById('btn-show-data');
      const dataTableContainer = document.getElementById('data-table-container');
      const btnCloseTable = document.getElementById('btn-close-table');
      const btnDownloadCsv= document.getElementById('btn-download-csv');

      // Build table
      const tbody = document.getElementById('data-table-body');
      tableRows.forEach(row=>{
        const tr= document.createElement('tr');
        const signStr= (row.rawValue<0)?'-':'';
        const absVal= Math.abs(row.rawValue).toFixed(1);
        tr.innerHTML= '<td>'+_escapeHtml(row.group)+'</td>'
                    + '<td>'+_escapeHtml(row.name)+'</td>'
                    + '<td>'+ signStr + absVal +'b</td>';
        tbody.appendChild(tr);
      });

      btnShowData.addEventListener('click', ()=>{
        chartEl.style.display='none';
        dataTableContainer.style.display='block';
      });
      btnCloseTable.addEventListener('click', ()=>{
        dataTableContainer.style.display='none';
        chartEl.style.display='block';
      });
      btnDownloadCsv.addEventListener('click', ()=>{
        let csv='Group,Name,Value\\n';
        tableRows.forEach(row=>{
          const signStr= (row.rawValue<0)?'-':'';
          const absVal= Math.abs(row.rawValue).toFixed(1);
          csv+= '"'+row.group.replace(/"/g,'\\"')+'","'
               + row.name.replace(/"/g,'\\"')+'","'
               + signStr+absVal+'b"\\n';
        });
        const blob= new Blob([csv],{type:'text/csv;charset=utf-8;'});
        const url= URL.createObjectURL(blob);
        const a= document.createElement('a');
        a.href= url;
        a.setAttribute('download','treemap_data.csv');
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
    return s.replaceAll('\\', '\\\\')
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


/// Esempio di uso in un main, con i dati “Assets” e “Liabilities + Equity”.
void main() {
  runApp(
    MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text("Treemap ECharts Example")),
        body: Center(
          child: TreemapEchartsWidget(
            title: "Assets | Liabilities + Equity",
            widthPx: 800,
            heightPx: 500,
            groups: [
              TreemapGroupData(
                groupName: "Assets",
                left: "0%",
                width: "50%",
                items: [
                  TreemapItemData(
                    name: "Cash & Short Term Investments",
                    value: 43.2,
                    colorHex: "#3AA76D",
                    borderColorHex: "#000",
                    borderWidth: 1,
                    textColorHex: "#fff",
                  ),
                  TreemapItemData(
                    name: "Long Term & Other Assets",
                    value: 27.2,
                    colorHex: "#3AA76D",
                  ),
                  TreemapItemData(
                    name: "Receivables",
                    value: 23.1,
                    colorHex: "#3AA76D",
                  ),
                  TreemapItemData(
                    name: "Inventory",
                    value: 10.1,
                    colorHex: "#3AA76D",
                  ),
                  TreemapItemData(
                    name: "Physical Assets",
                    value: 8.2,
                    colorHex: "#3AA76D",
                  ),
                ],
              ),
              TreemapGroupData(
                groupName: "Liabilities + Equity",
                left: "50%",
                width: "50%",
                items: [
                  TreemapItemData(
                    name: "Equity",
                    value: 79.3,
                    colorHex: "#3AA76D",
                  ),
                  TreemapItemData(
                    name: "Other Liabilities",
                    value: 17.5,
                    colorHex: "#3AA76D",
                  ),
                  // Esempio con valore negativo => appare in rosso e in valore assoluto sul riquadro
                  TreemapItemData(
                    name: "Debt",
                    value: -8.5,
                    colorHex: "#3AA76D", // verrà forzato a rosso se < 0
                  ),
                  TreemapItemData(
                    name: "Accounts Payable",
                    value: 6.3,
                    colorHex: "#3AA76D",
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
