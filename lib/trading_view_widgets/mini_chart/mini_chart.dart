import 'dart:html' as html;
import 'dart:ui' as ui;
import 'package:flutter/widgets.dart';

/// Widget Flutter per integrare il TradingView "Mini Symbol Overview" (Mini Chart Widget)
class TradingViewMiniSymbolOverview extends StatelessWidget {
  /// Il simbolo da visualizzare (es. "FX:EURUSD")
  final String symbol;
  /// Larghezza del widget TradingView, di solito impostata su "100%"
  final String widgetWidth;
  /// Altezza del widget TradingView, di solito impostata su "100%"
  final String widgetHeight;
  /// Lingua (es. "en")
  final String locale;
  /// Intervallo di data (es. "12M")
  final String dateRange;
  /// Tema di colore (es. "dark")
  final String colorTheme;
  /// Se il widget deve essere trasparente
  final bool isTransparent;
  /// Se il widget deve adattarsi automaticamente alle dimensioni del contenitore
  final bool autosize;
  /// URL per il "Large Chart"
  final String largeChartUrl;
  /// Larghezza del contenitore Flutter (in pixel)
  final double containerWidth;
  /// Altezza del contenitore Flutter (in pixel)
  final double containerHeight;

  TradingViewMiniSymbolOverview({
    Key? key,
    required this.symbol,
    this.widgetWidth = "100%",
    this.widgetHeight = "100%",
    this.locale = "en",
    this.dateRange = "12M",
    this.colorTheme = "dark",
    this.isTransparent = false,
    this.autosize = true,
    this.largeChartUrl = "https://mylargechart",
    this.containerWidth = 400.0,
    this.containerHeight = 300.0,
  }) : super(key: key) {
    // Genera un ID univoco per la view
    final String viewId =
        'tradingview-mini-symbol-overview-${symbol.hashCode}-${DateTime.now().millisecondsSinceEpoch}';

    // Crea il contenuto HTML dinamico sostituendo i parametri
    final String htmlContent = """
<!DOCTYPE html>
<html>
  <head>
    <meta charset="utf-8">
    <style>
      html, body { margin: 0; padding: 0; }
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
      <script type="text/javascript" src="https://s3.tradingview.com/external-embedding/embed-widget-mini-symbol-overview.js" async>
      {
        "symbol": "$symbol",
        "width": "$widgetWidth",
        "height": "$widgetHeight",
        "locale": "$locale",
        "dateRange": "$dateRange",
        "colorTheme": "$colorTheme",
        "isTransparent": $isTransparent,
        "autosize": $autosize,
        "largeChartUrl": "$largeChartUrl"
      }
      </script>
    </div>
    <!-- TradingView Widget END -->
  </body>
</html>
""";

    // Crea un Blob HTML e genera un URL oggetto
    final blob = html.Blob([htmlContent], 'text/html');
    final url = html.Url.createObjectUrlFromBlob(blob);

    // Crea un elemento IFrame per visualizzare il contenuto HTML
    final html.IFrameElement iFrameElement = html.IFrameElement()
      ..src = url
      ..style.border = 'none'
      ..width = '100%'
      ..height = '$containerHeight';

    // Registra la view factory con l'id univoco
    ui.platformViewRegistry.registerViewFactory(viewId, (int viewId) => iFrameElement);
    _viewId = viewId;
  }

  late final String _viewId;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: containerWidth,
      height: containerHeight,
      child: HtmlElementView(viewType: _viewId),
    );
  }
}
