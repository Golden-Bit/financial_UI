import 'dart:html' as html;
import 'dart:ui' as ui;
import 'package:flutter/widgets.dart';

/// Widget Flutter per integrare il TradingView "Fundamental Data Widget"
class TradingViewFundamentalData extends StatelessWidget {
  final bool isTransparent;
  final String largeChartUrl;
  final String displayMode;
  final int width; // larghezza in pixel
  final int height; // altezza in pixel
  final String colorTheme;
  final String symbol;
  final String locale;

  TradingViewFundamentalData({
    Key? key,
    required this.isTransparent,
    required this.largeChartUrl,
    required this.displayMode,
    required this.width,
    required this.height,
    required this.colorTheme,
    required this.symbol,
    required this.locale,
  }) : super(key: key) {
    // Genera un ID univoco per il widget
    final String viewId = 'tradingview-fundamental-data-${symbol.hashCode}-${DateTime.now().millisecondsSinceEpoch}';

    // Crea il contenuto HTML dinamico con i parametri sostituiti
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
      <script type="text/javascript" src="https://s3.tradingview.com/external-embedding/embed-widget-financials.js" async>
      {
        "isTransparent": $isTransparent,
        "largeChartUrl": "$largeChartUrl",
        "displayMode": "$displayMode",
        "width": $width,
        "height": $height,
        "colorTheme": "$colorTheme",
        "symbol": "$symbol",
        "locale": "$locale"
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

    // Registra il view factory con l'ID univoco
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
