/*
 * esc_pos_printer
 * Created by Andrey Ushakov
 * 
 * Copyright (c) 2019. All rights reserved.
 * See LICENSE for distribution and usage details.
 */

import 'enums.dart';

/// A string with styles
class PosString {
  PosString(
    this.text, {
    this.bold = false,
    this.reverse = false,
    this.underline = false,
    this.align = PosTextAlign.left,
    this.height = PosTextSize.size1,
    this.width = PosTextSize.size1,
    this.fontType = PosFontType.fontA,
  });

  String text;
  bool bold = false;
  bool reverse = false;
  bool underline = false;
  PosTextAlign align = PosTextAlign.left;
  PosTextSize height = PosTextSize.size1;
  PosTextSize width = PosTextSize.size1;
  PosFontType fontType = PosFontType.fontA;

  @override
  String toString() {
    return text;
  }
}
