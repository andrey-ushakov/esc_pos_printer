/*
 * esc_pos_printer
 * Created by Andrey Ushakov
 * 
 * Copyright (c) 2019-2020. All rights reserved.
 * See LICENSE for distribution and usage details.
 */

import 'dart:async';
import 'dart:io';
import 'dart:typed_data' show Uint8List;

import 'package:esc_pos_printer/esc_pos_utils/src/barcode.dart';
import 'package:esc_pos_printer/esc_pos_utils/src/capability_profile.dart';
import 'package:esc_pos_printer/esc_pos_utils/src/enums.dart';
import 'package:esc_pos_printer/esc_pos_utils/src/generator.dart';
import 'package:esc_pos_printer/esc_pos_utils/src/pos_column.dart';
import 'package:esc_pos_printer/esc_pos_utils/src/pos_styles.dart';
import 'package:esc_pos_printer/esc_pos_utils/src/qrcode.dart';
import 'package:image/image.dart';
import 'package:rxdart/rxdart.dart';

import './enums.dart';

/// Network Printer
class NetworkPrinter {
  NetworkPrinter({required this.host, this.port = 9100}) {
    _stateStream.add(currentState);
  }
  Stream<PosPrinterState> get state => _stateStream.stream;
  PosPrinterState get currentState => _currentState;
  final int port;
  final String host;
  PaperSize get currentPaperSize => _currentPaperSize;

  final StreamController<PosPrinterState> _stateStream = BehaviorSubject<PosPrinterState>();
  PosPrinterState _currentState = PosPrinterState.disconnected;
  Generator? _generator;
  Socket? _socket;
  CapabilityProfile? _profile;
  PaperSize _currentPaperSize = PaperSize.mm80;

  StreamSubscription<dynamic>? _streamSubscription;

  Future<PosPrintResult> connect({
    PaperSize paperSize = PaperSize.mm80,
    int maxCharsPerLine = 44,
    Duration timeout = const Duration(seconds: 5),
    int leftMargin = 6,
    int dpi = 203,
  }) async {
    _changeState(PosPrinterState.connecting);
    _currentPaperSize = paperSize;
    try {
      final profile = await _cachedProfile();
      _generator = Generator(paperSize, profile, maxCharsPerLine);
      _socket = await Socket.connect(host, port, timeout: timeout);

      _changeState(PosPrinterState.connected);
      _streamSubscription?.cancel();
      _streamSubscription = null;
      _streamSubscription = _socket!.listen(
        (event) {},
        onDone: () {
          disconnect();
        },
      );

      // set print position to the beginning of the line
      _sendCommand([10]);
      // reset settings
      _sendCommand([27, 64]);
      // enter standard mode
      _sendCommand([27, 83]);
      // character set hebrew
      _sendCommand([27, 82, 7]);
      // set global code table to Windows 1255
      _sendCommand(_generator?.setGlobalCodeTable('CP1255'));
      // set absolute print position
      _sendCommand([27, 36, 0, 0]);

      // Calculate dots based on dpi (dots per inch)
      // 1 inch is approximately 25.4 millimeters
      final dots = (leftMargin * dpi / 25.4).round();
      final nL = dots % 256;
      final nH = (dots / 256).floor();

      // set left margin
      _sendCommand([29, 76, nL, nH]);

      return Future<PosPrintResult>.value(PosPrintResult.success);
    } catch (e) {
      _changeState(PosPrinterState.disconnected);
      return Future<PosPrintResult>.value(PosPrintResult.timeout);
    }
  }

  Future<CapabilityProfile> _cachedProfile() async {
    if (_profile != null) {
      return _profile!;
    }
    _profile = await CapabilityProfile.load();
    return _profile!;
  }

  void disconnect() async {
    _socket?.destroy();
    _socket = null;
    _streamSubscription?.cancel();
    _streamSubscription = null;
    _changeState(PosPrinterState.disconnected);
  }

  void _changeState(PosPrinterState state) {
    if (_currentState != state) {
      _currentState = state;
      _stateStream.add(_currentState);
    }
  }

