/*
 * esc_pos_printer
 * Created by Andrey Ushakov
 * 
 * Copyright (c) 2019-2020. All rights reserved.
 * See LICENSE for distribution and usage details.
 */

import 'dart:async';
import 'dart:io';

import 'package:rxdart/rxdart.dart';

import './enums.dart';

class NetworkPrinter {
  NetworkPrinter({required this.host, this.port = 9100}) {
    _stateStream.add(currentState);
  }

  Stream<PosPrinterState> get state => _stateStream.stream;

  PosPrinterState get currentState => _currentState;
  final int port;
  final String host;

  final StreamController<PosPrinterState> _stateStream = BehaviorSubject<PosPrinterState>();
  PosPrinterState _currentState = PosPrinterState.disconnected;
  Socket? _socket;
  StreamSubscription<dynamic>? _streamSubscription;

  Future<PosPrintResult> connect({Duration timeout = const Duration(seconds: 5)}) async {
    _changeState(PosPrinterState.connecting);
    try {
      _socket = await Socket.connect(host, port, timeout: timeout);

      _changeState(PosPrinterState.connected);
      await _streamSubscription?.cancel();
      _streamSubscription = null;
      _streamSubscription = _socket!.listen(
        (event) {},
        onDone: () {
          disconnect();
        },
      );

      return Future<PosPrintResult>.value(PosPrintResult.success);
    } catch (e) {
      _changeState(PosPrinterState.disconnected);
      return Future<PosPrintResult>.value(PosPrintResult.timeout);
    }
  }

  bool sendCommands(List<List<int>> commands) {
    if (_socket != null) {
      commands.forEach(_socket!.add);
      return true;
    } else {
      return false;
    }
  }

  Future<void> disconnect() async {
    _socket?.destroy();
    _socket = null;
    await _streamSubscription?.cancel();
    _streamSubscription = null;
    _changeState(PosPrinterState.disconnected);
  }

  void _changeState(PosPrinterState state) {
    if (_currentState != state) {
      _currentState = state;
      _stateStream.add(_currentState);
    }
  }
}
