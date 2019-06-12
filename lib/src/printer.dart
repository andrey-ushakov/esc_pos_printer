import 'dart:io';
import 'dart:typed_data';
import 'commands.dart';
import 'enums.dart';

/// Printer.
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

  void println(
    String text, {
    bool bold = false,
    bool reverse = false,
    bool underline = false,
    PosTextAlign align = PosTextAlign.left,
    PosTextSize height = PosTextSize.size1,
    PosTextSize width = PosTextSize.size1,
    PosFontType fontType = PosFontType.fontA,
    int linesAfter = 0,
  }) {
    _socket.write(bold ? cBoldOn : cBoldOff);
    _socket.write(reverse ? cReverseOn : cReverseOff);
    _socket.write(underline ? cUnderline1dot : cUnderlineOff);
    _socket.write(align == PosTextAlign.left
        ? cAlignLeft
        : (align == PosTextAlign.center ? cAlignCenter : cAlignRight));
    _socket.write(fontType == PosFontType.fontA ? cFontA : cFontB);
    // Text size
    _socket.add(
      Uint8List.fromList(
        List.from(cSizeGSn.codeUnits)..add(PosTextSize.decSize(height, width)),
      ),
    );

    _socket.writeln(text);
    emptyLines(linesAfter);
    reset();
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
