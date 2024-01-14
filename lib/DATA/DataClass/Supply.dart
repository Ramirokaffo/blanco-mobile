

import 'package:dio/dio.dart';

import '../../LocalBdManager/LocalBdManager.dart';
import '../HttpRequest/dioConstructor.dart';
import 'MyUser.dart';

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
      productCount = supply["product_count"];
      productCountRest = supply["product_count_rest"];
      unitPrice = supply["unit_price"];
      unitCoast = supply["unit_coast"];
    } else {
      id = null;
      productCount = 0;
      productCountRest = 0;
      unitPrice = 0;
      unitCoast = 0;
    }
  }

  Map<String, dynamic> toSendMapDto() {
    return {
      "id": id,
      "product_count": productCount,
      "unit_price": unitPrice,
      "unit_coast": unitCoast,
    };
  }


  Future update({String? serverUri, void Function(double progess)? progressCallBack, CancelToken? cancelToken}) async {
    var dio = dioConstructor(serverUri?? await LocalBdManager.localBdSelectSetting("serverUri"), extraHeader: {"userId": MyUser.currentUser.id});
    var response = await dio.post(
      '/update_supply',
      data: toSendMapDto(),
      cancelToken: cancelToken,
      onSendProgress: (count, total) {
        if (progressCallBack != null) {
          progressCallBack(count / total);
        }
      },
    );
    if ([201, 200].contains(response.statusCode)) {
      return response.data;
    } else {
      throw Exception();
    }
  }


}
