final raw_html = ''' <!DOCTYPE html>
<html lang="it">
<head>
  <meta charset="UTF-8">
  <title>Ownership Stacked Bar - Colonne e Zoom (Fix)</title>
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
      width: 800px;
      height: 400px;
      margin: 0 auto;
      background-color: #2c2c3a; /* Sfondo container */
      border: 1px solid #333;
      box-shadow: 0 0 8px rgba(0,0,0,0.5);
    }
  </style>
</head>
<body>
  <h1>Ownership Structure</h1>
  <div id="chart"></div>

  <script>
    // Dati di esempio (cinque segmenti)
    var ownershipData = [
      {
        name: 'Private Companies',
        percent: 0.00264,  // ~0.00264%
        shares: 643498,
        color: '#4abffd'
      },
      {
        name: 'State or Government',
        percent: 0.103,
        shares: 25026584,
        color: '#26a69a'
      },
      {
        name: 'Individual Insiders',
        percent: 3.94,
        shares: 961144572,
        color: '#e91e63'
      },
      {
        name: 'General Public',
        percent: 29.3,
        shares: 7149925127,
        color: '#ff9800'
      },
      {
        name: 'Institutions',
        percent: 66.5,
        shares: 16263858229,
        color: '#9c27b0'
      }
    ];

    // Creiamo una serie per ogni voce (stack comune "ownership")
    var seriesData = ownershipData.map(function(d) {
      return {
        name: d.name,
        type: 'bar',
        stack: 'ownership',
        itemStyle: { color: d.color },
        emphasis: { focus: 'series' },
        barWidth: 25,  // spessore ridotto
        label: { show: false },
        data: [d.percent] // un'unica categoria => un array con un solo valore
      };
    });

    // Configurazione ECharts
    var option = {
      backgroundColor: '#2c2c3a',
      // Abilitiamo zoom e pan orizzontale sulla xAxis
      dataZoom: [
        {
          type: 'inside',
          xAxisIndex: 0,
          start: 0,
          end: 100  // mostriamo inizialmente l'intero range
        },
        {
          type: 'slider',
          xAxisIndex: 0,
          start: 0,
          end: 100,
          bottom: 10  // padding extra dalla base del grafico
        }
      ],
      tooltip: {
        trigger: 'axis',
        axisPointer: { type: 'shadow' },
        formatter: function(params) {
          var html = '';
          params.forEach(function(p) {
            var od = ownershipData.find(function(d) { return d.name === p.seriesName; });
            if (od) {
              html += '<div style="margin:4px 0;">'
                   + '<span style="display:inline-block;width:12px;height:12px;background-color:' + od.color + ';margin-right:5px;"></span>'
                   + '<strong>' + od.name + '</strong> '
                   + '(' + od.percent.toFixed(3) + '%) '
                   + od.shares.toLocaleString() + ' shares'
                   + '</div>';
            }
          });
          return html;
        }
      },
      grid: {
        left: '3%',
        right: '3%',
        bottom: '20%',  // più spazio per la barra di zoom
        top: '35%',     // lasciamo spazio sopra per le etichette in colonna
        containLabel: true
      },
      xAxis: {
        type: 'value',
        axisLabel: {
          color: '#fff',
          formatter: '{value}%'
        },
        min: 0,
        max: 100
      },
      yAxis: {
        type: 'category',
        data: [''],  // un'unica categoria
        axisLabel: { show: false },
        axisTick: { show: false },
        axisLine: { show: false }
      },
      legend: { show: false },
      series: seriesData
    };

    // Inizializziamo ECharts
    var chartDom = document.getElementById('chart');
    var myChart = echarts.init(chartDom);
    myChart.setOption(option);

    // Aggiungiamo le label testuali in colonna dall'alto,
    // e quando la colonna "finisce" in altezza, passiamo alla colonna successiva.
    var itemsPerColumn = 3;   // quanti item per colonna
    var columnWidth   = 220;  // larghezza di ciascuna colonna
    var topStart      = 10;   // offset dall'alto
    var leftStart     = 10;   // offset da sinistra
    var lineHeight    = 36;   // spazio per ciascun item (due righe di testo)
    var textItems     = [];

    ownershipData.forEach(function(d, i) {
      var colIndex = Math.floor(i / itemsPerColumn);
      var rowIndex = i % itemsPerColumn;
      var xPos = leftStart + (colIndex * columnWidth);
      var yPos = topStart + (rowIndex * lineHeight);

      // Testo multilinea: "Nome XX.XXX%\nXX,XXX,XXX shares"
      var textStr = d.name + ' ' + d.percent.toFixed(3) + '%\n' + d.shares.toLocaleString() + ' shares';
      textItems.push({
        type: 'text',
        left: xPos,
        top: yPos,
        style: {
          text: textStr,
          fill: d.color,
          font: '14px Arial',
          lineHeight: 18
        }
      });
    });

    // Aggiungiamo i testi come "graphic"
    myChart.setOption({
      graphic: textItems
    });
  </script>
</body>
</html>
''';