/*
 * esc_pos_printer
 * Created by Andrey Ushakov
 * 
 * Copyright (c) 2019-2020. All rights reserved.
 * See LICENSE for distribution and usage details.
 */

import 'dart:convert';
import 'dart:typed_data';
import 'package:gbk_codec/gbk_codec.dart';
import 'package:hex/hex.dart';
import 'package:image/image.dart';
import 'barcode.dart';
import 'commands.dart';
import 'enums.dart';
import 'pos_column.dart';
import 'pos_styles.dart';

class Ticket {
  Ticket(this._paperSize) {
    reset();
  }

  List<int> bytes = [];
  PosCodeTable _codeTable;
  final PaperSize _paperSize;

  /// Set global code table which will be used instead of the default printer's code table
  void setGlobalCodeTable(PosCodeTable codeTable) {
    _codeTable = codeTable;
    if (codeTable != null) {
      bytes += Uint8List.fromList(
        List.from(cCodeTable.codeUnits)..add(codeTable.value),
      );
    }
  }

  double _colIndToPosition(int colInd) {
    final int width = _paperSize.width;
    return colInd == 0 ? 0 : (width * colInd / 11 - 1);
  }

  /// Generic print for internal use
  ///
  /// [colInd] range: 0..11
  void _text(
    String text, {
    PosStyles styles = const PosStyles(),
    int colInd = 0,
    bool kanjiOff = true,
    int colWidth = 12,
  }) {
    const charLen = 11.625; // 48 symbols per line for 80mm and 32 for 58mm
    double fromPos = _colIndToPosition(colInd);

    // Align
    if (colWidth == 12) {
      bytes += latin1.encode(styles.align == PosTextAlign.left
          ? cAlignLeft
          : (styles.align == PosTextAlign.center ? cAlignCenter : cAlignRight));
    } else {
      final double toPos = _colIndToPosition(colInd + colWidth) - 5;
      final double textLen = text.length * charLen;

      if (styles.align == PosTextAlign.right) {
        fromPos = toPos - textLen;
      } else if (styles.align == PosTextAlign.center) {
        fromPos = fromPos + (toPos - fromPos) / 2 - textLen / 2;
      }
    }

    final hexStr = fromPos.round().toRadixString(16).padLeft(3, '0');
    final hexPair = HEX.decode(hexStr);

    bytes += styles.bold ? cBoldOn.codeUnits : cBoldOff.codeUnits;
    bytes += styles.turn90 ? cTurn90On.codeUnits : cTurn90Off.codeUnits;
    bytes += styles.reverse ? cReverseOn.codeUnits : cReverseOff.codeUnits;
    bytes +=
        styles.underline ? cUnderline1dot.codeUnits : cUnderlineOff.codeUnits;
    bytes += styles.fontType == PosFontType.fontA
        ? cFontA.codeUnits
        : cFontB.codeUnits;
    // Text size
    bytes += Uint8List.fromList(
      List.from(cSizeGSn.codeUnits)
        ..add(PosTextSize.decSize(styles.height, styles.width)),
    );
    // Position
    bytes += Uint8List.fromList(
      List.from(cPos.codeUnits)..addAll([hexPair[1], hexPair[0]]),
    );

    // Cancel Kanji mode
    if (kanjiOff) {
      bytes += cKanjiOff.codeUnits;
    } else {
      bytes += cKanjiOn.codeUnits;
    }

    // Set local code table
    if (styles.codeTable != null) {
      bytes += Uint8List.fromList(
        List.from(cCodeTable.codeUnits)..add(styles.codeTable.value),
      );
    }

    if (kanjiOff) {
      bytes += latin1.encode(text);
    } else {
      bytes += gbk_bytes.encode(text);
    }
  }

  /// Sens raw command(s)
  void rawBytes(List<int> cmd, {bool kanjiOff = true}) {
    if (kanjiOff) {
      bytes += cKanjiOff.codeUnits;
    }
    bytes += Uint8List.fromList(cmd);
  }

  void text(
    String text, {
    PosStyles styles = const PosStyles(),
    int linesAfter = 0,
    bool containsChinese = false,
  }) {
    if (!containsChinese) {
      _text(
        text,
        styles: styles,
        kanjiOff: !containsChinese,
      );
      emptyLines(linesAfter + 1); // at least ine line break after the text
      reset();
    } else {
      _mixedKanji(text, styles: styles, linesAfter: linesAfter);
    }
  }

