/*
 * esc_pos_printer
 * Created by Andrey Ushakov
 * 
 * Copyright (c) 2020. All rights reserved.
 * See LICENSE for distribution and usage details.
 */

import 'dart:async';
import 'dart:convert';
import 'package:rxdart/rxdart.dart';
// import 'dart:convert';
// import 'dart:io';
// import 'dart:typed_data';
// import 'package:gbk_codec/gbk_codec.dart';
// import 'package:hex/hex.dart';
// import 'package:image/image.dart';
// import 'barcode.dart';
// import 'commands.dart';
// import 'enums.dart';
// import 'pos_column.dart';
// import 'pos_styles.dart';
import 'package:flutter_bluetooth_basic/flutter_bluetooth_basic.dart';

/// Bluetooth printer
class PrinterBluetooth {
  PrinterBluetooth(this._device);
  final BluetoothDevice _device;
  // final BluetoothManager _bluetoothManager = BluetoothManager.instance;
  // final PrinterBluetoothManager _manager = PrinterBluetoothManager();
  // bool _isPrinting = false;

  String get name => _device.name;
  String get address => _device.address;
  int get type => _device.type;

  // Future _runDelayed(int seconds) {
  //   return Future<dynamic>.delayed(Duration(seconds: seconds));
  // }

  // void printLine(String text) async {
  //   const int timeout = 5;
  //   print('============ ${_manager._isScanning}');
  //   // if (_bluetoothManager.is) {
  //   //   showToast('Print failed (scanning in progress)');
  //   //   return;
  //   // }
  //   if (_isPrinting) {
  //     throw Exception('Print failed (another printing in progress)');
  //   }

  //   _isPrinting = true;

  //   // We have to rescan before connecting, otherwise we can connect only once
  //   await _manager._bluetoothManager.startScan(timeout: Duration(seconds: 1));
  //   await _manager._bluetoothManager.stopScan();

  //   // Connect
  //   await _manager._bluetoothManager.connect(_device);

  //   // Subscribe to the events
  //   _manager._bluetoothManager.state.listen((state) async {
  //     switch (state) {
  //       case BluetoothManager.CONNECTED:
  //         print('********************* CONNECTED');
  //         // to avoid double call
  //         // if (!_connected) {
  //         if (_device.connected == null || !_device.connected) {
  //           print('@@@@SEND DATA......');
  //           final List<int> bytes = latin1.encode('test!\n\n\n').toList();
  //           await _manager._bluetoothManager.writeData(bytes);
  //           // showToast('Data sent'); TODO
  //           // return 0;
  //         }
  //         // TODO sending disconnect signal should be event-based
  //         _runDelayed(3).then((dynamic v) async {
  //           print('@@@@DISCONNECTING......');
  //           await _manager._bluetoothManager.disconnect();
  //           _isPrinting = false;
  //         });
  //         // _connected = true;
  //         break;
  //       case BluetoothManager.DISCONNECTED:
  //         print('********************* DISCONNECTED');
  //         // _connected = false;
  //         break;
  //       default:
  //         break;
  //     }
  //     // return 0;
  //   });
  //   // Printing timeout
  //   _runDelayed(timeout).then((dynamic v) async {
  //     if (_isPrinting) {
  //       _isPrinting = false;
  //       throw Exception('Print failed (timeout)');
  //     }
  //   });
  // }
}

/// Printer Bluetooth Manager
class PrinterBluetoothManager {
  final BluetoothManager _bluetoothManager = BluetoothManager.instance;
  // bool _connected = false;
  bool _isScanning = false;
  bool _isPrinting = false;
  StreamSubscription _scanResultsSubscription;
  StreamSubscription _isScanningSubscription;
  PrinterBluetooth _selectedPrinter;

  Stream<bool> get isScanningStream => _bluetoothManager.isScanning;

  BehaviorSubject<List<PrinterBluetooth>> _scanResults =
      BehaviorSubject.seeded([]);
  Stream<List<PrinterBluetooth>> get scanResults => _scanResults.stream;

  Future _runDelayed(int seconds) {
    return Future<dynamic>.delayed(Duration(seconds: seconds));
  }

  void startScan(Duration timeout) async {
    _scanResults.add(<PrinterBluetooth>[]);

    _bluetoothManager.startScan(timeout: Duration(seconds: 4));

    _scanResultsSubscription = _bluetoothManager.scanResults.listen((devices) {
      _scanResults.add(devices.map((d) => PrinterBluetooth(d)).toList());
    });

    // TODO move listener to constructor
    _isScanningSubscription =
        _bluetoothManager.isScanning.listen((isScanningCurrent) async {
      // If isScanning value changed (scan just stopped)
      if (_isScanning && !isScanningCurrent) {
        _scanResultsSubscription.cancel();
        _isScanningSubscription.cancel();
      }
      _isScanning = isScanningCurrent;
    });
  }

  void stopScan() async {
    await _bluetoothManager.stopScan();
  }

  void selectPrinter(PrinterBluetooth printer) {
    _selectedPrinter = printer;
  }

  void printLine(String text) async {
    const int timeout = 5;
    print('============ $_isScanning');
    if (_selectedPrinter == null) {
      throw Exception('Print failed (Select a printer first)');
    }
    if (_isScanning) {
      throw Exception('Print failed (scanning in progress)');
    }
    if (_isPrinting) {
      throw Exception('Print failed (another printing in progress)');
    }

    _isPrinting = true;

    // We have to rescan before connecting, otherwise we can connect only once
    await _bluetoothManager.startScan(timeout: Duration(seconds: 1));
    await _bluetoothManager.stopScan();

    // Connect
    await _bluetoothManager.connect(_selectedPrinter._device);

    // Subscribe to the events
    _bluetoothManager.state.listen((state) async {
      switch (state) {
        case BluetoothManager.CONNECTED:
          print('********************* CONNECTED');
          // to avoid double call
          // if (!_connected) {
          if (_selectedPrinter._device.connected == null ||
              !_selectedPrinter._device.connected) {
            print('@@@@SEND DATA......');
            final List<int> bytes = latin1.encode('test!\n\n\n').toList();
            await _bluetoothManager.writeData(bytes);
            // TODO data sent
          }
          // TODO sending disconnect signal should be event-based
          _runDelayed(3).then((dynamic v) async {
            print('@@@@DISCONNECTING......');
            await _bluetoothManager.disconnect();
            _isPrinting = false;
          });
          // _connected = true;
          break;
        case BluetoothManager.DISCONNECTED:
          print('********************* DISCONNECTED');
          // _connected = false;
          break;
        default:
          break;
      }
      // return 0;
    });

    // Printing timeout
    _runDelayed(timeout).then((dynamic v) async {
      if (_isPrinting) {
        _isPrinting = false;
        throw Exception('Print failed (timeout)');
      }
    });
  }
}
