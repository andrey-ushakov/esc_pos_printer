/*
 * esc_pos_utils
 * Created by Andrey U.
 * 
 * Copyright (c) 2019-2020. All rights reserved.
 * See LICENSE for distribution and usage details.
 */

class BarcodeType {
  const BarcodeType._internal(this.value);
  final int value;

  /// UPC-A
  static const upcA = BarcodeType._internal(0);

  /// UPC-E
  static const upcE = BarcodeType._internal(1);

  /// JAN13 (EAN13)
  static const ean13 = BarcodeType._internal(2);

  /// JAN8 (EAN8)
  static const ean8 = BarcodeType._internal(3);

  /// CODE39
  static const code39 = BarcodeType._internal(4);

  /// ITF (Interleaved 2 of 5)
  static const itf = BarcodeType._internal(5);

  /// CODABAR (NW-7)
  static const codabar = BarcodeType._internal(6);

  /// CODE128
  static const code128 = BarcodeType._internal(73);
}

class BarcodeText {
  const BarcodeText._internal(this.value);
  final int value;

  /// Not printed
  static const none = BarcodeText._internal(0);

  /// Above the barcode
  static const above = BarcodeText._internal(1);

  /// Below the barcode
  static const below = BarcodeText._internal(2);

  /// Both above and below the barcode
  static const both = BarcodeText._internal(3);
}

class BarcodeFont {
  const BarcodeFont._internal(this.value);
  final int value;

  static const fontA = BarcodeFont._internal(0);
  static const fontB = BarcodeFont._internal(1);
  static const fontC = BarcodeFont._internal(2);
  static const fontD = BarcodeFont._internal(3);
  static const fontE = BarcodeFont._internal(4);
  static const specialA = BarcodeFont._internal(97);
  static const specialB = BarcodeFont._internal(98);
}

class Barcode {
  /// UPC-A
  ///
  /// k = 11, 12
  /// d = '0' – '9'
  Barcode.upcA(List<dynamic> barcodeData) {
    final k = barcodeData.length;
    if (![11, 12].contains(k)) {
      throw Exception('Barcode: Wrong data range');
    }

    final numeric = RegExp(r'^[0-9]$');
    final bool isDataValid =
        barcodeData.every((dynamic d) => numeric.hasMatch(d.toString()));
    if (!isDataValid) {
      throw Exception('Barcode: Data is not valid');
    }

    _type = BarcodeType.upcA;
    _data = _convertData(barcodeData);
  }

  /// UPC-E
  ///
  /// k = 6 – 8, 11, 12
  /// d = '0' – '9' (However, d0 = '0' when k = 7, 8, 11, 12)
  Barcode.upcE(List<dynamic> barcodeData) {
    final k = barcodeData.length;
    if (![6, 7, 8, 11, 12].contains(k)) {
      throw Exception('Barcode: Wrong data range');
    }

    if ([7, 8, 11, 12].contains(k) && barcodeData[0].toString() != '0') {
      throw Exception('Barcode: Data is not valid');
    }

    final numeric = RegExp(r'^[0-9]$');
    final bool isDataValid =
        barcodeData.every((dynamic d) => numeric.hasMatch(d.toString()));
    if (!isDataValid) {
      throw Exception('Barcode: Data is not valid');
    }

    _type = BarcodeType.upcE;
    _data = _convertData(barcodeData);
  }

  /// JAN13 (EAN13)
  ///
  /// k = 12, 13
  /// d = '0' – '9'
  Barcode.ean13(List<dynamic> barcodeData) {
    final k = barcodeData.length;
    if (![12, 13].contains(k)) {
      throw Exception('Barcode: Wrong data range');
    }

    final numeric = RegExp(r'^[0-9]$');
    final bool isDataValid =
        barcodeData.every((dynamic d) => numeric.hasMatch(d.toString()));
    if (!isDataValid) {
      throw Exception('Barcode: Data is not valid');
    }

    _type = BarcodeType.ean13;
    _data = _convertData(barcodeData);
  }

  /// JAN8 (EAN8)
  ///
  /// k = 7, 8
  /// d = '0' – '9'
  Barcode.ean8(List<dynamic> barcodeData) {
    final k = barcodeData.length;
    if (![7, 8].contains(k)) {
      throw Exception('Barcode: Wrong data range');
    }

    final numeric = RegExp(r'^[0-9]$');
    final bool isDataValid =
        barcodeData.every((dynamic d) => numeric.hasMatch(d.toString()));
    if (!isDataValid) {
      throw Exception('Barcode: Data is not valid');
    }

    _type = BarcodeType.ean8;
    _data = _convertData(barcodeData);
  }

