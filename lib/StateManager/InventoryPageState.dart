
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class InventoryPageState extends Cubit<bool> {
  InventoryPageState(bool state): super(state);
  void setPageState(bool newState) {
    emit(newState);
  }

}


void refreshInventoryPageStateState(BuildContext context) {
  context
      .read<InventoryPageState>()
      .setPageState(!context.read<InventoryPageState>().state? true: false);
}







