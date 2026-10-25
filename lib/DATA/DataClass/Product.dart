
import 'package:dio/dio.dart';
import 'package:image_to_text/DATA/DataClass/Category.dart';
import 'package:image_to_text/DATA/DataClass/Gamme.dart';
import 'package:image_to_text/DATA/DataClass/GrammageType.dart';

import '../../LocalBdManager/LocalBdManager.dart';
import '../HttpRequest/ApiHelper.dart';
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
    this.gammeId,
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
    stock = toInt(article["stock"])?? 0;
    description = article["description"];
    color = article["color"];
    grammage = toDouble(article["grammage"]);
    unitPrice = toDouble(article["actual_price"]);
    unitCoast = toDouble(article["last_purchase_price"]);
    supplyId = null;
    category = Category.fromMap(article["category"]);
    rayon = Rayon.fromMap(article["rayon"]);
    gamme = Gamme.fromMap(article["gamme"]);
    grammageType = GrammageType.fromMap(article["grammage_type"]);
    categoryId = category!.id;
    rayonId = rayon!.id;
    gammeId = gamme!.id;
    grammageTypeId = grammageType!.id;
    maxSalablePrice = toDouble(article["max_salable_price"]);
    expAlertPeriod = toInt(article["exp_alert_period"]);
    isPriceReducible = toBool(article["is_price_reducible"]);
    stockLimit = toInt(article["stock_limit"]);
    createAt = article["create_at"];
    deleteAt = article["delete_at"];
    // Le serveur ne gère plus de "bon approvisionnement" : le prix de vente
    // est porté par le produit (actual_price). On garde rightSupply pour
    // l'interface existante.
    rightSupply = Supply(productCount: stock, productCountRest: stock, unitPrice: unitPrice?? 0, unitCoast: unitCoast);
    images = article["images"] != null? (article["images"] as List<dynamic>).map((e) => ProductImage.fromMap(e)).toList(): [];
  }

  bool isNotEmpty() {
    return name != null || code != null || brand != null ||
        stock != null || description != null || color != null || grammage
        != null || unitPrice != null || unitCoast != null || categoryId != null
        || rayonId != null || gammeId != null ||
        grammageTypeId != null || maxSalablePrice != null || expAlertPeriod
        != null || isPriceReducible != null || stockLimit != null ||
        (images != null && images!.isNotEmpty);
  }


  /// Champs envoyés au serveur (ProductCreateSerializer / ProductUpdateSerializer).
  /// Les champs nuls sont omis : en mise à jour partielle, seuls les champs
  /// modifiés sont envoyés.
  Map<String, dynamic> toSendMapDto() {
    Map<String, dynamic> data = {
      "code": code,
      "name": name,
      "brand": brand,
      "stock": stock,
      "grammage": grammage,
      "actual_price": unitPrice,
      "last_purchase_price": unitCoast,
      "rayon": rayonId,
      "gamme": gammeId,
      "category": categoryId,
      "grammage_type": grammageTypeId,
      "description": description,
      "color": color,
      "max_salable_price": (maxSalablePrice?? 0.0) != 0.0? maxSalablePrice: null,
      "exp_alert_period": (expAlertPeriod?? 0) != 0? expAlertPeriod: null,
      "stock_limit": (stockLimit?? 0) != 0? stockLimit: null,
      "is_price_reducible": isPriceReducible,
    };
    data.removeWhere((key, value) => value == null);
    return data;
  }

  static Future<Dio> _dio({String? serverUri, Duration? receiveTimeout}) async {
    String uri = serverUri?? await LocalBdManager.localBdSelectSetting("serverUri");
    return receiveTimeout != null? dioConstructor(uri, receiveTimeout: receiveTimeout): dioConstructor(uri);
  }

  static List<Product> _productList(dynamic data) {
    return data is List? data.map((value) => Product.fromMap(value)).toList(): [];
  }

  static Future makeGetRequest(String path, {CancelToken? cancelToken, String? serverUri}) async {
    var dio = await _dio(serverUri: serverUri);
    var response = await dio.get(path, cancelToken: cancelToken);
    if (response.statusCode == 200) {
      return response.data;
    }
    throw ApiException(extractErrorMessage(response.data), statusCode: response.statusCode);
  }

  /// Produit portant ce code, ou null s'il n'existe pas.
  static Future<Map<String, dynamic>?> findByCode(String code, {CancelToken? cancelToken}) async {
    var data = await makeGetRequest(productByCodeRoute(code), cancelToken: cancelToken);
    return data is Map<String, dynamic>? data: null;
  }

  /// Produit portant ce nom, ou null s'il n'existe pas.
  static Future<Map<String, dynamic>?> findByName(String name, {CancelToken? cancelToken}) async {
    var data = await makeGetRequest(productByNameRoute(name), cancelToken: cancelToken);
    return data is Map<String, dynamic>? data: null;
  }

  static Future<Product?> getProductByCode(String code, {CancelToken? cancelToken, String? serverUri}) async {
    var dio = await _dio(serverUri: serverUri);
    var response = await dio.get(productByCodeRoute(code), cancelToken: cancelToken);
    if (response.statusCode == 200) {
      // Produit introuvable : le serveur répond 200 avec un corps vide
      return response.data is Map<String, dynamic>? Product.fromMap(response.data): null;
    }
    throw ApiException(extractErrorMessage(response.data), statusCode: response.statusCode);
  }

  static Future<Product?> getProductById(int productId, {CancelToken? cancelToken, String? serverUri}) async {
    var dio = await _dio(serverUri: serverUri);
    var response = await dio.get(productByIdRoute(productId), cancelToken: cancelToken);
    if (response.statusCode == 200) {
      return response.data is Map<String, dynamic>? Product.fromMap(response.data): null;
    }
    if (response.statusCode == 404) return null;
    throw ApiException(extractErrorMessage(response.data), statusCode: response.statusCode);
  }

  static Future<List<Product>?> getProductList({int page = 0, int count = 20, CancelToken? cancelToken, String? serverUri}) async {
    var dio = await _dio(serverUri: serverUri);
    var response = await dio.get(productListRoute, queryParameters: {"page": page, "count": count}, cancelToken: cancelToken);
    if (response.statusCode == 200) {
      return _productList(response.data);
    }
    throw ApiException(extractErrorMessage(response.data), statusCode: response.statusCode);
  }

  /// L'API Django n'a pas d'équivalent à l'ancienne route
  /// /get_product_with_any_unit_coast : le prix d'achat n'est exposé par aucune
  /// route de lecture.
  static Future<List<Product>?> getProductWithAnyUnitCoast({int page = 0, int count = 20, CancelToken? cancelToken, String? serverUri}) async {
    throw ApiException("Cette liste n'est pas disponible sur ce serveur");
  }

  static Future<List<Product>?> getSearchResult(String searchInput, {int page = 0, int count = 20, CancelToken? cancelToken, String? serverUri}) async {
    // Le serveur exige au moins 2 caractères : en deçà on affiche la liste complète
    if (searchInput.trim().length < 2) {
      return getProductList(page: page, count: count, cancelToken: cancelToken, serverUri: serverUri);
    }
    var dio = await _dio(serverUri: serverUri);
    var response = await dio.get(productSearchRoute,
        queryParameters: {"search_input": searchInput.trim(), "page": page, "count": count}, cancelToken: cancelToken);
    if (response.statusCode == 200) {
      return _productList(response.data);
    }
    throw ApiException(extractErrorMessage(response.data), statusCode: response.statusCode);
  }

  Future<FormData> _formData() async {
    List<MultipartFile> listImages = [];
    for (ProductImage image in images?? []) {
      if (image.imageFile != null) {
        listImages.add(await MultipartFile.fromFile(
          image.imageFile!.path,
          filename: image.imageFile!.name,
        ));
      }
    }
    Map<String, dynamic> fields = toSendMapDto();
    if (listImages.isNotEmpty) fields["images"] = listImages;
    return FormData.fromMap(fields, ListFormat.multi);
  }

  /// Crée le produit (et son approvisionnement initial si stock > 0).
  /// Renvoie le produit créé.
  Future<Product> createProduct({String? serverUri, void Function(double progess)? progressCallBack, CancelToken? cancelToken}) async {
    var dio = await _dio(serverUri: serverUri, receiveTimeout: const Duration(seconds: 60));
    // En multipart, DRF lit un booléen absent comme false : on envoie la
    // valeur par défaut du modèle (prix réductible)
    isPriceReducible ??= true;
    var response = await dio.post(
      createProductRoute,
      data: await _formData(),
      cancelToken: cancelToken,
      onSendProgress: (count, total) {
        if (progressCallBack != null && total > 0) {
          progressCallBack(count / total);
        }
      },
    );
    if ([201, 200].contains(response.statusCode) && response.data["status"] == 1) {
      return Product.fromMap(response.data["product"]);
    }
    throw ApiException(extractErrorMessage(response.data), statusCode: response.statusCode);
  }

  /// Mise à jour partielle : seuls les champs renseignés sont envoyés.
  /// Le stock n'est pas modifiable par cette voie (approvisionnement ou inventaire).
  Future<Product> updateProduct({String? serverUri, void Function(double progess)? progressCallBack, CancelToken? cancelToken}) async {
    var dio = await _dio(serverUri: serverUri, receiveTimeout: const Duration(seconds: 60));
    stock = null;
    var response = await dio.patch(
      updateProductRoute(id!),
      data: await _formData(),
      cancelToken: cancelToken,
      onSendProgress: (count, total) {
        if (progressCallBack != null && total > 0) {
          progressCallBack(count / total);
        }
      },
    );
    if (response.statusCode == 200 && response.data["status"] == 1) {
      return Product.fromMap(response.data["product"]);
    }
    throw ApiException(extractErrorMessage(response.data), statusCode: response.statusCode);
  }


}
