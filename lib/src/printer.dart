/*
 * esc_pos_printer
 * Created by Andrey Ushakov
 * 
 * Copyright (c) 2019. All rights reserved.
 * See LICENSE for distribution and usage details.
 */

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:hex/hex.dart';
import 'package:image/image.dart';
import 'commands.dart';
import 'enums.dart';
import 'pos_column.dart';
import 'pos_styles.dart';

/// Network printer
class Printer {
  Printer._internal(this._socket) {
    reset();
  }

  final Socket _socket;
  PosCodeTable _codeTable;

  /// Creates a new socket connection to the network printer.
  ///
  /// The argument [timeout] is used to specify the maximum allowed time to wait
  /// for a connection to be established.
  static Future<Printer> connect(
    String host, {
    int port = 9100,
    Duration timeout,
  }) {
    return Socket.connect(host, port, timeout: timeout).then((socket) {
      return Printer._internal(socket);
    });
  }

  /// Disconnect from the printer
  void disconnect() {
    _socket.destroy();
  }

  /// Set global code table which will be used instead of the default printer's code table
  void setGlobalCodeTable(PosCodeTable codeTable) {
    _codeTable = codeTable;
    if (codeTable != null) {
      _socket.add(
        Uint8List.fromList(
          List.from(cCodeTable.codeUnits)..add(codeTable.value),
        ),
      );
    }
  }

  double _colIndToPosition(int colInd) {
    return colInd == 0 ? 0 : (512 * colInd / 11 - 1);
  }

