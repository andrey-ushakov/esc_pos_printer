/*
 * esc_pos_utils
 * Created by Andrey U.
 * 
 * Copyright (c) 2019-2020. All rights reserved.
 * See LICENSE for distribution and usage details.
 */

import 'package:esc_pos_printer/esc_pos_utils/src/font_config/font_size_config.dart';

enum PosAlign { left, center, right }

enum PosCutMode { full, partial }

enum PosFontType { fontA, fontB }

enum PosDrawer { pin2, pin5 }

/// Choose image printing function
/// bitImageRaster: GS v 0 (obsolete)
/// graphics: GS ( L
enum PosImageFn { bitImageRaster, graphics }

class PosTextSize {
  const PosTextSize._internal(this.value);

  final int value;
  static const size1 = PosTextSize._internal(1);
  static const size2 = PosTextSize._internal(2);
  static const size3 = PosTextSize._internal(3);
  static const size4 = PosTextSize._internal(4);
  static const size5 = PosTextSize._internal(5);
  static const size6 = PosTextSize._internal(6);
  static const size7 = PosTextSize._internal(7);
  static const size8 = PosTextSize._internal(8);

  static const defaultFontSizeConfig =
      FontSizeConfig(maxCharsPerLineSmall: 41, maxCharsPerLineLarge: 27);

  static int decSize(Size fontSize) => 16 * (fontSize.value - 1) + (fontSize.value - 1);
}

class PaperSize {
  factory PaperSize.custom(int value) => PaperSize._internal(value);

  const PaperSize._internal(this.value);

  final int value;

  static const mm58 = PaperSize._internal(372);
  static const mm80 = PaperSize._internal(558);

  int get width => value;
}

class PosBeepDuration {
  const PosBeepDuration._internal(this.value);

  final int value;
  static const beep50ms = PosBeepDuration._internal(1);
  static const beep100ms = PosBeepDuration._internal(2);
  static const beep150ms = PosBeepDuration._internal(3);
  static const beep200ms = PosBeepDuration._internal(4);
  static const beep250ms = PosBeepDuration._internal(5);
  static const beep300ms = PosBeepDuration._internal(6);
  static const beep350ms = PosBeepDuration._internal(7);
  static const beep400ms = PosBeepDuration._internal(8);
  static const beep450ms = PosBeepDuration._internal(9);
}
