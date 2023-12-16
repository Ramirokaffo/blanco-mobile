

import 'package:image_to_text/DATA/DataClass/Product.dart';

import '../HttpRequest/dioConstructor.dart';
import 'Sale.dart';

class SaleProduct {
  late int? id;
  late int? productCount;
  late double? unitPrice;
  late String? state;
  late bool? isValid = true;
  late bool? wasBecauseSponsored;
  late Sale? basket;
  late Product? product;
  // late Deliver? deliver;

  late int? localId;
  static int staticLocalId = 0;

  SaleProduct({
    this.id,
    this.productCount,
    this.state,
    this.isValid,
    this.unitPrice,
    this.wasBecauseSponsored,
    this.basket,
    this.product,
  }) {
    localId = staticLocalId++;
    // isValid
  }

  SaleProduct.fromMap(Map<String, dynamic> basketArticle) {
    id = basketArticle["id"];
    productCount = basketArticle["article_count"];
    // isPaid = basketArticle["is_paid"];
    unitPrice = basketArticle["unit_price"].toDouble();
  }

  // static Future<List<BasketArticle>?>? getPopularBasketArticle(String serverUri, {int count = 0, int page = 0}) async {
  //   try {
  //     List<BasketArticle> listArticle = [];
  //     var dio = dioConstructor(serverUri);
  //     var response = await dio.get([getPopularBasketArticleRoute, count, page].join("/"));
  //     if (response.statusCode == 200) {
  //       print(response.data);
  //       for (var element in response.data) {
  //         listArticle.add(BasketArticle.fromMap(element));
  //       }
  //       return listArticle;
  //     } else {
  //       print(response.extra);
  //       throw Exception();
  //
  //     }
  //
  //   } catch (e) {
  //     print(e);
  //     throw Exception(e);
  //   }
  //   return null;
  // }



  Map<String, dynamic> toSendMapDto() {
    return {
      "product_count": productCount,
      "unit_price": unitPrice,
      "product_id": product!.id
    };
  }

  double getTotalPrice() {
    return productCount! * unitPrice!;
  }


  // double getRightArticleUnitPrice() {
  //   return 30;
  // }
}
