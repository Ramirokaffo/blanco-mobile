

import 'package:flutter/material.dart';
import 'package:image_to_text/UI/MiniWidget/UniversalSnackBar.dart';

import '../AppService/BarCodeService.dart';
import '../DATA/DataClass/MyUser.dart';

void globalConnectivityTest(BuildContext context) async {
  MyUser.testServerConnection(serverUri: await BarCodeService.scanBarCode(context: context)).then((value) {
    if (value["status"] == 1) {
      showUniversalSnackBar(context: context, message: 'Le test de connectivité au serveur a réussi', backgroundColor: Colors.green);
    } else {
      showUniversalSnackBar(context: context, message: 'Test de connectivité échoué !', backgroundColor: Colors.red);
    }
  }).onError((error, stackTrace) {
    showUniversalSnackBar(context: context, message: "Une erreur s'est produite", backgroundColor: Colors.red);
  });
}