  /// Break text into chinese/non-chinese lexemes
  List _getLexemes(String text) {
    bool _isChinese(String ch) {
      return ch.codeUnitAt(0) > 255 ? true : false;
    }

    final List<String> lexemes = [];
    final List<bool> isLexemeChinese = [];
    int start = 0;
    int end = 0;
    bool curLexemeChinese = _isChinese(text[0]);
    for (var i = 1; i < text.length; ++i) {
      if (curLexemeChinese == _isChinese(text[i])) {
        end += 1;
      } else {
        lexemes.add(text.substring(start, end + 1));
        isLexemeChinese.add(curLexemeChinese);
        start = i;
        end = i;
        curLexemeChinese = !curLexemeChinese;
      }
    }
    lexemes.add(text.substring(start, end + 1));
    isLexemeChinese.add(curLexemeChinese);

    return <dynamic>[lexemes, isLexemeChinese];
  }

  /// Prints one line of styled mixed (chinese and latin symbols) text
  void _mixedKanji(
    String text, {
    PosStyles styles = const PosStyles(),
    int linesAfter = 0,
  }) {
    final list = _getLexemes(text);
    final List<String> lexemes = list[0];
    final List<bool> isLexemeChinese = list[1];

    // Print each lexeme using codetable OR kanji
    for (var i = 0; i < lexemes.length; ++i) {
      _text(
        lexemes[i],
        styles: styles,
        kanjiOff: !isLexemeChinese[i],
      );
    }

    emptyLines(linesAfter + 1);
    reset();
  }

  /// Print selected code table.
  ///
  /// If [codeTable] is null, global code table is used.
  /// If global code table is null, default printer code table is used.
  void codeTable({PosCodeTable codeTable}) {
    bytes += cKanjiOff.codeUnits;

    if (codeTable != null) {
      bytes += Uint8List.fromList(
        List.from(cCodeTable.codeUnits)..add(codeTable.value),
      );
    }

    final List<int> list = [];
    for (int i = 0; i < 256; i++) {
      list.add(i);
    }

    bytes += Uint8List.fromList(list);

    // Back to initial code table
    setGlobalCodeTable(_codeTable);
  }

  /// Print a row.
  ///
  /// A row contains up to 12 columns. A column has a width between 1 and 12.
  /// Total width of columns in one row must be equal 12.
  void row(List<PosColumn> cols) {
    final validSum = cols.fold(0, (int sum, col) => sum + col.width) == 12;
    if (!validSum) {
      throw Exception('Total columns width must be equal to 12');
    }

    for (int i = 0; i < cols.length; ++i) {
      final colInd =
          cols.sublist(0, i).fold(0, (int sum, col) => sum + col.width);
      if (!cols[i].containsChinese) {
        _text(
          cols[i].text,
          styles: cols[i].styles,
          colInd: colInd,
          colWidth: cols[i].width,
        );
      } else {
        final list = _getLexemes(cols[i].text);
        final List<String> lexemes = list[0];
        final List<bool> isLexemeChinese = list[1];

        // Print each lexeme using codetable OR kanji
        for (var j = 0; j < lexemes.length; ++j) {
          _text(
            lexemes[j],
            styles: cols[i].styles,
            colInd: colInd,
            colWidth: cols[i].width,
            kanjiOff: !isLexemeChinese[j],
          );
        }
      }
    }

    emptyLines(1);
    reset();
  }

  /// Beeps [n] times
  ///
  /// Beep [duration] could be between 50 and 450 ms.
  void beep({int n = 3, PosBeepDuration duration = PosBeepDuration.beep450ms}) {
    if (n <= 0) {
      return;
    }

    int beepCount = n;
    if (beepCount > 9) {
      beepCount = 9;
    }

    bytes += Uint8List.fromList(
      List.from(cBeep.codeUnits)..addAll([beepCount, duration.value]),
    );

    beep(n: n - 9, duration: duration);
  }

  /// Clear the buffer and reset text styles
  void reset() {
    bytes += cInit.codeUnits;
    setGlobalCodeTable(_codeTable);
  }

