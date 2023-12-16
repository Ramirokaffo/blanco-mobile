

class Supply {
  late int? id;
  late int? productCount;
  late int? productCountRest;
  late double? unitPrice;
  // late String? state;
  // late bool? isValid = true;
  // late bool? wasBecauseSponsored;
  // late Sale? basket;
  // late Product? product;
  // late Deliver? deliver;

  late int? localId;
  static int staticLocalId = 0;

  Supply({
    this.id,
    this.productCount,
    this.productCountRest,
    // this.isValid,
    this.unitPrice,
    // this.wasBecauseSponsored,
    // this.basket,
    // this.product,
  }) {
    localId = staticLocalId++;
    // isValid
  }

  Supply.fromMap(Map<String, dynamic>? supply) {
    if (supply != null) {
      id = supply["id"];
      productCount = supply["product_count"];
      productCountRest = supply["product_count_rest"];
      // isPaid = basketArticle["is_paid"];
      unitPrice = supply["unit_price"];
    } else {
      id = null;
      productCount = 0;
      productCountRest = 0;
      unitPrice = 0;
    }
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
      // "product_id": product!.id
    };
  }


}
