import 'dart:html' as html;
import 'dart:ui' as ui;

import 'package:flutter/widgets.dart';

/// Rappresenta un punto prezzo (time, value).
class PricePoint {
  final String time; // Formato 'yyyy-MM-dd'
  final double value;
  PricePoint(this.time, this.value);
}

/// Rappresenta un evento (es. 'Dividendo: testo') associato a una data.
class DateEvent {
  final String date; // 'yyyy-MM-dd'
  final String label; // 'Dividendo: Testo...'
  DateEvent(this.date, this.label);
}

/// Widget che integra uno script HTML di Lightweight Charts
/// con:
/// - Grafico principale + Navigator
/// - Markers di eventi
/// - Pulsanti di range (1M,3M,1Y,...)
/// - Tabella dati con pulsante "DATA" e "Download CSV"
///
/// NOTA: Funziona SOLO su Flutter Web.
class LightweightChartsWidget extends StatelessWidget {
  final String title; // Titolo mostrato in <h1>
  final List<PricePoint> dailyData; // Dati prezzo
  final List<DateEvent> events;     // Elenco di eventi, ognuno con date e label
  final double width;
  final double height;

  /// Costruttore del widget, parametri minimi per la demo
  LightweightChartsWidget({
    Key? key,
    required this.title,
    required this.dailyData,
    required this.events,
    this.width = 1200,
    this.height = 800,  // include spazi per tabella etc.
  }) : super(key: key) {
    // Generiamo un ID univoco per l'iframe (sufficiente)
    final String viewId = 'lw-charts-${DateTime.now().millisecondsSinceEpoch}';
    _viewId = viewId;

    // Convertiamo dailyData in JS array
    // Esempio: [ { time: '2020-01-01', value: 123.45 }, ... ]
    final String dailyDataJs = _convertDailyDataToJsArray(dailyData);

    // Creiamo una mappa {date -> List<string>} con gli "Eventi"
    // Per semplificare, simile a eventsByDate del tuo script
    final Map<String, List<String>> eventsByDate = {};
    for (final ev in events) {
      eventsByDate.putIfAbsent(ev.date, () => []).add(ev.label);
    }
    final String eventsByDateJs = _convertEventsToJsMap(eventsByDate);

    // Ora incolliamo tutto il tuo HTML in una stringa, con i placeholder
    // Ci assicuriamo di:
    // - Inserire dailyDataJs al posto di "generateDailyData"
    // - Inserire eventsByDateJs al posto di "eventsByDate"
    // - Sostituire il "title" in <h1>
    // - Mantenere l'intero script e stile (non tralasciare nulla).
    // - NB: dimensioni width/height fisse: 1200, 400 ecc. potresti anche
    //   farle parametriche, ma semplifichiamo.
    final String htmlContent = '''<!DOCTYPE html>
<html lang="it">
<head>
  <meta charset="UTF-8" />
  <title>${_escapeHtml(title)}</title>
  <style>
    body {
      background: #1e242c;
      margin: 0;
      padding: 0;
      font-family: sans-serif;
      color: #fff;
    }

    /* Titolo allineato a sinistra ma “bloccato” alla stessa larghezza del grafico (1200px) */
    h1 {
      width: 1200px;
      margin: 20px auto 10px auto;
      text-align: left;
    }

    /* Pulsanti del range: stile “espanso” su 6 colonne con un po’ di padding e gap */
    #range-buttons {
      width: 1200px;
      margin: 0 auto 20px auto;
      display: grid;
      grid-template-columns: repeat(6, 1fr);
      gap: 10px;
    }
    #range-buttons button {
      background: #2b333d;
      color: #fff;
      border: 1px solid #444;
      padding: 8px;
      text-align: center;
      cursor: pointer;
      border-radius: 4px;
      font-size: 14px;
    }
    #range-buttons button:hover {
      background: #3e464f;
    }
    #range-buttons button.selected {
      background: #404854;
    }

#charts-container {
  width: 1200px;
  margin: 0 auto;
  position: relative;
+ /* Aggiungiamo padding interno per creare “spazio”
+    e assicuriamoci di contare il padding nel totale (box-sizing) */
+  padding: 20px;
+  box-sizing: border-box;
}
    #main-chart {
      width: 1200px;
      height: 400px;
      position: relative;
    }

    #navigator-chart {
      width: 1200px;
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

    #marker-tooltip {
      position: absolute;
      background: rgba(0, 0, 0, 0.8);
      color: #fff;
      padding: 6px 8px;
      font-size: 14px;
      border-radius: 4px;
      pointer-events: none;
      display: none;
      z-index: 999;
      max-width: 300px;
      text-align: center;
      white-space: pre-line;
      top: 0;
      left: 0;
    }

    #custom-legend {
      width: 1200px;
      margin: 10px auto 10px auto;
      display: flex;
      flex-wrap: wrap;
      gap: 20px;
      justify-content: flex-start;
    }
    .legend-item {
      display: flex;
      align-items: center;
      gap: 6px;
    }
    .legend-color {
      width: 12px;
      height: 12px;
      border-radius: 50%;
      display: inline-block;
    }

    #data-button-container {
      width: 1200px;
      margin: 0 auto 40px auto;
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
    }
    #btn-show-data:hover {
      background: #3e464f;
    }

    #data-table-container {
      display: none;
      width: 1200px;
      margin: 0 auto 40px auto;
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
  <h1>${_escapeHtml(title)}</h1>

  <!-- Pulsanti Range -->
  <div id="range-buttons">
    <button id="btn-1m">1M</button>
    <button id="btn-3m">3M</button>
    <button id="btn-1y">1Y</button>
    <button id="btn-3y">3Y</button>
    <button id="btn-5y">5Y</button>
    <button id="btn-all">Max</button>
  </div>

  <div id="charts-container">
    <!-- Chart principale -->
    <div id="main-chart"></div>

    <!-- Navigator (fisso su tutto il range) -->
    <div id="navigator-chart">
      <!-- Rettangolo indicatore -->
      <div id="navigator-rectangle"></div>
    </div>

    <!-- Tooltip per i marker -->
    <div id="marker-tooltip"></div>
  </div>

  <!-- Legenda personalizzata, allineata a sinistra -->
  <div id="custom-legend">
    <div class="legend-item">
      <span class="legend-color" style="background: #58D68D;"></span>
      <span>Dividendo</span>
    </div>
    <div class="legend-item">
      <span class="legend-color" style="background: #BB8FCE;"></span>
      <span>Finanziario</span>
    </div>
    <div class="legend-item">
      <span class="legend-color" style="background: #F5B041;"></span>
      <span>Gestione</span>
    </div>
    <div class="legend-item">
      <span class="legend-color" style="background: #5DADE2;"></span>
      <span>Strategia</span>
    </div>
    <div class="legend-item">
      <span class="legend-color" style="background: #BDC3C7;"></span>
      <span>Altro</span>
    </div>
  </div>

  <!-- Pulsante DATA -->
  <div id="data-button-container">
    <button id="btn-show-data">
      <span>📊</span>
      DATA
    </button>
  </div>

  <!-- Contenitore tabella -->
  <div id="data-table-container">
    <div id="data-table-header">
      <span class="title">Tabella Dati & Eventi</span>
      <button id="btn-close-table">X</button>
    </div>
    <div id="data-table-scroll">
      <table class="data-table" id="data-table">
        <thead>
          <tr>
            <th>Date</th>
            <th>Price</th>
            <th>Eventi</th>
          </tr>
        </thead>
        <tbody id="data-table-body">
        </tbody>
      </table>
    </div>
    <div id="download-button-container">
      <button id="btn-download-csv">Download CSV</button>
    </div>
  </div>

  <!-- Libreria Lightweight Charts v4 -->
  <script src="https://unpkg.com/lightweight-charts@4/dist/lightweight-charts.standalone.production.js"></script>

  <script>
    (function(){
      // Dati passati da Flutter (o da un tuo generatore):
      const dailyData = $dailyDataJs;
      const eventsByDate = $eventsByDateJs;

      window.addEventListener('DOMContentLoaded', () => {
        // FUNZIONI UTILI
        function parseYMD(str) {
          const [y, m, d] = str.split('-');
          return new Date(+y, +m - 1, +d);
        }

        function clampRange(range, min, max) {
          return {
            from: Math.max(range.from, min),
            to: Math.min(range.to, max),
          };
        }

        // CHART PRINCIPALE
        const mainChartEl = document.getElementById('main-chart');
        const mainChart = LightweightCharts.createChart(mainChartEl, {
          width: 1200,
          height: 400,
          layout: {
            background: { type: 'Solid', color: '#1e242c' },
            textColor: '#fff',
          },
          timeScale: {
            timeVisible: true,
            secondsVisible: false,
          },
          rightPriceScale: { visible: true },
          grid: {
            vertLines: { color: '#2B2B43', style: 0 },
            horzLines: { color: '#2B2B43', style: 0 },
          },
          crosshair: {
            vertLine: { labelVisible: true },
            horzLine: { labelVisible: true },
          },
        });

        const mainSeries = mainChart.addLineSeries({
          color: '#5f94f9',
          lineWidth: 2,
        });
        mainSeries.setData(dailyData);

        // COSTRUISCI MARKERS DA eventsByDate (opzionale, se vuoi)
        // Oppure se hai già un array di markers, potresti passarlo
        // Qui es. generico:
        const allMarkers = [];
        for (const date in eventsByDate) {
          const evList = eventsByDate[date];
          evList.forEach(evText => {
            allMarkers.push({
              time: date,
              position: 'aboveBar',
              color: '#58D68D',
              shape: 'circle',
              text: 'Ev',
              fullText: evText,
            });
          });
        }
        mainSeries.setMarkers(allMarkers);

        // NAVIGATOR
        const navChartEl = document.getElementById('navigator-chart');
        const navChart = LightweightCharts.createChart(navChartEl, {
          width: 1200,
          height: 80,
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
        const navSeries = navChart.addLineSeries({ color: '#ffffff', lineWidth: 1 });
        navSeries.setData(dailyData);
        navChart.timeScale().fitContent();

        // Rettangolo indicatore
        const navRectangle = document.getElementById('navigator-rectangle');
        function updateNavigatorRectangle() {
          const logicalRange = mainChart.timeScale().getVisibleLogicalRange();
          if (!logicalRange) {
            navRectangle.style.display = 'none';
            return;
          }
          let leftIndex = Math.floor(logicalRange.from);
          let rightIndex = Math.ceil(logicalRange.to);
          // Clip:
          leftIndex = Math.max(0, leftIndex);
          rightIndex = Math.min(dailyData.length - 1, rightIndex);

          const fromTime = dailyData[leftIndex].time;
          const toTime = dailyData[rightIndex].time;
          const fromX = navChart.timeScale().timeToCoordinate(fromTime);
          const toX = navChart.timeScale().timeToCoordinate(toTime);

          if (fromX === null || toX === null) {
            navRectangle.style.display = 'none';
            return;
          }

          let left = Math.min(fromX, toX);
          let width = Math.abs(toX - fromX);
          const containerWidth = navChartEl.offsetWidth;

          if (left < 0) {
            width += left;
            left = 0;
          }
          if (left + width > containerWidth) {
            width = containerWidth - left;
          }
          if (width <= 0) {
            navRectangle.style.display = 'none';
            return;
          }

          navRectangle.style.display = 'block';
          navRectangle.style.left = left + 'px';
          navRectangle.style.width = width + 'px';
          navRectangle.style.top = '0px';
          navRectangle.style.height = navChartEl.offsetHeight + 'px';
        }
        mainChart.timeScale().subscribeVisibleLogicalRangeChange(updateNavigatorRectangle);
        updateNavigatorRectangle();

        // TOOLTIP MARKER
        const markerTooltip = document.getElementById('marker-tooltip');
        const HOVER_THRESHOLD = 30;

        // Prepara un mappa {time -> value}
        const priceByTime = {};
        dailyData.forEach(dp => {
          priceByTime[dp.time] = dp.value;
        });

        mainChart.subscribeCrosshairMove(param => {
          if (!param.point || !param.sourceEvent) {
            markerTooltip.style.display = 'none';
            return;
          }
          const mouseX = param.point.x;
          const mouseY = param.point.y;
          const hoveredMarkers = [];
          for (const m of allMarkers) {
            const val = priceByTime[m.time];
            if (val === undefined) continue;
            const markerX = mainChart.timeScale().timeToCoordinate(m.time);
            const markerY = mainSeries.priceToCoordinate(val);
            if (markerX === null || markerY === null) continue;
            const dx = mouseX - markerX;
            const dy = mouseY - markerY;
            if (dx*dx + dy*dy <= HOVER_THRESHOLD*HOVER_THRESHOLD) {
              hoveredMarkers.push(m);
            }
          }
          if (hoveredMarkers.length === 0) {
            markerTooltip.style.display = 'none';
            return;
          }
          // Se si trovano uno o più marker ravvicinati
          // Costruiamo un testo multilinea
          const lines = hoveredMarkers.map(m => m.time + '\\n' + m.fullText);
          markerTooltip.textContent = lines.join('\\n\\n');
          markerTooltip.style.display = 'block';
          markerTooltip.style.left = '0px';
          markerTooltip.style.top = '0px';
        });

        // RANGE BUTTONS
        function setCustomRange(btnId) {
          document.querySelectorAll('#range-buttons button').forEach(b => b.classList.remove('selected'));
          const bEl = document.getElementById(btnId);
          if (bEl) bEl.classList.add('selected');

          if (btnId === 'btn-all') {
            mainChart.timeScale().fitContent();
            return;
          }

          const lastTime = dailyData[dailyData.length - 1].time;
          const now = parseYMD(lastTime);
          let fromDate = new Date(now);

          if (btnId === 'btn-1m') {
            fromDate.setMonth(fromDate.getMonth() - 1);
          } else if (btnId === 'btn-3m') {
            fromDate.setMonth(fromDate.getMonth() - 3);
          } else if (btnId === 'btn-1y') {
            fromDate.setFullYear(fromDate.getFullYear() - 1);
          } else if (btnId === 'btn-3y') {
            fromDate.setFullYear(fromDate.getFullYear() - 3);
          } else if (btnId === 'btn-5y') {
            fromDate.setFullYear(fromDate.getFullYear() - 5);
          } else {
            mainChart.timeScale().fitContent();
            return;
          }

          const yyyy = fromDate.getFullYear();
          const mm = String(fromDate.getMonth() + 1).padStart(2, '0');
          const dd = String(fromDate.getDate()).padStart(2, '0');
          const fromStr = yyyy + '-' + mm + '-' + dd;

          if (fromStr < dailyData[0].time) {
            mainChart.timeScale().fitContent();
            return;
          }

          let fromIndex = dailyData.findIndex(d => d.time >= fromStr);
          if (fromIndex < 0) fromIndex = 0;
          const toIndex = dailyData.length - 1;
          mainChart.timeScale().setVisibleLogicalRange({ from: fromIndex, to: toIndex });
        }

        document.getElementById('btn-1m').addEventListener('click', () => setCustomRange('btn-1m'));
        document.getElementById('btn-3m').addEventListener('click', () => setCustomRange('btn-3m'));
        document.getElementById('btn-1y').addEventListener('click', () => setCustomRange('btn-1y'));
        document.getElementById('btn-3y').addEventListener('click', () => setCustomRange('btn-3y'));
        document.getElementById('btn-5y').addEventListener('click', () => setCustomRange('btn-5y'));
        document.getElementById('btn-all').addEventListener('click', () => setCustomRange('btn-all'));

        // Di default "Max"
        setCustomRange('btn-all');

        // BLOCCO SCORRIMENTO
        let currentValidRange = mainChart.timeScale().getVisibleLogicalRange() || { from: 0, to: dailyData.length - 1 };
        mainChart.timeScale().subscribeVisibleLogicalRangeChange((newRange) => {
          if (!newRange) return;
          const clamped = clampRange(newRange, 0, dailyData.length - 1);
          if (clamped.from !== newRange.from || clamped.to !== newRange.to) {
            mainChart.timeScale().setVisibleLogicalRange(currentValidRange);
          } else {
            currentValidRange = newRange;
          }
        });

        // TABELLA DATI
        const dataButtonContainer = document.getElementById('data-button-container');
        const dataTableContainer = document.getElementById('data-table-container');
        const btnShowData = document.getElementById('btn-show-data');
        const btnCloseTable = document.getElementById('btn-close-table');
        const btnDownloadCsv = document.getElementById('btn-download-csv');
        const tbodyEl = document.getElementById('data-table-body');

        function buildDataTable() {
          tbodyEl.innerHTML = '';
          for (let i = 0; i < dailyData.length; i++) {
            const dateStr = dailyData[i].time;
            const priceVal = dailyData[i].value.toFixed(2);
            const evList = eventsByDate[dateStr] || [];
            const eventsStr = evList.join(' | ');

            const tr = document.createElement('tr');
            tr.innerHTML = 
              '<td>' + dateStr + '</td>' +
              '<td>' + priceVal + '</td>' +
              '<td>' + eventsStr + '</td>';
            tbodyEl.appendChild(tr);
          }
        }
        buildDataTable();

        btnShowData.addEventListener('click', () => {
          document.getElementById('main-chart').style.display = 'none';
          document.getElementById('navigator-chart').style.display = 'none';
          document.getElementById('range-buttons').style.display = 'none';
          document.getElementById('custom-legend').style.display = 'none';
          document.getElementById('marker-tooltip').style.display = 'none';
          dataButtonContainer.style.display = 'none';
          dataTableContainer.style.display = 'block';
        });

        btnCloseTable.addEventListener('click', () => {
          dataTableContainer.style.display = 'none';
          document.getElementById('main-chart').style.display = 'block';
          document.getElementById('navigator-chart').style.display = 'block';
          document.getElementById('range-buttons').style.display = 'grid';
          document.getElementById('custom-legend').style.display = 'flex';
          dataButtonContainer.style.display = 'block';
        });

        btnDownloadCsv.addEventListener('click', () => {
          let csvContent = 'Date,Price,Events\\n';
          for (let i = 0; i < dailyData.length; i++) {
            const dateStr = dailyData[i].time;
            const priceVal = dailyData[i].value.toFixed(2);
            const evList = eventsByDate[dateStr] || [];
            const eventsStr = evList.join(' | ');
            csvContent += dateStr + ',' + priceVal + ',' + eventsStr + '\\n';
          }
          const blob = new Blob([csvContent], { type: 'text/csv;charset=utf-8;' });
          const url = URL.createObjectURL(blob);
          const tempLink = document.createElement('a');
          tempLink.href = url;
          tempLink.setAttribute('download', 'price_and_events_data.csv');
          tempLink.style.display = 'none';
          document.body.appendChild(tempLink);
          tempLink.click();
          document.body.removeChild(tempLink);
          URL.revokeObjectURL(url);
        });
      });
    })();
  </script>
</body>
</html>
'''
;

    // Creiamo il Blob e l'URL
    final blob = html.Blob([htmlContent], 'text/html');
    final url = html.Url.createObjectUrlFromBlob(blob);

    // Creiamo un IFrame che punta a quell'URL
    final html.IFrameElement iFrameElement = html.IFrameElement()
      ..src = url
      ..style.border = 'none'
      ..width = '100%'
      ..height = '100%';

    // Registriamo la view con l'ID
    ui.platformViewRegistry.registerViewFactory(viewId, (int viewId) => iFrameElement);
  }

