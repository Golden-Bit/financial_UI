final raw_html = '''
<!DOCTYPE html>
<html lang="it">
<head>
  <meta charset="UTF-8">
  <title>Radar Chart con Vertici Draggabili (White Markers e Grid)</title>
  <script src="https://d3js.org/d3.v7.min.js"></script>
  <style>
    body {
      font-family: Arial, sans-serif;
      background-color: #222; /* Sfondo scuro */
      color: white;
      margin: 20px;
    }
    h1 {
      text-align: center;
      color: white;
    }
    svg {
      background-color: #333; /* Sfondo svg scuro */
      border: 1px solid #444;
      box-shadow: 0 0 8px rgba(0,0,0,0.5);
      display: block;
      margin: 0 auto;
    }
    .axis {
      stroke: #555;
      stroke-width: 1;
    }
    .polygon {
      stroke-width: 2;
    }
    .vertex {
      fill: white; /* Marker draggabili in bianco */
      cursor: pointer;
      stroke-width: 2;
    }
    .label {
      font-size: 12px;
      text-anchor: middle;
      fill: white;
    }
    /* Griglia con cerchi concentrici bianchi marcati */
    .grid {
      fill: none;
      stroke: white;
      stroke-opacity: 0.8;
      stroke-width: 1.5;
    }
    /* Tooltip styling */
    #tooltip {
      position: absolute;
      background: rgba(0,0,0,0.85);
      color: #fff;
      padding: 6px 8px;
      border-radius: 4px;
      font-size: 12px;
      pointer-events: none;
      opacity: 0;
      transition: opacity 0.2s ease-in-out;
    }
  </style>
</head>
<body>
  <h1>Radar Chart con Vertici Draggabili (White Markers e Grid)</h1>
  <div id="chart"></div>
  <div id="tooltip"></div>
  <script>
    // Dimensioni e costanti
    const width = 500, height = 500;
    const radius = 150;
    const centerX = width / 2, centerY = height / 2;
    
    // Definizione degli indicatori (0-10) con valore iniziale
    const indicators = [
      { name: 'Dividend', max: 10, value: 7 },
      { name: 'Value',    max: 10, value: 8 },
      { name: 'Future',   max: 10, value: 6 },
      { name: 'Past',     max: 10, value: 5 },
      { name: 'Health',   max: 10, value: 9 }
    ];
    const n = indicators.length;
    
    // Crea l'elemento SVG
    const svg = d3.select("#chart")
      .append("svg")
      .attr("width", width)
      .attr("height", height);
    
    // Disegna gli assi radiali
    for (let i = 0; i < n; i++) {
      const angle = (2 * Math.PI / n) * i - Math.PI / 2;
      const x = centerX + radius * Math.cos(angle);
      const y = centerY + radius * Math.sin(angle);
      svg.append("line")
         .attr("class", "axis")
         .attr("x1", centerX)
         .attr("y1", centerY)
         .attr("x2", x)
         .attr("y2", y);
    }
    
    // Funzione che calcola la posizione [x,y] per un indicatore in base al suo valore
    function pointForIndicator(ind, i) {
      const angle = (2 * Math.PI / n) * i - Math.PI / 2;
      const r = (ind.value / ind.max) * radius;
      return [centerX + r * Math.cos(angle), centerY + r * Math.sin(angle)];
    }
    
    // Disegna la griglia (cerchi concentrici) con class "grid"
    const gridLevels = 5;
    for (let i = 1; i <= gridLevels; i++) {
      svg.append("circle")
         .attr("class", "grid")
         .attr("cx", centerX)
         .attr("cy", centerY)
         .attr("r", radius * i / gridLevels);
    }
    
    // Disegna le etichette degli indicatori
    indicators.forEach((d, i) => {
      const angle = (2 * Math.PI / n) * i - Math.PI / 2;
      const labelRadius = radius + 20;
      const x = centerX + labelRadius * Math.cos(angle);
      const y = centerY + labelRadius * Math.sin(angle);
      svg.append("text")
         .attr("class", "label")
         .attr("x", x)
         .attr("y", y)
         .text(d.name);
    });
    
    // Disegna il poligono che collega i vertici
    let radarPolygon = svg.append("polygon")
      .attr("class", "polygon")
      .attr("points", indicators.map((d, i) => pointForIndicator(d, i).join(",")).join(" "));
    
    // Crea una scala lineare per il colore: dominio [0,10] con breakpoints a 0, 5, 6, 10
    const colorScale = d3.scaleLinear()
      .domain([0, 5, 6, 10])
      .range([
        "rgba(255,0,0,0.95)",    // rosso
        "rgba(255,165,0,0.95)",  // arancione
        "rgba(255,255,0,0.95)",  // giallo
        "rgba(144,238,144,0.95)" // light green
      ]);
    
    // Funzione per aggiornare il poligono e il colore di riempimento in base alla media
    function updatePolygon() {
      const points = indicators.map((d, i) => pointForIndicator(d, i).join(",")).join(" ");
      radarPolygon.attr("points", points);
      
      // Calcola la media dei valori degli indicatori
      const avg = d3.mean(indicators, d => d.value);
      const fillColor = colorScale(avg);
      radarPolygon.attr("fill", fillColor);
      
      // Calcola il colore di bordo scurendo leggermente il colore interno
      const borderColor = d3.rgb(fillColor).darker(0.7).toString();
      radarPolygon.attr("stroke", borderColor);
      
      // Aggiorna il bordo dei marker (pallini)
      svg.selectAll(".vertex")
         .attr("stroke", borderColor);
    }
    
    // Gestione del tooltip sul poligono
    const tooltip = d3.select("#tooltip");
    radarPolygon
      .on("mousemove", (event) => {
        const tooltipText = indicators.map(d => `${d.name}: ${d.value.toFixed(2)}`).join("<br/>");
        tooltip
          .html(tooltipText)
          .style("left", (event.pageX + 10) + "px")
          .style("top", (event.pageY + 10) + "px")
          .style("opacity", 1);
      })
      .on("mouseout", () => {
        tooltip.style("opacity", 0);
      });
    
    // Disegna i marker draggabili per ogni vertice (marker in bianco)
    let vertices = svg.selectAll(".vertex")
      .data(indicators)
      .enter()
      .append("circle")
      .attr("class", "vertex")
      .attr("r", 8)
      .attr("cx", (d, i) => pointForIndicator(d, i)[0])
      .attr("cy", (d, i) => pointForIndicator(d, i)[1])
      .attr("stroke", d3.rgb(colorScale(d3.mean(indicators, d => d.value))).darker(0.7).toString())
      .call(d3.drag()
        .on("drag", function(event, d) {
          const index = indicators.indexOf(d);
          const dx = event.x - centerX;
          const dy = event.y - centerY;
          let newDistance = Math.sqrt(dx * dx + dy * dy);
          if (newDistance > radius) newDistance = radius;
          d.value = (newDistance / radius) * d.max;
          const newX = centerX + newDistance * Math.cos((2 * Math.PI / n) * index - Math.PI/2);
          const newY = centerY + newDistance * Math.sin((2 * Math.PI / n) * index - Math.PI/2);
          d3.select(this)
            .attr("cx", newX)
            .attr("cy", newY);
          updatePolygon();
        })
      );
    
    // Inizializza il poligono
    updatePolygon();
  </script>
</body>
</html>
''';