final raw_html = '''<!DOCTYPE html>
<html lang="it">
<head>
  <meta charset="UTF-8">
  <title>Grafico a Torta Radiale (Rose Chart)</title>
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
  <h1>Radial Pie Chart (Rose Chart)</h1>
  <div id="chart"></div>

  <script>
    // Dati di esempio: sette segmenti con valori diversi
    var dataRose = [
      { value: 10, name: 'Segment A', itemStyle: { color: '#66BB6A' } },
      { value: 22, name: 'Segment B', itemStyle: { color: '#EF5350' } },
      { value: 18, name: 'Segment C', itemStyle: { color: '#FFA726' } },
      { value: 25, name: 'Segment D', itemStyle: { color: '#AB47BC' } },
      { value: 14, name: 'Segment E', itemStyle: { color: '#26A69A' } },
      { value: 30, name: 'Segment F', itemStyle: { color: '#9C27B0' } },
      { value: 12, name: 'Segment G', itemStyle: { color: '#42A5F5' } }
    ];

    // Configurazione ECharts
    // "roseType: 'radius'" fa sì che il raggio di ciascuna fetta vari in base al valore
    var option = {
      backgroundColor: '#2c2c3a',
      tooltip: {
        trigger: 'item',
        formatter: '{b}: {c} ({d}%)'
      },
      series: [
        {
          name: 'Radial Pie',
          type: 'pie',
          radius: [30, 120],    // Raggio interno 30, esterno 120
          center: ['50%', '50%'],
          roseType: 'radius',   // rende il grafico "radiale" in base al valore
          label: {
            color: '#fff',
            fontSize: 12
          },
          labelLine: {
            lineStyle: { color: '#fff' }
          },
          data: dataRose
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