import 'dart:io';
import 'commands.dart';

enum TextAlign { left, center, right }
enum CutMode { normal, partial, full }

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
    TextAlign align = TextAlign.left,
    int charHeight = -1, // TODO replace by font size
    int charWidth = -1,
    int linesAfter = 0,
  }) {
    _socket.write(bold ? cBoldOn : cBoldOff);
    _socket.write(reverse ? cReverseOn : cReverseOff);
    _socket.write(underline ? cUnderline1dot : cUnderlineOff);
    _socket.write(align == TextAlign.left
        ? cAlignLeft
        : (align == TextAlign.center ? cAlignCenter : cAlignRight));

    if (charHeight > 0 && charWidth > 0) {
      var n = 16 * (charWidth - 1) + (charHeight - 1);
      _socket.writeAll([cSizeN, n]);
    }

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
      _socket.writeAll([cFeedN, n.toString()]);
    }
  }

  void reverseFeed(int n) {
    _socket.writeAll([cReverseFeedN, n.toString()]);
  }

  void cut({CutMode mode = CutMode.normal}) {
    _socket.write('\n\n\n\n\n');
    if (mode == CutMode.partial) {
      _socket.write(cCutPart);
    } else if (mode == CutMode.full) {
      _socket.write(cCutFull);
    } else {
      _socket.write(cCut);
    }
  }
}
