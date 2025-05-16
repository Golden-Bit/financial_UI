import 'dart:html' as html;
import 'dart:ui' as ui;
import 'package:flutter/widgets.dart';

/// Widget Flutter per integrare il TradingView "Single Ticker Widget"
/// Mostra il prezzo e la variazione percentuale per il simbolo indicato.
class TradingViewSingleQuote extends StatelessWidget {
  final String symbol;
  final int width; // larghezza in pixel per il widget
  final bool isTransparent;
  final String colorTheme;
  final String locale;
  final String largeChartUrl;
  final double height; // altezza in pixel per il widget

  TradingViewSingleQuote({
    Key? key,
    required this.symbol,
    required this.width,
    this.isTransparent = false,
    this.colorTheme = "dark",
    this.locale = "en",
    this.largeChartUrl = "https://mylargechart",
    this.height = 100.0, // puoi modificare l'altezza di default in base alle tue necessità
  }) : super(key: key) {
    // Genera un id univoco per il widget
    final String viewId =
        'tradingview-single-quote-${symbol.hashCode}-${DateTime.now().millisecondsSinceEpoch}';

    // Crea il contenuto HTML dinamico sostituendo i parametri
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
      <script type="text/javascript" src="https://s3.tradingview.com/external-embedding/embed-widget-single-quote.js" async>
      {
        "symbol": "$symbol",
        "width": $width,
        "isTransparent": $isTransparent,
        "colorTheme": "$colorTheme",
        "locale": "$locale",
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

    // Registra la view factory con l'id univoco
    ui.platformViewRegistry.registerViewFactory(viewId, (int viewId) => iFrameElement);
    _viewId = viewId;
  }

  late final String _viewId;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width.toDouble(),
      height: height,
      child: HtmlElementView(viewType: _viewId),
    );
  }
}
