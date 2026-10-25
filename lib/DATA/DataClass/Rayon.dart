

import 'package:image_to_text/DATA/DataClass/Product.dart';

import '../../LocalBdManager/LocalBdManager.dart';
import '../HttpRequest/ApiHelper.dart';
import '../HttpRequest/RouteFile.dart';
import '../HttpRequest/dioConstructor.dart';

class Rayon {

  late int? id;
  late String? name;
  late String? description;
  late List<Product>? articles;
  static List<Rayon> allRayonList = [];


  Rayon({
    this.id,
    this.name,
    this.description,
    this.articles,
  });

  Future<List<Rayon>> getAllRayon() async {
    // print("allCategoryList: $allCategoryList");
    if (allRayonList.isNotEmpty) {
      return allRayonList;
    } else {
      try {
        var dio = dioConstructor(await LocalBdManager.localBdSelectSetting("serverUri"));
        var response = await dio.get(rayonsRoute);
        if (response.statusCode == 200) {
          // print("response.data: ${response.data}");
          allRayonList.addAll((response.data as List<dynamic>).map((rayon) => Rayon.fromMap(rayon)));
          // print(allCategoryList[0].name);
          return allRayonList;
        }
        throw ApiException(extractErrorMessage(response.data), statusCode: response.statusCode);
      } catch (e) {
        print(e);
        rethrow;
      }
    }
  }




  Rayon.fromMap(Map<String, dynamic>? rayon) {
    // print("Le rayon du produit: ${rayon}");
    if (rayon != null) {
      id = rayon["id"];
      name = rayon["name"];
      description = rayon["description"];
    } else {
      id = null;
      name = null;
      description = null;
    }
  }
}