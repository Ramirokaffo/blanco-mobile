import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';

import '../UI/MiniWidget/UniversalSnackBar.dart';



class BarCodeService {


 static Future<String> scanBarCode(
     {required BuildContext context, ScanMode? scanType = ScanMode.BARCODE}) async {
    String barcodeScanRes = "";
    try {
      barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
          '#00ff00', 'Cancel', true, scanType!);
    } on PlatformException {
      // showUniversalSnackBar(context: context, message: "Failed to get platform version.");
      return "";
    }
    return barcodeScanRes;
  }

}