import 'dart:html' as html;
import 'dart:ui' as ui;

import 'package:flutter/widgets.dart';

/// Tipi di serie supportati.
/// In Lightweight Charts v4, i metodi di creazione sono:
/// - addLineSeries(...)         // per line
/// - addAreaSeries(...)         // per area
/// - addBarSeries(...)          // per bar (OHLC)
/// - addCandlestickSeries(...)  // per candele classiche
/// - addHistogramSeries(...)    // per istogramma
///
/// (Puoi aggiungere anche 'baseline' con addBaselineSeries(...) se ti serve)
enum SeriesType {
  line,
  area,
  bar,
  candlestick,
  histogram,
  // se vuoi, potresti aggiungere baseline, etc...
}

/// Rappresenta un singolo punto dati su cui può basarsi la serie.
/// "time" dev'essere in formato "yyyy-MM-dd".
///
/// - Se la serie è 'line', 'area', 'histogram', useremo `value`.
/// - Se la serie è 'bar' o 'candlestick', useremo i campi O/H/L/C:
///   open, high, low, close.
///
/// Se una serie line/area/histogram legge O/H/L/C, semplicemente ignora i campi
/// e usa `value`.
/// Viceversa, se una serie bar/candlestick trova i campi O/H/L/C, li usa. Se
/// mancano, la serie potrebbe non disegnarsi correttamente.
class ChartDataPoint {
  final String time;

  /// Per line/area/histogram
  final double? value;

  /// Per bar/candlestick
  final double? open;
  final double? high;
  final double? low;
  final double? close;

  ChartDataPoint({
    required this.time,
    this.value,
    this.open,
    this.high,
    this.low,
    this.close,
  });
}

/// Rappresenta i parametri di una singola serie.
///
/// - [label]: etichetta da mostrare in toggles e tabella
/// - [colorHex]: colore principale (in hex, es "#d9534f")
/// - [data]: la lista di punti. Vedi [ChartDataPoint].
/// - [visible]: se la serie è inizialmente visibile
/// - [seriesType]: uno dei valori definito in [SeriesType] (line, area, bar, candlestick, histogram).
/// - [customOptions]: mappa di opzioni addizionali. Ad es.:
///       {
///         'upColor': '#00ff00',
///         'downColor': '#ff0000',
///         'borderVisible': true,
///         'lineWidth': 3,
///         'priceFormat': {...},
///         ...
///       }
///   Queste opzioni, se specificate, verranno passate così come sono a
///   LightweightCharts quando creiamo la serie. Serve per personalizzare
///   parametri come upColor/downColor di una candlestick, lineWidth di una line, base di un histogram, ecc.
class SeriesData {
  final String label;
  final String colorHex;
  final List<ChartDataPoint>? data;
  final bool visible;

  final SeriesType seriesType;

  /// Opzioni extra per la creazione della serie (passate a addXxxSeries).
  /// Utile per parametri specifici (es. candlestick: upColor/downColor, bar: thinBars, histogram: base, ecc.)
  final Map<String, dynamic> customOptions;

  SeriesData({
    required this.label,
    required this.colorHex,
    this.data,
    this.visible = true,
    this.seriesType = SeriesType.area, // default
    this.customOptions = const {},
  });
}

/// Rappresenta un divisore verticale.
/// [time] in "yyyy-MM-dd"
/// [colorHex] colore, es "#ff0000"
/// [leftLabel], [rightLabel] eventuali stringhe mostrate in alto (sinistra/destra della linea)
class VerticalDividerData {
  final String time;
  final String colorHex;
  final String leftLabel;
  final String rightLabel;

  VerticalDividerData({
    required this.time,
    required this.colorHex,
    required this.leftLabel,
    required this.rightLabel,
  });
}

/// Un widget Flutter che incapsula un IFrame con Lightweight Charts v4,
/// gestendo:
/// - Serie multiple (vari tipi: line, area, bar, candlestick, histogram)
/// - toggles di visibilità
/// - range buttons (1m,3m,1y,3y,5y,all)
/// - navigator (chart piccolo in basso)
/// - crosshair tooltip
/// - tabella dati (con "DATA" e "Download CSV")
/// - divisori verticali personalizzati
///
/// Funziona solo su Flutter Web.
class MultiSeriesLightweightChartWidget extends StatelessWidget {
  final String title;
  final List<SeriesData> seriesList;
  final bool simulateIfNoData;
  final double width;
  final double height;

