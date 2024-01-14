

import 'package:dio/dio.dart';
import 'package:image_to_text/DATA/DataClass/Category.dart';
import 'package:image_to_text/DATA/DataClass/Gamme.dart';
import 'package:image_to_text/DATA/DataClass/GrammageType.dart';
import 'package:image_to_text/DATA/DataClass/MyUser.dart';

import '../../LocalBdManager/LocalBdManager.dart';
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
  late int? supplyId;
  late double? maxSalablePrice;
  late double? unitPrice;
  late double? unitCoast;
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
    this.unitCoast,
    this.deleteAt,
    this.category,
    this.createAt,
    this.categoryId,
    this.supplyId,
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
    unitCoast = article["unit_coast"];
    supplyId = article["supply_id"];
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

  bool isNotEmpty() {
    return name != null || code != null || brand != null ||
        stock != null || description != null || color != null || grammage
        != null || unitPrice != null || unitCoast != null || category != null
        || rayon != null || gamme != null || grammageType != null ||
        grammageTypeId != null || maxSalablePrice != null || expAlertPeriod
        != null || isPriceReducible != null || stockLimit != null ||
        rightSupply != null || (images != null && images!.isNotEmpty);
  }


  Map<String, dynamic> toSendMapDto() {
    return {
      "id": id,
      "code": code,
      "name": name,
      "brand": brand,
      "stock": stock,
      "grammage": grammage,
      "unit_price": unitPrice,
      "unit_coast": unitCoast,
      "rayon_id": rayonId,
      "gamme_id": gamme,
      "category_id": categoryId,
      "grammage_type_id": grammageTypeId,
      "description": (description?? "").isNotEmpty? description: null,
      "max_salable_price": (maxSalablePrice?? 0.0) != 0.0? maxSalablePrice: null,
      "exp_alert_period": (expAlertPeriod?? 0) != 0? expAlertPeriod: null,
      "stock_limit": (stockLimit?? 0) != 0? stockLimit: null,
      "images": images?.map((image) => image.toSendMapDto()).toList(),
    };
  }


  static Future makeGetRequest(String path, {CancelToken? cancelToken, String? serverUri}) async {
    var dio = dioConstructor(serverUri?? await LocalBdManager.localBdSelectSetting("serverUri"), extraHeader: {"userId": MyUser.currentUser.id});
    var response = await dio.get(path, cancelToken: cancelToken);
    if (response.statusCode == 200) {
      return response.data;
    } else {
      // return
    }
  }

  static Future<Product?> getProductByCode(String code, {CancelToken? cancelToken, String? serverUri, int? returnAll = 0}) async {
    var dio = dioConstructor(serverUri?? await LocalBdManager.localBdSelectSetting("serverUri"), extraHeader: {"userId": MyUser.currentUser.id});
    var response = await dio.get("/get_product_by_code/$code?return_all=$returnAll", cancelToken: cancelToken);
    if (response.statusCode == 200) {
      return response.data != null? Product.fromMap(response.data): null;
    }
    return null;
  }

  static Future<Product?> getProductById(int productId, {CancelToken? cancelToken, String? serverUri}) async {
    var dio = dioConstructor(serverUri?? await LocalBdManager.localBdSelectSetting("serverUri"), extraHeader: {"userId": MyUser.currentUser.id});
    var response = await dio.get("/get_product_by_id/$productId", cancelToken: cancelToken);
    if (response.statusCode == 200) {
      return response.data != null? Product.fromMap(response.data): null;
    }
    return null;
  }

  static Future<List<Product>?> getProductList({int page = 0, int count = 20, CancelToken? cancelToken, String? serverUri}) async {
    var dio = dioConstructor(serverUri?? await LocalBdManager.localBdSelectSetting("serverUri"), extraHeader: {"userId": MyUser.currentUser.id});
    var response = await dio.get("/get_product_list/$page/$count", cancelToken: cancelToken);
    if (response.statusCode == 200) {
      return response.data != null? (response.data as List<dynamic>).map((value) => Product.fromMap(value)).toList(): null;
    }
    return null;
  }

  static Future<List<Product>?> getProductWithAnyUnitCoast({int page = 0, int count = 20, CancelToken? cancelToken, String? serverUri}) async {
    var dio = dioConstructor(serverUri?? await LocalBdManager.localBdSelectSetting("serverUri"), extraHeader: {"userId": MyUser.currentUser.id});
    var response = await dio.get("/get_product_with_any_unit_coast/$page/$count", cancelToken: cancelToken);
    if (response.statusCode == 200) {
      return response.data != null? (response.data as List<dynamic>).map((value) => Product.fromMap(value)).toList(): null;
    }
    return null;
  }

  static Future<List<Product>?> getSearchResult(String searchInput, {int page = 0, int count = 20, CancelToken? cancelToken, String? serverUri}) async {
    var dio = dioConstructor(serverUri?? await LocalBdManager.localBdSelectSetting("serverUri"), extraHeader: {"userId": MyUser.currentUser.id});
    var response = await dio.get("/search_product?search_input=$searchInput&page=$page&count=$count", cancelToken: cancelToken);
    if (response.statusCode == 200) {
      return response.data != null? (response.data as List<dynamic>).map((value) => Product.fromMap(value)).toList(): null;
    }
    return null;
  }

  Future createProduct({String? serverUri, void Function(double progess)? progressCallBack, CancelToken? cancelToken, int? inventoryMode = 0}) async {
    var dio = dioConstructor(serverUri?? await LocalBdManager.localBdSelectSetting("serverUri"), extraHeader: {"userId": MyUser.currentUser.id});
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
    var formData =
    FormData.fromMap({"images": listImages, "": toSendMapDto()});
    var response = await dio.post(
      '/create_product?inventory_mode=$inventoryMode',
      data: formData,
      cancelToken: cancelToken,
      onSendProgress: (count, total) {
        if (progressCallBack != null) {
          progressCallBack(count / total);
          // Future.delayed(
          //   const Duration(milliseconds: 1000),
          // );
        }
      },
    );
    if ([201, 200].contains(response.statusCode)) {
      return response.data;
    } else {
      throw Exception();
    }

  }

  Future updateProduct({String? serverUri, void Function(double progess)? progressCallBack, CancelToken? cancelToken, int? inventoryMode = 0}) async {
    var dio = dioConstructor(serverUri?? await LocalBdManager.localBdSelectSetting("serverUri"), extraHeader: {"userId": MyUser.currentUser.id});
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
    var response = await dio.patch(
      '/update_product',
      data: formData,
      cancelToken: cancelToken,
      onSendProgress: (count, total) {
        if (progressCallBack != null) {
          progressCallBack(count / total);
          // Future.delayed(
          //   const Duration(milliseconds: 1000),
          // );
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
