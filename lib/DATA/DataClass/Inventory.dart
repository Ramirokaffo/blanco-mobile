

import 'package:dio/dio.dart';
import 'package:image_to_text/DATA/DataClass/MyUser.dart';
import 'package:image_to_text/DATA/DataClass/Product.dart';

import '../../LocalBdManager/LocalBdManager.dart';
import '../HttpRequest/ApiHelper.dart';
import '../HttpRequest/RouteFile.dart';
import '../HttpRequest/dioConstructor.dart';

class Inventory {

  late int? id;
  late Product? product;
  late int? validProductCount;
  late int? invalidProductCount;
  late MyUser? staff;


  Inventory({
    this.id,
    this.staff,
    this.product,
    this.validProductCount,
    this.invalidProductCount,
  });

  // Category({})

  // Future<List<Category>> getAllCategory() async {
  //   if (allCategoryList.isNotEmpty) {
  //     return allCategoryList;
  //   } else {
  //     try {
  //       var dio = dioConstructor();
  //       var response = await dio.get([getAllCategoryRoute, 0, 0].join("/"));
  //       if (response.statusCode == 200) {
  //         allCategoryList.addAll((response.data as List<dynamic>).map((category) => Category.fromMap(category)));
  //         print(allCategoryList[0].name);
  //         return allCategoryList;
  //       }
  //     } catch (e) {
  //       throw Exception(e);
  //     }
  //   }
  //   return [];
  // }


  Inventory.fromMap(Map<String, dynamic> inventory) {
    id = inventory["id"];
    product = Product(id: inventory["product"], name: inventory["product_name"], code: inventory["product_code"]);
    staff = null;
    validProductCount = inventory["valid_product_count"];
    invalidProductCount = inventory["invalid_product_count"];
  }

  Map<String, dynamic> toSendMapDto() {
    return {
      "product_id": product!.id!,
      "valid_product_count": validProductCount,
      "invalid_product_count": invalidProductCount?? 0,
    };
  }

  Future<Inventory?> save({String? route, String? serverUri}) async {
    try {
      CancelToken cancelToken = CancelToken();
      var dio = dioConstructor(serverUri?? await LocalBdManager.localBdSelectSetting("serverUri"));
      var response = await dio.post(route?? createInventoryRoute, data: toSendMapDto(), cancelToken: cancelToken);
      if ([201, 200].contains(response.statusCode) && response.data["status"] == 1) {
        Inventory inventory = Inventory.fromMap(response.data["inventory"]);
        return inventory;
      } else {
        throw ApiException(extractErrorMessage(response.data), statusCode: response.statusCode);
      }
    } catch (e) {
      print(e);
      rethrow;
    }
  }

}