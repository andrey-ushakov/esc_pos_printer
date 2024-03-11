// ignore_for_file: prefer_final_locals, avoid_function_literals_in_foreach_calls

/*
 * esc_pos_utils
 * Created by Andrey U.
 * 
 * Copyright (c) 2019-2020. All rights reserved.
 * See LICENSE for distribution and usage details.
 */

import 'dart:typed_data' show Uint8List;

import 'package:bidi/bidi.dart' as bidi;
import 'package:enough_convert/latin.dart';
import 'package:esc_pos_printer/esc_pos_utils/src/barcode.dart';
import 'package:esc_pos_printer/esc_pos_utils/src/capability_profile.dart';
import 'package:esc_pos_printer/esc_pos_utils/src/enums.dart';
import 'package:esc_pos_printer/esc_pos_utils/src/font_config/font_size_config.dart';
import 'package:esc_pos_printer/esc_pos_utils/src/pos_column.dart';
import 'package:esc_pos_printer/esc_pos_utils/src/pos_styles.dart';
import 'package:esc_pos_printer/esc_pos_utils/src/qrcode.dart';
import 'package:hex/hex.dart';

import 'commands.dart';
import 'not_supported_characters.dart';

class Generator {
  Generator(this._paperSize, this._profile, this._fontSizeConfig, {this.spaceBetweenRows = 4});

  // Ticket config
  final PaperSize _paperSize;
  final CapabilityProfile _profile;
  final FontSizeConfig _fontSizeConfig;

  // Global styles
  String? _codeTable;

  // Current styles
  PosStyles _styles = PosStyles();
  int spaceBetweenRows;

  // ************************ Internal helpers ************************
  int _getMaxCharsPerLine(Size fontSize) {
    switch (fontSize) {
      case Size.small:
        return _fontSizeConfig.maxCharsPerLineSmall;
      case Size.large:
        return _fontSizeConfig.maxCharsPerLineLarge;
    }
  }

  // charWidth = default width * text size multiplier
  double _getCharWidth(PosStyles styles) {
    int charsPerLine = _getCharsPerLine(styles);
    double charWidth = _paperSize.width / charsPerLine;
    return charWidth;
  }

  double _colIndToPosition(int colInd) {
    final int width = _paperSize.width;
    return colInd == 0 ? 0 : (width * colInd / 12 - 1);
  }

  int _getCharsPerLine(PosStyles styles) {
    final int charsPerLine = _getMaxCharsPerLine(styles.fontSize);
    return charsPerLine;
  }

  Uint8List _encode(String text, {bool isKanji = false}) {
    var textToEncode = text;
    notSupportedCharactersForBidi.forEach((element) {
      textToEncode = textToEncode.replaceAll(String.fromCharCode(element.asci), element.replacteTo);
    });
    final visual = bidi.logicalToVisual(textToEncode);
    var decoded = String.fromCharCodes(visual);
    notSupportedCharactersForPrint.forEach((element) {
      decoded = decoded.replaceAll(String.fromCharCode(element.asci), element.replacteTo);
    });

    return Uint8List.fromList(Latin8Codec(allowInvalid: true).encode(decoded));
  }

  // ************************ (end) Internal helpers  ************************

  //**************************** Public command generators ************************
  /// Clear the buffer and reset text styles
  List<int> reset() {
    List<int> bytes = [];
    bytes += cInit.codeUnits;
    _styles = PosStyles();
    bytes += setGlobalCodeTable(_codeTable);
    return bytes;
  }

  /// Set global code table which will be used instead of the default printer's code table
  /// (even after resetting)
  List<int> setGlobalCodeTable(String? codeTable) {
    List<int> bytes = [];
    _codeTable = codeTable;
    if (codeTable != null) {
      bytes += Uint8List.fromList(
        List.from(cCodeTable.codeUnits)..add(_profile.getCodePageId(codeTable)),
      );
      _styles = _styles.copyWith(codeTable: codeTable);
    }
    return bytes;
  }

