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

  Future sleep3() {
    return Future<dynamic>.delayed(const Duration(seconds: 7), () => "1");
  }

  void _testPrint(BluetoothDevice printer) async {
    // print('Test print.... name: ${printer.name}');
    if (printer != null && printer.address != null) {
      // Connect
      await bluetoothManager.connect(printer);

      // Subscribe to the events
      bluetoothManager.state.listen((state) async {
        // print('**************cur device status: $state');
        switch (state) {
          case BluetoothManager.CONNECTED:
            print('********************* CONNECTED');
            // to avoid double call
            if (!_connected) {
              print('@@@@SEND DATA......');
              final List<int> bytes = latin1.encode('test!\n\n\n').toList();
              await bluetoothManager.writeData(bytes);
              // print('################## print send #############');
              // bluetoothManager.
            }
            sleep3().then((dynamic printer) async {
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

      // TODO show message "Data sent"
    } else {
      // TODO show message "Can't connect to the device"
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: StreamBuilder<List<BluetoothDevice>>(
        stream: bluetoothManager.scanResults,
        initialData: [],
        builder: (c, snapshot) => Column(
          children: snapshot.data
              .map((d) => InkWell(
                    onTap: () => _testPrint(d),
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
                                    Text(d.name ?? ''),
                                    Text(d.address),
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
                  ))
              .toList(),
        ),
      ),
      floatingActionButton: StreamBuilder<bool>(
        stream: bluetoothManager.isScanning,
        initialData: false,
        builder: (c, snapshot) {
          if (snapshot.data) {
            return FloatingActionButton(
              child: Icon(Icons.stop),
              onPressed: () => bluetoothManager.stopScan(),
              backgroundColor: Colors.red,
            );
          } else {
            return FloatingActionButton(
                child: Icon(Icons.search),
                onPressed: () =>
                    bluetoothManager.startScan(timeout: Duration(seconds: 4)));
          }
        },
      ),
    );
  }
}
