import 'dart:html' as html;
import 'dart:ui' as ui;
import 'package:flutter/widgets.dart';

/// Widget Flutter per integrare il TradingView "Screener Widget".
/// Puoi configurare:
/// - Dimensioni (width, height) o l'uso di container size
/// - Mercato (market) e le relative opzioni (ad es. 'forex', 'crypto', 'america', ecc.)
/// - Colonne e screen di default (defaultColumn, defaultScreen)
/// - Toolbar e trasparenza
/// - Tema (dark / light)
/// - Locale per la lingua
/// - URL di chart esterna (largeChartUrl)
/// 
/// Per maggiori dettagli sui parametri consultare la documentazione ufficiale:
/// https://www.tradingview.com/widget/screener/
class TradingViewScreener extends StatelessWidget {
  /// Larghezza del widget. Può essere un valore numerico (es. "600") oppure "100%".
  final String width;

  /// Altezza in pixel del widget. Se preferisci dimensioni “responsive”, puoi
  /// impostare width="100%" e height="100%" e incapsulare il widget in un container
  /// con dimensioni definite.
  final int height;

  /// Indica quale colonna mostrare di default. Possibili valori tipici:
  /// "overview", "performance", "oscillators", "moving_averages"
  /// (vedi docs ufficiali per lista completa).
  final String defaultColumn;

  /// Indica quale screen mostrare di default. Possibili valori:
  /// "general", "top_gainers", "top_losers", "ath", "atl", "above_52wk_high", "below_52wk_low", ecc.
  final String defaultScreen;

  /// Seleziona il mercato (Exchange) da screener. Ad esempio:
  /// "forex", "crypto", "america", "brazil", "germany", ecc.
  /// (vedi docs e snippet HTML per la lista completa).
  final String market;

  /// Mostra o meno la toolbar in alto.
  final bool showToolbar;

  /// Se impostato a "dark" o "light" cambia il tema dei colori del widget.
  final String colorTheme;

  /// Locale (lingua) del widget. Esempi: "en", "it", "de_DE", "fr", ecc.
  final String locale;

  /// URL di una eventuale pagina contenente un grafico a schermo intero a cui reindirizzare
  /// quando l'utente clicca su "vedi grafico più grande".
  /// Se vuoto, reindirizza di default alla pagina di TradingView.
  final String largeChartUrl;

  /// Se true, lo sfondo del widget sarà trasparente (utile per integrare su sfondi custom).
  final bool isTransparent;

  TradingViewScreener({
    Key? key,
    this.width = "100%",
    this.height = 550,
    this.defaultColumn = "overview",
    this.defaultScreen = "general",
    this.market = "forex",
    this.showToolbar = true,
    this.colorTheme = "dark",
    this.locale = "en",
    this.largeChartUrl = "",
    this.isTransparent = false,
  }) : super(key: key) {
    // Genera un ID univoco per la view factory
    final String viewId =
        'tradingview-screener-${DateTime.now().millisecondsSinceEpoch}';

    // Crea la configurazione JSON in base ai parametri
    final String config = '''
{
  "width": "$width",
  "height": "$height",
  "defaultColumn": "$defaultColumn",
  "defaultScreen": "$defaultScreen",
  "market": "$market",
  "showToolbar": ${showToolbar.toString()},
  "colorTheme": "$colorTheme",
  "locale": "$locale",
  "largeChartUrl": "$largeChartUrl",
  "isTransparent": ${isTransparent.toString()}
}
''';

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
      <script type="text/javascript" src="https://s3.tradingview.com/external-embedding/embed-widget-screener.js" async>
      $config
      </script>
    </div>
    <!-- TradingView Widget END -->
  </body>
</html>
""";

    // Crea un Blob HTML e genera un URL oggetto
    final blob = html.Blob([htmlContent], 'text/html');
    final url = html.Url.createObjectUrlFromBlob(blob);

    // Crea l'elemento IFrame per visualizzare il contenuto HTML
    final html.IFrameElement iFrameElement = html.IFrameElement()
      ..src = url
      ..style.border = 'none'
      ..width = '100%'
      ..height = '${height}';

    // Registra la view factory con l'id univoco
    ui.platformViewRegistry.registerViewFactory(viewId, (int viewId) => iFrameElement);
    _viewId = viewId;
  }

  late final String _viewId;

  @override
  Widget build(BuildContext context) {
    // Il widget viene inserito in uno SizedBox che prende la dimensione desiderata
    return SizedBox(
      // Se 'width' è un numero, puoi convertirlo in double, altrimenti fallback a infinity
      width: double.tryParse(width) ?? double.infinity,
      height: height.toDouble(),
      child: HtmlElementView(viewType: _viewId),
    );
  }
}
