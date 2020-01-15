import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_basic/flutter_bluetooth_basic.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bluetooth demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Bluetooth demo'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;
  // final FlutterBlue flutterBlue = FlutterBlue.instance;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  BluetoothManager bluetoothManager = BluetoothManager.instance;
  bool _connected = false;
  bool _isScanning = false;
  List<BluetoothDevice> _devices = [];
  StreamSubscription _scanResultsSubscription;
  StreamSubscription _isScanningSubscription;
  // Buffers used for rescan before sending the data
  List<BluetoothDevice> _bufDevices = [];
  StreamSubscription _bufScanSubscription;
  // StreamSubscription _isScanningSubscription;

  void _startScanDevices() {
    setState(() {
      _devices = [];
    });

    bluetoothManager.startScan(timeout: Duration(seconds: 4));

    _scanResultsSubscription =
        bluetoothManager.scanResults.listen((devices) async {
      setState(() {
        _devices = devices;
      });
    });

    _isScanningSubscription =
        bluetoothManager.isScanning.listen((isScanningCurrent) async {
      // if isScanning value changed (scan just stopped)
      if (_isScanning && !isScanningCurrent) {
        _scanResultsSubscription.cancel();
        _isScanningSubscription.cancel();
      }
      setState(() {
        _isScanning = isScanningCurrent;
      });
    });
  }

  void _stopScanDevices() {
    bluetoothManager.stopScan();
  }

  Future _sleep(int seconds) {
    return Future<dynamic>.delayed(Duration(seconds: seconds));
  }

  void _testPrint(BluetoothDevice printer) async {
    // We have to rescan before connecting, otherwise we can connect only once
    await bluetoothManager.startScan(timeout: Duration(seconds: 1));
    await bluetoothManager.stopScan();

    // Connect
    await bluetoothManager.connect(printer);

    // Subscribe to the events
    bluetoothManager.state.listen((state) async {
      switch (state) {
        case BluetoothManager.CONNECTED:
          print('********************* CONNECTED');
          // to avoid double call
          if (!_connected) {
            print('@@@@SEND DATA......');
            final List<int> bytes = latin1.encode('test!\n\n\n').toList();
            await bluetoothManager.writeData(bytes);
            // TODO show message "Data sent"
          }
          // TODO sending disconnect signal should be event-based
          _sleep(3).then((dynamic printer) async {
            print('@@@@DISCONNECTING......');
            await bluetoothManager.disconnect();
          });
          _connected = true;
          break;
        case BluetoothManager.DISCONNECTED:
          print('********************* DISCONNECTED');
          _connected = false;
          break;
        default:
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: ListView.builder(
          itemCount: _devices.length,
          itemBuilder: (BuildContext context, int index) {
            return InkWell(
              onTap: () => _testPrint(_devices[index]),
              child: Column(
                children: <Widget>[
                  Container(
                    height: 60,
                    padding: EdgeInsets.only(left: 10),
                    alignment: Alignment.centerLeft,
                    child: Row(
                      children: <Widget>[
                        Icon(Icons.print),
                        SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Text(_devices[index].name ?? ''),
                              Text(_devices[index].address),
                              Text(
                                'Click to print a test receipt',
                                style: TextStyle(color: Colors.grey[700]),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                  Divider(),
                ],
              ),
            );
          }),
      floatingActionButton: _isScanning
          ? FloatingActionButton(
              child: Icon(Icons.stop),
              onPressed: _stopScanDevices,
              backgroundColor: Colors.red,
            )
          : FloatingActionButton(
              child: Icon(Icons.search),
              onPressed: _startScanDevices,
            ),
    );
  }
}