  List<int> setStyles(PosStyles styles, {bool isKanji = false}) {
    List<int> bytes = [];
    if (styles.align != _styles.align) {
      bytes += Latin8Codec().encode(styles.align == PosAlign.left
          ? cAlignLeft
          : (styles.align == PosAlign.center ? cAlignCenter : cAlignRight));

      _styles = _styles.copyWith(align: styles.align);
    }

    if (styles.bold != _styles.bold) {
      bytes += styles.bold ? cBoldOn.codeUnits : cBoldOff.codeUnits;
      _styles = _styles.copyWith(bold: styles.bold);
    }
    if (styles.turn90 != _styles.turn90) {
      bytes += styles.turn90 ? cTurn90On.codeUnits : cTurn90Off.codeUnits;
      _styles = _styles.copyWith(turn90: styles.turn90);
    }
    if (styles.reverse != _styles.reverse) {
      bytes += styles.reverse ? cReverseOn.codeUnits : cReverseOff.codeUnits;
      _styles = _styles.copyWith(reverse: styles.reverse);
    }
    if (styles.underline != _styles.underline) {
      bytes += styles.underline ? cUnderline1dot.codeUnits : cUnderlineOff.codeUnits;
      _styles = _styles.copyWith(underline: styles.underline);
    }

    // Set font
    // Characters size
    switch (styles.fontSize) {
      case Size.small:
        if (_styles.fontSize != Size.small) {
          bytes += cFontA.codeUnits;
          bytes += Uint8List.fromList(
            List.from(cSizeGSn.codeUnits)..add(PosTextSize.decSize(styles.fontSize)),
          );
          _styles = _styles.copyWith(fontSize: styles.fontSize);
        }
        break;
      case Size.large:
        if (_styles.fontSize != Size.large) {
          _setLinesSpacing(bytes);
          bytes += cFontB.codeUnits;
          bytes += Uint8List.fromList(
            List.from(cSizeGSn.codeUnits)..add(PosTextSize.decSize(styles.fontSize)),
          );
          _styles = _styles.copyWith(fontSize: Size.large);
        }
        break;
    }

    // Set Kanji mode
    if (isKanji) {
      bytes += cKanjiOn.codeUnits;
    } else {
      bytes += cKanjiOff.codeUnits;
    }

    // Set local code table
    if (styles.codeTable != null) {
      bytes += Uint8List.fromList(
        List.from(cCodeTable.codeUnits)..add(_profile.getCodePageId(styles.codeTable)),
      );
      _styles = _styles.copyWith(align: styles.align, codeTable: styles.codeTable);
    } else if (_codeTable != null) {
      bytes += Uint8List.fromList(
        List.from(cCodeTable.codeUnits)..add(_profile.getCodePageId(_codeTable)),
      );
      _styles = _styles.copyWith(align: styles.align, codeTable: _codeTable);
    }

    return bytes;
  }

  void _setLinesSpacing(List<int> bytes) {
    bytes.addAll([27, 51, 90]);
  }

  /// Sens raw command(s)
  List<int> rawBytes(List<int> cmd, {bool isKanji = false}) {
    List<int> bytes = [];
    if (!isKanji) {
      bytes += cKanjiOff.codeUnits;
    }
    bytes += Uint8List.fromList(cmd);
    return bytes;
  }

  List<int> text(
    String text, {
    PosStyles styles = const PosStyles(),
    int linesAfter = 0,
    bool containsChinese = false,
  }) {
    List<int> bytes = [];
    bytes += _text(
      _encode(text, isKanji: containsChinese),
      styles: styles,
      isKanji: containsChinese,
    );
    // Ensure at least one line break after the text
    bytes += emptyLines(linesAfter + 1);

    return bytes;
  }

  /// Skips [n] lines
  ///
  /// Similar to [feed] but uses an alternative command
  List<int> emptyLines(int n) {
    List<int> bytes = [];
    if (n > 0) {
      bytes += List.filled(n, '\n').join().codeUnits;
    }
    return bytes;
  }

  /// Skips [n] lines
  ///
  /// Similar to [emptyLines] but uses an alternative command
  List<int> feed(int n) {
    List<int> bytes = [];
    if (n >= 0 && n <= 255) {
      bytes += Uint8List.fromList(
        List.from(cFeedN.codeUnits)..add(n),
      );
    }
    return bytes;
  }