  /// Skips [n] lines
  ///
  /// Similar to [feed] but uses an alternative command
  void emptyLines(int n) {
    if (n > 0) {
      bytes += List.filled(n, '\n').join().codeUnits;
    }
  }

  /// Skips [n] lines
  ///
  /// Similar to [emptyLines] but uses an alternative command
  void feed(int n) {
    if (n >= 0 && n <= 255) {
      bytes += Uint8List.fromList(
        List.from(cFeedN.codeUnits)..add(n),
      );
    }
  }

  /// Reverse feed for [n] lines (if supported by the priner)
  void reverseFeed(int n) {
    bytes += Uint8List.fromList(
      List.from(cReverseFeedN.codeUnits)..add(n),
    );
  }

  /// Cut the paper
  ///
  /// [mode] is used to define the full or partial cut (if supported by the priner)
  void cut({PosCutMode mode = PosCutMode.full}) {
    emptyLines(5);
    if (mode == PosCutMode.partial) {
      bytes += cCutPart.codeUnits;
    } else {
      bytes += cCutFull.codeUnits;
    }
  }


 void drawer({DrawerPin mode = DrawerPin.pin2}) {
    if (mode == DrawerPin.pin2) {
      bytes += cCashDrawerPin2.codeUnits;
    } else {
      bytes += cCashDrawerPin5.codeUnits;
    }
  }

  /// Generate multiple bytes for a number: In lower and higher parts, or more parts as needed.
  ///
  /// [value] Input number
  /// [bytesNb] The number of bytes to output (1 - 4)
  List<int> _intLowHigh(int value, int bytesNb) {
    final dynamic maxInput = 256 << (bytesNb * 8) - 1;

    if (bytesNb < 1 || bytesNb > 4) {
      throw Exception('Can only output 1-4 bytes');
    }
    if (value < 0 || value > maxInput) {
      throw Exception(
          'Number too large. Can only output up to $maxInput in $bytesNb bytes');
    }

    final List<int> res = <int>[];
    int buf = value;
    for (int i = 0; i < bytesNb; ++i) {
      res.add(buf % 256);
      buf = buf ~/ 256;
    }
    return res;
  }

  /// Replaces a single bit in a 32-bit unsigned integer.
  int _transformUint32Bool(int uint32, int shift, bool newValue) {
    return ((0xFFFFFFFF ^ (0x1 << shift)) & uint32) |
        ((newValue ? 1 : 0) << shift);
  }

  /// Merges each 8 values (bits) into one byte
  List<int> _packBitsIntoBytes(List<int> bytes) {
    const pxPerLine = 8;
    final List<int> res = <int>[];
    const threshold = 127; // set the greyscale -> b/w threshold here
    for (int i = 0; i < bytes.length; i += pxPerLine) {
      int newVal = 0;
      for (int j = 0; j < pxPerLine; j++) {
        newVal = _transformUint32Bool(
          newVal,
          pxPerLine - j,
          bytes[i + j] > threshold,
        );
      }
      res.add(newVal ~/ 2);
    }
    return res;
  }

  /// Print image using (ESC *) command
  ///
  /// [image] is an instanse of class from [Image library](https://pub.dev/packages/image)
  void image(Image imgSrc) {
    final Image image = Image.from(imgSrc); // make a copy
    const bool highDensityHorizontal = true;
    const bool highDensityVertical = true;

    invert(image);
    flip(image, Flip.horizontal);
    final Image imageRotated = copyRotate(image, 270);

    const int lineHeight = highDensityVertical ? 3 : 1;
    final List<List<int>> blobs = _toColumnFormat(imageRotated, lineHeight * 8);

    // Compress according to line density
    // Line height contains 8 or 24 pixels of src image
    // Each blobs[i] contains greyscale bytes [0-255]
    // const int pxPerLine = 24 ~/ lineHeight;
    for (int blobInd = 0; blobInd < blobs.length; blobInd++) {
      blobs[blobInd] = _packBitsIntoBytes(blobs[blobInd]);
    }

    final int heightPx = imageRotated.height;
    const int densityByte =
        (highDensityHorizontal ? 1 : 0) + (highDensityVertical ? 32 : 0);

    final List<int> header = List.from(cBitImg.codeUnits);
    header.add(densityByte);
    header.addAll(_intLowHigh(heightPx, 2));

    // Adjust line spacing (for 16-unit line feeds): ESC 3 0x10 (HEX: 0x1b 0x33 0x10)
    rawBytes([27, 51, 16]);
    for (int i = 0; i < blobs.length; ++i) {
      rawBytes(List.from(header)..addAll(blobs[i])..addAll('\n'.codeUnits));
    }
    // Reset line spacing: ESC 2 (HEX: 0x1b 0x32)
    rawBytes([27, 50]);
  }

