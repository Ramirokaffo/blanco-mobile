

import 'package:dio/dio.dart';
import 'package:image_to_text/DATA/DataClass/Category.dart';
import 'package:image_to_text/DATA/DataClass/Gamme.dart';
import 'package:image_to_text/DATA/DataClass/GrammageType.dart';
import 'package:image_to_text/DATA/DataClass/MyUser.dart';

import '../../LocalBdManager/LocalBdManager.dart';
import '../HttpRequest/RouteFile.dart';
import '../HttpRequest/dioConstructor.dart';
import 'ProductImage.dart';
import 'Rayon.dart';
import 'Supply.dart';

class Product {

  late int? id;
  late String? name;
  late String? code;
  late String? description;
  late String? brand;
  late String? color;
  late int? stockLimit;
  late int? stock;
  late double? maxSalablePrice;
  late double? unitPrice;
  late int? expAlertPeriod;
  late String? deleteAt;
  late String? createAt;
  late double? grammage;
  late GrammageType? grammageType;
  late int? grammageTypeId;
  late Category? category;
  late int? categoryId;
  late int? rayonId;
  late int? gammeId;
  late Gamme? gamme;
  late Rayon? rayon;
  late bool? isPriceReducible;
  late List<ProductImage>? images;
  late Supply? rightSupply;

  Product({
    this.id,
    this.name,
    this.code,
    this.brand,
    this.description,
    this.color,
    this.maxSalablePrice,
    this.expAlertPeriod,
    this.unitPrice,
    this.deleteAt,
    this.category,
    this.createAt,
    this.categoryId,
    this.stock,
    this.rayonId,
    this.gamme,
    this.isPriceReducible,
    this.grammageTypeId,
    this.grammageType,
    this.grammage,
    this.rayon,
    this.images,
    this.rightSupply,
    this.stockLimit,
  });

  Product.fromMap(Map<String, dynamic> article) {
    id = article["id"];
    name = article["name"];
    code = article["code"];
    brand = article["brand"];
    stock = int.tryParse(article["stock"]?? "0");
    description = article["description"];
    color = article["color"];
    grammage = article["grammage"];
    unitPrice = article["unit_price"];
    category = Category.fromMap(article["category"]);
    rayon = Rayon.fromMap(article["rayon"]);
    gamme = Gamme.fromMap(article["gamme"]);
    grammageType = GrammageType.fromMap(article["grammage_type"]);
    maxSalablePrice = double.tryParse(article["max_salable_price"]?? "");
    expAlertPeriod = article["expAlertPeriod"];
    isPriceReducible = [1, true].contains(article["is_price_reducible"]);
    stockLimit = article["stockLimit"];
    rightSupply = Supply.fromMap(article["right_supply"]);
    images = article["images"] != null? (article["images"] as List<dynamic>).map((e) => ProductImage.fromMap(e)).toList(): null;
  }


  Map<String, dynamic> toSendMapDto() {
    return {
      "code": code,
      "name": name,
      "brand": brand,
      "stock": stock,
      "grammage": grammage,
      "unit_price": unitPrice,
      "rayon_id": rayonId,
      "gamme_id": gamme,
      "category_id": categoryId,
      "grammage_type_id": grammageTypeId,
      "description": (description?? "").isNotEmpty? description: null,
      "max_salable_price": (maxSalablePrice?? 0.0) != 0.0? maxSalablePrice: null,
      "exp_alert_period": (expAlertPeriod?? 0) != 0? expAlertPeriod: null,
      "stock_limit": (stockLimit?? 0) != 0? stockLimit: null,
      // "maxSalablePrice": maxSalablePrice,
      // "expAlertPeriod": expAlertPeriod,
      // "categoryId": categoryId,
      // "stockLimit": stockLimit,
      // "shopId": 2,
      // "prices": prices?.map((price) => price.toSendMapDto()).toList(),
      // "searchKeys": searchKeys?.map((searchKey) => searchKey.toSendMapDto()).toList(),
      // "images": images?.map((image) => image.toSendMapDto()).toList(),
      // "prices": prices?.map((price) => price.toSendMapDto()).toList(),
      // "searchKeys": searchKeys?.map((searchKey) => searchKey.toSendMapDto()).toList(),
      "images": images?.map((image) => image.toSendMapDto()).toList(),
    };
  }


