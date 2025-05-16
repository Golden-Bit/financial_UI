
final raw_html = ''' 
<!DOCTYPE html>
<html lang="it">
<head>
  <meta charset="UTF-8">
  <title>Sankey Evolutivo - Esempio</title>
  <!-- Carichiamo ECharts dal CDN -->
  <script src="https://cdn.jsdelivr.net/npm/echarts@5/dist/echarts.min.js"></script>
  <style>
    body {
      font-family: Arial, sans-serif;
      background-color: #2c2c2c;
      color: #fff;
      margin: 20px;
    }
    h1 {
      text-align: center;
    }
    .chart-container {
      margin: 0 auto;
      width: 80%;
      height: 600px;
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
  <h1>Sankey Evolutivo con ECharts</h1>
  
  <!-- Contenitore del grafico -->
  <div id="sankey" class="chart-container"></div>

  <!-- Slider temporale -->
  <div class="slider-container">
    <input type="range" id="timeSlider" min="0" max="2" step="1" value="0">
    <span id="timeLabel">Timestep: 0</span>
  </div>

  <script>
    // Inizializziamo l'istanza ECharts
    var chart = echarts.init(document.getElementById('sankey'));

    // Definiamo i nodi principali del Sankey (stessi nomi del diagramma)
    var nodes = [
      { name: 'Compute & Network' },
      { name: 'Graphics' },
      { name: 'Revenue' },
      { name: 'Cost of Sales' },
      { name: 'Gross Profit' },
      { name: 'Expenses' },
      { name: 'Earnings' },
      { name: 'General & Admin.' },
      { name: 'Research & Dev.' },
      { name: 'Non-Operating Exp.' }
    ];

    // Dati per diversi timestep (0, 1, 2)
    // Nel timestep 1 trovi i valori "reali" mostrati nello screenshot
    var sankeyData = [
      // Timestep 0 (esempio simulato)
      [
        { source: 'Compute & Network', target: 'Revenue', value: 100 },
        { source: 'Graphics',          target: 'Revenue', value: 10 },
        { source: 'Revenue',           target: 'Cost of Sales', value: 28 },
        { source: 'Revenue',           target: 'Gross Profit',  value: 82 },
        { source: 'Gross Profit',      target: 'Expenses',      value: 20 },
        { source: 'Gross Profit',      target: 'Earnings',      value: 62 },
        { source: 'Expenses',          target: 'General & Admin.',     value: 3 },
        { source: 'Expenses',          target: 'Research & Dev.',      value: 10 },
        { source: 'Expenses',          target: 'Non-Operating Exp.',   value: 7 }
      ],
      // Timestep 1 (valori del diagramma mostrato)
      [
        { source: 'Compute & Network', target: 'Revenue',            value: 116.19 },
        { source: 'Graphics',          target: 'Revenue',            value: 14.30 },
        { source: 'Revenue',           target: 'Cost of Sales',      value: 32.64 },
        { source: 'Revenue',           target: 'Gross Profit',       value: 97.86 },
        { source: 'Gross Profit',      target: 'Expenses',           value: 24.98 },
        { source: 'Gross Profit',      target: 'Earnings',           value: 72.88 },
        { source: 'Expenses',          target: 'General & Admin.',   value: 3.49 },
        { source: 'Expenses',          target: 'Research & Dev.',    value: 12.91 },
        { source: 'Expenses',          target: 'Non-Operating Exp.', value: 8.57 }
      ],
      // Timestep 2 (esempio simulato)
      [
        { source: 'Compute & Network', target: 'Revenue',            value: 120 },
        { source: 'Graphics',          target: 'Revenue',            value: 15 },
        { source: 'Revenue',           target: 'Cost of Sales',      value: 35 },
        { source: 'Revenue',           target: 'Gross Profit',       value: 100 },
        { source: 'Gross Profit',      target: 'Expenses',           value: 26 },
        { source: 'Gross Profit',      target: 'Earnings',           value: 74 },
        { source: 'Expenses',          target: 'General & Admin.',   value: 4 },
        { source: 'Expenses',          target: 'Research & Dev.',    value: 13 },
        { source: 'Expenses',          target: 'Non-Operating Exp.', value: 9 }
      ]
    ];

    // Funzione che aggiorna il grafico Sankey in base al timestep
    function updateSankey(timestep) {
      var option = {
        backgroundColor: '#2c2c2c',
        tooltip: {
          trigger: 'item',
          triggerOn: 'mousemove',
          formatter: function (params) {
            // Se l'elemento è un "link" (edge), mostriamo la sorgente, il target e il valore
            if (params.dataType === 'edge') {
              return params.data.source + ' → ' + params.data.target + '<br/>' +
                     'US$' + params.data.value.toFixed(2) + 'b';
            } else if (params.dataType === 'node') {
              // Se è un nodo, mostriamo solo il nome
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
          // Stile dei nodi
          itemStyle: {
            borderWidth: 0
          },
          // Stile dei link
          lineStyle: {
            color: 'gradient',
            opacity: 0.8
          },
          // Stile delle etichette
          label: {
            color: '#fff',
            fontSize: 12
          }
        }]
      };
      chart.setOption(option);
    }

    // Inizializziamo il grafico a timestep 0
    updateSankey(0);

    // Gestione slider
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