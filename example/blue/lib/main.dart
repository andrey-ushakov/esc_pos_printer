import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
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
  final FlutterBlue flutterBlue = FlutterBlue.instance;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<ScanResult> _scanResults = [];

  void _scanDevices() {
    setState(() {
      _scanResults = [];
    });

    // Start scanning
    widget.flutterBlue.startScan(timeout: Duration(seconds: 4));

    // Listen to scan results
    var subscription = widget.flutterBlue.scanResults.listen((scanResult) {
      // do something with scan result
      // device = scanResult.device;
      // print('${device.name} found! rssi: ${scanResult.rssi}');

      print('FOUND !!! ${scanResult.length}');
      scanResult.forEach((ScanResult scanRes) async {
        if (scanRes.device.name.isNotEmpty) {
          if (!_scanResults.contains(scanRes)) {
            _scanResults.add(scanRes);
            setState(() {
              _scanResults
                  .sort((scanRes1, scanRes2) => scanRes2.rssi - scanRes1.rssi);
            });
          }
          print(
              '\t> ${scanRes.device.name} : ${scanRes.rssi} : ${_scanResults.length}');
        }
      });
    });

    // Stop scanning
    widget.flutterBlue.stopScan();
  }

  void testPrint(ScanResult scanResult, BuildContext ctx) async {
    BluetoothDevice device = scanResult.device;
    print('Sending test print to... ${device.name}');

    await device.connect();
    print('\t>connected');

    List<BluetoothService> services = await device.discoverServices();
    services.forEach((service) async {
      print('> Service // isPrimary: ${service.isPrimary} // ${service.uuid}');

      // Reads all characteristics
      final characteristics = service.characteristics;
      for (BluetoothCharacteristic c in characteristics) {
        // List<int> value = await c.read();
        // print('\t\t## charact. // $value');
      }
    });

    // const esc = '\x1B';
    // const cInit = '$esc@'; // Initialize printer

    // reset
    // _socket.write(cInit);
    // print text
    // _socket.add(latin1.encode(text));
    // empty lines
    // _socket.write(List.filled(5, '\n').join());
    // reset
    // _socket.write(cInit);

    device.disconnect();
    print('\t>disconnected');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: ListView.builder(
        itemCount: _scanResults.length,
        itemBuilder: (BuildContext context, int index) {
          return InkWell(
            onTap: () => testPrint(_scanResults[index], context),
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
                            Text(
                              'Signal ${_scanResults[index].rssi + 100}% : ${_scanResults[index].device.name}',
                            ),
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
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _scanDevices,
        tooltip: 'Scan',
        child: Icon(Icons.add),
      ),
    );
  }
}
