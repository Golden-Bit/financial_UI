final raw_html = ''' 
<!DOCTYPE html>
<!DOCTYPE html>
<html lang="it">
<head>
  <meta charset="UTF-8">
  <title>Gauge con due lancette - Future ROE (3yrs)</title>
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
  <h1>Future ROE (3yrs) - Gauge con due lancette (0–100)</h1>
  <div id="chart"></div>

  <script>
    // Selezioniamo il container e inizializziamo ECharts
    var chartDom = document.getElementById('chart');
    var myChart = echarts.init(chartDom);

    // Definizione dei valori (scala 0–100)
    // Esempio: Company = 50.0% => 50 su 100
    //          Industry = 11.9% => 11.9 su 100
    var companyValue = 50;    // 50.0%
    var industryValue = 11.9; // 11.9%

    // Segmenti colore (0–25%, 25–50%, 50–75%, 75–100%)
    // [0.25, '#f44336'] => 0–25% rosso
    // [0.50, '#ff9800'] => 25–50% arancione
    // [0.75, '#ffeb3b'] => 50–75% giallo
    // [1,    '#4caf50'] => 75–100% verde
    var axisColor = [
      [0.25, '#f44336'],
      [0.50, '#ff9800'],
      [0.75, '#ffeb3b'],
      [1.00, '#4caf50']
    ];

    var option = {
      backgroundColor: '#2c2c3a',
      animationDuration: 2000,
      animationEasing: 'cubicOut',

      series: [
        // PRIMA SERIE GAUGE (Company - blu)
        {
          name: 'Company Gauge',
          type: 'gauge',
          center: ['50%', '55%'],
          radius: '80%',
          min: 0,
          max: 100,
          splitNumber: 5,  // 0, 20, 40, 60, 80, 100
          startAngle: 200,
          endAngle: -20,

          axisLine: {
            lineStyle: {
              width: 20,
              color: axisColor
            }
          },
          axisTick: {
            length: 8,
            lineStyle: { color: '#fff' }
          },
          splitLine: {
            length: 15,
            lineStyle: { color: '#fff', width: 2 }
          },
          axisLabel: {
            color: '#fff',
            fontSize: 10,
            formatter: function (value) {
              return value + '%';
            }
          },
          pointer: {
            length: '70%',
            width: 6,
            itemStyle: {
              color: '#0055ff' // Lancetta blu per Company
            }
          },
          anchor: {
            show: true,
            size: 10,
            showAbove: true,
            itemStyle: {
              color: '#9e9e9e'
            }
          },
          detail: { show: false },
          data: [{ value: 0 }] // Partenza da 0
        },

        // SECONDA SERIE GAUGE (Industry - azzurro)
        // Stessa scala, ma nascondiamo l'arco
        {
          name: 'Industry Gauge',
          type: 'gauge',
          center: ['50%', '55%'],
          radius: '80%',
          min: 0,
          max: 100,
          startAngle: 200,
          endAngle: -20,

          axisLine: { show: false },
          axisTick: { show: false },
          splitLine: { show: false },
          axisLabel: { show: false },

          pointer: {
            length: '70%',
            width: 6,
            itemStyle: {
              color: '#4abffd' // Lancetta azzurra per Industry
            }
          },
          anchor: {
            show: true,
            size: 10,
            showAbove: true,
            itemStyle: {
              color: '#9e9e9e'
            }
          },
          detail: { show: false },
          data: [{ value: 0 }] // Partenza da 0
        },

        // Serie "pie" fittizia per il testo in basso
        {
          type: 'pie',
          center: ['50%', '85%'],
          radius: [0, 0],
          label: {
            show: true,
            position: 'center',
            formatter: function() {
              // Testo multilinea con i valori di Company e Industry
              return '{title|Future ROE (3yrs)}\n'
                   + '{company|Company  ' + companyValue.toFixed(1) + '%}\n'
                   + '{industry|Industry ' + industryValue.toFixed(1) + '%}';
            },
            rich: {
              title: {
                fontSize: 16,
                fontWeight: 'bold',
                color: '#fff',
                align: 'center',
                padding: [0, 0, 8, 0]
              },
              company: {
                fontSize: 14,
                color: '#0055ff',   // Blu
                align: 'center',
                padding: [0, 0, 4, 0]
              },
              industry: {
                fontSize: 14,
                color: '#4abffd',   // Azzurro
                align: 'center'
              }
            }
          },
          data: [100] // Valore dummy
        }
      ]
    };

    // Impostiamo l'opzione iniziale (lancette a 0)
    myChart.setOption(option);

    // Dopo un breve delay, aggiorniamo i valori di Company e Industry
    setTimeout(function(){
      myChart.setOption({
        series: [
          { data: [{ value: companyValue }] },  // prima serie gauge
          { data: [{ value: industryValue }] }  // seconda serie gauge
        ]
      });
    }, 300);
  </script>
</body>
</html>
''';