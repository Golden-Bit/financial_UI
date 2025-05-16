import 'dart:html' as html;
import 'dart:ui' as ui;

import 'package:flutter/widgets.dart';

/// Rappresenta un singolo punto dati: (time, value).
/// "time" deve essere in formato "yyyy-MM-dd".
class PricePoint {
  final String time;
  final double value;

  PricePoint(this.time, this.value);
}

/// Rappresenta i parametri di una singola serie.
class SeriesData {
  /// Etichetta (usata ad es. in toggle e tabella).
  final String label;

  /// Colore in formato es. "#d9534f" (hex).
  final String colorHex;

  /// Eventuale lista di dati (time, value).
  /// Se è null o vuota e [simulateIfNoData] è true,
  /// verranno generati dati simulati.
  final List<PricePoint>? data;

  /// Se la serie è inizialmente visibile.
  final bool visible;

  SeriesData({
    required this.label,
    required this.colorHex,
    this.data,
    this.visible = true,
  });
}

/// Un widget Flutter che incapsula un IFrame contenente
/// lo script HTML di Lightweight Charts, con:
/// - Più serie (ciascuna con label, colore, dati)
/// - Toggles di visibilità
/// - Range buttons
/// - Navigator
/// - Tabella con "DATA" e "Download CSV"
///
/// Funziona SOLO su Flutter Web.
class MultiSeriesLightweightChartWidget extends StatelessWidget {
  final String title;
  final List<SeriesData> seriesList;
  final bool simulateIfNoData;
  final double width;
  final double height;

  /// Costruttore
  ///
  /// [title] verrà mostrato in `<h1>`.
  /// [seriesList] definisce le varie serie (label, color, data).
  /// [simulateIfNoData] se true, genera dati fittizi
  ///   se la serie non ha data.
  MultiSeriesLightweightChartWidget({
    Key? key,
    required this.title,
    required this.seriesList,
    this.simulateIfNoData = false,
    this.width = 1200,
    this.height = 700,
  }) : super(key: key) {
    final String viewId = 'multi-series-charts-${DateTime.now().millisecondsSinceEpoch}';
    _viewId = viewId;

    // Convertiamo l'elenco di serie in JS
    // avremo un oggetto JS come:
    // [
    //   {
    //     "label": "Debt",
    //     "color": "#d9534f",
    //     "visible": true,
    //     "data": [ { time: '2020-01-01', value: 100 }, ... ]
    //   },
    //   ...
    // ]
    final String seriesJsArray = _buildSeriesJsArray(seriesList, simulateIfNoData);

    // Costruiamo l'HTML:
    final String htmlContent = _buildHtmlContent(title, seriesJsArray);

    // Creiamo un blob
    final blob = html.Blob([htmlContent], 'text/html');
    final url = html.Url.createObjectUrlFromBlob(blob);

    // Creiamo un IFrame
    final html.IFrameElement iFrameElement = html.IFrameElement()
      ..src = url
      ..style.border = 'none'
      ..width = '100%'
      ..height = '100%';

    // Registriamo la view
    ui.platformViewRegistry.registerViewFactory(viewId, (int viewId) => iFrameElement);
  }

