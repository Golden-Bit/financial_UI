import 'dart:html' as html;
import 'dart:ui' as ui;
import 'package:flutter/widgets.dart';

/// Widget Flutter per integrare il TradingView "Top Stories" (Timeline) widget.
class TradingViewTopStories extends StatelessWidget {
  /// Modalità del feed: "symbol", "market" oppure "all_symbols"
  final String feedMode;

  /// Se feedMode è "symbol", indica il simbolo (es. "BITSTAMP:BTCUSD").
  final String? symbol;

  /// Se feedMode è "market", indica il mercato (es. "crypto").
  final String? market;

  final bool isTransparent;
  final String largeChartUrl;
  final String displayMode; // "adaptive" o "regular"
  final String width;      // es. "100%"
  final int height;        // altezza in pixel, es. 600
  final String colorTheme; // es. "dark"
  final String locale;     // es. "en"

  TradingViewTopStories({
    Key? key,
    required this.feedMode,
    this.symbol,
    this.market,
    this.isTransparent = false,
    this.largeChartUrl = "",
    this.displayMode = "adaptive",
    this.width = "100%",
    this.height = 600,
    this.colorTheme = "dark",
    this.locale = "en",
  }) : super(key: key) {
    // Genera un ID univoco per la view factory.
    final String viewId =
        'tradingview-top-stories-${DateTime.now().millisecondsSinceEpoch}';

    // Costruisce la configurazione in formato JSON.
    String config = '{\n'
        '  "feedMode": "$feedMode",\n';
    if (feedMode == "symbol" && symbol != null) {
      config += '  "symbol": "$symbol",\n';
    }
    if (feedMode == "market" && market != null) {
      config += '  "market": "$market",\n';
    }
    config += '  "isTransparent": ${isTransparent.toString()},\n'
        '  "largeChartUrl": "$largeChartUrl",\n'
        '  "displayMode": "$displayMode",\n'
        '  "width": "$width",\n'
        '  "height": "$height",\n'
        '  "colorTheme": "$colorTheme",\n'
        '  "locale": "$locale"\n'
        '}';

    // Crea il contenuto HTML sostituendo i parametri.
    final String htmlContent = """
<!DOCTYPE html>
<html>
  <head>
    <meta charset="utf-8">
    <style>
      html, body { margin: 0; padding: 0; height: 100%; }
      .tradingview-widget-container { height: 100%; }
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
      <script type="text/javascript" src="https://s3.tradingview.com/external-embedding/embed-widget-timeline.js" async>
      $config
      </script>
    </div>
    <!-- TradingView Widget END -->
  </body>
</html>
""";

    // Crea un blob HTML e genera un URL oggetto.
    final blob = html.Blob([htmlContent], 'text/html');
    final url = html.Url.createObjectUrlFromBlob(blob);

    // Crea l'elemento IFrame con le dimensioni desiderate.
    final html.IFrameElement iFrameElement = html.IFrameElement()
      ..src = url
      ..style.border = 'none'
      ..width = '100%'
      ..height = '$height';

    // Registra la view factory con l'id univoco.
    ui.platformViewRegistry.registerViewFactory(viewId, (int viewId) => iFrameElement);
    _viewId = viewId;
  }

  late final String _viewId;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.tryParse(width) ?? double.infinity,
      height: height.toDouble(),
      child: HtmlElementView(viewType: _viewId),
    );
  }
}
