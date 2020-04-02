import 'dart:async';
import 'dart:io';
import 'package:esc_pos_utils/esc_pos_utils.dart';
import 'package:escposprinter/escposprinter.dart';

import './enums.dart';

class PrinterUsbManager {

  Future<List> getDevices() async {
    List devices = await Escposprinter.getUSBDeviceList;
    return devices;
  }

  Future<void> connectDevice(int vendor, int product) async {
    await Escposprinter.connectPrinter(vendor, product);
    return;
  }

  Future<PosPrintResult> writeBytes(List<int> bytes) async {
    final Completer<PosPrintResult> completer = Completer();
    await Escposprinter.printBytes(bytes);
    completer.complete(PosPrintResult.success);
    return completer.future;
  }

  Future<PosPrintResult> printTicket(Ticket ticket) {
    if (ticket == null || ticket.bytes.isEmpty) {
      return Future<PosPrintResult>.value(PosPrintResult.ticketEmpty);
    }
    return writeBytes(ticket.bytes);
  }
}