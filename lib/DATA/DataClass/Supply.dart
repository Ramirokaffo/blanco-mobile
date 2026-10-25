

import '../HttpRequest/ApiHelper.dart';

/// Ancien "bon approvisionnement" du serveur Flask. L'API Django porte le prix
/// de vente et le dernier prix d'achat sur le produit ; cette classe sert
/// seulement à les présenter à l'interface existante.
class Supply {
  late int? id;
  late int? productCount;
  late int? productCountRest;
  late double? unitPrice;
  late double? unitCoast;
  late int? localId;
  static int staticLocalId = 0;

  Supply({
    this.id,
    this.productCount,
    this.productCountRest,
    this.unitPrice,
    this.unitCoast,
  }) {
    localId = staticLocalId++;
  }

  Supply.fromMap(Map<String, dynamic>? supply) {
    if (supply != null) {
      id = supply["id"];
      productCount = toInt(supply["product_count"]);
      productCountRest = toInt(supply["product_count_rest"]);
      unitPrice = toDouble(supply["unit_price"]);
      unitCoast = toDouble(supply["unit_coast"]);
    } else {
      id = null;
      productCount = 0;
      productCountRest = 0;
      unitPrice = 0;
      unitCoast = 0;
    }
  }
}
