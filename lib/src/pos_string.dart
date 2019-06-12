import 'enums.dart';

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
    this.linesAfter = 0,
  });

  String text;
  bool bold = false;
  bool reverse = false;
  bool underline = false;
  PosTextAlign align = PosTextAlign.left;
  PosTextSize height = PosTextSize.size1;
  PosTextSize width = PosTextSize.size1;
  PosFontType fontType = PosFontType.fontA;
  int linesAfter = 0;

  @override
  String toString() {
    return text;
  }
}
