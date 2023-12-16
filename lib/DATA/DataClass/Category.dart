

import 'package:image_to_text/DATA/DataClass/MyUser.dart';
import 'package:image_to_text/DATA/DataClass/Product.dart';

import '../../LocalBdManager/LocalBdManager.dart';
import '../HttpRequest/RouteFile.dart';
import '../HttpRequest/dioConstructor.dart';

class Category {

  late int? id;
  late String? name;
  late String? description;
  late List<Product>? articles;
  static List<Category> allCategoryList = [];


  Category({
    this.id,
    this.name,
    this.description,
    this.articles,
});

  Future<List<Category>> getAllCategory() async {
    // print("allCategoryList: $allCategoryList");
    if (allCategoryList.isNotEmpty) {
      return allCategoryList;
    } else {
      try {
        var dio = dioConstructor(await LocalBdManager.localBdSelectSetting("serverUri"),
        extraHeader: {"userId": await MyUser.getCurrentUser()});
        var response = await dio.get("/get_category",);
        if (response.statusCode == 200) {
          // print("response.data: ${response.data}");
          allCategoryList.addAll((response.data as List<dynamic>).map((category) => Category.fromMap(category)));
          // print(allCategoryList[0].name);
          return allCategoryList;
        }
      } catch (e) {
        print(e);
        throw Exception(e);
      }
    }
    return [];
  }

  void createCategory(String serverUri, String name, String image) async {
    var dio = dioConstructor(serverUri);
    var response = await dio.post(
      createPaymentMethodRoute,
      data: {"name": name, "iconImage": image},
    );
    if (response.statusCode != 201) {
      print(response.statusMessage);
      print(response.extra);
      print(response.headers);
      print(response.data);
      throw Exception();
    }
  }



  Category.fromMap(Map<String, dynamic>? category) {
    if (category != null) {
      id = category["id"];
      name = category["name"];
      description = category["description"];
    } else {
      id = null;
      name = null;
      description = null;
    }
  }
}