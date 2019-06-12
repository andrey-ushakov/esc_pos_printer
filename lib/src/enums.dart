enum PosTextAlign { left, center, right }
enum PosCutMode { normal, partial, full }
enum PosFontType { fontA, fontB }

class PosTextSize {
  final int value;
  const PosTextSize._internal(this.value);
  static const size1 = const PosTextSize._internal(1);
  static const size2 = const PosTextSize._internal(2);
  static const size3 = const PosTextSize._internal(3);
  static const size4 = const PosTextSize._internal(4);
  static const size5 = const PosTextSize._internal(5);
  static const size6 = const PosTextSize._internal(6);
  static const size7 = const PosTextSize._internal(7);
  static const size8 = const PosTextSize._internal(8);

  static int decSize(PosTextSize height, PosTextSize width) =>
      16 * (width.value - 1) + (height.value - 1);
}

class PosBeepDuration {
  final int value;
  const PosBeepDuration._internal(this.value);
  static const beep50ms = const PosBeepDuration._internal(1);
  static const beep100ms = const PosBeepDuration._internal(2);
  static const beep150ms = const PosBeepDuration._internal(3);
  static const beep200ms = const PosBeepDuration._internal(4);
  static const beep250ms = const PosBeepDuration._internal(5);
  static const beep300ms = const PosBeepDuration._internal(6);
  static const beep350ms = const PosBeepDuration._internal(7);
  static const beep400ms = const PosBeepDuration._internal(8);
  static const beep450ms = const PosBeepDuration._internal(9);
}
