/*
 * esc_pos_printer
 * Created by Andrey Ushakov
 * 
 * Copyright (c) 2019-2020. All rights reserved.
 * See LICENSE for distribution and usage details.
 */

import 'dart:io';
import 'package:esc_pos_utils/esc_pos_utils.dart';
import './enums.dart';

/// Printer Network Manager
class PrinterNetworkManager {
  String _host;
  int _port;
  Duration _timeout;

  /// Select a network printer
  ///
  /// [timeout] is used to specify the maximum allowed time to wait
  /// for a connection to be established.
  void selectPrinter(
    String host, {
    int port = 9100,
    Duration timeout = const Duration(seconds: 5),
  }) {
    _host = host;
    _port = port;
    _timeout = timeout;
  }

  Future<PosPrintResult> printTicket(Ticket ticket) {
    if (_host == null || _port == null) {
      return Future<PosPrintResult>.value(PosPrintResult.printerNotSelected);
    } else if (ticket == null || ticket.bytes.isEmpty) {
      return Future<PosPrintResult>.value(PosPrintResult.ticketEmpty);
    }

    return Socket.connect(_host, _port, timeout: _timeout)
        .then((Socket socket) {
      socket.add(ticket.bytes);
      socket.destroy();
      return Future<PosPrintResult>.value(PosPrintResult.success);
    }).catchError((dynamic e) {
      return Future<PosPrintResult>.value(PosPrintResult.timeout);
    });
  }
}
