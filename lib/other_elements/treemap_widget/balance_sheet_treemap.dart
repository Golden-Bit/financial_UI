final raw_html = ''' <!DOCTYPE html>
<html lang="it">
<head>
  <meta charset="UTF-8">
  <title>Treemap con Bordo Nero e Tooltip</title>
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
      height: 500px;
      margin: 0 auto;
      background-color: #2c2c3a; /* Sfondo container */
      border: 1px solid #333;
      box-shadow: 0 0 8px rgba(0,0,0,0.5);
    }
  </style>
</head>
<body>
  <h1>Assets | Liabilities + Equity</h1>
  <div id="chart"></div>

  <script>
    // Dati di esempio per "Assets"
    // Se il valore è negativo, lo mostreremo in rosso e in valore assoluto sul riquadro.
    // Ma nel tooltip si vedrà il valore originale (con segno meno).
    var assetsData = [
      { name: 'Cash & Short Term Investments', value: 43.2 },
      { name: 'Long Term & Other Assets',      value: 27.2 },
      { name: 'Receivables',                  value: 23.1 },
      { name: 'Inventory',                    value: 10.1 },
      { name: 'Physical Assets',              value: 8.2 }
    ];

    // Dati di esempio per "Liabilities + Equity"
    var liabData = [
      { name: 'Equity',            value: 79.3 },
      { name: 'Other Liabilities', value: 17.5 },
      // Esempio con valore negativo (Debt) => riquadro rosso e no segno meno sul riquadro
      { name: 'Debt',              value: -8.5 },
      { name: 'Accounts Payable',  value: 6.3 }
    ];

    // Funzione per determinare colore, label e dimensione
    function formatItemAndLabel(item) {
      var val = item.value;
      var absVal = Math.abs(val).toFixed(1); // Mostriamo una cifra decimale
      // Se < 0 => rosso, altrimenti verde
      var color = (val < 0) ? '#f04e4e' : '#3AA76D';

      // Testo nel riquadro (senza segno meno se negativo)
      var labelText = item.name + '\nUS$' + absVal + 'b';

      // Restituiamo un oggetto con i campi per ECharts
      return {
        // Manteniamo la chiave "rawValue" personalizzata per il tooltip
        // (così possiamo mostrare il valore con segno in tooltip)
        rawValue: val,
        name: item.name,
        value: Math.abs(val), 
        label: { formatter: labelText },
        itemStyle: {
          color: color,
          borderColor: '#000',  // Bordo nero
          borderWidth: 1
        }
      };
    }

    // Convertiamo i dati
    var assetsChildren = assetsData.map(formatItemAndLabel);
    var liabChildren   = liabData.map(formatItemAndLabel);

    // Configurazione ECharts
    var option = {
      backgroundColor: '#2c2c3a',

      // Definiamo un tooltip globale
      tooltip: {
        trigger: 'item',
        formatter: function(params) {
          // params.data.rawValue contiene il valore originale (con segno)
          var rawVal = params.data.rawValue;
          var signStr = (rawVal < 0) ? '-' : '';
          var absVal  = Math.abs(rawVal).toFixed(1);
          return (
            '<strong>' + params.name + '</strong><br/>' +
            'Value: US$' + signStr + absVal + 'b'
          );
        }
      },

      series: [
        {
          name: 'Assets',
          type: 'treemap',
          left: '0%',
          top: 0,
          bottom: 0,
          width: '50%',
          roam: false,
          nodeClick: false,
          breadcrumb: { show: false },
          label: {
            show: true,
            position: 'insideTopLeft',
            color: '#fff',
            fontSize: 14
          },
          data: [
            {
              name: 'Assets',
              children: assetsChildren
            }
          ]
        },
        {
          name: 'Liabilities + Equity',
          type: 'treemap',
          left: '50%',
          top: 0,
          bottom: 0,
          width: '50%',
          roam: false,
          nodeClick: false,
          breadcrumb: { show: false },
          label: {
            show: true,
            position: 'insideTopLeft',
            color: '#fff',
            fontSize: 14
          },
          data: [
            {
              name: 'Liabilities + Equity',
              children: liabChildren
            }
          ]
        }
      ]
    };

    // Inizializziamo il grafico
    var chartDom = document.getElementById('chart');
    var myChart = echarts.init(chartDom);
    myChart.setOption(option);
  </script>
</body>
</html>
''';