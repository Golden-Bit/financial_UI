import 'dart:html' as html;
import 'dart:ui' as ui;
import 'dart:convert';
import 'package:flutter/widgets.dart';

/// Widget Flutter per integrare il TradingView "Ticker Tape Widget"
class TradingViewTickerTape extends StatelessWidget {
  /// Lista di simboli, ciascuno rappresentato da una mappa contenente "proName" e "title"
  final List<Map<String, String>> symbols;
  
  /// Mostra o meno il logo del simbolo
  final bool showSymbolLogo;
  
  /// Imposta la trasparenza del widget
  final bool isTransparent;
  
  /// URL per il large chart (opzionale)
  final String largeChartUrl;
  
  /// Modalità di visualizzazione: "adaptive", "regular" oppure "compact"
  final String displayMode;
  
  /// Tema del widget ("dark" o "light")
  final String colorTheme;
  
  /// Lingua (es. "en")
  final String locale;
  
  /// Altezza del widget in pixel (se non specificato, usa 75)
  final double height;

  TradingViewTickerTape({
    Key? key,
    required this.symbols,
    this.showSymbolLogo = true,
    this.isTransparent = false,
    this.largeChartUrl = "",
    this.displayMode = "adaptive",
    this.colorTheme = "dark",
    this.locale = "en",
    this.height = 75.0,
  }) : super(key: key) {
    // Genera un id univoco per il widget
    final String viewId =
        'tradingview-ticker-tape-${symbols.hashCode}-${DateTime.now().millisecondsSinceEpoch}';

    // Converte la lista dei simboli in una stringa JSON
    final String symbolsJson = jsonEncode(symbols);

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
      <script type="text/javascript" src="https://s3.tradingview.com/external-embedding/embed-widget-ticker-tape.js" async>
      {
        "symbols": $symbolsJson,
        "showSymbolLogo": $showSymbolLogo,
        "isTransparent": $isTransparent,
        "largeChartUrl": "$largeChartUrl",
        "displayMode": "$displayMode",
        "colorTheme": "$colorTheme",
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

    // Crea l'elemento IFrame che ospiterà il contenuto HTML
    final html.IFrameElement iFrameElement = html.IFrameElement()
      ..src = url
      ..style.border = 'none'
      ..width = '100%'
      ..height = '100%';

    // Registra il view factory con l'id univoco
    ui.platformViewRegistry.registerViewFactory(viewId, (int viewId) => iFrameElement);
    _viewId = viewId;
  }

  late final String _viewId;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: double.infinity,
      child: HtmlElementView(viewType: _viewId),
    );
  }
}
