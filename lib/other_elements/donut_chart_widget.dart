final raw_html = ''' <!DOCTYPE html>
<html lang="it">
<head>
  <meta charset="UTF-8">
  <title>Donut Chart - Multi Values & Colors</title>
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
  <h1>Multi-Value Donut Chart</h1>
  <div id="chart"></div>

  <script>
    // Esempio di dati con più valori e colori
    // La somma dei "value" può essere 100 (percentuali) o qualsiasi numero
    // L'importante è che i segmenti abbiano un valore e un colore univoco.
    var donutData = [
      { name: 'Paid as dividend', value: 2,  color: '#42A5F5' },
      { name: 'Segment B',        value: 10, color: '#66BB6A' },
      { name: 'Segment C',        value: 15, color: '#FFCA28' },
      { name: 'Segment D',        value: 25, color: '#EF5350' },
      { name: 'Segment E',        value: 30, color: '#AB47BC' },
      { name: 'Segment F',        value: 18, color: '#FFA726' }
    ];

    // Creiamo l'array di oggetti per la "data" della serie
    var pieData = donutData.map(function(d) {
      return {
        name: d.name,
        value: d.value,
        itemStyle: {
          color: d.color
        }
      };
    });

    // Configurazione ECharts
    var option = {
      backgroundColor: '#2c2c3a',
      tooltip: {
        trigger: 'item',
        formatter: '{b}: {c} ({d}%)' // Mostra nome, valore e percentuale
      },
      series: [
        {
          name: 'Donut',
          type: 'pie',
          radius: ['50%', '70%'], // Imposta ciambella (interno 50%, esterno 70%)
          center: ['50%', '50%'], // Centra orizzontalmente e verticalmente
          avoidLabelOverlap: false,
          // Disabilitiamo la label interna, usiamo tooltip e un testo custom in center
          label: {
            show: false
          },
          labelLine: {
            show: false
          },
          data: pieData
        }
      ]
    };

    // Inizializziamo ECharts
    var chartDom = document.getElementById('chart');
    var myChart = echarts.init(chartDom);
    myChart.setOption(option);

    // Aggiungiamo testo personalizzato in centro:
    // 1) "Paid as dividend" in alto (sopra "2%")
    // 2) "2%" al centro
    // 3) "Cash flow retained" in basso
    // Puoi ovviamente personalizzare testo, colori e posizioni.
    myChart.setOption({
      graphic: [
        // Testo in alto
        {
          type: 'text',
          left: 'center',
          top: '40%',
          style: {
            text: 'Paid as dividend',
            fill: '#fff',
            font: '12px Arial'
          }
        },
        // Testo "2%" al centro
        {
          type: 'text',
          left: 'center',
          top: 'center',
          style: {
            text: '2%',
            fill: '#fff',
            font: 'bold 20px Arial',
            textAlign: 'center'
          }
        },
        // Testo in basso
        {
          type: 'text',
          left: 'center',
          top: '60%',
          style: {
            text: 'Cash flow retained',
            fill: '#fff',
            font: '12px Arial',
            textAlign: 'center'
          }
        }
      ]
    });
  </script>
</body>
</html>
''';