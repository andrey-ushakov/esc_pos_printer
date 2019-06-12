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

  void println(PosString data) {
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

    _socket.writeln(data.text);
    emptyLines(data.linesAfter);
    reset();
  }

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
      _printCol(colInd, data[i]);
    }

    _socket.writeln();
  }

  void _printCol(int i, PosString data) {
    final int pos = i == 0 ? 0 : (512 * i / 11 - 1).round();
    final hexStr = pos.toRadixString(16).padLeft(3, '0');
    final hexPair = HEX.decode(hexStr);
    // print('dec: $pos \t hex: $hexStr \t pair $hexPair');
    _socket.add(Uint8List.fromList([0x1b, 0x24, hexPair[1], hexPair[0]]));
    _socket.write(data);
  }

  void beep(
      {int count = 3, PosBeepDuration duration = PosBeepDuration.beep450ms}) {
    if (count <= 0) {
      return;
    }

    int beepCount = count;
    if (beepCount > 9) {
      beepCount = 9;
    }

    _socket.add(
      Uint8List.fromList(
        List.from(cBeep.codeUnits)..addAll([beepCount, duration.value]),
      ),
    );

    beep(count: count - 9, duration: duration);
  }

  void reset() {
    _socket.write(cInit);
  }

  void emptyLines(int n) {
    if (n > 0) {
      _socket.write(List.filled(n, '\n').join());
    }
  }

  void feed(int n) {
    if (n >= 0 && n <= 255) {
      _socket.add(
        Uint8List.fromList(
          List.from(cFeedN.codeUnits)..add(n),
        ),
      );
    }
  }

  void reverseFeed(int n) {
    _socket.add(
      Uint8List.fromList(
        List.from(cReverseFeedN.codeUnits)..add(n),
      ),
    );
  }

  void cut({PosCutMode mode = PosCutMode.full}) {
    _socket.write('\n\n\n\n\n');
    if (mode == PosCutMode.partial) {
      _socket.write(cCutPart);
    } else {
      _socket.write(cCutFull);
    }
  }
}
