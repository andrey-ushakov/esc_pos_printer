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
  final NetworkPrinter printer = NetworkPrinter(host: "192.168.0.222");
  // final NetworkPrinter printer = NetworkPrinter(host: "192.168.0.54");

  Future<void> testReceipt() async {
    printer.row([
      PosColumn(text: "test1", styles: const PosStyles(align: PosAlign.left), width: 2),
      PosColumn(text: "test2 ", styles: const PosStyles(align: PosAlign.right), width: 10),
    ]);
    printer.row([
      PosColumn(
          text: "test1 fsdkjfhsd kjfhds kjfhdks jhpp",
          styles: const PosStyles(align: PosAlign.left),
          width: 2),
      PosColumn(
          text: "test2 fskjd jhgf jhgfhf hf h q w e r t y u io p a s d f g h j kl",
          styles: const PosStyles(align: PosAlign.right),
          width: 10),
    ]);

    printer.hr();

    // // // Print image
    // final ByteData data = await rootBundle.load('assets/logo.png');
    // final Uint8List bytes = data.buffer.asUint8List();
    // final Image image = decodeImage(bytes)!;
    // printer.image(image);

    // printer.feed(2);
    printer.cut();
  }

  void connectAndPrint() async {
    final PosPrintResult res = await printer.connect(
      paperSize: PaperSize.custom(510),
      leftMargin: 0,
      dpi: 203,
      maxCharsPerLine: 42,
    );

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
                // print(Latin1Codec().encode("₪"));
                // print(Windows1().encode("₪"));

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
