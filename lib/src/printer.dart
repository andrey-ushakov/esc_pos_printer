import 'dart:io';
import 'commands.dart';

enum TextAlign { left, center, right }

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
  static Future<Printer> connect(host, int port,
      {sourceAddress, Duration timeout}) {
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

  // void writeAll(Iterable objects, [String separator = '']) {
  //   socket.writeAll(objects, separator);
  // }

  // void writeLine([Object obj = '']) {
  //   socket.writeln(obj);
  // }

  // void write(Object obj) {
  //   socket.write(obj);
  // }

  // TODO charHeight, charWidth range ?

  // TODO should be ended by \n
  void println(
    Object text, {
    bool bold = false,
    bool reverse = false,
    bool underline = false,
    TextAlign align = TextAlign.left,
    int charHeight = -1,
    int charWidth = -1,
    int linesAfter = -1,
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

    feed(linesAfter);

    // reset all to default
    reset();
  }

  void reset() {
    _socket.write(cInit);
  }

  void feed(int n) {
    if (n >= 0 && n <= 255) {
      _socket.writeAll([cFeedN, n.toString()]);
    }
  }

  void reverseFeed(int n) {
    _socket.writeAll([cReverseFeedN, n.toString()]);
  }

  void cut() {
    _socket.write('\n\n\n\n\n');
    _socket.write(cCut);
  }
}