  /// CODE39
  ///
  /// k >= 1
  /// d: '0'–'9', A–Z, SP, $, %, *, +, -, ., /
  Barcode.code39(List<dynamic> barcodeData) {
    final k = barcodeData.length;
    if (k < 1) {
      throw Exception('Barcode: Wrong data range');
    }

    final regex = RegExp(r'^[0-9A-Z \$\%\*\+\-\.\/]$');
    final bool isDataValid =
        barcodeData.every((dynamic d) => regex.hasMatch(d.toString()));
    if (!isDataValid) {
      throw Exception('Barcode: Data is not valid');
    }

    _type = BarcodeType.code39;
    _data = _convertData(barcodeData);
  }

  /// ITF (Interleaved 2 of 5)
  ///
  /// k >= 2 (even number)
  /// d = '0'–'9'
  Barcode.itf(List<dynamic> barcodeData) {
    final k = barcodeData.length;
    if (k < 2 || !k.isEven) {
      throw Exception('Barcode: Wrong data range');
    }

    final numeric = RegExp(r'^[0-9]$');
    final bool isDataValid =
        barcodeData.every((dynamic d) => numeric.hasMatch(d.toString()));
    if (!isDataValid) {
      throw Exception('Barcode: Data is not valid');
    }

    _type = BarcodeType.itf;
    _data = _convertData(barcodeData);
  }

  /// CODABAR (NW-7)
  ///
  /// k >= 2
  /// d: '0'–'9', A–D, a–d, $, +, −, ., /, :
  /// However, d0 = A–D, dk = A–D (65-68)
  /// d0 = a-d, dk = a-d (97-100)
  Barcode.codabar(List<dynamic> barcodeData) {
    final k = barcodeData.length;
    if (k < 2) {
      throw Exception('Barcode: Wrong data range');
    }

    final regex = RegExp(r'^[0-9A-Da-d\$\+\-\.\/\:]$');
    final bool isDataValid =
        barcodeData.every((dynamic d) => regex.hasMatch(d.toString()));
    if (!isDataValid) {
      throw Exception('Barcode: Data is not valid');
    }

    if ((_charcode(barcodeData[0]) >= 65 && _charcode(barcodeData[0]) <= 68) &&
        !(_charcode(barcodeData[k - 1]) >= 65 &&
            _charcode(barcodeData[k - 1]) <= 68)) {
      throw Exception('Barcode: Wrong data range');
    }

    if ((_charcode(barcodeData[0]) >= 97 && _charcode(barcodeData[0]) <= 100) &&
        !(_charcode(barcodeData[k - 1]) >= 97 &&
            _charcode(barcodeData[k - 1]) <= 100)) {
      throw Exception('Barcode: Wrong data range');
    }

    _type = BarcodeType.codabar;
    _data = _convertData(barcodeData);
  }

  /// CODE128
  ///
  /// k >= 2
  /// d: '{A'/'{B'/'{C' => '0'–'9', A–D, a–d, $, +, −, ., /, :
  /// usage:
  /// {A = QRCode type A
  /// {B = QRCode type B
  /// {C = QRCode type C
  /// barcodeData ex.: "{A978020137962".split("");
  Barcode.code128(List<dynamic> barcodeData) {
    final k = barcodeData.length;
    if (k < 2) {
      throw Exception('Barcode: Wrong data range');
    }

    final regex = RegExp(r'^\{[A-C][\x00-\x7F]+$');
    final bool isDataValid = regex.hasMatch(barcodeData.join());

    if (!isDataValid) {
      throw Exception('Barcode: Data is not valid');
    }

    _type = BarcodeType.code128;
    _data = _convertData(barcodeData);
  }

  BarcodeType? _type;
  List<int>? _data;

  List<int> _convertData(List<dynamic> list) =>
      list.map((dynamic d) => d.toString().codeUnitAt(0)).toList();

  int _charcode(dynamic ch) => ch.toString().codeUnitAt(0);

  BarcodeType? get type => _type;
  List<int>? get data => _data;
}
