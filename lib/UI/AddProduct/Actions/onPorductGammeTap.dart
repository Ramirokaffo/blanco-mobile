


import 'package:drop_down_list/model/selected_list_item.dart';
import 'package:flutter/cupertino.dart';
import 'package:image_to_text/DATA/DataClass/Product.dart';
import '../../../DATA/DataClass/Category.dart';
import '../../../DATA/DataClass/Gamme.dart';
import '../../../ModalBottomWidget/SelectionModalDropDown.dart';
import '../../../StateManager/AddArticlePageState.dart';

void onArticleGammeTap(Product article, TextEditingController controller, BuildContext context) async {
  Gamme gamme = Gamme();
  await gamme.getAllGamme().then((List<Gamme> listCategory) async {
    List<SelectedListItem> listSelectedListItem = listCategory.map((Gamme myGamme) {
      return SelectedListItem(name: myGamme.name!, value: myGamme.id.toString());
    }).toList();
    await showSelectionDropDown(controller, context, listSelectedListItem, title: "Gamme du produit").then((value) {
      if (controller.text.isNotEmpty) {
        refreshAddArticlePageState(context);
      }
    });
  });
}