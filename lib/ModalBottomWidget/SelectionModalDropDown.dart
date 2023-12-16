
import 'package:drop_down_list/drop_down_list.dart';
import 'package:drop_down_list/model/selected_list_item.dart';
import 'package:flutter/material.dart';

Future showSelectionDropDown(TextEditingController controller, BuildContext context, List<SelectedListItem> dataList, {required String title}) async {
  return DropDownState(
    DropDown(
        bottomSheetTitle: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20.0,
          ),
          textAlign: TextAlign.center,
        ),
        data: dataList,
        selectedItems: (List<dynamic> selectedList) {
          List<String> list = [];
          for (var item in selectedList) {
            if (item is SelectedListItem) {
              list.add(item.name);
            }
          }
          controller.text = list[0];
        },
        isSearchVisible: true
    ),
  ).showModal(context);
}