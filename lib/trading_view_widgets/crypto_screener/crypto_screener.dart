import 'dart:html' as html;
import 'dart:ui' as ui;
import 'package:flutter/widgets.dart';

/// Widget Flutter per integrare il TradingView "Cryptocurrency Market Widget".
/// È basato sullo Screener, ma con screener_type impostato a "crypto_mkt".
/// 
/// Parametri configurabili (tra gli altri):
///   - width, height (dimensioni widget)
///   - displayCurrency (USD / BTC)
///   - defaultColumn (overview / performance / oscillators / moving_averages)
///   - colorTheme (light / dark)
///   - locale (en, it, es, fr, de_DE, ecc.)
///   - isTransparent (sfondo trasparente o opaco)
///   - largeChartUrl (URL a cui reindirizzare per un grafico a schermo intero)
/// 
/// Per maggiori dettagli consultare la doc ufficiale:
/// https://www.tradingview.com/widget/screener/
class TradingViewCryptoMarket extends StatelessWidget {
  /// Larghezza del widget (es. "100%" o "800").
  final String width;

  /// Altezza in pixel del widget (es. 550).
  final int height;

  /// Colonna predefinita. Esempi: "overview", "performance", "oscillators", "moving_averages".
  final String defaultColumn;

  /// Currency di visualizzazione (es. "USD" o "BTC").
  final String displayCurrency;

  /// Tema colori widget, "light" o "dark".
  final String colorTheme;

  /// Lingua (locale) del widget, es. "en", "it", "de_DE".
  final String locale;

  /// Se `true`, il widget avrà uno sfondo trasparente.
  final bool isTransparent;

  /// URL verso una pagina contenente un grafico a schermo intero a cui reindirizzare.
  /// Se vuoto, verrà usata la pagina TradingView di default.
  final String largeChartUrl;

  TradingViewCryptoMarket({
    Key? key,
    this.width = "100%",
    this.height = 550,
    this.defaultColumn = "overview",
    this.displayCurrency = "USD",
    this.colorTheme = "dark",
    this.locale = "en",
    this.isTransparent = false,
    this.largeChartUrl = "",
  }) : super(key: key) {
    // Genera un ID univoco per la view factory
    final String viewId =
        'tradingview-crypto-market-${DateTime.now().millisecondsSinceEpoch}';

    // Crea la configurazione JSON
    final String config = '''
{
  "width": "$width",
  "height": "$height",
  "defaultColumn": "$defaultColumn",
  "screener_type": "crypto_mkt",
  "displayCurrency": "$displayCurrency",
  "colorTheme": "$colorTheme",
  "locale": "$locale",
  "isTransparent": ${isTransparent.toString()},
  "largeChartUrl": "$largeChartUrl"
}
''';

    // Crea il contenuto HTML
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
      <script type="text/javascript" src="https://s3.tradingview.com/external-embedding/embed-widget-screener.js" async>
      $config
      </script>
    </div>
    <!-- TradingView Widget END -->
  </body>
</html>
""";

    // Crea un blob HTML e genera un URL oggetto
    final blob = html.Blob([htmlContent], 'text/html');
    final url = html.Url.createObjectUrlFromBlob(blob);

    // Crea l'elemento IFrame
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
