import 'dart:html' as html;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';

/// Modello per ogni link del Sankey
class SankeyLinkData {
  final String source;
  final String target;
  final double value;
  // Qui si possono aggiungere altre proprietà per configurare forma, posizione, ecc.
  SankeyLinkData({
    required this.source,
    required this.target,
    required this.value,
  });
}

/// Widget che disegna un grafico Sankey evolutivo tramite ECharts.
/// L'input comprende:
/// - [nodes]: una lista di nomi dei nodi (String)
/// - [states]: una lista di stati; ogni stato è una lista di link (SankeyLinkData)
/// - Altri parametri grafici (titolo, dimensioni, background, ecc.)
class SankeyEvolutiveWidget extends StatelessWidget {
  final String title;
  final double width;
  final double height;
  final List<String> nodes;
  final List<List<SankeyLinkData>> states;
  final String backgroundColor;

  late final String _viewId;

  SankeyEvolutiveWidget({
    Key? key,
    required this.title,
    required this.nodes,
    required this.states,
    this.width = 800,
    this.height = 600,
    this.backgroundColor = "#2c2c2c",
  }) : super(key: key) {
    // Genera un ID univoco per l'iframe
    final String viewId = 'sankey-evolutive-${DateTime.now().millisecondsSinceEpoch}';
    _viewId = viewId;

    // Costruisce le stringhe JS per i nodi e per gli stati
    final String nodesJs = _buildNodesJs(nodes);
    final String statesJs = _buildStatesJs(states);

    // Impostiamo i parametri dello slider
    final int sliderMin = 0;
    final int sliderMax = states.length - 1;
    final int sliderStep = 1;
    final int sliderValue = 0;

    // Costruiamo il contenuto HTML completo
    final String htmlContent = '''
<!DOCTYPE html>
<html lang="it">
<head>
  <meta charset="UTF-8">
  <title>${_escapeHtml(title)}</title>
  <script src="https://cdn.jsdelivr.net/npm/echarts@5/dist/echarts.min.js"></script>
  <style>
    body {
      font-family: Arial, sans-serif;
      background-color: ${_escapeHtml(backgroundColor)};
      color: #fff;
      margin: 20px;
    }
    h1 {
      text-align: center;
    }
    .chart-container {
      margin: 0 auto;
      width: 80%;
      height: ${height.toInt()}px;
      background-color: #1c1c1c;
      border: 1px solid #444;
      box-shadow: 0 0 8px rgba(0,0,0,0.3);
    }
    .slider-container {
      width: 80%;
      margin: 20px auto;
      text-align: center;
    }
    #timeSlider {
      width: 300px;
    }
    #timeLabel {
      margin-left: 10px;
      font-weight: bold;
    }
  </style>
</head>
<body>
  <h1>${_escapeHtml(title)}</h1>
  
  <!-- Contenitore del grafico -->
  <div id="sankey" class="chart-container"></div>

  <!-- Slider temporale -->
  <div class="slider-container">
    <input type="range" id="timeSlider" min="$sliderMin" max="$sliderMax" step="$sliderStep" value="$sliderValue">
    <span id="timeLabel">Timestep: $sliderValue</span>
  </div>

  <script>
    // Inizializziamo l'istanza ECharts
    var chart = echarts.init(document.getElementById('sankey'));

    // Definizione dei nodi del Sankey (con solo il nome)
    var nodes = $nodesJs;

    // Stato evolutivo: array di array di link
    var sankeyData = $statesJs;

    // Funzione che aggiorna il grafico in base al timestep
    function updateSankey(timestep) {
      var option = {
        backgroundColor: '${_escapeJs(backgroundColor)}',
        tooltip: {
          trigger: 'item',
          triggerOn: 'mousemove',
          formatter: function (params) {
            if (params.dataType === 'edge') {
              return params.data.source + ' → ' + params.data.target + '<br/>' +
                     'US\$' + params.data.value.toFixed(2) + 'b';
            } else if (params.dataType === 'node') {
              return params.data.name;
            }
          }
        },
        series: [{
          type: 'sankey',
          data: nodes,
          links: sankeyData[timestep],
          layout: 'none',
          focusNodeAdjacency: 'allEdges',
          itemStyle: { borderWidth: 0 },
          lineStyle: { color: 'gradient', opacity: 0.8 },
          label: { color: '#fff', fontSize: 12 }
        }]
      };
      chart.setOption(option);
    }

    // Inizializza il grafico con il primo stato (timestep 0)
    updateSankey(0);

    // Gestione dello slider per l'evoluzione
    var slider = document.getElementById('timeSlider');
    var label = document.getElementById('timeLabel');
    slider.addEventListener('input', function() {
      var t = parseInt(this.value);
      label.innerText = "Timestep: " + t;
      updateSankey(t);
    });
  </script>
</body>
</html>
''';

    final blob = html.Blob([htmlContent], 'text/html');
    final url = html.Url.createObjectUrlFromBlob(blob);

    final html.IFrameElement iFrameElement = html.IFrameElement()
      ..src = url
      ..style.border = 'none'
      ..width = '100%'
      ..height = '100%';

    ui.platformViewRegistry.registerViewFactory(_viewId, (int viewId) => iFrameElement);
  }

  // Converte la lista di nodi (String) in un array JS di oggetti { name: "..." }
  String _buildNodesJs(List<String> nodes) {
    final sb = StringBuffer();
    sb.write('[');
    for (int i = 0; i < nodes.length; i++) {
      sb.write('{ name: "${_escapeJs(nodes[i])}" }');
      if (i < nodes.length - 1) sb.write(', ');
    }
    sb.write(']');
    return sb.toString();
  }

  // Converte la lista di stati in una stringa JS.
  // Ogni stato è un array di oggetti { source: "...", target: "...", value: ... }
  String _buildStatesJs(List<List<SankeyLinkData>> states) {
    final sb = StringBuffer();
    sb.write('[');
    for (int i = 0; i < states.length; i++) {
      final state = states[i];
      sb.write('[');
      for (int j = 0; j < state.length; j++) {
        final link = state[j];
        sb.write('{ source: "${_escapeJs(link.source)}", target: "${_escapeJs(link.target)}", value: ${link.value} }');
        if (j < state.length - 1) sb.write(', ');
      }
      sb.write(']');
      if (i < states.length - 1) sb.write(', ');
    }
    sb.write(']');
    return sb.toString();
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

  @override
  Widget build(BuildContext context) {
    // Aggiungiamo spazio extra per lo slider
    return SizedBox(
      width: width,
      height: height + 150,
      child: HtmlElementView(viewType: _viewId),
    );
  }
}

