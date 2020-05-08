import 'package:barcode_scan/barcode_scan.dart';
import 'package:flutter/material.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'dart:async';
import 'package:flutter/services.dart';

Future<String> getBarcode() async {
  try {
    String barcode = await BarcodeScanner.scan();
    return barcode;
  } on PlatformException catch (e) {
    if (e.code == BarcodeScanner.CameraAccessDenied) {
      return 'Allow camera to use barcode';
    } else {
      return 'Some error occured';
    }
  } on FormatException {
    return null;
  } catch (e) {
    return null;
  }
}

Future<List<String>> getProduct(String barcode) async {
  ProductResult result =
      await OpenFoodAPIClient.getProduct(barcode, User.LANGUAGE_EN);

  if (result.status == 1) {
    return [result.product.productName, result.product.imgSmallUrl];
  } else {
    return ["404", "404"];
  }
}

SnackBar makeSnackBar(String text) {
  return SnackBar(
    duration: Duration(seconds: 2),
    content: Text(text),
    backgroundColor: Color(0xff5c39f8),
  );
}
