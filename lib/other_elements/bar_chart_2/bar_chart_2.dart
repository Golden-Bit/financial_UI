import 'dart:html' as html;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';

/// Rappresenta i dati di una singola barra all'interno di una serie.
class BarChartItemData {
  /// Valore numerico da plottare.
  final double value;
  /// (Opzionale) colore personalizzato per questa barra. Esempio "#4a90e2".
  final String? colorHex;
  /// (Opzionale) Testo personalizzato della label (ad es. "62.2%\nCompany").
  /// Se nullo, verrà usato un formatter di default (es. il solo [value]).
  final String? label;
  
  BarChartItemData({
    required this.value,
    this.colorHex,
    this.label,
  });
}

/// Rappresenta i dati di una "serie" di barre (es. "Company", "Industry", "Market").
class BarChartSeriesData {
  /// Nome della serie. Verrà usato ad es. in legend o per identificare la serie.
  final String seriesName;
  /// Lista di barre (ogni barra ha [value], [colorHex], [label], ecc.).
  final List<BarChartItemData> items;
  /// Se desideri un colore di default per la serie
  /// (usato se un item non specifica colorHex).
  final String defaultColorHex;
  
  BarChartSeriesData({
    required this.seriesName,
    required this.items,
    this.defaultColorHex = "#4a90e2",
  });
}

/// Widget Flutter che incapsula il codice HTML/JS ECharts per disegnare
/// il grafico "Earnings Growth Comparison" (o simili) con barre personalizzate.
/// Include anche il pulsante DATA (in alto a destra, allineato al bordo destro del grafico)
/// che scompare quando si apre la tabella e riappare quando la tabella viene chiusa,
/// oltre alla funzionalità di Download CSV.
class CustomEarningsBarChartWidget extends StatelessWidget {
  final String title;
  final double widthPx;
  final double heightPx;
  final List<String> categories;
  final List<BarChartSeriesData> seriesList;
  final String backgroundColorHex;
  final bool showLegend;
  final bool showTooltipAxisPointer;
  
  late final String _viewId;
  
  CustomEarningsBarChartWidget({
    Key? key,
    required this.title,
    required this.categories,
    required this.seriesList,
    this.widthPx = 800,
    this.heightPx = 400,
    this.backgroundColorHex = "#2c2c3a",
    this.showLegend = false,
    this.showTooltipAxisPointer = true,
  }) : super(key: key) {
    // 1) Generiamo un ID univoco per l'iframe.
    final String viewId = 'custom-earnings-bar-${DateTime.now().millisecondsSinceEpoch}';
    _viewId = viewId;
    
    // 2) Creiamo le stringhe JS per categorie e serie.
    final String categoriesJs = _buildCategoriesJs(categories);
    final String seriesJs = _buildSeriesJs(seriesList);
    
    // 3) Creiamo l'HTML completo, includendo il pulsante DATA e la tabella.
    final String htmlContent = _buildHtmlContent(
      title: title,
      categoriesJs: categoriesJs,
      seriesJs: seriesJs,
      bgColorHex: backgroundColorHex,
      showLegend: showLegend,
      showTooltipAxisPointer: showTooltipAxisPointer,
    );
    
    // 4) Creiamo un Blob e un URL dal contenuto HTML.
    final blob = html.Blob([htmlContent], 'text/html');
    final url = html.Url.createObjectUrlFromBlob(blob);
    
    // 5) Creiamo l'IFrame.
    final html.IFrameElement iFrameElement = html.IFrameElement()
      ..src = url
      ..style.border = 'none'
      ..width = '100%'
      ..height = '100%';
    
    // 6) Registriamo la view.
    ui.platformViewRegistry.registerViewFactory(viewId, (int viewId) => iFrameElement);
  }
  
