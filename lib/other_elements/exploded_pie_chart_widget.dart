final raw_html = ''' <!DOCTYPE html>
<html lang="it">
<head>
  <meta charset="UTF-8">
  <title>Grafico a Torta Esploso - ECharts</title>
  <script src="https://cdn.jsdelivr.net/npm/echarts@5/dist/echarts.min.js"></script>
  <style>
    body {
      margin: 20px;
      background-color: #1f1f2e; /* Sfondo scuro */
      font-family: Arial, sans-serif;
      color: #fff;
    }
    h1 {
      text-align: center;
      margin-bottom: 10px;
    }
    #chart {
      width: 600px;
      height: 400px;
      margin: 0 auto;
      background-color: #2c2c3a; /* Sfondo container */
      border: 1px solid #333;
      box-shadow: 0 0 8px rgba(0,0,0,0.5);
    }
  </style>
</head>
<body>
  <h1>Torta Esplosa (Exploded Pie)</h1>
  <div id="chart"></div>

  <script>
    // Dati di esempio con cinque segmenti
    // "Segment B" è estratto ("selected: true")
    var pieData = [
      { value: 15, name: 'Segment A', itemStyle: { color: '#66BB6A' } },
      { value: 25, name: 'Segment B', itemStyle: { color: '#42A5F5' }, selected: true },
      { value: 20, name: 'Segment C', itemStyle: { color: '#FFA726' } },
      { value: 30, name: 'Segment D', itemStyle: { color: '#EF5350' } },
      { value: 10, name: 'Segment E', itemStyle: { color: '#AB47BC' } }
    ];

    // Configurazione ECharts
    var option = {
      backgroundColor: '#2c2c3a',
      tooltip: {
        trigger: 'item',
        formatter: '{b}: {c} ({d}%)'
      },
      series: [
        {
          name: 'Exploded Pie',
          type: 'pie',
          radius: '60%',            // Raggio del grafico
          center: ['50%', '50%'],   // Posizione al centro
          selectedMode: 'single',   // Modalità "singolo" selezionato
          selectedOffset: 20,       // Offset di "esplosione" (in px) per il segmento selezionato
          data: pieData,
          label: {
            color: '#fff',
            fontSize: 12
          },
          labelLine: {
            lineStyle: { color: '#fff' }
          }
        }
      ]
    };

    // Inizializziamo ECharts
    var chartDom = document.getElementById('chart');
    var myChart = echarts.init(chartDom);
    myChart.setOption(option);
  </script>
</body>
</html>
''';