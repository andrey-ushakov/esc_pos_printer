/*
 * esc_pos_printer
 * Created by Andrey Ushakov
 * 
 * Copyright (c) 2019. All rights reserved.
 * See LICENSE for distribution and usage details.
 */

enum PosTextAlign { left, center, right }
enum PosCutMode { full, partial }
enum PosFontType { fontA, fontB }

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

  static int decSize(PosTextSize height, PosTextSize width) =>
      16 * (width.value - 1) + (height.value - 1);
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

class PosCodeTable {
  const PosCodeTable._internal(this.value);
  final int value;

  /// PC437 - U.S.A., Standard Europe
  static const pc437 = PosCodeTable._internal(0);

  /// Katakana
  static const katakana = PosCodeTable._internal(1);

  /// PC850 Multilingual
  static const pc850 = PosCodeTable._internal(2);

  /// PC860 - Portuguese
  static const pc860 = PosCodeTable._internal(3);

  /// PC863 - Canadian-French
  static const pc863 = PosCodeTable._internal(4);

  /// PC865 - Nordic
  static const pc865 = PosCodeTable._internal(5);

  /// Western Europe
  static const westEur = PosCodeTable._internal(6);

  /// Greek
  static const greek = PosCodeTable._internal(7);

  /// PC737 - Greek
  static const pc737 = PosCodeTable._internal(64);

  /// PC851 - Greek
  static const pc851 = PosCodeTable._internal(65);

  /// PC869 - Greek
  static const pc869 = PosCodeTable._internal(66);

  /// PC928 - Greek
  static const pc928 = PosCodeTable._internal(67);

  /// PC866 - Cyrillic #2
  static const pc866 = PosCodeTable._internal(17);

  /// PC852 - Latin2
  static const pc852 = PosCodeTable._internal(18);

  /// WPC1252 - Latin1
  static const wpc1252 = PosCodeTable._internal(71);

  /// Space page
  static const spacePage = PosCodeTable._internal(255);
}

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
}

class Barcode {
  /// UPC-A
  ///
  /// k = 11, 12
  /// d = '0' – '9'
  Barcode.upcA(List<int> data) {
    _type = BarcodeType.upcA;
    _data = data;

    final k = data.length;
    if (k != 11 || k != 12) {
      throw Exception('Barcode: Wrong data range');
    }

    final numeric = RegExp(r'^[0-9]$');
    final bool isDataValid = data.every((d) => numeric.hasMatch(d.toString()));
    if (!isDataValid) {
      throw Exception('Barcode: Data is not valid');
    }
  }

  /// UPC-E
  ///
  /// k = 6 – 8, 11, 12
  /// d = '0' – '9' (However, d0 = '0' when k = 7, 8, 11, 12)
  Barcode.upcE(List<int> data) {
    _type = BarcodeType.upcE;
    _data = data;

    final k = data.length;
    if (![6, 7, 8, 11, 12].contains(k)) {
      throw Exception('Barcode: Wrong data range');
    }

    if ([7, 8, 11, 12].contains(k) && data[0].toString() != '0') {
      throw Exception('Barcode: Data is not valid');
    }

    final numeric = RegExp(r'^[0-9]$');
    final bool isDataValid = data.every((d) => numeric.hasMatch(d.toString()));
    if (!isDataValid) {
      throw Exception('Barcode: Data is not valid');
    }
  }

  /// JAN13 (EAN13)
  ///
  /// k = 12, 13
  /// d = '0' – '9'
  Barcode.ean13(List<int> data) {
    _type = BarcodeType.ean13;
    _data = data;

    final k = data.length;
    if (k != 12 || k != 13) {
      throw Exception('Barcode: Wrong data range');
    }

    final numeric = RegExp(r'^[0-9]$');
    final bool isDataValid = data.every((d) => numeric.hasMatch(d.toString()));
    if (!isDataValid) {
      throw Exception('Barcode: Data is not valid');
    }
  }

  /// JAN8 (EAN8)
  ///
  /// k = 7, 8
  /// d = '0' – '9'
  Barcode.ean8(List<int> data) {
    _type = BarcodeType.ean8;
    _data = data;

    final k = data.length;
    if (k != 7 || k != 8) {
      throw Exception('Barcode: Wrong data range');
    }

    final numeric = RegExp(r'^[0-9]$');
    final bool isDataValid = data.every((d) => numeric.hasMatch(d.toString()));
    if (!isDataValid) {
      throw Exception('Barcode: Data is not valid');
    }
  }

  /// CODE39
  ///
  /// k >= 1
  /// d: '0'–'9', A–Z, SP, $, %, *, +, -, ., /
  Barcode.code39(List<int> data) {
    _type = BarcodeType.code39;
    _data = data;

    final k = data.length;
    if (k < 1) {
      throw Exception('Barcode: Wrong data range');
    }

    final regex = RegExp(r'^[0-9A-Z \$\%\*\+\-\.\/]$');
    final bool isDataValid = data.every((d) => regex.hasMatch(d.toString()));
    if (!isDataValid) {
      throw Exception('Barcode: Data is not valid');
    }
  }

  /// ITF (Interleaved 2 of 5)
  ///
  /// k >= 2 (even number)
  /// d = '0'–'9'
  Barcode.itf(List<int> data) {
    _type = BarcodeType.itf;
    _data = data;

    final k = data.length;
    if (k < 2 || !k.isEven) {
      throw Exception('Barcode: Wrong data range');
    }

    final numeric = RegExp(r'^[0-9]$');
    final bool isDataValid = data.every((d) => numeric.hasMatch(d.toString()));
    if (!isDataValid) {
      throw Exception('Barcode: Data is not valid');
    }
  }

  /// CODABAR (NW-7)
  ///
  /// k >= 2
  /// d: '0'–'9', A–D, a–d, $, +, −, ., /, :
  /// However, d0 = A–D, dk = A–D (65-68)
  /// d1 = a-d, dk = a-d (97-100)
  Barcode.codabar(List<int> data) {
    _type = BarcodeType.codabar;
    _data = data;

    final k = data.length;
    if (k < 2) {
      throw Exception('Barcode: Wrong data range');
    }

    final regex = RegExp(r'^[0-9A-Da-d\$\+\-\.\/\:]$');
    final bool isDataValid = data.every((d) => regex.hasMatch(d.toString()));
    if (!isDataValid) {
      throw Exception('Barcode: Data is not valid');
    }

    if (!((data[0] >= 65 && data[0] <= 68) &&
        (data[k - 1] >= 65 && data[k - 1] <= 68))) {
      throw Exception('Barcode: Wrong data range');
    }

    if (!((data[0] >= 97 && data[0] <= 100) &&
        (data[k - 1] >= 97 && data[k - 1] <= 100))) {
      throw Exception('Barcode: Wrong data range');
    }
  }

  BarcodeType _type;
  List<int> _data;

  BarcodeType get type => _type;
  List<int> get data => _data.map<int>((d) => d.toString().codeUnitAt(0));
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

  static const fontA = BarcodeText._internal(0);
  static const fontB = BarcodeText._internal(1);
  static const fontC = BarcodeText._internal(2);
  static const fontD = BarcodeText._internal(3);
  static const fontE = BarcodeText._internal(4);
  static const specialA = BarcodeText._internal(97);
  static const specialB = BarcodeText._internal(98);
}