  final List<VerticalDividerData> verticalDividers;

  MultiSeriesLightweightChartWidget({
    Key? key,
    required this.title,
    required this.seriesList,
    this.simulateIfNoData = false,
    this.width = 1200,
    this.height = 700,
    this.verticalDividers = const [],
  }) : super(key: key) {
    // 1) Creiamo l'id univoco del widget
    final String viewId = 'multi-series-charts-${DateTime.now().millisecondsSinceEpoch}';
    _viewId = viewId;

    // 2) Convertiamo la lista di serie e divisori in JS
    final String seriesJsArray = _buildSeriesJsArray(seriesList, simulateIfNoData);
    final String verticalDividersJsArray = _buildVerticalDividersJsArray(verticalDividers);

    // 3) Costruiamo l'HTML
    final String htmlContent = _buildHtmlContent(
      title,
      seriesJsArray,
      verticalDividersJsArray,
    );

    // 4) Creiamo un Blob + URL
    final blob = html.Blob([htmlContent], 'text/html');
    final url = html.Url.createObjectUrlFromBlob(blob);

    // 5) Creiamo l'iFrame
    final html.IFrameElement iFrameElement = html.IFrameElement()
      ..src = url
      ..style.border = 'none'
      ..width = '100%'
      ..height = '100%';

    // 6) Registriamo la view
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

  /// Costruisce l'HTML completo da iniettare,
  /// integrando il supporto ai diversi tipi di serie e le opzioni custom.
  String _buildHtmlContent(
    String title,
    String seriesJsArray,
    String verticalDividersJsArray,
  ) {
    // Tutto l'HTML + CSS + script
    // A differenza della versione base, in JavaScript vedrai un "createSeries(...)" con uno switch
    // su seriesType, e passiamo anche le opzioni custom.
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
    /* Contenitore per le linee verticali e label */
    #vertical-dividers-container {
      position: absolute;
      top: 0;
      left: 0;
      width: 100%;
      height: 100%;
      pointer-events: none;
      overflow: visible;
      z-index: 9999;
    }
    .vertical-divider-line {
      position: absolute;
      top: 0;
      width: 2px;
      height: 100%;
      background-color: #ff0000;
    }
    .vertical-divider-label-left,
    .vertical-divider-label-right {
      position: absolute;
      top: 0;
      color: #fff;
      background: rgba(0,0,0,0.7);
      padding: 2px 6px;
      border-radius: 4px;
      white-space: nowrap;
      font-size: 12px;
    }
    .vertical-divider-label-left {
      transform: translate(-130%, 0px);
    }
    .vertical-divider-label-right {
      transform: translate(30%, 0px);
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
    <div id="main-chart">
      <!-- container per linee verticali -->
      <div id="vertical-dividers-container"></div>
    </div>
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
      const seriesList = $seriesJsArray; // array di serie (label, color, visible, data, seriesType, customOptions)
      const verticalDividers = $verticalDividersJsArray; // array di divisori verticali

      // parseYMD e clampRange come prima
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

      // uniamo i time di tutte le serie per la tabella
      let allTimesSet = new Set();
      seriesList.forEach(s => {
        s.data.forEach(dp => {
          allTimesSet.add(dp.time);
        });
      });
      let allTimes = Array.from(allTimesSet).sort();

      // crea la chart principale
      let mainChartEl, navChartEl, mainChart, navChart;
      window.addEventListener('DOMContentLoaded', () => {
        mainChartEl = document.getElementById('main-chart');
        navChartEl  = document.getElementById('navigator-chart');

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

        // crea la chart del navigator
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

        // Funzione per creare una singola serie sul chart
        function createSeriesOnChart(chart, s) {
          // s contiene: label, color, visible, data, seriesType, customOptions
          // doc: https://tradingview.github.io/lightweight-charts/docs/api#series
          let series;
          // costruiamo un oggetto di opzioni base
          // es. color = s.color + '???' ecc.
          // Poi uniamo customOptions
          let baseOptions = {
            visible: s.visible,
            // color se serve...
            // Se la serie è line/area, potremmo impostare "lineColor: s.color"
            //   e "topColor, bottomColor" se area, ecc.
            // Vedrai che alcuni parametri si setteranno a runtime:
          };

          // unisci (merge) baseOptions + s.customOptions
          // con un banale shallow copy
          for (let k in s.customOptions) {
            baseOptions[k] = s.customOptions[k];
          }

          // se la serieType è area/line e non hai upColor,downColor, ecc.
          // Invece se candlestick, potresti volere upColor/downColor/etc
          switch (s.seriesType) {
            case 'line':
              series = chart.addLineSeries({
                lineColor: s.color,
                lineWidth: 2,
                lastValueVisible: false,
                priceLineVisible: false,
                ...baseOptions,
              });
              break;

            case 'bar':
              // bar series (richiede open, high, low, close)
              // vedi doc: addBarSeries
              series = chart.addBarSeries({
                // es. thinBars: true,
                // upColor, downColor se serve...
                ...baseOptions,
              });
              break;

            case 'candlestick':
              // candlestick series
              // ex. upColor, downColor, borderUpColor, borderDownColor, wickUpColor, wickDownColor
              series = chart.addCandlestickSeries({
                // se non specificate, potresti usare s.color come "borderUpColor" ecc.
                // upColor: '#00ff00',
                // downColor: '#ff0000',
                // etc...
                lastValueVisible: false,
                priceLineVisible: false,
                ...baseOptions,
              });
              break;

            case 'histogram':
              series = chart.addHistogramSeries({
                color: s.color,
                lastValueVisible: false,
                priceLineVisible: false,
                ...baseOptions,
              });
              break;

            case 'area':
            default:
              series = chart.addAreaSeries({
                topColor: s.color + '33',
                bottomColor: s.color + '00',
                lineColor: s.color,
                lineWidth: 2,
                lastValueVisible: false,
                priceLineVisible: false,
                ...baseOptions,
              });
              break;
          }
          // adesso settiamo i dati
          // se la serie è bar/candlestick, i dati richiedono { time, open, high, low, close }.
          // se line/area/histogram => { time, value }.
          // gestiamolo:
          const dataForChart = s.data.map(dp => {
            if (s.seriesType === 'bar' || s.seriesType === 'candlestick') {
              return {
                time: dp.time,
                open: dp.open,
                high: dp.high,
                low: dp.low,
                close: dp.close
              };
            } else {
              // line, area, histogram
              return {
                time: dp.time,
                value: dp.value
              };
            }
          });
          series.setData(dataForChart);
          return series;
        }

        const mainSeriesObjs = [];
        seriesList.forEach(s => {
          const created = createSeriesOnChart(mainChart, s);
          mainSeriesObjs.push({
            label: s.label,
            series: created,
            color: s.color,
            // keep data for crosshair, etc.
            data: s.data
          });
        });

        mainChart.timeScale().fitContent();

        // Nel navigator, per semplicità, disegniamo tutte come area
        seriesList.forEach(s => {
          // potresti farlo con un if s.seriesType => create different
          // ma qui lo semplifichiamo
          const navSeries = navChart.addAreaSeries({
            topColor: s.color + '33',
            bottomColor: s.color + '00',
            lineColor: s.color,
            lineWidth: 1,
            lastValueVisible: false,
            priceLineVisible: false,
          });
          // mappiamo data in { time, value } ignoring OHLC
          const navData = s.data.map(dp => ({
            time: dp.time,
            value: dp.value ?? dp.close ?? 0,
          }));
          navSeries.setData(navData);
        });

        navChart.timeScale().fitContent();

        // Funzioni range, toggles, crosshair, resizing, vertical dividers, etc...
        // identiche a prima:

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
          else {
            mainChart.timeScale().fitContent();
            return;
          }
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
          item.innerHTML= '<div class="toggle-color-box" style="background:'+obj.color+';"></div><span>'+_escapeHtml(s.label)+'</span>';
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
          mainSeriesObjs.forEach(({label,series,data,color})=>{
            if(series.options().visible){
              const idx= data.findIndex(d=>d.time===dateStr);
              if(idx>=0){
                const dp = data[idx];
                // se la serie è line/area/histogram => dp.value
                // se bar/candle => O/H/L/C
                let strVal = '';
                if (dp.open!==undefined && dp.high!==undefined && dp.low!==undefined && dp.close!==undefined) {
                  strVal = 'O:'+dp.open.toFixed(2)+' H:'+dp.high.toFixed(2)+' L:'+dp.low.toFixed(2)+' C:'+dp.close.toFixed(2);
                } else if (dp.value!==undefined) {
                  strVal = dp.value.toFixed(2);
                } else {
                  strVal = '???';
                }
                lines.push('<span style="color:'+color+'">'+label+': '+ strVal +' B\$</span>');
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
          const x= param.point.x;
          const y= param.point.y;
          multiTooltip.style.left= x+'px';
          multiTooltip.style.top = y+'px';
        });

        // scroll clamp
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

        // resize
        window.addEventListener('resize', ()=>{
          const cw= mainChartEl.clientWidth;
          const ch= mainChartEl.clientHeight;
          mainChart.applyOptions({width:cw,height:ch});
          const nw= navChartEl.clientWidth;
          const nh= navChartEl.clientHeight;
          navChart.applyOptions({width:nw,height:nh});
          updateNavRectangle();
          updateVerticalDividers();
        });

        // vertical dividers
        const verticalDividersContainer = document.getElementById('vertical-dividers-container');
        const dividerElems = [];
        verticalDividers.forEach((vd, idx)=>{
          const lineEl = document.createElement('div');
          lineEl.className = 'vertical-divider-line';
          lineEl.style.backgroundColor = vd.colorHex;
          verticalDividersContainer.appendChild(lineEl);

          const labelLeftEl = document.createElement('div');
          labelLeftEl.className = 'vertical-divider-label-left';
          labelLeftEl.style.backgroundColor = 'rgba(0,0,0,0.7)';
          labelLeftEl.style.display = (vd.leftLabel.trim().length>0 ? 'block' : 'none');
          labelLeftEl.innerText = vd.leftLabel;
          verticalDividersContainer.appendChild(labelLeftEl);

          const labelRightEl = document.createElement('div');
          labelRightEl.className = 'vertical-divider-label-right';
          labelRightEl.style.backgroundColor = 'rgba(0,0,0,0.7)';
          labelRightEl.style.display = (vd.rightLabel.trim().length>0 ? 'block' : 'none');
          labelRightEl.innerText = vd.rightLabel;
          verticalDividersContainer.appendChild(labelRightEl);

          dividerElems.push({
            time: vd.time,
            lineEl,
            labelLeftEl,
            labelRightEl,
          });
        });

        function updateVerticalDividers(){
          dividerElems.forEach(de => {
            const xCoord = mainChart.timeScale().timeToCoordinate(de.time);
            if(xCoord===null) {
              de.lineEl.style.display='none';
              de.labelLeftEl.style.display='none';
              de.labelRightEl.style.display='none';
              return;
            }
            de.lineEl.style.display='block';
            de.lineEl.style.left = xCoord+'px';

            if(de.labelLeftEl.innerText.trim().length>0){
              de.labelLeftEl.style.display='block';
              de.labelLeftEl.style.left = xCoord+'px';
            }
            if(de.labelRightEl.innerText.trim().length>0){
              de.labelRightEl.style.display='block';
              de.labelRightEl.style.left = xCoord+'px';
            }
          });
        }
        mainChart.timeScale().subscribeVisibleTimeRangeChange(updateVerticalDividers);
        updateVerticalDividers();

        // data table
        buildDataTable();
        function buildDataTable(){
          const thr= document.getElementById('table-header-row');
          thr.innerHTML= '<th>Date</th>';
          seriesList.forEach(s=>{
            thr.innerHTML+= '<th>'+_escapeHtml(s.label)+'</th>';
          });
          const tbody= document.getElementById('data-table-body');
          tbody.innerHTML= '';
          // costruiamo mappa time-> value (o close) per visualizzare
          // (bar/candle => close, line => value, etc.)
          // ma potresti anche mostrare open, high, low, close se preferisci
          // qui semplifichiamo e mostriamo "value" o "close".
          const dataMaps= seriesList.map(s=>{
            const map={};
            s.data.forEach(dp=>{
              let val = 0;
              if(s.seriesType==='bar' || s.seriesType==='candlestick'){
                val = dp.close ?? 0;
              } else {
                val = dp.value ?? 0;
              }
              map[dp.time]= val;
            });
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

        // pulsanti "DATA" e "download CSV"
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
          let csvContent= 'Date';
          seriesList.forEach(s=>{
            csvContent+= ','+s.label;
          });
          csvContent+='\\n';
          const dataMaps= seriesList.map(s=>{
            const map={};
            s.data.forEach(dp=>{
              let val=0;
              if(s.seriesType==='bar' || s.seriesType==='candlestick'){
                val = dp.close ?? 0;
              } else {
                val = dp.value ?? 0;
              }
              map[dp.time]= val;
            });
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

      function _escapeHtml(s){
        return s.replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;');
      }
    })();
  </script>
</body>
</html>
''';
  }

  /// Costruisce il JSON di "seriesList"
  /// Se [simulateIfNoData] è true, generiamo dati fittizi se la serie non ne ha.
  String _buildSeriesJsArray(List<SeriesData> series, bool simulate) {
    final buffer = StringBuffer();
    buffer.write('[');
    for (int i = 0; i < series.length; i++) {
      final s = series[i];

      // Se i dati sono vuoti e simulateIfNoData è true, generiamo dati
      final dataList = (s.data == null || s.data!.isEmpty)
          ? (simulate ? _simulateDataForSeriesType(s.seriesType) : <ChartDataPoint>[])
          : s.data!;

      // costruiamo un array di {time, value, open, high, low, close}
      final dataJs = _pointsToJs(dataList, s.seriesType);

      final visibleStr = s.visible ? 'true' : 'false';
      final stype = s.seriesType.toString().split('.').last; // es. SeriesType.area => "area"

      // serializziamo la customOptions come un oggetto JS
      final customOptionsJs = _mapToJsObject(s.customOptions);

      buffer.write('{ ');
      buffer.write('"label":"${_escapeJs(s.label)}", ');
      buffer.write('"color":"${_escapeJs(s.colorHex)}", ');
      buffer.write('"visible":$visibleStr, ');
      buffer.write('"seriesType":"$stype", ');
      buffer.write('"customOptions":$customOptionsJs, ');
      buffer.write('"data":$dataJs ');
      buffer.write('}');
      if (i < series.length - 1) {
        buffer.write(', ');
      }
    }
    buffer.write(']');
    return buffer.toString();
  }

  /// Converte la mappa (Dart) in un oggetto JS
  /// Esempio: { upColor: "#00ff00", lineWidth: 3 } => { "upColor":"#00ff00","lineWidth":3 }
  String _mapToJsObject(Map<String, dynamic> map) {
    if (map.isEmpty) {
      return '{}';
    }
    final sb = StringBuffer();
    sb.write('{');
    int idx = 0;
    map.forEach((key, value) {
      sb.write('"${_escapeJs(key)}":');
      if (value is num || value is bool) {
        sb.write('$value');
      } else {
        // lo consideriamo stringa
        sb.write('"${_escapeJs(value.toString())}"');
      }
      if (idx < map.length - 1) {
        sb.write(',');
      }
      idx++;
    });
    sb.write('}');
    return sb.toString();
  }

  /// Converte la lista di ChartDataPoint in array JS.
  /// Ogni oggetto avrà { time: 'yyyy-mm-dd', value: X } se line/histogram
  /// oppure { time, open, high, low, close } se bar/candlestick.
  String _pointsToJs(List<ChartDataPoint> points, SeriesType stype) {
    final sb = StringBuffer();
    sb.write('[');
    for (int i = 0; i < points.length; i++) {
      final p = points[i];
      if (stype == SeriesType.bar || stype == SeriesType.candlestick) {
        // OHLC
        sb.write('{ ');
        sb.write('time:"${_escapeJs(p.time)}", ');
        sb.write('open:${p.open ?? 0}, ');
        sb.write('high:${p.high ?? 0}, ');
        sb.write('low:${p.low ?? 0}, ');
        sb.write('close:${p.close ?? 0} ');
        sb.write('}');
      } else {
        // line, area, histogram => { time, value }
        sb.write('{ ');
        sb.write('time:"${_escapeJs(p.time)}", ');
        sb.write('value:${p.value ?? 0} ');
        sb.write('}');
      }
      if (i < points.length - 1) sb.write(', ');
    }
    sb.write(']');
    return sb.toString();
  }

  /// Simula dati in base al seriesType
  /// - se bar/candlestick => generiamo O/H/L/C
  /// - se line/area/histogram => generiamo un singolo "value"
  List<ChartDataPoint> _simulateDataForSeriesType(SeriesType stype) {
    switch (stype) {
      case SeriesType.bar:
      case SeriesType.candlestick:
        return _simulateOhlcData();
      case SeriesType.histogram:
      case SeriesType.line:
      case SeriesType.area:
      default:
        return _simulateValueData();
    }
  }

  /// Simula dati mensili dal 2016 al 2025 con partenza ~50, single value
  List<ChartDataPoint> _simulateValueData() {
    final List<ChartDataPoint> result = [];
    DateTime current = DateTime(2016, 1, 1);
    final end = DateTime(2025, 12, 31);
    double value = 50.0;
    while (!current.isAfter(end)) {
      final timeStr = '${current.year}-${_twoDigits(current.month)}-01';
      result.add(ChartDataPoint(time: timeStr, value: value.clamp(0.0, double.infinity)));
      final rnd = (DateTime.now().microsecondsSinceEpoch % 1000) / 1000.0 - 0.5;
      value += (rnd * 10);
      current = DateTime(current.year, current.month + 1, 1);
    }
    return result;
  }

  /// Simula dati mensili dal 2016 al 2025 con partenza ~50, generando open/high/low/close
  List<ChartDataPoint> _simulateOhlcData() {
    final List<ChartDataPoint> result = [];
    DateTime current = DateTime(2016, 1, 1);
    final end = DateTime(2025, 12, 31);
    double baseVal = 50.0;
    while (!current.isAfter(end)) {
      final timeStr = '${current.year}-${_twoDigits(current.month)}-01';
      // generiamo open, high, low, close in modo casuale
      final rnd1 = (DateTime.now().microsecondsSinceEpoch % 1000) / 1000.0; // 0..1
      final open = baseVal + (rnd1 - 0.5) * 4;
      final rnd2 = ((current.microsecondsSinceEpoch) % 1000) / 1000.0; // 0..1
      final close = open + (rnd2 - 0.5) * 6;
      final high = (open > close ? open : close) + 3;
      final low = (open < close ? open : close) - 3;

      result.add(ChartDataPoint(
        time: timeStr,
        open: open,
        high: high,
        low: low,
        close: close,
      ));

      // aggiorniamo baseVal
      baseVal = close;
      current = DateTime(current.year, current.month + 1, 1);
    }
    return result;
  }

  String _twoDigits(int v) => v < 10 ? '0$v' : '$v';

  /// Costruisce l'array JSON dei divisori verticali
  String _buildVerticalDividersJsArray(List<VerticalDividerData> dividers) {
    final buffer = StringBuffer();
    buffer.write('[');
    for (int i = 0; i < dividers.length; i++) {
      final d = dividers[i];
      buffer.write('{ ');
      buffer.write('"time":"${_escapeJs(d.time)}", ');
      buffer.write('"colorHex":"${_escapeJs(d.colorHex)}", ');
      buffer.write('"leftLabel":"${_escapeJs(d.leftLabel)}", ');
      buffer.write('"rightLabel":"${_escapeJs(d.rightLabel)}" ');
      buffer.write('}');
      if (i < dividers.length - 1) buffer.write(', ');
    }
    buffer.write(']');
    return buffer.toString();
  }

  /// Escape per stringhe in contesto JS
  String _escapeJs(String s) {
    return s.replaceAll('\\', '\\\\').replaceAll('\'', '\\\'');
  }
}
