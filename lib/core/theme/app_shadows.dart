import 'package:flutter/material.dart';

class AppShadows {
  const AppShadows._();

  static const List<BoxShadow> none = [];

  static const List<BoxShadow> card = [
    BoxShadow(color: Color(0x1A67CFC2), blurRadius: 22, offset: Offset(0, 9)),
  ];

  static const List<BoxShadow> floating = [
    BoxShadow(color: Color(0x247C8BEF), blurRadius: 30, offset: Offset(0, 14)),
  ];
}