  late final String _viewId;

  @override
  Widget build(BuildContext context) {
    // Ritorna un box delle dimensioni desiderate, contenente l'HtmlElementView
    return SizedBox(
      width: width,
      height: height,
      child: HtmlElementView(viewType: _viewId),
    );
  }

  /// Converte una lista di PricePoint in una stringa JS (JSON array).
  /// Esempio: [ { time: '2020-01-01', value: 123.45 }, ... ]
  String _convertDailyDataToJsArray(List<PricePoint> data) {
    final buffer = StringBuffer();
    buffer.write('[');
    for (int i = 0; i < data.length; i++) {
      final p = data[i];
      final t = _escapeJs(p.time);
      buffer.write("{ time: '$t', value: ${p.value} }");
      if (i < data.length - 1) {
        buffer.write(', ');
      }
    }
    buffer.write(']');
    return buffer.toString();
  }

  /// Converte una mappa {data -> [evento1, evento2]} in JS (es: var eventsByDate = { '2020-03-10': ['Dividendo: ...'] }
  String _convertEventsToJsMap(Map<String, List<String>> map) {
    final buffer = StringBuffer();
    buffer.write('{');
    bool firstKey = true;
    map.forEach((date, list) {
      if (!firstKey) {
        buffer.write(', ');
      } else {
        firstKey = false;
      }
      buffer.write("'${_escapeJs(date)}': [");
      for (int i = 0; i < list.length; i++) {
        final ev = _escapeJs(list[i]);
        buffer.write("'$ev'");
        if (i < list.length - 1) buffer.write(', ');
      }
      buffer.write(']');
    });
    buffer.write('}');
    return buffer.toString();
  }

  /// Semplice funzione di escaping per le stringhe HTML
  String _escapeHtml(String text) {
    // Fai escaping di <, >, &
    return text
        .replaceAll('&', '&amp;')
        .replaceAll('<', '&lt;')
        .replaceAll('>', '&gt;');
  }

  /// Semplice escape per le stringhe JS
  String _escapeJs(String text) {
    // Esempio banale, sostituisci apici
    return text
        .replaceAll('\\', '\\\\')
        .replaceAll("'", "\\'");
  }
}