  /// Cut the paper
  ///
  /// [mode] is used to define the full or partial cut (if supported by the priner)
  List<int> cut({PosCutMode mode = PosCutMode.full}) {
    List<int> bytes = [];
    bytes += emptyLines(5);
    if (mode == PosCutMode.partial) {
      bytes += cCutPart.codeUnits;
    } else {
      bytes += cCutFull.codeUnits;
    }
    return bytes;
  }

  /// Print selected code table.
  ///
  /// If [codeTable] is null, global code table is used.
  /// If global code table is null, default printer code table is used.
  List<int> printCodeTable({String? codeTable}) {
    List<int> bytes = [];
    bytes += cKanjiOff.codeUnits;

    if (codeTable != null) {
      bytes += Uint8List.fromList(
        List.from(cCodeTable.codeUnits)..add(_profile.getCodePageId(codeTable)),
      );
    }

    bytes += Uint8List.fromList(List<int>.generate(256, (i) => i));

    // Back to initial code table
    setGlobalCodeTable(_codeTable);
    return bytes;
  }

  /// Beeps [n] times
  ///
  /// Beep [duration] could be between 50 and 450 ms.
  List<int> beep({int n = 3, PosBeepDuration duration = PosBeepDuration.beep450ms}) {
    List<int> bytes = [];
    if (n <= 0) {
      return [];
    }

    int beepCount = n;
    if (beepCount > 9) {
      beepCount = 9;
    }

    bytes += Uint8List.fromList(
      List.from(cBeep.codeUnits)..addAll([beepCount, duration.value]),
    );

    beep(n: n - 9, duration: duration);
    return bytes;
  }

  /// Reverse feed for [n] lines (if supported by the priner)
  List<int> reverseFeed(int n) {
    List<int> bytes = [];
    bytes += Uint8List.fromList(
      List.from(cReverseFeedN.codeUnits)..add(n),
    );
    return bytes;
  }

  /// Print a row.
  ///
  /// A row contains up to 12 columns. A column has a width between 1 and 12.
  /// Total width of columns in one row must be equal 12.
  List<int> row(List<PosColumn> cols) {
    List<int> bytes = [];
    final isSumValid = cols.fold(0, (int sum, col) => sum + col.width) == 12;
    if (!isSumValid) {
      throw Exception('Total columns width must be equal to 12');
    }
    bool isNextRow = false;
    List<PosColumn> nextRow = <PosColumn>[];

    for (int i = 0; i < cols.length; ++i) {
      int colInd = cols.sublist(0, i).fold(0, (int sum, col) => sum + col.width);
      double charWidth = _getCharWidth(cols[i].styles);
      double fromPos = _colIndToPosition(colInd);
      final double toPos = _colIndToPosition(colInd + cols[i].width) - spaceBetweenRows;
      int maxCharactersNb = ((toPos - fromPos) / charWidth).floor();

      Uint8List encodedToPrint =
          cols[i].textEncoded != null ? cols[i].textEncoded! : _encode(cols[i].text);

      // If the col's content is too long, split it to the next row
      int realCharactersNb = encodedToPrint.length;

      if (realCharactersNb > maxCharactersNb) {
        // Print max possible and split to the next row
        Uint8List encodedToPrintNextRow = encodedToPrint.sublist(maxCharactersNb);
        encodedToPrint = encodedToPrint.sublist(0, maxCharactersNb);
        isNextRow = true;
        nextRow.add(PosColumn(
            textEncoded: encodedToPrintNextRow, width: cols[i].width, styles: cols[i].styles));
      } else {
        // Insert an empty col
        nextRow.add(PosColumn(text: '', width: cols[i].width, styles: cols[i].styles));
      }
      // end rows splitting
      bytes += _text(
        encodedToPrint,
        styles: cols[i].styles,
        colInd: colInd,
        colWidth: cols[i].width,
      );
    }

    bytes += emptyLines(1);

    if (isNextRow) {
      bytes += row(nextRow);
    }
    return bytes;
  }

