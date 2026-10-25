
import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_to_text/DATA/DataClass/Product.dart';

import '../HttpRequest/ApiHelper.dart';
import '../HttpRequest/RouteFile.dart';

class ProductImage {
  late int? id;
  late String? path;
  late String? url;
  late XFile? imageFile;
  late String? description;
  late Product? product;
  late bool? isPrincipal;

  ProductImage({
    this.id,
    this.path,
    this.url,
    this.imageFile,
    this.description,
    this.product,
    this.isPrincipal});

  ProductImage.fromMap(Map<String, dynamic> articleImage) {
     id = articleImage["id"];
     path = articleImage["image"];
     url = _publicImageUrl(articleImage["url"]?? articleImage["image"]);
     isPrincipal = toBool(articleImage["is_primary"]);
     product = null;
     imageFile = null;
  }

  /// Les fichiers /media/ ne sont servis par Django qu'en DEBUG : on passe par
  /// la route publique /api/images/product/<fichier>/ sur le même serveur.
  static String? _publicImageUrl(String? mediaUrl) {
    if (mediaUrl == null || mediaUrl.isEmpty) return null;
    Uri uri = Uri.parse(mediaUrl);
    if (!uri.hasAuthority || uri.pathSegments.isEmpty) return mediaUrl;
    return "${uri.origin}${imageRoute("product", uri.pathSegments.last)}";
  }

  /// L'API Django ne propose pas de suppression d'image : elle se fait depuis
  /// le back-office web.
  static Future deleteImageById(int imageId, {CancelToken? cancelToken, String? serverUri}) async {
    throw ApiException("La suppression d'image se fait depuis le back-office web");
  }

}
