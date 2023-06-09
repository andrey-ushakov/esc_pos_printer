/*
 * esc_pos_utils
 * Created by Andrey U.
 * 
 * Copyright (c) 2019-2020. All rights reserved.
 * See LICENSE for distribution and usage details.
 */

import 'dart:typed_data' show Uint8List;

import 'pos_styles.dart';

/// Column contains text, styles and width (an integer in 1..12 range)
/// [containsChinese] not used if the text passed as textEncoded
class PosColumn {
  PosColumn({
    this.text = '',
    this.textEncoded,
    this.containsChinese = false,
    this.width = 2,
    this.styles = const PosStyles(),
  }) {
    if (width < 1 || width > 12) {
      throw Exception('Column width must be between 1..12');
    }
    if (text.isNotEmpty && textEncoded != null && textEncoded!.isNotEmpty) {
      throw Exception('Only one parameter - text or textEncoded - should be passed');
    }
  }

  String text;
  Uint8List? textEncoded;
  bool containsChinese;
  int width;
  PosStyles styles;
}
