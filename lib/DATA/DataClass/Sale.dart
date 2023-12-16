

import 'package:dio/dio.dart';

import '../../LocalBdManager/LocalBdManager.dart';
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
    isPaid = basket["is_paid"] == 1;
    isCredit = basket["is_credit"] == 1;
    createAt = basket["create_at"];
    deleteAt = basket["delete_at"];
    total = double.tryParse(basket["total"]);
    // deliveredDate = basket["deliveredDate"];
    // paymentMethod = PaymentMethod.fromMap((basket["paymentMethod"] as Map<String, dynamic>));
  }


  Map<String, dynamic> toSendMapDto() {
    return {
      "sale_products": saleProducts?.map((SaleProduct basketArticle) => basketArticle.toSendMapDto()).toList(),
    };
  }

  double getTotalPrice() {
    return saleProducts!.fold(0.0, (previousValue, SaleProduct basketArticle) => previousValue + basketArticle.getTotalPrice());
  }


  Future createBasket({void Function(double progess)? progressCallBack, String? serverUri}) async {
    CancelToken cancelToken = CancelToken();
    var dio = dioConstructor(serverUri?? await LocalBdManager.localBdSelectSetting("serverUri"));
    print(toSendMapDto());
    var response = await dio.post(
      "/sale?current_sale=${addToCurrentSale!? 1: 0}",
      data: toSendMapDto(),
      cancelToken: cancelToken,
      onSendProgress: (count, total) {
        if (progressCallBack != null) {
          progressCallBack(count / total);
        }
        print("Count: $count");
        print("Total: $total");
      },
    );
    if (response.statusCode != 201) {
      print(response.statusMessage);
      print(response.extra);
      print(response.headers);
      print(response.data);
      throw Exception();
    }

  }


}