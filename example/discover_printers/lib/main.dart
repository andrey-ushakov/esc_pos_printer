// ignore_for_file: use_build_context_synchronously, library_private_types_in_public_api, import_of_legacy_library_into_null_safe, depend_on_referenced_packages

import 'package:flutter/material.dart' hide Image;
import 'package:esc_pos_printer/esc_pos_printer.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Discover Printers',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final NetworkPrinter printer = NetworkPrinter(host: "192.168.0.220");
  // final NetworkPrinter printer = NetworkPrinter(host: "192.168.0.54");

  Future<void> testReceipt() async {
    final commands = EscPosGenerator.generateCommands(
      [
        InitCommand(
          leftMargin: 0,
          dpi: 203,
          globalCodeTable: "CP1255",
          characterSet: PrinterCharacterSet.hebrew,
        ),
        RowCommand(cols: [
          PosColumn(text: "test1", styles: const PosStyles(align: PosAlign.left), width: 2),
          PosColumn(text: "test2 ", styles: const PosStyles(align: PosAlign.right), width: 10),
        ]),
        HrCommand(),
        CutCommand(),
      ],
      paperSize: PaperSize.custom(510),
      maxCharsPerLine: 42,
    );

    printer.sendCommands(commands);
  }

  void connectAndPrint() async {
    final PosPrintResult res = await printer.connect();

    if (res == PosPrintResult.success) {
      // DEMO RECEIPT
      // await printDemoReceipt();
      // TEST PRINT
      await testReceipt();
      printer.disconnect();
    }

    final snackBar = SnackBar(content: Text(res.msg, textAlign: TextAlign.center));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  void connect() async {
    final PosPrintResult res = await printer.connect();
    final snackBar = SnackBar(content: Text(res.msg, textAlign: TextAlign.center));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  void disconnect() async {
    printer.disconnect();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Discover Printers'),
      ),
      body: Center(
        child: Column(
          children: [
            StreamBuilder(
              stream: printer.state,
              builder: (context, data) {
                return Text("Printor state: ${data.data}");
              },
            ),
            const SizedBox(width: 10),
            const Icon(Icons.print),
            const SizedBox(width: 10),
            TextButton(
              onPressed: () {
                connectAndPrint();
              },
              child: const Text("connect and print"),
            ),
            const SizedBox(width: 10),
            TextButton(
              onPressed: () {
                testReceipt();
              },
              child: const Text("print"),
            ),
            const SizedBox(width: 10),
            TextButton(
              onPressed: () async {
                final commands = EscPosGenerator.generateCommands(
                  [OpenCashDrawerCommand(pin: 0)],
                );
                printer.sendCommands(commands);
              },
              child: const Text("cash drawer"),
            ),
            const SizedBox(width: 10),
            TextButton(
              onPressed: () {
                connect();
              },
              child: const Text("connect"),
            ),
            const SizedBox(width: 10),
            TextButton(
              onPressed: () {
                disconnect();
              },
              child: const Text("disconnect"),
            ),
          ],
        ),
      ),
    );
  }
}
