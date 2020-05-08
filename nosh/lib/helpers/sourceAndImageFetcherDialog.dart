import 'dart:async';
import 'dart:io';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

Future<File> alertForSourceAndGetImage(context) {
  return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          title: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text('Select'),
          ),
          content: SingleChildScrollView(
              child: ListBody(children: <Widget>[
            InkWell(
              child: Container(
                height: 50,
                child: Row(
                  children: <Widget>[
                    Icon(Icons.camera_alt),
                    SizedBox(width: 10),
                    Text('Camera')
                  ],
                ),
              ),
              onTap: () async {
                var img = await openCamera();

                Navigator.of(context).pop(img);
              },
            ),
            SizedBox(height: 10),
            InkWell(
              child: Container(
                height: 50,
                child: Row(
                  children: <Widget>[
                    Icon(Icons.album),
                    SizedBox(width: 10),
                    Text('Gallery')
                  ],
                ),
              ),
              onTap: () async {
                var img = await openGallery();
                if (img == "nul" || img == "" || img == null) img = null;
                Navigator.of(context).pop(img);
              },
            )
          ])),
        );
      });
}

openGallery() async {
  var status = await Permission.camera.request();
  if (status.isDenied) return '';
  var image = await ImagePicker.pickImage(source: ImageSource.gallery);
  if (image != null) {
    var croppedImage = await ImageCropper.cropImage(
        sourcePath: image.path,
        cropStyle: CropStyle.circle,
        aspectRatio: CropAspectRatio(ratioY: 1, ratioX: 1),
        androidUiSettings: AndroidUiSettings(
          activeWidgetColor: Color(0xff0000ff),
          activeControlsWidgetColor: Color(0xff5c39f8),
        ));
    return croppedImage;
  }
}

openCamera() async {
  var status = await Permission.camera.request();
  var storageSatus = await Permission.storage.request();
  if (status.isDenied || storageSatus.isDenied) return null;
  var image = await ImagePicker.pickImage(source: ImageSource.camera);

  if (image != null) {
    var croppedImage = await ImageCropper.cropImage(
        sourcePath: image.path,
        cropStyle: CropStyle.circle,
        aspectRatio: CropAspectRatio(ratioY: 1, ratioX: 1),
        androidUiSettings: AndroidUiSettings(
            activeWidgetColor: Color(0xff0000ff),
            activeControlsWidgetColor: Color(0xff5c39f8)));
    return croppedImage;
  }
  return null;
}