  /// Generic print for internal use
  ///
  /// [colInd] range: 0..11
  void _print(
    String text, {
    PosStyles styles = const PosStyles(),
    int colInd = 0,
    int linesAfter = 0,
    bool cancelKanji = true,
    int colWidth = 12,
  }) {
    const charLen = 11.625; // 48 symbols per line
    double fromPos = _colIndToPosition(colInd);

    // Align
    if (colWidth == 12) {
      _socket.write(styles.align == PosTextAlign.left
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

    _socket.write(styles.bold ? cBoldOn : cBoldOff);
    _socket.write(styles.turn90 ? cTurn90On : cTurn90Off);
    _socket.write(styles.reverse ? cReverseOn : cReverseOff);
    _socket.write(styles.underline ? cUnderline1dot : cUnderlineOff);
    _socket.write(styles.fontType == PosFontType.fontA ? cFontA : cFontB);
    // Text size
    _socket.add(
      Uint8List.fromList(
        List.from(cSizeGSn.codeUnits)
          ..add(PosTextSize.decSize(styles.height, styles.width)),
      ),
    );
    // Position
    _socket.add(
      Uint8List.fromList(
        List.from(cPos.codeUnits)..addAll([hexPair[1], hexPair[0]]),
      ),
    );

    // Cancel Kanji mode
    if (cancelKanji) {
      _socket.write(cKanjiCancel);
    }

    // Set local code table
    if (styles.codeTable != null) {
      _socket.add(
        Uint8List.fromList(
          List.from(cCodeTable.codeUnits)..add(styles.codeTable.value),
        ),
      );
    }

    if (cancelKanji) {
      _socket.add(latin1.encode(text));
    } else {
      _socket.write(text);
    }
  }

  /// Sens raw command(s)
  void sendRaw(List<int> cmd, {bool cancelKanji = true}) {
    if (cancelKanji) {
      _socket.write(cKanjiCancel);
    }
    _socket.add(Uint8List.fromList(cmd));
  }

  /// Prints one line of styled text
  void println(
    String text, {
    PosStyles styles = const PosStyles(),
    int linesAfter = 0,
    bool cancelKanji = true,
  }) {
    _print(
      text,
      styles: styles,
      linesAfter: linesAfter,
      cancelKanji: cancelKanji,
    );
    _socket.writeln();
    emptyLines(linesAfter);
    reset();
  }

  /// Print selected code table.
  ///
  /// If [codeTable] is null, global code table is used.
  /// If global code table is null, default printer code table is used.
  void printCodeTable({PosCodeTable codeTable}) {
    _socket.write(cKanjiCancel);

    if (codeTable != null) {
      _socket.add(
        Uint8List.fromList(
          List.from(cCodeTable.codeUnits)..add(codeTable.value),
        ),
      );
    }

    final List<int> list = [];
    for (int i = 0; i < 256; i++) {
      list.add(i);
    }

    _socket.add(
      Uint8List.fromList(list),
    );

    // Back to initial code table
    setGlobalCodeTable(_codeTable);
  }

  /// Print a row.
  ///
  /// A row contains up to 12 columns. A column has a width between 1 and 12.
  /// Total width of columns in one row must be equal 12.
  void printRow(List<PosColumn> cols) {
    final validSum = cols.fold(0, (int sum, col) => sum + col.width) == 12;
    if (!validSum) {
      throw Exception('Total columns width must be equal to 12');
    }

    for (int i = 0; i < cols.length; ++i) {
      final colInd =
          cols.sublist(0, i).fold(0, (int sum, col) => sum + col.width);
      _print(
        cols[i].text,
        styles: cols[i].styles,
        colInd: colInd,
        colWidth: cols[i].width,
      );
    }

    _socket.writeln();
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

    _socket.add(
      Uint8List.fromList(
        List.from(cBeep.codeUnits)..addAll([beepCount, duration.value]),
      ),
    );

    beep(n: n - 9, duration: duration);
  }

  /// Clear the buffer and reset text styles
  void reset() {
    _socket.write(cInit);
    setGlobalCodeTable(_codeTable);
  }

  /// Skips [n] lines
  ///
  /// Similar to [feed] but uses an alternative command
  void emptyLines(int n) {
    if (n > 0) {
      _socket.write(List.filled(n, '\n').join());
    }
  }

  /// Skips [n] lines
  ///
  /// Similar to [emptyLines] but uses an alternative command
  void feed(int n) {
    if (n >= 0 && n <= 255) {
      _socket.add(
        Uint8List.fromList(
          List.from(cFeedN.codeUnits)..add(n),
        ),
      );
    }
  }

  /// Reverse feed for [n] lines (if supported by the priner)
  void reverseFeed(int n) {
    _socket.add(
      Uint8List.fromList(
        List.from(cReverseFeedN.codeUnits)..add(n),
      ),
    );
  }

  /// Cut the paper
  ///
  /// [mode] is used to define the full or partial cut (if supported by the priner)
  void cut({PosCutMode mode = PosCutMode.full}) {
    _socket.write('\n\n\n\n\n');
    if (mode == PosCutMode.partial) {
      _socket.write(cCutPart);
    } else {
      _socket.write(cCutFull);
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

  List<int> _convert1bit(List<int> bytes) {
    final List<int> res = [];
    for (int i = 0; i < bytes.length; i += 8) {
      res.add(bytes[i]);
    }
    return res;
  }

  /// Print image
  ///
  /// [image] is an instanse of class from [Image library](https://pub.dev/packages/image)
  void printImage(Image image) {
    const bool highDensityHorizontal = true;
    const bool highDensityVertical = true;

    final int widthPx = image.width;
    final int heightPx = image.height;

    final int widthBytes = (widthPx + 7) ~/ 8;
    const int densityByte =
        (highDensityVertical ? 0 : 1) + (highDensityHorizontal ? 0 : 2);

    final List<int> header = List.from(cImgPrint.codeUnits);
    header.add(densityByte);
    header.addAll(_intLowHigh(widthBytes, 2));
    header.addAll(_intLowHigh(heightPx, 2));

    final xL = header[4];
    final xH = header[5];

    final newWidth = (xL + xH * 256) * 8;
    final Image imgResized =
        copyResize(image, width: newWidth, height: image.height);

    invert(imgResized);
    final bytes = imgResized.getBytes(format: Format.luminance);

    final res = _convert1bit(bytes);

    // print('img w * h (src): $widthPx * $heightPx');
    // print('img w * h (new): ${imgResized.width} * ${imgResized.height}');
    // print('source bytes: ${bytes.length}');
    // print('= target bytes: ${(xL + xH * 256) * (header[6] + header[7] * 256)}');
    // print('= to print bytes: ${res.length}');
    // print(header);

    sendRaw(List.from(header)..addAll(res));
  }
}
