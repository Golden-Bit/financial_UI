final raw_html = ''' <!DOCTYPE html>
<html lang="it">
<head>
  <meta charset="UTF-8">
  <title>PE & Earnings Growth Widget</title>
  <script src="https://cdn.jsdelivr.net/npm/echarts@5/dist/echarts.min.js"></script>
  <style>
    body {
      margin: 20px;
      background-color: #1f1f2e; /* Sfondo scuro */
      font-family: Arial, sans-serif;
      color: #fff;
    }
    #chart {
      width: 900px;
      height: 500px;
      margin: 0 auto;
      background-color: #2c2c3a; /* Sfondo container */
      border: 1px solid #333;
      box-shadow: 0 0 8px rgba(0,0,0,0.5);
    }
  </style>
</head>
<body>
  <h2 style="text-align:center; color:#fff; margin-bottom:10px;">
    Price to Earnings vs Earnings Growth
  </h2>
  <div id="chart"></div>

  <script>
    // Dati di esempio per 5 aziende
    var data = [
      { name: 'Arm Holdings',            pe: 156.6, growth: 29.0 },
      { name: 'Advanced Micro Devices',  pe: 102.2, growth: 32.0 },
      { name: 'Broadcom',                pe: 85.3,  growth: 26.6 },
      { name: 'NVIDIA',                  pe: 38.6,  growth: 20.7 },
      { name: 'QUALCOMM',                pe: 16.5,  growth: 21.1 }
    ];
    // Valore medio di riferimento: oltre questo valore la parte rossa appare
    var peerAvg = 90.1;
    
    // Invertiamo i dati per avere la prima voce in alto (asse y inverso)
    data.reverse();
    
    // Calcoliamo la parte "verde" (fino a peerAvg) e la parte "rossa" (oltre peerAvg)
    var greenValues = data.map(function(d){
      return Math.min(d.pe, peerAvg);
    });
    var redValues = data.map(function(d){
      return (d.pe > peerAvg) ? (d.pe - peerAvg) : 0;
    });
    // Categorie per l'asse Y
    var categories = data.map(function(d){ return d.name; });
    
    // Creiamo un pattern per la parte rossa tratteggiata
    var patternCanvas = document.createElement('canvas');
    patternCanvas.width = 20;
    patternCanvas.height = 20;
    var ctx = patternCanvas.getContext('2d');
    ctx.fillStyle = '#f04e4e';
    ctx.fillRect(0, 0, 20, 20);
    ctx.strokeStyle = '#2c2c3a';
    ctx.lineWidth = 3;
    ctx.beginPath();
    ctx.moveTo(0, 0);
    ctx.lineTo(20, 20);
    ctx.stroke();
    ctx.beginPath();
    ctx.moveTo(20, 0);
   	ctx.lineTo(0, 20);
    ctx.stroke();
    var redPattern = {
      image: patternCanvas,
      repeat: 'repeat'
    };
    
    // Serie verde: mostra la parte fino a peerAvg.
    // Modifichiamo il formatter in modo che, anche se la barra ha parte rossa,
    // il segmento verde mostri sempre il valore "peerAvg" (se PE > peerAvg) oppure il valore reale.
    var seriesGreen = {
      name: 'PE-green',
      type: 'bar',
      stack: 'peStack',
      data: greenValues,
      itemStyle: {
        color: '#3AA76D'
      },
      label: {
        show: true,
        position: 'insideLeft',
        color: '#fff',
        formatter: function(params) {
          var originalPE = data[params.dataIndex].pe;
          // Se l'azienda ha PE maggiore del peerAvg, mostriamo il valore peerAvg in verde
          if (originalPE > peerAvg) {
            return peerAvg.toFixed(1) + 'x\n' + data[params.dataIndex].name;
          } else {
            return originalPE.toFixed(1) + 'x\n' + data[params.dataIndex].name;
          }
        }
      }
    };
    
    // Serie rossa: mostra l'eccedenza oltre peerAvg.
    // Posizioniamo il label a destra per evitare sovrapposizioni.
    var seriesRed = {
      name: 'PE-red',
      type: 'bar',
      stack: 'peStack',
      data: redValues,
      itemStyle: {
        color: redPattern
      },
      label: {
        show: true,
        position: 'insideRight',
        color: '#fff',
        formatter: function(params) {
          var gVal = greenValues[params.dataIndex];
          var rVal = redValues[params.dataIndex];
          if (rVal > 0) {
            var total = gVal + rVal;
            return total.toFixed(1) + 'x';
          }
          return '';
        }
      },
      markLine: {
        symbol: ['none','none'],
        data: [
          {
            xAxis: peerAvg,
            lineStyle: {
              color: '#ffc107',
              width: 2
            },
            label: {
              formatter: 'Peer Avg ' + peerAvg.toFixed(1) + 'x',
              position: 'start',
              color: '#fff',
              fontSize: 12,
              backgroundColor: '#222',
              padding: [3,6],
              borderRadius: 3
            }
          }
        ]
      }
    };
    
    // Configurazione dell'asse e del grafico
    var option = {
      backgroundColor: '#2c2c3a',
      tooltip: {
        trigger: 'axis',
        axisPointer: { type: 'shadow' }
      },
      grid: {
        left: 60,
        right: 60,
        top: 40,
        bottom: 40
      },
      xAxis: {
        type: 'value',
        min: 0,
        max: 160,
        axisLabel: {
          color: '#fff',
          formatter: '{value}'
        },
        splitLine: {
          lineStyle: { color: '#444' }
        }
      },
      yAxis: {
        type: 'category',
        inverse: true,
        data: categories,
        axisLine: { show: false },
        axisTick: { show: false },
        axisLabel: {
          color: '#fff',
          fontSize: 12
        }
      },
      series: [
        Object.assign({}, seriesGreen, {
          barCategoryGap: '20%',
          barWidth: 30,
          emphasis: { focus: 'none' }
        }),
        Object.assign({}, seriesRed, {
          barCategoryGap: '20%',
          barWidth: 30,
          emphasis: { focus: 'none' }
        })
      ]
    };
    
    // Inizializziamo il grafico
    var chartDom = document.getElementById('chart');
    var myChart = echarts.init(chartDom);
    myChart.setOption(option);
    
    // Rimuoviamo la parte grafica dei "Earnings Growth" (non più richiesta)
  </script>
</body>
</html>
''';