  /// Print a barcode
  ///
  /// [width] range and units are different depending on the printer model (some printers use 1..5).
  /// [height] range: 1 - 255. The units depend on the printer model.
  /// Width, height, font, text position settings are effective until performing of ESC @, reset or power-off.
  List<int> barcode(
    Barcode barcode, {
    int? width,
    int? height,
    BarcodeFont? font,
    BarcodeText textPos = BarcodeText.below,
    PosAlign align = PosAlign.center,
  }) {
    List<int> bytes = [];
    // Set alignment
    bytes += setStyles(PosStyles().copyWith(align: align));

    // Set text position
    bytes += cBarcodeSelectPos.codeUnits + [textPos.value];

    // Set font
    if (font != null) {
      bytes += cBarcodeSelectFont.codeUnits + [font.value];
    }

    // Set width
    if (width != null && width >= 0) {
      bytes += cBarcodeSetW.codeUnits + [width];
    }
    // Set height
    if (height != null && height >= 1 && height <= 255) {
      bytes += cBarcodeSetH.codeUnits + [height];
    }

    // Print barcode
    final header = cBarcodePrint.codeUnits + [barcode.type!.value];
    if (barcode.type!.value <= 6) {
      // Function A
      bytes += header + barcode.data! + [0];
    } else {
      // Function B
      bytes += header + [barcode.data!.length] + barcode.data!;
    }
    return bytes;
  }

  /// Print a QR Code
  List<int> qrcode(
    String text, {
    PosAlign align = PosAlign.center,
    QRSize size = QRSize.Size4,
    QRCorrection cor = QRCorrection.L,
  }) {
    List<int> bytes = [];
    // Set alignment
    bytes += setStyles(PosStyles().copyWith(align: align));
    QRCode qr = QRCode(text, size, cor);
    bytes += qr.bytes;
    return bytes;
  }

  /// Print horizontal full width separator
  /// If [len] is null, then it will be defined according to the paper width
  List<int> hr({
    String ch = '-',
    int? len,
    int linesAfter = 0,
    PosStyles styles = const PosStyles(),
  }) {
    List<int> bytes = [];
    int n = len ?? _getMaxCharsPerLine(styles.fontSize);
    String ch1 = ch.length == 1 ? ch : ch[0];
    bytes += text(List.filled(n, ch1).join(), linesAfter: linesAfter, styles: styles);
    return bytes;
  }

  List<int> textEncoded(
    Uint8List textBytes, {
    PosStyles styles = const PosStyles(),
    int linesAfter = 0,
    int? maxCharsPerLine,
  }) {
    List<int> bytes = [];
    bytes += _text(textBytes, styles: styles);
    // Ensure at least one line break after the text
    bytes += emptyLines(linesAfter + 1);
    return bytes;
  }

  List<int> openCashDrawer({required int pin}) {
    // ESC p m t1 t2
    // p -> 112
    // m -> pin connector (0, 1)
    // t1 t2 -> on off impulse milliseconds
    const t1 = 120;
    const t2 = 240;
    List<int> bytes = [];
    bytes += esc.codeUnits;
    bytes += [112, pin, t1, t2];

    return bytes;
  }

  // ************************ (end) Public command generators ************************

  // ************************ (end) Internal command generators ************************
  /// Generic print for internal use
  ///
  /// [colInd] range: 0..11. If null: do not define the position
  List<int> _text(
    Uint8List textBytes, {
    PosStyles styles = const PosStyles(),
    int? colInd = 0,
    bool isKanji = false,
    int colWidth = 12,
  }) {
    List<int> bytes = [];
    if (colInd != null) {
      double charWidth = _getCharWidth(styles);
      double fromPos = _colIndToPosition(colInd);

      // Align
      if (colWidth != 12) {
        // Update fromPos
        final double toPos = _colIndToPosition(colInd + colWidth) - spaceBetweenRows;
        final double textLen = textBytes.length * charWidth;

        if (styles.align == PosAlign.right) {
          fromPos = toPos - textLen;
        } else if (styles.align == PosAlign.center) {
          fromPos = fromPos + (toPos - fromPos) / 2 - textLen / 2;
        }
        if (fromPos < 0) {
          fromPos = 0;
        }
      }

      final hexStr = fromPos.round().toRadixString(16).padLeft(3, '0');
      final hexPair = HEX.decode(hexStr);

      // Position
      bytes += Uint8List.fromList(
        List.from(cPos.codeUnits)..addAll([hexPair[1], hexPair[0]]),
      );
    }

    bytes += setStyles(styles, isKanji: isKanji);

    bytes += textBytes;
    return bytes;
  }

// ************************ (end) Internal command generators ************************
}
