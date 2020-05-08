import 'package:flutter/material.dart';

showError(msg) => SnackBar(
      duration: Duration(seconds: 2),
      content: Text(msg),
      backgroundColor: Colors.grey[800],
    );