  /// Extract slices of an image as equal-sized blobs of column-format data.
  ///
  /// [image] Image to extract from
  /// [lineHeight] Printed line height in dots
  List<List<int>> _toColumnFormat(Image imgSrc, int lineHeight) {
    final Image image = Image.from(imgSrc); // make a copy

    // Determine new width: closest integer that is divisible by lineHeight
    final int widthPx = (image.width + lineHeight) - (image.width % lineHeight);
    final int heightPx = image.height;

    // Create a black bottom layer
    final biggerImage = copyResize(image, width: widthPx, height: heightPx);
    fill(biggerImage, 0);
    // Insert source image into bigger one
    drawImage(biggerImage, image, dstX: 0, dstY: 0);

    int left = 0;
    final List<List<int>> blobs = [];

    while (left < widthPx) {
      final Image slice = copyCrop(biggerImage, left, 0, lineHeight, heightPx);
      final Uint8List bytes = slice.getBytes(format: Format.luminance);
      blobs.add(bytes);
      left += lineHeight;
    }

    return blobs;
  }

  /// Print image using (GS v 0) obsolete command
  ///
  /// [image] is an instanse of class from [Image library](https://pub.dev/packages/image)
  void imageRaster(
    Image imgSrc, {
    bool highDensityHorizontal = true,
    bool highDensityVertical = true,
  }) {
    final Image image = Image.from(imgSrc); // make a copy

    final int widthPx = image.width;
    final int heightPx = image.height;

    final int widthBytes = (widthPx + 7) ~/ 8;
    final int densityByte =
        (highDensityVertical ? 0 : 1) + (highDensityHorizontal ? 0 : 2);

    final List<int> header = List.from(cRasterImg.codeUnits);
    header.add(densityByte);
    header.addAll(_intLowHigh(widthBytes, 2));
    header.addAll(_intLowHigh(heightPx, 2));

    grayscale(image);
    invert(image);

    // R/G/B channels are same -> keep only one channel
    final List<int> oneChannelBytes = [];
    final List<int> buffer = image.getBytes(format: Format.rgba);
    for (int i = 0; i < buffer.length; i += 4) {
      oneChannelBytes.add(buffer[i]);
    }

    // Add some empty pixels at the end of each line (to make the width divisible by 8)
    final targetWidth = (widthPx + 8) - (widthPx % 8);
    final missingPx = targetWidth - widthPx;
    final extra = Uint8List(missingPx);
    for (int i = 0; i < heightPx; i++) {
      final pos = (i * widthPx + widthPx) + i * missingPx;
      oneChannelBytes.insertAll(pos, extra);
    }

    // Pack bits into bytes
    final List<int> res = _packBitsIntoBytes(oneChannelBytes);

    rawBytes(List.from(header)..addAll(res));
  }

  /// Print barcode
  ///
  /// [width] range and units are different depending on the printer model.
  /// [height] range: 1 - 255. The units depend on the printer model.
  /// Width, height, font, text position settings are effective until performing of ESC @, reset or power-off.
  void barcode(
    Barcode barcode, {
    int width,
    int height,
    BarcodeFont font,
    BarcodeText textPos = BarcodeText.below,
  }) {
    // Set text position
    rawBytes(cBarcodeSelectPos.codeUnits + [textPos.value]);

    // Set font
    if (font != null) {
      rawBytes(cBarcodeSelectFont.codeUnits + [font.value]);
    }

    // Set width
    if (width != null && width >= 0) {
      rawBytes(cBarcodeSetW.codeUnits + [width]);
    }
    // Set height
    if (height != null && height >= 1 && height <= 255) {
      rawBytes(cBarcodeSetH.codeUnits + [height]);
    }

    // Print barcode
    final header = cBarcodePrint.codeUnits + [barcode.type.value];
    rawBytes(header + barcode.data + [0]);
  }
}
