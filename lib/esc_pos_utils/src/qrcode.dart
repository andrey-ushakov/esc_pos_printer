// ignore_for_file: prefer_final_locals

/*
 * esc_pos_utils
 * Created by Andrey U.
 * 
 * Copyright (c) 2019-2020. All rights reserved.
 * See LICENSE for distribution and usage details.
 */

import 'dart:convert';
import 'package:esc_pos_printer/esc_pos_utils/src/commands.dart';

class QRSize {
  const QRSize(this.value);
  final int value;

  static const Size1 = QRSize(0x01);
  static const Size2 = QRSize(0x02);
  static const Size3 = QRSize(0x03);
  static const Size4 = QRSize(0x04);
  static const Size5 = QRSize(0x05);
  static const Size6 = QRSize(0x06);
  static const Size7 = QRSize(0x07);
  static const Size8 = QRSize(0x08);
}

/// QR Correction level
class QRCorrection {
  const QRCorrection._internal(this.value);
  final int value;

  /// Level L: Recovery Capacity 7%
  static const L = QRCorrection._internal(48);

  /// Level M: Recovery Capacity 15%
  static const M = QRCorrection._internal(49);

  /// Level Q: Recovery Capacity 25%
  static const Q = QRCorrection._internal(50);

  /// Level H: Recovery Capacity 30%
  static const H = QRCorrection._internal(51);
}

class QRCode {
  QRCode(String text, QRSize size, QRCorrection level) {
    // FN 167. QR Code: Set the size of module
    // pL pH cn fn n
    bytes += cQrHeader.codeUnits + [0x03, 0x00, 0x31, 0x43] + [size.value];

    // FN 169. QR Code: Select the error correction level
    // pL pH cn fn n
    bytes += cQrHeader.codeUnits + [0x03, 0x00, 0x31, 0x45] + [level.value];

    // FN 180. QR Code: Store the data in the symbol storage area
    List<int> textBytes = latin1.encode(text);
    // pL pH cn fn m
    bytes += cQrHeader.codeUnits + [textBytes.length + 3, 0x00, 0x31, 0x50, 0x30];
    bytes += textBytes;

    // FN 182. QR Code: Transmit the size information of the symbol data in the symbol storage area
    // pL pH cn fn m
    bytes += cQrHeader.codeUnits + [0x03, 0x00, 0x31, 0x52, 0x30];

    // FN 181. QR Code: Print the symbol data in the symbol storage area
    // pL pH cn fn m
    bytes += cQrHeader.codeUnits + [0x03, 0x00, 0x31, 0x51, 0x30];
  }
  List<int> bytes = <int>[];
}
