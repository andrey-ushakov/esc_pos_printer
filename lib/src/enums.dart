/*
 * esc_pos_printer
 * Created by Andrey Ushakov
 * 
 * Copyright (c) 2019-2020. All rights reserved.
 * See LICENSE for distribution and usage details.
 */

enum PosTextAlign { left, center, right }
enum PosCutMode { full, partial }
enum PosFontType { fontA, fontB }

class PosPrintResult {
  const PosPrintResult._internal(this.value);
  final int value;
  static const success = PosPrintResult._internal(1);
  static const timeout = PosPrintResult._internal(2);
  static const printerNotSelected = PosPrintResult._internal(3);
  static const ticketEmpty = PosPrintResult._internal(4);

  static String msg(PosPrintResult val) {
    if (val == PosPrintResult.success) {
      return 'Success';
    } else if (val == PosPrintResult.timeout) {
      return 'Error. Printer connection timeout';
    } else if (val == PosPrintResult.printerNotSelected) {
      return 'Error. Printer not selected';
    } else if (val == PosPrintResult.ticketEmpty) {
      return 'Error. Ticket is empty';
    } else {
      return 'Unknown error';
    }
  }
}

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

class PaperSize {
  const PaperSize._internal(this.value);
  final int value;
  static const mm58 = PaperSize._internal(1);
  static const mm80 = PaperSize._internal(2);

  static int width(PaperSize size) => size == PaperSize.mm58 ? 350 : 512;
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
