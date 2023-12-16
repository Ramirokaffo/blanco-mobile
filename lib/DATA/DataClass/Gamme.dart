

import 'package:image_to_text/DATA/DataClass/MyUser.dart';
import 'package:image_to_text/DATA/DataClass/Product.dart';

import '../../LocalBdManager/LocalBdManager.dart';
import '../HttpRequest/RouteFile.dart';
import '../HttpRequest/dioConstructor.dart';

class Gamme {

  late int? id;
  late String? name;
  late String? description;
  late List<Product>? articles;
  static List<Gamme> allGammeList = [];


  Gamme({
    this.id,
    this.name,
    this.description,
    this.articles,
  });

  Future<List<Gamme>> getAllGamme() async {
    // print("allCategoryList: $allCategoryList");
    if (allGammeList.isNotEmpty) {
      return allGammeList;
    } else {
      try {
        var dio = dioConstructor(await LocalBdManager.localBdSelectSetting("serverUri"),
            extraHeader: {"userId": await MyUser.getCurrentUser()});
        var response = await dio.get("/get_gamme",);
        if (response.statusCode == 200) {
          // print("response.data: ${response.data}");
          allGammeList.addAll((response.data as List<dynamic>).map((category) => Gamme.fromMap(category)));
          // print(allCategoryList[0].name);
          return allGammeList;
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



  Gamme.fromMap(Map<String, dynamic>? gamme) {
    if (gamme != null) {
      id = gamme["id"];
      name = gamme["name"];
      description = gamme["description"];
    } else {
      id = null;
      name = null;
      description = null;
    }
  }
}