  static Future makeGetRequest(String path, {CancelToken? cancelToken, String? serverUri}) async {
    var dio = dioConstructor(serverUri?? await LocalBdManager.localBdSelectSetting("serverUri"), extraHeader: {"userId": MyUser.currentUser.id});
    var response = await dio.get(path, cancelToken: cancelToken);
    print("response.data: ${response.data}");
    if (response.statusCode == 200) {
      return response.data;
    } else {
      // return
    }
  }

  static Future<Product?> getProductByCode(String code, {CancelToken? cancelToken, String? serverUri, int? returnAll = 0}) async {
    var dio = dioConstructor(serverUri?? await LocalBdManager.localBdSelectSetting("serverUri"), extraHeader: {"userId": MyUser.currentUser.id});
    var response = await dio.get("/get_product_by_code/$code?return_all=$returnAll", cancelToken: cancelToken);
    print("response.data: ${response.data}");
    if (response.statusCode == 200) {
      // print(response.data);
      return response.data != null? Product.fromMap(response.data): null;
    }
    return null;
  }

  static Future<Product?> getProductById(int productId, {CancelToken? cancelToken, String? serverUri}) async {
    var dio = dioConstructor(serverUri?? await LocalBdManager.localBdSelectSetting("serverUri"), extraHeader: {"userId": MyUser.currentUser.id});
    var response = await dio.get("/get_product_by_id/$productId", cancelToken: cancelToken);
    print("response.data: ${response.data}");
    if (response.statusCode == 200) {
      return response.data != null? Product.fromMap(response.data): null;
    }
    return null;
  }

  static Future<List<Product>?> getProductList({int page = 0, int count = 20, CancelToken? cancelToken, String? serverUri}) async {
    var dio = dioConstructor(serverUri?? await LocalBdManager.localBdSelectSetting("serverUri"), extraHeader: {"userId": MyUser.currentUser.id});
    var response = await dio.get("/get_product_list/$page/$count", cancelToken: cancelToken);
    print("response.data: ${response.data}");
    if (response.statusCode == 200) {
      return response.data != null? (response.data as List<dynamic>).map((value) => Product.fromMap(value)).toList(): null;
    }
    return null;
  }

  static Future<List<Product>?> getSearchResult(String searchInput, {int page = 0, int count = 20, CancelToken? cancelToken, String? serverUri}) async {
    var dio = dioConstructor(serverUri?? await LocalBdManager.localBdSelectSetting("serverUri"), extraHeader: {"userId": MyUser.currentUser.id});
    var response = await dio.get("/search_product?search_input=$searchInput&page=$page&count=$count", cancelToken: cancelToken);
    print("response.data: ${response.data}");
    if (response.statusCode == 200) {
      return response.data != null? (response.data as List<dynamic>).map((value) => Product.fromMap(value)).toList(): null;
    }
    return null;
  }

  Future createProduct(String serverUri, {void Function(double progess)? progressCallBack, int? inventoryMode = 0}) async {
    CancelToken cancelToken = CancelToken();
    var dio = dioConstructor("$serverUri", extraHeader: {"userId": MyUser.currentUser.id});
    List listImages = [];
    for (ProductImage image in images?? []) {
      if (image.imageFile != null) {
        listImages.add(await MultipartFile.fromFile(
          image.imageFile!.path,
          filename: image.imageFile!.name,
          headers: {
            "description": [(image.description?? "").toString()]
          },
        ));
      }
    }
    print(toSendMapDto());
    var formData =
    FormData.fromMap({"images": listImages, "": toSendMapDto()});
    var response = await dio.post(
      '/create_product?inventory_mode=$inventoryMode',
      data: formData,
      cancelToken: cancelToken,
      onSendProgress: (count, total) {
        if (progressCallBack != null) {
          progressCallBack(count / total);
          Future.delayed(
            const Duration(milliseconds: 1000),
          );
        }
        print("Count: $count");
        print("Total: $total");
      },
    );
    print("response.data: ${response.data}");

    if ([201, 200].contains(response.statusCode)) {
      return response.data;
    } else {
      throw Exception();
    }

  }


}
