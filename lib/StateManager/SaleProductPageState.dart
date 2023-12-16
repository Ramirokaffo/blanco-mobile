
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SaleProductPageState extends Cubit<bool> {
  SaleProductPageState(bool state): super(state);
  void setPageState(bool newState) {
    emit(newState);
  }

}


void refreshSaleProductPageState(BuildContext context) {
  context
      .read<SaleProductPageState>()
      .setPageState(!context.read<SaleProductPageState>().state? true: false);
}






