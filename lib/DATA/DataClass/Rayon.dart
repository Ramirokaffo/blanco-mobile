

import 'package:image_to_text/DATA/DataClass/Product.dart';

import '../../LocalBdManager/LocalBdManager.dart';
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
        var response = await dio.get("/get_rayon");
        if (response.statusCode == 200) {
          // print("response.data: ${response.data}");
          allRayonList.addAll((response.data as List<dynamic>).map((rayon) => Rayon.fromMap(rayon)));
          // print(allCategoryList[0].name);
          return allRayonList;
        }
      } catch (e) {
        print(e);
        throw Exception(e);
      }
    }
    return [];
  }

  void createCategory(String serverUri, String name, String description) async {
    var dio = dioConstructor(serverUri);
    var response = await dio.post(
      createPaymentMethodRoute,
      data: {"name": name, "description": description},
    );
    if (response.statusCode != 201) {
      print(response.statusMessage);
      print(response.extra);
      print(response.headers);
      print(response.data);
      throw Exception();
    }
  }



  Rayon.fromMap(Map<String, dynamic>? rayon) {
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