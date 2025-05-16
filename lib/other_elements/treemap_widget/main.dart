
import 'package:flutter/material.dart';
import 'package:flutter_financials/other_elements/treemap_widget/treemap_widget.dart';

/// Esempio di uso in un main separato.
/// Questo main crea un'app Flutter con un AppBar e utilizza il widget TreemapEchartsWidget
/// per visualizzare un treemap configurabile con dati per "Assets" e "Liabilities + Equity".
void main() {
  runApp(
    MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text("Treemap ECharts Example")),
        body: Center(
          child: TreemapEchartsWidget(
            title: "Assets | Liabilities + Equity",
            widthPx: 800,
            heightPx: 500,
            groups: [
              // Gruppo "Assets" (sinistra)
              TreemapGroupData(
                groupName: "Assets",
                left: "0%",
                width: "50%",
                items: [
                  TreemapItemData(
                    name: "Cash & Short Term Investments",
                    value: 43.2,
                    colorHex: "#3AA76D",
                    borderColorHex: "#000",
                    borderWidth: 1,
                    textColorHex: "#fff",
                  ),
                  TreemapItemData(
                    name: "Long Term & Other Assets",
                    value: 27.2,
                    colorHex: "#3AA76D",
                    borderColorHex: "#000",
                    borderWidth: 1,
                    textColorHex: "#fff",
                  ),
                  TreemapItemData(
                    name: "Receivables",
                    value: 23.1,
                    colorHex: "#3AA76D",
                    borderColorHex: "#000",
                    borderWidth: 1,
                    textColorHex: "#fff",
                  ),
                  TreemapItemData(
                    name: "Inventory",
                    value: 10.1,
                    colorHex: "#3AA76D",
                    borderColorHex: "#000",
                    borderWidth: 1,
                    textColorHex: "#fff",
                  ),
                  TreemapItemData(
                    name: "Physical Assets",
                    value: 8.2,
                    colorHex: "#3AA76D",
                    borderColorHex: "#000",
                    borderWidth: 1,
                    textColorHex: "#fff",
                  ),
                ],
              ),
              // Gruppo "Liabilities + Equity" (destra)
              TreemapGroupData(
                groupName: "Liabilities + Equity",
                left: "50%",
                width: "50%",
                items: [
                  TreemapItemData(
                    name: "Equity",
                    value: 79.3,
                    colorHex: "#3AA76D",
                    borderColorHex: "#000",
                    borderWidth: 1,
                    textColorHex: "#fff",
                  ),
                  TreemapItemData(
                    name: "Other Liabilities",
                    value: 17.5,
                    colorHex: "#3AA76D",
                    borderColorHex: "#000",
                    borderWidth: 1,
                    textColorHex: "#fff",
                  ),
                  // Valore negativo: apparirà in rosso e il valore mostrato in riquadro sarà in valore assoluto.
                  TreemapItemData(
                    name: "Debt",
                    value: -8.5,
                    colorHex: "#3AA76D", // il widget gestirà il colore negativo
                    borderColorHex: "#000",
                    borderWidth: 1,
                    textColorHex: "#fff",
                  ),
                  TreemapItemData(
                    name: "Accounts Payable",
                    value: 6.3,
                    colorHex: "#3AA76D",
                    borderColorHex: "#000",
                    borderWidth: 1,
                    textColorHex: "#fff",
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ),
  );
}