

import 'package:dio/dio.dart';

import '../../LocalBdManager/LocalBdManager.dart';
import '../HttpRequest/ApiHelper.dart';
import '../HttpRequest/RouteFile.dart';
import '../HttpRequest/dioConstructor.dart';
import 'SaleProduct.dart';
import 'MyUser.dart';

class Sale {

  late int? id;
  late bool? isPaid;
  late bool? isCredit;
  bool? addToCurrentSale = false;
  late double? total;
  late String? createAt;
  late String? deleteAt;
  late MyUser? buyer;
  late MyUser? seller;
  late List<SaleProduct>? saleProducts;

  Sale({
    this.id,
    // this.deliveredDate,
    this.buyer,
    this.seller,
    this.isPaid,
    this.addToCurrentSale,
    this.isCredit,
    this.total,
    this.createAt,
    this.deleteAt,
    this.saleProducts,
}) {
    addToCurrentSale = false;
  }

  Sale.fromMap(Map<String, dynamic> basket) {
    id = basket["id"];
    isPaid = toBool(basket["is_paid"]);
    isCredit = toBool(basket["is_credit"]);
    createAt = basket["create_at"];
    deleteAt = basket["delete_at"];
    total = toDouble(basket["total"]);
    // deliveredDate = basket["deliveredDate"];
    // paymentMethod = PaymentMethod.fromMap((basket["paymentMethod"] as Map<String, dynamic>));
  }


  Map<String, dynamic> toSendMapDto() {
    return {
      "items": saleProducts?.map((SaleProduct basketArticle) => basketArticle.toSendMapDto()).toList(),
      "payment_method": "CASH",
    };
  }

  double getTotalPrice() {
    return saleProducts!.fold(0.0, (previousValue, SaleProduct basketArticle) => previousValue + basketArticle.getTotalPrice());
  }


  /// Envoie la vente. La vente est rattachée par le serveur à la journée
  /// (Daily) en cours ; l'option "ajouter à la vente courante" n'existe plus.
  Future createBasket({void Function(double progess)? progressCallBack, String? serverUri}) async {
    CancelToken cancelToken = CancelToken();
    var dio = dioConstructor(serverUri?? await LocalBdManager.localBdSelectSetting("serverUri"));
    var response = await dio.post(
      createSaleRoute,
      data: toSendMapDto(),
      cancelToken: cancelToken,
      onSendProgress: (count, total) {
        if (progressCallBack != null && total > 0) {
          progressCallBack(count / total);
        }
      },
    );
    if (![200, 201].contains(response.statusCode) || response.data["status"] != 1) {
      throw ApiException(extractErrorMessage(response.data), statusCode: response.statusCode);
    }
    return response.data;
  }


}