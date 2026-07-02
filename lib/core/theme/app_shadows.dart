import 'package:flutter/material.dart';

class AppShadows {
  const AppShadows._();

  static const List<BoxShadow> none = [];

  static const List<BoxShadow> card = [
    BoxShadow(color: Color(0x140F172A), blurRadius: 18, offset: Offset(0, 8)),
  ];

  static const List<BoxShadow> floating = [
    BoxShadow(color: Color(0x1F0F172A), blurRadius: 24, offset: Offset(0, 12)),
  ];
}