  // Funzione per calcolare il valore massimo rilevato tra tutti gli item delle serie,
  // e aggiungere 30.
  double _computeMaxValue() {
    double maxVal = double.negativeInfinity;
    for (var series in seriesList) {
      for (var item in series.items) {
        if (item.value > maxVal) {
          maxVal = item.value;
        }
      }
    }
    if (maxVal == double.negativeInfinity) {
      maxVal = 0;
    }
    return maxVal + 30;
  }
  
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widthPx,
      height: heightPx,
      child: HtmlElementView(viewType: _viewId),
    );
  }
  
  // Converte l'elenco di categorie in un array JS.
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
  
  // Converte la lista di series in un array ECharts "series",
  // dove "data" è un array di oggetti (con value, label, itemStyle, ecc.).
  String _buildSeriesJs(List<BarChartSeriesData> seriesList) {
    final sb = StringBuffer();
    sb.write('[');
    for (int i = 0; i < seriesList.length; i++) {
      final s = seriesList[i];
      final dataBuffer = StringBuffer();
      dataBuffer.write('[');
      for (int j = 0; j < s.items.length; j++) {
        final item = s.items[j];
        dataBuffer.write('{');
        // value
        dataBuffer.write('value:${item.value},');
        // Se esiste, label personalizzata
        if (item.label != null) {
          dataBuffer.write('label:{show:true,position:"top",color:"#fff",fontSize:13,formatter:"${_escapeJs(item.label!)}"},');
        }
        // itemStyle per il colore della barra
        final chosenColor = item.colorHex ?? s.defaultColorHex;
        dataBuffer.write('itemStyle:{color:"${_escapeJs(chosenColor)}"},');
        dataBuffer.write('}');
        if (j < s.items.length - 1) {
          dataBuffer.write(',');
        }
      }
      dataBuffer.write(']');
      sb.write('{');
      sb.write('name:"${_escapeJs(s.seriesName)}",');
      sb.write('type:"bar",');
      sb.write('data:${dataBuffer.toString()}');
      sb.write('}');
      if (i < seriesList.length - 1) {
        sb.write(',');
      }
    }
    sb.write(']');
    return sb.toString();
  }
  
  // Costruisce l'intero HTML con ECharts, il pulsante DATA (in alto a destra del grafico)
  // e la tabella con Download CSV. La tabella è posizionata all'interno del contenitore del grafico
  // (in modo da sovrapporsi esattamente al grafico).
  String _buildHtmlContent({
    required String title,
    required String categoriesJs,
    required String seriesJs,
    required String bgColorHex,
    required bool showLegend,
    required bool showTooltipAxisPointer,
  }) {
    final tooltipConfig = showTooltipAxisPointer
        ? """tooltip: {
            trigger: 'axis',
            axisPointer: { type: 'shadow' }
          },"""
        : """tooltip: { trigger: 'item' },""";
    
    final legendConfig = showLegend
        ? """legend: { show: true },"""
        : """legend: { show: false },""";
    
    // Inseriamo il valore massimo calcolato nell'asse Y.
    final computedMax = _computeMaxValue();
    
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
      position: relative;
    }
    h1 {
      text-align: center;
      margin-bottom: 30px;
    }
    /* Contenitore del grafico con padding-top per creare spazio in alto */
    #chart-container {
      position: relative;
      width: 800px;
      height: 400px;
      margin: 0 auto;
      padding-top: 20px;
    }
    /* Contenitore del grafico */
    #chart {
      width: 100%;
      height: 100%;
      background-color: #2c2c3a;
      border: 1px solid #333;
      box-shadow: 0 0 8px rgba(0,0,0,0.5);
    }
    /* Pulsante DATA posizionato in alto a destra del contenitore del grafico */
    #data-button-container {
      position: absolute;
      top: -30px;
      right: 0;
      z-index: 10;
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
    /* Contenitore della tabella dati (posizionato all'interno di #chart-container per sovrapporsi al grafico) */
    #data-table-container {
      display: none;
      position: absolute;
      top: 0;
      left: 0;
      width: 100%;
      height: 100%;
      margin: 0;
      background: #1e242c;
      border: 1px solid #444;
      border-radius: 4px;
      z-index: 20;
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
  </style>
