import 'dart:html' as html;
import 'dart:ui' as ui;
import 'package:flutter/widgets.dart';

/// Widget Flutter per integrare il TradingView "Technical Analysis Widget"
class TradingViewTechnicalAnalysis extends StatelessWidget {
  final String interval;
  final String symbol;
  final int width; // larghezza in pixel
  final int height; // altezza in pixel
  final bool isTransparent;
  final bool showIntervalTabs;
  final String displayMode;
  final String locale;
  final String colorTheme;
  final String largeChartUrl;

  TradingViewTechnicalAnalysis({
    Key? key,
    required this.interval,
    required this.symbol,
    required this.width,
    required this.height,
    this.isTransparent = false,
    this.showIntervalTabs = true,
    this.displayMode = "multiple",
    this.locale = "en",
    this.colorTheme = "dark",
    this.largeChartUrl = "http://mylargecharturl",
  }) : super(key: key) {
    // Genera un ID univoco per il widget
    final String viewId = 'tradingview-technical-analysis-${symbol.hashCode}-${DateTime.now().millisecondsSinceEpoch}';

    // Crea il contenuto HTML sostituendo i parametri
    final String htmlContent = """
<!DOCTYPE html>
<html>
  <head>
    <meta charset="utf-8">
<style>
  html, body { 
    margin: 0; 
    padding: 0; 
    height: 100%; 
    width: 100%; 
  }
</style>
  </head>
  <body>
    <!-- TradingView Widget BEGIN -->
    <div class="tradingview-widget-container">
      <div class="tradingview-widget-container__widget"></div>
      <div class="tradingview-widget-copyright">
        <a href="https://www.tradingview.com/" rel="noopener nofollow" target="_blank">
          <span class="blue-text">Track all markets on TradingView</span>
        </a>
      </div>
      <script type="text/javascript" src="https://s3.tradingview.com/external-embedding/embed-widget-technical-analysis.js" async>
      {
        "interval": "$interval",
        "width": $width,
        "isTransparent": $isTransparent,
        "height": $height,
        "symbol": "$symbol",
        "showIntervalTabs": $showIntervalTabs,
        "displayMode": "$displayMode",
        "locale": "$locale",
        "colorTheme": "$colorTheme",
        "largeChartUrl": "$largeChartUrl"
      }
      </script>
    </div>
    <!-- TradingView Widget END -->
  </body>
</html>
""";

    // Crea un blob HTML e genera un URL oggetto
    final blob = html.Blob([htmlContent], 'text/html');
    final url = html.Url.createObjectUrlFromBlob(blob);

    // Crea un elemento IFrame per visualizzare il contenuto HTML
    final html.IFrameElement iFrameElement = html.IFrameElement()
      ..src = url
      ..style.border = 'none'
      ..width = '100%'
      ..height = '$height';

    // Registra il view factory con l'id univoco
    ui.platformViewRegistry.registerViewFactory(viewId, (int viewId) => iFrameElement);
    _viewId = viewId;
  }

  late final String _viewId;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width.toDouble(),
      height: height.toDouble(),
      child: HtmlElementView(viewType: _viewId),
    );
  }
}
