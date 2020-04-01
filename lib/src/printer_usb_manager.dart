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

  Future<PosPrintResult> writeBytes(
      List<int> bytes, {
        int chunkSizeBytes = 20,
        int queueSleepTimeMs = 20,
      }) async {
    final Completer<PosPrintResult> completer = Completer();

    final len = bytes.length;
    List<List<int>> chunks = [];

    for (var i = 0; i < len; i += chunkSizeBytes) {
      var end = (i + chunkSizeBytes < len) ? i + chunkSizeBytes : len;
      chunks.add(bytes.sublist(i, end));
    }

    for (var i = 0; i < chunks.length; i += 1) {
      await Escposprinter.printBytes(bytes);
      sleep(Duration(milliseconds: queueSleepTimeMs));
    }

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