  late final String _viewId;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: HtmlElementView(viewType: _viewId),
    );
  }

  /// Crea l'HTML completo da iniettare.
  String _buildHtmlContent(String title, String seriesJsArray) {
    // TUTTO l'HTML + CSS + script
    // Variante "multi-series" con toggles e tabella
    // ispirato a "Multi-Series Chart (Debt, Equity, Cash) - Lightweight Charts + Data Table"
    // ma parametric.
    return '''
<!DOCTYPE html>
<html lang="it">
<head>
  <meta charset="UTF-8" />
  <title>\${_escapeHtml(title)}</title>
  <style>
    body {
      margin: 0;
      padding: 0;
      background: #1e242c;
      font-family: sans-serif;
      color: #fff;
    }
    /* Contenitore principale */
    #app-container {
      width: 90%;
      max-width: 1200px;
      margin: 0 auto;
      padding: 20px 0;
      position: relative;
    }
    h1 {
      width: 100%;
      margin: 20px 0 10px 0;
      text-align: left;
    }
    /* Pulsanti range */
    #range-buttons {
      display: grid;
      grid-template-columns: repeat(6, 1fr);
      gap: 10px;
      margin-bottom: 20px;
    }
    #range-buttons button {
      background: #2b333d;
      color: #fff;
      border: 1px solid #444;
      padding: 8px;
      cursor: pointer;
      border-radius: 4px;
      font-size: 14px;
      text-align: center;
    }
    #range-buttons button:hover {
      background: #3e464f;
    }
    #range-buttons button.selected {
      background: #404854;
    }
    /* Chart principale */
    #main-chart {
      width: 100%;
      height: 400px;
      position: relative;
    }
    /* Navigator */
    #navigator-chart {
      width: 100%;
      height: 80px;
      margin-top: 10px;
      position: relative;
      overflow: hidden;
    }
    #navigator-rectangle {
      position: absolute;
      top: 0;
      height: 100%;
      background: rgba(140,198,255,0.3);
      pointer-events: none;
      z-index: 2;
    }
    /* Legenda toggles */
    #series-toggles {
      display: flex;
      gap: 20px;
      margin-top: 15px;
      align-items: center;
      flex-wrap: wrap;
      justify-content: flex-start;
    }
    .toggle-item {
      display: flex;
      align-items: center;
      gap: 6px;
      cursor: pointer;
      transition: opacity 0.3s;
    }
    .toggle-item.disabled {
      opacity: 0.5;
    }
    .toggle-color-box {
      width: 12px;
      height: 12px;
      border-radius: 2px;
      display: inline-block;
    }
    /* Crosshair tooltip */
    #multi-tooltip {
      position: absolute;
      display: none;
      pointer-events: none;
      background: rgba(0,0,0,0.8);
      color: #fff;
      padding: 8px 10px;
      font-size: 14px;
      border-radius: 4px;
      z-index: 999;
      max-width: 300px;
    }
    /* Pulsante "DATA" */
    #data-button-container {
      width: 100%;
      margin-top: 20px;
      text-align: right;
    }
    #btn-show-data {
      background: #2b333d;
      color: #fff;
      border: 1px solid #444;
      padding: 8px 12px;
      cursor: pointer;
      border-radius: 4px;
      font-size: 14px;
      display: inline-flex;
      align-items: center;
      gap: 6px;
    }
    #btn-show-data:hover {
      background: #3e464f;
    }
    /* Tabella dati */
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
    <h1>$title</h1>
    <!-- Range Buttons -->
    <div id="range-buttons">
      <button data-range="1m">1M</button>
      <button data-range="3m">3M</button>
      <button data-range="1y">1Y</button>
      <button data-range="3y">3Y</button>
      <button data-range="5y">5Y</button>
      <button data-range="all">Max</button>
    </div>
    <!-- Main Chart -->
    <div id="main-chart"></div>
    <!-- Navigator -->
    <div id="navigator-chart">
      <div id="navigator-rectangle"></div>
    </div>
    <!-- Toggles series -->
    <div id="series-toggles"></div>
    <!-- Data button -->
    <div id="data-button-container">
      <button id="btn-show-data">
        <span>📊</span>
        DATA
      </button>
    </div>
    <!-- Crosshair tooltip -->
    <div id="multi-tooltip"></div>
    <!-- Data Table -->
    <div id="data-table-container">
      <div id="data-table-header">
        <span class="title">Data Table</span>
        <button id="btn-close-table">X</button>
      </div>
      <div id="data-table-scroll">
        <table class="data-table" id="data-table">
          <thead>
            <tr id="table-header-row">
              <!-- colonna "Date" + 1 colonna per ogni serie -->
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
  <script src="https://unpkg.com/lightweight-charts@4/dist/lightweight-charts.standalone.production.js"></script>
  <script>
    (function(){
      const seriesList = $seriesJsArray; // array di serie: label, color, visible, data[..]
      // Funzioni di supporto
      function parseYMD(str) {
        const [y,m,d] = str.split('-');
        return new Date(+y, +m-1, +d);
      }
      function clampRange(range, min, max) {
        return {
          from: Math.max(range.from, min),
          to: Math.min(range.to, max),
        };
      }
      // Uniamo i time unici di tutte le serie, per la tabella
      let allTimesSet = new Set();
      seriesList.forEach(s => {
        s.data.forEach(dp => {
          allTimesSet.add(dp.time);
        });
      });
      let allTimes = Array.from(allTimesSet).sort();
      // CHART Principale
      let mainChartEl, navChartEl, mainChart, navChart;
      window.addEventListener('DOMContentLoaded', () => {
        mainChartEl = document.getElementById('main-chart');
        navChartEl  = document.getElementById('navigator-chart');
        // Main Chart
        mainChart = LightweightCharts.createChart(mainChartEl, {
          width: mainChartEl.clientWidth,
          height: mainChartEl.clientHeight,
          layout: {
            background: { type: 'Solid', color: '#1e242c' },
            textColor: '#fff',
          },
          timeScale: {
            timeVisible: true,
            secondsVisible: false,
          },
          rightPriceScale: { visible: false },
          leftPriceScale: {
            visible: true,
            borderVisible: false,
          },
          grid: {
            vertLines: { color: '#2B2B43', style: 0 },
            horzLines: { color: '#2B2B43', style: 0 },
          },
          crosshair: {
            vertLine: { labelVisible: true },
            horzLine: { labelVisible: true },
          },
        });
        // Aggiungiamo le serie
        const mainSeriesObjs = [];
        seriesList.forEach(s => {
          const ser = mainChart.addAreaSeries({
            topColor: s.color + '33',
            bottomColor: s.color + '00',
            lineColor: s.color,
            lineWidth: 2,
            visible: s.visible,
            lastValueVisible: false,
            priceLineVisible: false,
            priceFormat: {
              type: 'custom',
              minMove: 0.01,
              formatter: (price) => price.toFixed(2) + ' B\$',
            },
          });
          ser.setData(s.data);
          mainSeriesObjs.push({ label: s.label, series: ser });
        });
        // Fit content
        mainChart.timeScale().fitContent();
        // Navigator
        navChart = LightweightCharts.createChart(navChartEl, {
          width: navChartEl.clientWidth,
          height: navChartEl.clientHeight,
          layout: {
            background: { type: 'Solid', color: '#1e242c' },
            textColor: '#aaa',
          },
          kineticScroll: { mouse: false, touch: false },
          handleScroll: false,
          handleScale: false,
          timeScale: {
            timeVisible: true,
            secondsVisible: false,
          },
          rightPriceScale: { visible: false },
          leftPriceScale: { visible: false },
          grid: {
            vertLines: { visible: false },
            horzLines: { visible: false },
          },
          crosshair: {
            mode: 0,
            vertLine: { visible: false },
            horzLine: { visible: false },
          },
        });
        // Aggiungiamo una areaSeries "cumulata"? Oppure le stesse? A scopo demo, disegniamo TUTTE, sovrapposte
        seriesList.forEach(s => {
          const nser = navChart.addAreaSeries({
            topColor: s.color + '33',
            bottomColor: s.color + '00',
            lineColor: s.color,
            lineWidth: 1,
            lastValueVisible: false,
            priceLineVisible: false,
          });
          nser.setData(s.data);
        });
        navChart.timeScale().fitContent();
        // Navigator rectangle
        const navRect = document.getElementById('navigator-rectangle');
        function updateNavRectangle() {
          const range = mainChart.timeScale().getVisibleLogicalRange();
          if (!range) {
            navRect.style.display = 'none';
            return;
          }
          let leftIndex = Math.floor(range.from);
          let rightIndex= Math.ceil(range.to);
          leftIndex = Math.max(0, leftIndex);
          rightIndex= Math.min(allTimes.length-1, rightIndex);
          const fromTime = allTimes[leftIndex];
          const toTime = allTimes[rightIndex];
          const fromX = navChart.timeScale().timeToCoordinate(fromTime);
          const toX   = navChart.timeScale().timeToCoordinate(toTime);
          if (fromX===null || toX===null) {
            navRect.style.display='none';
            return;
          }
          let left = Math.min(fromX, toX);
          let width= Math.abs(toX - fromX);
          const containerW= navChartEl.clientWidth;
          if (left<0) {
            width+= left;
            left=0;
          }
          if (left+width>containerW) {
            width= containerW-left;
          }
          if (width<=0) {
            navRect.style.display='none';
            return;
          }
          navRect.style.display='block';
          navRect.style.left= left+'px';
          navRect.style.width= width+'px';
          navRect.style.top='0px';
          navRect.style.height= navChartEl.clientHeight+'px';
        }
        mainChart.timeScale().subscribeVisibleLogicalRangeChange(updateNavRectangle);
        updateNavRectangle();
        // Range Buttons
        const rangeButtons = document.querySelectorAll('#range-buttons button');
        rangeButtons.forEach(btn => {
          btn.addEventListener('click', () => {
            rangeButtons.forEach(b => b.classList.remove('selected'));
            btn.classList.add('selected');
            setCustomRange(btn.dataset.range);
          });
        });
        function setCustomRange(rid) {
          if (rid==='all') {
            mainChart.timeScale().fitContent();
            return;
          }
          const last = allTimes[allTimes.length-1];
          const lastDate= parseYMD(last);
          let fromDate= new Date(lastDate);
          if(rid==='1m'){ fromDate.setMonth(fromDate.getMonth()-1); }
          else if(rid==='3m'){ fromDate.setMonth(fromDate.getMonth()-3); }
          else if(rid==='1y'){ fromDate.setFullYear(fromDate.getFullYear()-1); }
          else if(rid==='3y'){ fromDate.setFullYear(fromDate.getFullYear()-3); }
          else if(rid==='5y'){ fromDate.setFullYear(fromDate.getFullYear()-5); }
          else { mainChart.timeScale().fitContent(); return; }
          function toYMD(d){const y=d.getFullYear();const m=('0'+(d.getMonth()+1)).slice(-2);const dd=('0'+d.getDate()).slice(-2);return y+'-'+m+'-'+dd;}
          const fromStr= toYMD(fromDate);
          if(fromStr<allTimes[0]){
            mainChart.timeScale().fitContent();
            return;
          }
          let fromIndex= allTimes.findIndex(t=>t>=fromStr);
          if(fromIndex<0) fromIndex=0;
          const toIndex= allTimes.length-1;
          mainChart.timeScale().setVisibleLogicalRange({from: fromIndex, to: toIndex});
        }
        document.querySelector('button[data-range="all"]').classList.add('selected');
        // Toggles
        const seriesTogglesDiv = document.getElementById('series-toggles');
        mainSeriesObjs.forEach((obj,i)=>{
          const s= seriesList[i];
          const item= document.createElement('div');
          item.className= 'toggle-item' + (s.visible ? '' : ' disabled');
          item.dataset.seriesIndex= i;
          item.innerHTML= '<div class="toggle-color-box" style="background:'+s.color+';"></div><span>'+_escapeHtml(s.label)+'</span>';
          item.addEventListener('click', ()=>{
            const isVisible= obj.series.options().visible;
            obj.series.applyOptions({ visible: !isVisible });
            item.classList.toggle('disabled', isVisible);
          });
          seriesTogglesDiv.appendChild(item);
        });
        // Crosshair tooltip
        const multiTooltip= document.getElementById('multi-tooltip');
        mainChart.subscribeCrosshairMove(param=>{
          if(!param.point || !param.time){
            multiTooltip.style.display='none';
            return;
          }
          const dateStr= param.time;
          let lines=['<strong>'+dateStr+'</strong>'];
          mainSeriesObjs.forEach(({label,series})=>{
            if(series.options().visible){
              const idx= series.data().findIndex(d=>d.time===dateStr);
              if(idx>=0){
                const val= series.data()[idx].value;
                lines.push('<span style="color:'+series.options().lineColor+'">'+label+': '+val.toFixed(2)+' B\$</span>');
              }
            }
          });
          if(lines.length<=1){
            multiTooltip.style.display='none';
            return;
          }
          multiTooltip.innerHTML= lines.join('<br/>');
          multiTooltip.style.display='block';
          const rect= mainChartEl.getBoundingClientRect();
          const x= param.point.x; // rect.left + param.point.x;
          const y= param.point.y; // rect.top + param.point.y;
          multiTooltip.style.left= x+'px';
          multiTooltip.style.top = y+'px';
        });


        // Blocco scorrimento
        let currentValidRange= mainChart.timeScale().getVisibleLogicalRange() || {from:0,to:allTimes.length-1};
        mainChart.timeScale().subscribeVisibleLogicalRangeChange((newRange)=>{
          if(!newRange) return;
          const clamped= clampRange(newRange,0,allTimes.length-1);
          if(clamped.from!==newRange.from||clamped.to!==newRange.to){
            mainChart.timeScale().setVisibleLogicalRange(currentValidRange);
          } else {
            currentValidRange= newRange;
          }
        });
        // Resize
        window.addEventListener('resize', ()=>{
          const cw= mainChartEl.clientWidth;
          const ch= mainChartEl.clientHeight;
          mainChart.applyOptions({width:cw,height:ch});
          const nw= navChartEl.clientWidth;
          const nh= navChartEl.clientHeight;
          navChart.applyOptions({width:nw,height:nh});
          updateNavRectangle();
        });
        // Data Table
        buildDataTable(); // costruiamo l'header e righe
        function buildDataTable(){
          // Header con "Date" + col per ogni serie
          const thr= document.getElementById('table-header-row');
          thr.innerHTML= '<th>Date</th>';
          seriesList.forEach(s=>{
            thr.innerHTML+= '<th>'+_escapeHtml(s.label)+'</th>';
          });
          // Body
          const tbody= document.getElementById('data-table-body');
          tbody.innerHTML= '';
          // Creiamo una "mappa" per ogni series
          const dataMaps= seriesList.map(s=>{
            const map={};
            s.data.forEach(dp=> map[dp.time]= dp.value);
            return map;
          });
          allTimes.forEach(time=>{
            const tr= document.createElement('tr');
            let row= '<td>'+ time + '</td>';
            dataMaps.forEach((map,i)=>{
              const v= map[time];
              row+= '<td>'+(v!==undefined ? v.toFixed(2) : '-')+'</td>';
            });
            tr.innerHTML= row;
            tbody.appendChild(tr);
          });
        }
        // Bottoni "DATA"
        const dataTableContainer= document.getElementById('data-table-container');
        const btnShowData= document.getElementById('btn-show-data');
        const btnCloseTable= document.getElementById('btn-close-table');
        const btnDownloadCsv= document.getElementById('btn-download-csv');
        btnShowData.addEventListener('click', ()=>{
          document.getElementById('main-chart').style.display='none';
          document.getElementById('navigator-chart').style.display='none';
          document.getElementById('range-buttons').style.display='none';
          document.getElementById('series-toggles').style.display='none';
          document.getElementById('multi-tooltip').style.display='none';
          document.getElementById('data-button-container').style.display='none';
          dataTableContainer.style.display='block';
        });
        btnCloseTable.addEventListener('click',()=>{
          dataTableContainer.style.display='none';
          document.getElementById('main-chart').style.display='block';
          document.getElementById('navigator-chart').style.display='block';
          document.getElementById('range-buttons').style.display='grid';
          document.getElementById('series-toggles').style.display='flex';
          document.getElementById('data-button-container').style.display='block';
        });
        btnDownloadCsv.addEventListener('click',()=>{
          // CSV con header: Date, Label1, Label2, ...
          let csvContent= 'Date';
          seriesList.forEach(s=>{
            csvContent+= ','+s.label;
          });
          csvContent+='\\n';
          const dataMaps= seriesList.map(s=>{
            const map={};
            s.data.forEach(dp=> map[dp.time]= dp.value);
            return map;
          });
          allTimes.forEach(time=>{
            csvContent+= time;
            dataMaps.forEach((map,i)=>{
              const v= map[time];
              csvContent+= ','+(v!==undefined ? v.toFixed(2) : '');
            });
            csvContent+='\\n';
          });
          const blob= new Blob([csvContent],{type:'text/csv;charset=utf-8;'});
          const url= URL.createObjectURL(blob);
          const tempLink= document.createElement('a');
          tempLink.href= url;
          tempLink.setAttribute('download','multi_series_data.csv');
          tempLink.style.display='none';
          document.body.appendChild(tempLink);
          tempLink.click();
          document.body.removeChild(tempLink);
          URL.revokeObjectURL(url);
        });
      });
      // ESCAPE
      function _escapeHtml(s){
        return s.replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;');
      }
    })();
  </script>
</body>
</html>
''';
  }

  /// Costruisce l'array JS di serie, simulando dati se serve.
  String _buildSeriesJsArray(List<SeriesData> series, bool simulate) {
    final buffer = StringBuffer();
    buffer.write('[');
    for (int i = 0; i < series.length; i++) {
      final s = series[i];
      // Se data è nulla (o vuota) e simulateIfNoData, generiamo
      final dataList = (s.data == null || s.data!.isEmpty)
          ? (simulate ? _simulateData() : <PricePoint>[])
          : s.data!;
      // Convertiamolo in JS
      final dataJs = _pricePointsToJs(dataList);
      final visibleStr = s.visible ? 'true' : 'false';
      buffer.write('{ ');
      buffer.write('"label":"${_escapeJs(s.label)}", ');
      buffer.write('"color":"${_escapeJs(s.colorHex)}", ');
      buffer.write('"visible":$visibleStr, ');
      buffer.write('"data":$dataJs ');
      buffer.write('}');
      if (i < series.length - 1) {
        buffer.write(', ');
      }
    }
    buffer.write(']');
    return buffer.toString();
  }

  /// Simula dati mensili dal 2016 al 2025 con partenza 50.
  List<PricePoint> _simulateData() {
    final List<PricePoint> result = [];
    DateTime current = DateTime(2016, 1, 1);
    final end = DateTime(2025, 12, 31);
    double value = 50.0;
    while (!current.isAfter(end)) {
      final timeStr = '${current.year}-${_twoDigits(current.month)}-01';
      result.add(PricePoint(timeStr, value.clamp(0.0, double.infinity)));
      // random
      final rnd = (DateTime.now().microsecondsSinceEpoch % 1000) / 1000.0 - 0.5;
      value += (rnd * 10);
      current = DateTime(current.year, current.month + 1, 1);
    }
    return result;
  }

  String _twoDigits(int v) => v < 10 ? '0$v' : '$v';

  /// Converte PricePoint[] in un array JS
  String _pricePointsToJs(List<PricePoint> points) {
    final sb = StringBuffer();
    sb.write('[');
    for (int i = 0; i < points.length; i++) {
      final p = points[i];
      final t = _escapeJs(p.time);
      sb.write('{ time: \'$t\', value: ${p.value} }');
      if (i < points.length - 1) sb.write(', ');
    }
    sb.write(']');
    return sb.toString();
  }

  /// Escape per stringhe in contesto JS
  String _escapeJs(String s) {
    return s
        .replaceAll('\\', '\\\\')
        .replaceAll('\'', '\\\'');
  }
}
