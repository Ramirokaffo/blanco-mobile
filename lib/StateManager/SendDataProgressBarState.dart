import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SendDataProgressBarState extends Cubit<double> {
  SendDataProgressBarState(double state) : super(state);
  void setPageState(double newState) {
    emit(newState);
  }
}

void refreshSendDataProgressBarState(BuildContext context, double progressValue) {
  context.read<SendDataProgressBarState>().setPageState(progressValue);
}

