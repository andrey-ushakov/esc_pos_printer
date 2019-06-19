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
import 'pos_column.dart';
import 'pos_styles.dart';

/// Network printer
class Printer {
  Printer._internal(this._socket) {
    reset();
  }

  final Socket _socket;
  PosCodeTable _codeTable = PosCodeTable.pc437;

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

  void setCodeTable(PosCodeTable codeTable) {
    _codeTable = codeTable;
    _socket.add(
      Uint8List.fromList(
        List.from(cCodeTable.codeUnits)..add(codeTable.value),
      ),
    );
  }

  /// Generic print for internal use
  ///
  /// [colInd] range: 0..11
  void _print(
    String text, {
    PosStyles styles = const PosStyles(),
    int colInd = 0,
    int linesAfter = 0,
  }) {
    final int pos = colInd == 0 ? 0 : (512 * colInd / 11 - 1).round();
    final hexStr = pos.toRadixString(16).padLeft(3, '0');
    final hexPair = HEX.decode(hexStr);
    // print('dec: $pos \t hex: $hexStr \t pair $hexPair');

    _socket.write(styles.bold ? cBoldOn : cBoldOff);
    _socket.write(styles.turn90 ? cTurn90On : cTurn90Off);
    _socket.write(styles.reverse ? cReverseOn : cReverseOff);
    _socket.write(styles.underline ? cUnderline1dot : cUnderlineOff);
    _socket.write(styles.align == PosTextAlign.left
        ? cAlignLeft
        : (styles.align == PosTextAlign.center ? cAlignCenter : cAlignRight));
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

    _socket.write(text);
  }

  /// Sens raw command(s)
  void sendRaw(List<int> cmd) {
    _socket.add(Uint8List.fromList(List.from(cmd)));
  }

  /// Prints one line of styled text
  void println(
    String text, {
    PosStyles styles = const PosStyles(),
    int linesAfter = 0,
  }) {
    _print(text, styles: styles, linesAfter: linesAfter);
    _socket.writeln();
    emptyLines(linesAfter);
    reset();
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
      _print(cols[i].text, styles: cols[i].styles, colInd: colInd);
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
    setCodeTable(_codeTable);
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
