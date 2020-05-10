import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:nosh/helpers/barcodeItemHelper.dart';
import 'package:nosh/helpers/errorMessageSnackBar.dart';
import 'package:nosh/helpers/checkConnection.dart';
import 'package:nosh/models/StoredItem.dart';
import 'inputModal.dart';

class SpeedDialButton extends StatelessWidget {
  final vm;
  SpeedDialButton(this.vm);
  @override
  Widget build(BuildContext context) {
    return SpeedDial(
      animatedIcon: Icons.add,
      animatedIconTheme: IconThemeData(size: 22, color: Color(0xff5c39f8)),
      backgroundColor: Colors.white,
      children: [
        SpeedDialChild(
          child: Icon(
            Icons.filter_center_focus,
            color: Color(0xff5c39f8),
            size: 17,
          ),
          backgroundColor: Colors.white,
          onTap: () async {
            Widget snackbar;
            if (await isConnected()) {
              String barcode = await getBarcode();
              showDialog(
                  barrierDismissible: false,
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      backgroundColor: Colors.transparent,
                      elevation: 0,
                      contentPadding: EdgeInsets.symmetric(horizontal: 70),
                      content: Container(
                        height: 50,
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(15)),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 3,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                    Theme.of(context).primaryColor),
                              ),
                            ),
                            SizedBox(width: 20),
                            Text('Loading',
                                style: TextStyle(color: Colors.grey))
                          ],
                        ),
                      ),
                    );
                  });
              if (barcode == 'Allow camera to use barcode' ||
                  barcode == 'Something went wrong')
                snackbar = showError(barcode);
              else if (barcode == null || barcode == '') {
                Navigator.of(context).pop();
                return;
              } else {
                List productData = await getProduct(barcode);
                String productName = productData[0];
                String productImageUri = productData[1];
                Navigator.of(context).pop();

                if (productName == '404')
                  snackbar = showError('Product Not Found');
                else {
                  var item = Item();
                  item.name = productName;
                  if (productImageUri == null) productImageUri = '';

                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return InputModal(
                        'ADD_TO_STOCKED',
                        vm,
                        item,
                        imageUri: productImageUri,
                      );
                    },
                  );
                }
              }
            } else {
              snackbar = showError('Internet Connnection Not Established');
            }

            if (snackbar != null) Scaffold.of(context).showSnackBar(snackbar);
          },
          label: 'Scan barcode',
          labelStyle: TextStyle(
              fontWeight: FontWeight.w500,
              color: Color(0xff5c39f8),
              fontSize: 14.0),
        ),
        SpeedDialChild(
          child: Icon(
            Icons.keyboard,
            color: Color(0xff5c39f8),
            size: 17,
          ),
          onTap: () {
            showDialog(
                context: context,
                builder: (BuildContext context) =>
                    InputModal('ADD_TO_STOCKED', vm, null));
          },
          label: 'Type manually',
          labelStyle: TextStyle(
              fontWeight: FontWeight.w500,
              color: Color(0xff5c39f8),
              fontSize: 14.0),
        )
      ],
    );
  }
}
