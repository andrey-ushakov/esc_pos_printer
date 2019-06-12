/*
 * esc_pos_printer
 * Created by Andrey Ushakov
 * 
 * Copyright (c) 2019. All rights reserved.
 * See LICENSE for distribution and usage details.
 */

import 'dart:io';
import 'dart:typed_data';
import 'package:hex/hex.dart';
import 'commands.dart';
import 'enums.dart';
import 'exceptions.dart';
import 'pos_string.dart';

/// Network printer
class Printer {
  Printer(this._socket) {
    reset();
  }

  final Socket _socket;

  /// Creates a new socket connection to the network printer.
  ///
  /// The argument [timeout] is used to specify the maximum allowed time to wait
  /// for a connection to be established.
  static Future<Printer> connect(String host,
      {int port = 9100, Duration timeout}) {
    return Socket.connect(host, port, timeout: timeout).then((socket) {
      return Printer(socket);
    });
  }

  /// Disconnect from the printer
  void disconnect() {
    _socket.destroy();
  }

  /// Generic print for internal use
  ///
  /// [colInd] range: 0..11
  void _print(PosString data, {int colInd = 0, int linesAfter = 0}) {
    final int pos = colInd == 0 ? 0 : (512 * colInd / 11 - 1).round();
    final hexStr = pos.toRadixString(16).padLeft(3, '0');
    final hexPair = HEX.decode(hexStr);
    // print('dec: $pos \t hex: $hexStr \t pair $hexPair');

    _socket.write(data.bold ? cBoldOn : cBoldOff);
    _socket.write(data.reverse ? cReverseOn : cReverseOff);
    _socket.write(data.underline ? cUnderline1dot : cUnderlineOff);
    _socket.write(data.align == PosTextAlign.left
        ? cAlignLeft
        : (data.align == PosTextAlign.center ? cAlignCenter : cAlignRight));
    _socket.write(data.fontType == PosFontType.fontA ? cFontA : cFontB);
    // Text size
    _socket.add(
      Uint8List.fromList(
        List.from(cSizeGSn.codeUnits)
          ..add(PosTextSize.decSize(data.height, data.width)),
      ),
    );
    // Position
    _socket.add(
      Uint8List.fromList(
        List.from(cPos.codeUnits)..addAll([hexPair[1], hexPair[0]]),
      ),
    );

    _socket.write(data.text);
  }

  /// Prints one line of styled text
  void println(PosString data, {int linesAfter = 0}) {
    _print(data, linesAfter: linesAfter);
    _socket.writeln();
    emptyLines(linesAfter);
    reset();
  }

  /// Print a row.
  ///
  /// A row contains up to 12 columns. A column has a width between 1 and 12.
  /// Total width of columns in one row must be equal 12.
  ///
  /// [cols] parameter is used to define the row structure (each integer value is one column width).
  /// [data] parameter is used to define the column data (text, align inside of the column and styles).
  /// Column data is represented by [PosString] class.
  ///
  /// ```dart
  /// printer.printRow(
  ///   [3, 6, 3],
  ///   [ PosString('col3'),
  ///     PosString('col6'),
  ///     PosString('col3') ],
  /// );
  /// ```
  void printRow(List<int> cols, List<PosString> data) {
    final validRange = cols.every((val) => val >= 1 && val <= 12);
    if (!validRange) {
      throw PosRowException('Column width should be between 1..12');
    }
    final validSum = cols.fold(0, (int sum, cur) => sum + cur) == 12;
    if (!validSum) {
      throw PosRowException('Total columns width must be equal 12');
    }
    if (cols.length != data.length) {
      throw PosRowException("Columns number doesn't equal to data number");
    }

    for (int i = 0; i < cols.length; ++i) {
      final colInd = cols.sublist(0, i).fold(0, (int sum, cur) => sum + cur);
      _print(data[i], colInd: colInd);
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
}
