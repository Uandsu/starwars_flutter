import 'package:flutter/material.dart';

Color red = Color.fromARGB(255, 196, 0, 0);

BoxDecoration customBoxDecoration() {
  return BoxDecoration(
    color: Colors.black54,
    border: Border.all(
      width: 2.0,
      color: red,
    ),
  );
}