</head>
<body>
  <h1>${_escapeHtml(title)}</h1>
  <div id="chart-container">
    <div id="chart"></div>
    <div id="data-button-container">
      <button id="btn-show-data">DATA</button>
    </div>
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
      var categories = $categoriesJs;
      var seriesArr = $seriesJs;
      var option = {
        backgroundColor: '${_escapeJs(bgColorHex)}',
        $tooltipConfig
        grid: {
          left: '5%',
          right: '5%',
          bottom: '10%',
          top: '5%',
          containLabel: true
        },
        xAxis: {
          type: 'category',
          data: categories,
          axisLabel: { color: '#fff', fontSize: 12 },
          axisLine: { show: false },
          axisTick: { show: false }
        },
        yAxis: {
          type: 'value',
          max: ${computedMax},
          axisLabel: { color: '#fff', formatter: '{value}%' },
          axisLine: { show: false },
          axisTick: { show: false },
          splitLine: { show: true, lineStyle: { color: '#444' } }
        },
        $legendConfig
        animationDuration: 1500,
        animationEasing: 'cubicOut',
        series: seriesArr
      };
      var chartDom = document.getElementById('chart');
      var myChart = echarts.init(chartDom);
      myChart.setOption(option);
      var dataTableContainer = document.getElementById('data-table-container');
      var btnShowData = document.getElementById('btn-show-data');
      var btnCloseTable = document.getElementById('btn-close-table');
      var btnDownloadCsv = document.getElementById('btn-download-csv');
      var tbody = document.getElementById('data-table-body');
      var rows = [];
      for(var s=0; s<seriesArr.length; s++){
        var serieObj = seriesArr[s];
        var serieName = serieObj.name;
        var dataArray = serieObj.data;
        for(var c=0; c<categories.length; c++){
          var cat = categories[c];
          var itemData = dataArray[c];
          var val = itemData.value;
          rows.push({ category: cat, series: serieName, value: val });
        }
      }
      rows.forEach(function(r){
        var tr = document.createElement('tr');
        tr.innerHTML = '<td>' + _escapeHtml(r.category) + '</td>' +
                       '<td>' + _escapeHtml(r.series) + '</td>' +
                       '<td>' + r.value + '</td>';
        tbody.appendChild(tr);
      });
      btnShowData.addEventListener('click', function(){
        chartDom.style.display = 'none';
        dataTableContainer.style.display = 'block';
        document.getElementById('data-button-container').style.display = 'none';
      });
      btnCloseTable.addEventListener('click', function(){
        dataTableContainer.style.display = 'none';
        chartDom.style.display = 'block';
        document.getElementById('data-button-container').style.display = 'block';
      });
      btnDownloadCsv.addEventListener('click', function(){
        var csv = 'Category,Series,Value\\n';
        rows.forEach(function(r){
          csv += '"' + r.category.replace(/"/g,'\\"') + '","' +
                 r.series.replace(/"/g,'\\"') + '","' +
                 r.value + '"\\n';
        });
        var blob = new Blob([csv], { type:'text/csv;charset=utf-8;' });
        var url = URL.createObjectURL(blob);
        var a = document.createElement('a');
        a.href = url;
        a.setAttribute('download', 'earnings_growth_data.csv');
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
  
  static String _escapeJs(String s) {
    const placeholder = '[[NEWLINE]]';
    s = s.replaceAll('\n', placeholder);
    s = s
        .replaceAll('\\', '\\\\')
        .replaceAll('"', '\\"')
        .replaceAll("'", "\\'");
    return s.replaceAll(placeholder, '\\u000A');
  }
  
  static String _escapeHtml(String s) {
    return s
        .replaceAll('&', '&amp;')
        .replaceAll('<', '&lt;')
        .replaceAll('>', '&gt;')
        .replaceAll('"', '&quot;')
        .replaceAll("'", '&#39;');
  }
}
  
// ----------------------------------------------------
// MAIN: Riproduce esattamente il grafico "Earnings Growth Comparison"
// ----------------------------------------------------
void main() {
  runApp(
    MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text("Earnings Growth Bar Example")),
        body: Center(
          child: CustomEarningsBarChartWidget(
            title: "Earnings Growth Comparison",
            categories: const [
              "Past 5 Years Annual Earnings Growth",
              "Last 1 Year Earnings Growth"
            ],
            seriesList: [
              BarChartSeriesData(
                seriesName: "Company",
                defaultColorHex: "#4a90e2",
                items: [
                  BarChartItemData(
                    value: 62.2,
                    colorHex: "#4a90e2",
                    label: "62.2%\nCompany",
                  ),
                  BarChartItemData(
                    value: 146.9,
                    colorHex: "#4a90e2",
                    label: "146.9%\nCompany",
                  ),
                ],
              ),
              BarChartSeriesData(
                seriesName: "Industry",
                defaultColorHex: "#26a69a",
                items: [
                  BarChartItemData(
                    value: 13.5,
                    colorHex: "#26a69a",
                    label: "13.5%\nIndustry",
                  ),
                  BarChartItemData(
                    value: -5.9,
                    colorHex: "#f04e4e",
                    label: "-5.9%\nIndustry",
                  ),
                ],
              ),
              BarChartSeriesData(
                seriesName: "Market",
                defaultColorHex: "#f78fba",
                items: [
                  BarChartItemData(
                    value: 12.2,
                    colorHex: "#f78fba",
                    label: "12.2%\nMarket",
                  ),
                  BarChartItemData(
                    value: 3.8,
                    colorHex: "#f78fba",
                    label: "3.8%\nMarket",
                  ),
                ],
              ),
            ],
            widthPx: 900,
            heightPx: 500,
            backgroundColorHex: "#2c2c3a",
            showLegend: false,
            showTooltipAxisPointer: true,
          ),
        ),
      ),
    ),
  );
}