  bool _sendCommand(List<int>? data) {
    if (_socket != null && data != null) {
      _socket!.add(data);
      return true;
    } else {
      return false;
    }
  }

  // ************************ Printer Commands ************************

  bool reset() {
    return _sendCommand(_generator?.reset());
  }

  bool text(
    String text, {
    PosStyles styles = const PosStyles(),
    int linesAfter = 0,
    bool containsChinese = false,
    int? maxCharsPerLine,
  }) {
    return _sendCommand(
      _generator?.text(
        text,
        styles: styles,
        linesAfter: linesAfter,
        containsChinese: containsChinese,
        maxCharsPerLine: maxCharsPerLine,
      ),
    );
  }

  bool setGlobalCodeTable(String codeTable) {
    return _sendCommand(_generator?.setGlobalCodeTable(codeTable));
  }

  bool setStyles(PosStyles styles, {bool isKanji = false}) {
    return _sendCommand(_generator?.setStyles(styles, isKanji: isKanji));
  }

  bool rawBytes(List<int> cmd, {bool isKanji = false}) {
    return _sendCommand(_generator?.rawBytes(cmd, isKanji: isKanji));
  }

  bool emptyLines(int n) {
    return _sendCommand(_generator?.emptyLines(n));
  }

  bool feed(int n) {
    return _sendCommand(_generator?.feed(n));
  }

  bool cut({PosCutMode mode = PosCutMode.full}) {
    return _sendCommand(_generator?.cut(mode: mode));
  }

  bool printCodeTable({String? codeTable}) {
    return _sendCommand(_generator?.printCodeTable(codeTable: codeTable));
  }

  bool beep({int n = 3, PosBeepDuration duration = PosBeepDuration.beep450ms}) {
    return _sendCommand(_generator?.beep(n: n, duration: duration));
  }

  bool reverseFeed(int n) {
    return _sendCommand(_generator?.reverseFeed(n));
  }

  bool row(List<PosColumn> cols) {
    return _sendCommand(_generator?.row(cols));
  }

  bool image(Image imgSrc, {PosAlign align = PosAlign.center}) {
    return _sendCommand(_generator?.image(imgSrc, align: align));
  }

  bool imageRaster(
    Image image, {
    PosAlign align = PosAlign.center,
    bool highDensityHorizontal = true,
    bool highDensityVertical = true,
    PosImageFn imageFn = PosImageFn.bitImageRaster,
  }) {
    return _sendCommand(_generator?.imageRaster(
      image,
      align: align,
      highDensityHorizontal: highDensityHorizontal,
      highDensityVertical: highDensityVertical,
      imageFn: imageFn,
    ));
  }

  bool barcode(
    Barcode barcode, {
    int? width,
    int? height,
    BarcodeFont? font,
    BarcodeText textPos = BarcodeText.below,
    PosAlign align = PosAlign.center,
  }) {
    return _sendCommand(_generator?.barcode(
      barcode,
      width: width,
      height: height,
      font: font,
      textPos: textPos,
      align: align,
    ));
  }

  bool qrcode(
    String text, {
    PosAlign align = PosAlign.center,
    QRSize size = QRSize.Size4,
    QRCorrection cor = QRCorrection.L,
  }) {
    return _sendCommand(
      _generator?.qrcode(text, align: align, size: size, cor: cor),
    );
  }

  bool drawer({PosDrawer pin = PosDrawer.pin2}) {
    return _sendCommand(_generator?.drawer(pin: pin));
  }

  bool hr({
    String ch = '-',
    int? len,
    int linesAfter = 0,
    PosStyles styles = const PosStyles(),
  }) {
    return _sendCommand(_generator?.hr(
      ch: ch,
      linesAfter: linesAfter,
      len: len,
      styles: styles,
    ));
  }

  bool textEncoded(
    Uint8List textBytes, {
    PosStyles styles = const PosStyles(),
    int linesAfter = 0,
    int? maxCharsPerLine,
  }) {
    return _sendCommand(_generator?.textEncoded(
      textBytes,
      styles: styles,
      linesAfter: linesAfter,
      maxCharsPerLine: maxCharsPerLine,
    ));
  }
  // ************************ (end) Printer Commands ************************
}
