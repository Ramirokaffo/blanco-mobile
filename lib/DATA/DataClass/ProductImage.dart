


import 'package:image_picker/image_picker.dart';
import 'package:image_to_text/DATA/DataClass/Product.dart';

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
     path = articleImage["path"];
     url = articleImage["url"];
     isPrincipal = articleImage["is_principal"] == 1;
     product = articleImage["product"];

  }

  Map<String, dynamic> toSendMapDto() {
    return {
      "path": path,
      "description": description,
      // "isPrincipal": isPrincipal!? 1: 0,
    };
  }



}