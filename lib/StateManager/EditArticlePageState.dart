
import 'package:flutter/material.dart';




import 'package:flutter_bloc/flutter_bloc.dart';

class EditArticlePageState extends Cubit<bool> {
  EditArticlePageState(bool state): super(state);
  void setPageState(bool newState) {
    emit(newState);
  }

}


void refreshEditArticlePageState(BuildContext context) {
  context
      .read<EditArticlePageState>()
      .setPageState(!context.read<EditArticlePageState>().state? true: false);
}






