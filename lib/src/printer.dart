import 'dart:io';
import 'dart:typed_data';
import 'commands.dart';

enum PosTextAlign { left, center, right }
enum PosCutMode { normal, partial, full }

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

/// Abstract printer.
class Printer {
  Printer(this._socket) {
    reset();
  }

  final Socket _socket;

  /// Creates a new socket connection to the printer.
  ///
  /// [host] can either be a [String] or an [InternetAddress]. If [host] is a
  /// [String], [connect] will perform a [InternetAddress.lookup] and try
  /// all returned [InternetAddress]es, until connected. Unless a
  /// connection was established, the error from the first failing connection is
  /// returned.
  ///
  /// The argument [sourceAddress] can be used to specify the local
  /// address to bind when making the connection. `sourceAddress` can either
  /// be a `String` or an `InternetAddress`. If a `String` is passed it must
  /// hold a numeric IP address.
  ///
  /// The argument [timeout] is used to specify the maximum allowed time to wait
  /// for a connection to be established.
  static Future<Printer> connect(host,
      {int port = 9100, sourceAddress, Duration timeout}) {
    return Socket.connect(host, port,
            sourceAddress: sourceAddress, timeout: timeout)
        .then((socket) {
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
    int linesAfter = 0,
  }) {
    _socket.write(bold ? cBoldOn : cBoldOff);
    _socket.write(reverse ? cReverseOn : cReverseOff);
    _socket.write(underline ? cUnderline1dot : cUnderlineOff);
    _socket.write(align == PosTextAlign.left
        ? cAlignLeft
        : (align == PosTextAlign.center ? cAlignCenter : cAlignRight));

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

  void cut({PosCutMode mode = PosCutMode.normal}) {
    _socket.write('\n\n\n\n\n');
    if (mode == PosCutMode.partial) {
      _socket.write(cCutPart);
    } else if (mode == PosCutMode.full) {
      _socket.write(cCutFull);
    } else {
      _socket.write(cCut);
    }
  }
}
