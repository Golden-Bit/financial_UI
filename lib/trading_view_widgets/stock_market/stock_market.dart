import 'dart:html' as html;
import 'dart:ui' as ui;
import 'package:flutter/widgets.dart';

/// Widget Flutter per integrare il TradingView "Stock Market Widget"
class TradingViewStockMarketWidget extends StatelessWidget {
  final String colorTheme;
  final String dateRange;
  final String exchange;
  final bool showChart;
  final String locale;
  final String width; // es. "100%" oppure valore numerico in stringa
  final int height;   // Altezza in pixel (es. 700)
  final String largeChartUrl;
  final bool isTransparent;
  final bool showSymbolLogo;
  final bool showFloatingTooltip;
  final String plotLineColorGrowing;
  final String plotLineColorFalling;
  final String gridLineColor;
  final String scaleFontColor;
  final String belowLineFillColorGrowing;
  final String belowLineFillColorFalling;
  final String belowLineFillColorGrowingBottom;
  final String belowLineFillColorFallingBottom;
  final String symbolActiveColor;

  TradingViewStockMarketWidget({
    Key? key,
    this.colorTheme = "dark",
    this.dateRange = "12M",
    this.exchange = "US",
    this.showChart = true,
    this.locale = "en",
    this.width = "100%",
    this.height = 700,
    this.largeChartUrl = "https://mylargechart",
    this.isTransparent = false,
    this.showSymbolLogo = false,
    this.showFloatingTooltip = true,
    this.plotLineColorGrowing = "rgba(41, 98, 255, 1)",
    this.plotLineColorFalling = "rgba(41, 98, 255, 1)",
    this.gridLineColor = "rgba(42, 46, 57, 0)",
    this.scaleFontColor = "rgba(219, 219, 219, 1)",
    this.belowLineFillColorGrowing = "rgba(41, 98, 255, 0.12)",
    this.belowLineFillColorFalling = "rgba(41, 98, 255, 0.12)",
    this.belowLineFillColorGrowingBottom = "rgba(41, 98, 255, 0)",
    this.belowLineFillColorFallingBottom = "rgba(41, 98, 255, 0)",
    this.symbolActiveColor = "rgba(41, 98, 255, 0.12)",
  }) : super(key: key) {
    // Genera un ID univoco per la view factory
    final String viewId =
        'tradingview-stock-market-${DateTime.now().millisecondsSinceEpoch}';

    // Crea il contenuto HTML sostituendo i parametri
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
      <script type="text/javascript" src="https://s3.tradingview.com/external-embedding/embed-widget-hotlists.js" async>
      {
        "colorTheme": "$colorTheme",
        "dateRange": "$dateRange",
        "exchange": "$exchange",
        "showChart": ${showChart.toString()},
        "locale": "$locale",
        "width": "$width",
        "height": "$height",
        "largeChartUrl": "$largeChartUrl",
        "isTransparent": ${isTransparent.toString()},
        "showSymbolLogo": ${showSymbolLogo.toString()},
        "showFloatingTooltip": ${showFloatingTooltip.toString()},
        "plotLineColorGrowing": "$plotLineColorGrowing",
        "plotLineColorFalling": "$plotLineColorFalling",
        "gridLineColor": "$gridLineColor",
        "scaleFontColor": "$scaleFontColor",
        "belowLineFillColorGrowing": "$belowLineFillColorGrowing",
        "belowLineFillColorFalling": "$belowLineFillColorFalling",
        "belowLineFillColorGrowingBottom": "$belowLineFillColorGrowingBottom",
        "belowLineFillColorFallingBottom": "$belowLineFillColorFallingBottom",
        "symbolActiveColor": "$symbolActiveColor"
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

    // Crea l'elemento IFrame con le dimensioni desiderate
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
      width: double.tryParse(width) ?? double.infinity,
      height: height.toDouble(),
      child: HtmlElementView(viewType: _viewId),
    );
  }
}
