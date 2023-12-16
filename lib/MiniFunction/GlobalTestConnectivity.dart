

import 'package:flutter/material.dart';
import 'package:image_to_text/UI/MiniWidget/UniversalSnackBar.dart';

import '../AppService/BarCodeService.dart';
import '../DATA/DataClass/MyUser.dart';

void globalConnectivityTest(BuildContext context) async {
  MyUser.testServerConnection(serverUri: await BarCodeService.scanBarCode(context: context)).then((value) {
    if (value["status"] == 1) {
      showUniversalSnackBar(context: context, message: 'Le test de connectivité au serveur a réussi');
    } else {
      showUniversalSnackBar(context: context, message: 'Test de connectivité échoué ');
    }
  }).onError((error, stackTrace) {
    print(error);
    showUniversalSnackBar(context: context, message: "Une erreur s'est produite");
  });
}
