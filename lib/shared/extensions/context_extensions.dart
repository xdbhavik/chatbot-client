import 'package:flutter/material.dart';

extension ContextExtensions on BuildContext {
  ColorScheme get colors => Theme.of(this).colorScheme;
  TextTheme get text => Theme.of(this).textTheme;
  bool get isDesktop => MediaQuery.sizeOf(this).width >= 900;
}
