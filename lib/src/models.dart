import 'package:esc_pos_printer/esc_pos_printer.dart';

sealed class PrinterCommand {}

class InitCommand extends PrinterCommand {
  InitCommand({
    required this.leftMargin,
    required this.dpi,
    required this.globalCodeTable,
    required this.characterSet,
  });

  final int leftMargin;
  final int dpi;
  final String globalCodeTable;
  final PrinterCharacterSet characterSet;
}

class OpenCashDrawerCommand extends PrinterCommand {
  OpenCashDrawerCommand({required this.pin});

  final int pin;
}

class HrCommand extends PrinterCommand {
  HrCommand({
    this.ch = '-',
    this.len,
    this.linesAfter = 0,
    this.styles = const PosStyles(),
  });

  final String ch;
  final int? len;
  final int linesAfter;
  final PosStyles styles;
}

class QrcodeCommand extends PrinterCommand {
  QrcodeCommand({
    required this.text,
    this.align = PosAlign.center,
    this.size = QRSize.Size4,
    this.cor = QRCorrection.L,
  });

  final String text;
  final PosAlign align;
  final QRSize size;
  final QRCorrection cor;
}

class BarcodeCommand extends PrinterCommand {
  BarcodeCommand({
    required this.barcode,
    this.width,
    this.height,
    this.font,
    this.textPos = BarcodeText.below,
    this.align = PosAlign.center,
  });

  final Barcode barcode;
  final int? width;
  final int? height;
  final BarcodeFont? font;
  final BarcodeText textPos;
  final PosAlign align;
}

class RowCommand extends PrinterCommand {
  RowCommand({
    required this.cols,
  });

  final List<PosColumn> cols;
}

class ReverseFeedCommand extends PrinterCommand {
  ReverseFeedCommand({
    required this.n,
  });

  final int n;
}

class BeepCommand extends PrinterCommand {
  BeepCommand({
    this.n = 3,
    this.duration = PosBeepDuration.beep450ms,
  });

  final int n;
  final PosBeepDuration duration;
}

class CutCommand extends PrinterCommand {
  CutCommand({
    this.mode = PosCutMode.full,
  });

  final PosCutMode mode;
}

class FeedCommand extends PrinterCommand {
  FeedCommand({
    required this.n,
  });

  final int n;
}

class EmptyLinesCommand extends PrinterCommand {
  EmptyLinesCommand({
    required this.n,
  });

  final int n;
}

class RawBytesCommand extends PrinterCommand {
  RawBytesCommand({
    required this.cmd,
    this.isKanji = false,
  });

  final List<int> cmd;
  final bool isKanji;
}

class TextCommand extends PrinterCommand {
  TextCommand({
    required this.text,
    this.styles = const PosStyles(),
    this.linesAfter = 0,
    this.containsChinese = false,
    this.maxCharsPerLine,
  });

  final String text;
  final PosStyles styles;
  final int linesAfter;
  final bool containsChinese;
  final int? maxCharsPerLine;
}
