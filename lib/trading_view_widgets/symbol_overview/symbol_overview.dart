import 'dart:html' as html;
import 'dart:ui' as ui;
import 'package:flutter/widgets.dart';
import 'dart:convert';

/// Widget Flutter per integrare il TradingView "Symbol Overview Widget"
class TradingViewSymbolOverview extends StatelessWidget {
  /// Lista di coppie [etichetta, simbolo|intervallo], es. [["Apple", "AAPL|1D"], ...]
  final List<List<String>> symbols;
  
  final bool chartOnly;
  /// Parametro da usare nell’embed: es. "100%" o "550"
  final String width;
  /// Parametro da usare nell’embed: es. "100%" o "450"
  final String height;
  final String locale;
  final String colorTheme;
  final bool autosize;
  final bool showVolume;
  final bool showMA;
  final bool hideDateRanges;
  final bool hideMarketStatus;
  final bool hideSymbolLogo;
  final String scalePosition;
  final String scaleMode;
  final String fontFamily;
  final String fontSize;
  final bool noTimeScale;
  final String valuesTracking;
  final String changeMode;
  final String chartType;
  final String maLineColor;
  final int maLineWidth;
  final int maLength;
  final String headerFontSize;
  final int lineWidth;
  final int lineType;
  /// Oggetto per il simbolo di confronto
  final Map<String, dynamic> compareSymbol;
  /// Lista dei range di date
  final List<String> dateRanges;

  TradingViewSymbolOverview({
    Key? key,
    required this.symbols,
    this.chartOnly = false,
    this.width = "100%",
    this.height = "100%",
    this.locale = "en",
    this.colorTheme = "dark",
    this.autosize = true,
    this.showVolume = true,
    this.showMA = true,
    this.hideDateRanges = false,
    this.hideMarketStatus = false,
    this.hideSymbolLogo = false,
    this.scalePosition = "right",
    this.scaleMode = "Normal",
    this.fontFamily = "-apple-system, BlinkMacSystemFont, Trebuchet MS, Roboto, Ubuntu, sans-serif",
    this.fontSize = "10",
    this.noTimeScale = false,
    this.valuesTracking = "1",
    this.changeMode = "price-and-percent",
    this.chartType = "area",
    this.maLineColor = "#2962FF",
    this.maLineWidth = 1,
    this.maLength = 9,
    this.headerFontSize = "medium",
    this.lineWidth = 2,
    this.lineType = 0,
    this.compareSymbol = const {
      "symbol": "AMEX:SPY",
      "lineColor": "#FF9800",
      "lineWidth": 2,
      "showLabels": true
    },
    this.dateRanges = const ["1d|1", "1m|30", "3m|60", "12m|1D", "60m|1W", "all|1M"],
  }) : super(key: key) {
    // Genera un id univoco per il widget
    final String viewId = 'tradingview-symbol-overview-${symbols.hashCode}-${DateTime.now().millisecondsSinceEpoch}';

    // Crea una mappa di configurazione basata sui parametri
    final Map<String, dynamic> config = {
      "symbols": symbols,
      "chartOnly": chartOnly,
      "width": width,
      "height": height,
      "locale": locale,
      "colorTheme": colorTheme,
      "autosize": autosize,
      "showVolume": showVolume,
      "showMA": showMA,
      "hideDateRanges": hideDateRanges,
      "hideMarketStatus": hideMarketStatus,
      "hideSymbolLogo": hideSymbolLogo,
      "scalePosition": scalePosition,
      "scaleMode": scaleMode,
      "fontFamily": fontFamily,
      "fontSize": fontSize,
      "noTimeScale": noTimeScale,
      "valuesTracking": valuesTracking,
      "changeMode": changeMode,
      "chartType": chartType,
      "maLineColor": maLineColor,
      "maLineWidth": maLineWidth,
      "maLength": maLength,
      "headerFontSize": headerFontSize,
      "lineWidth": lineWidth,
      "lineType": lineType,
      "compareSymbol": compareSymbol,
      "dateRanges": dateRanges,
    };

    // Converte la configurazione in JSON
    String configJson = jsonEncode(config);

    // Costruisce il contenuto HTML per l’embed
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
      <script type="text/javascript" src="https://s3.tradingview.com/external-embedding/embed-widget-symbol-overview.js" async>
      $configJson
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
      ..height = '100%';

    // Registra la view factory con l’ID univoco
    ui.platformViewRegistry.registerViewFactory(viewId, (int viewId) => iFrameElement);
    _viewId = viewId;
  }

  late final String _viewId;

  @override
  Widget build(BuildContext context) {
    // Utilizza un SizedBox per definire le dimensioni del widget in Flutter
    return SizedBox(
      width: 700,
      height: 450, // Puoi modificare l’altezza in base alle tue esigenze
      child: HtmlElementView(viewType: _viewId),
    );
  }
}
