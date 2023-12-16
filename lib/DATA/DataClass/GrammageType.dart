
import 'package:image_to_text/DATA/DataClass/Product.dart';

import '../../LocalBdManager/LocalBdManager.dart';
import '../HttpRequest/RouteFile.dart';
import '../HttpRequest/dioConstructor.dart';

class GrammageType {

  late int? id;
  late String? name;
  late String? description;
  late List<Product>? articles;
  static List<GrammageType> allGrammageTypeList = [];


  GrammageType({
    this.id,
    this.name,
    this.description,
    this.articles,
  });

  Future<List<GrammageType>> getAllRayon() async {
    if (allGrammageTypeList.isNotEmpty) {
      return allGrammageTypeList;
    } else {
      try {
        var dio = dioConstructor(await LocalBdManager.localBdSelectSetting("serverUri"));
        var response = await dio.get("/get_grammage_type");
        if (response.statusCode == 200) {
          allGrammageTypeList.addAll((response.data as List<dynamic>).map((grammageType) => GrammageType.fromMap(grammageType)));
          return allGrammageTypeList;
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



  GrammageType.fromMap(Map<String, dynamic>? grammageType) {
    if (grammageType != null) {
      id = grammageType["id"];
      name = grammageType["name"];
      description = grammageType["description"];
    } else {
      id = null;
      name = null;
      description = null;
    }
  }
}