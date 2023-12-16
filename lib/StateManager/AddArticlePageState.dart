

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AddArticlePageState extends Cubit<bool> {
  AddArticlePageState(bool state): super(state);
  void setPageState(bool newState) {
    emit(newState);
  }

}


void refreshAddArticlePageState(BuildContext context) {
  context
      .read<AddArticlePageState>()
      .setPageState(!context.read<AddArticlePageState>().state? true: false);
}





