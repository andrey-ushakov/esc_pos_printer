# esc_pos_printer

![Pub](https://img.shields.io/pub/v/esc_pos_printer.svg)

The library allows to print receipts using an ESC/POS thermal WiFi/Bluetooth printer.

[[pub.dev page]](https://pub.dev/packages/esc_pos_printer)
| [[Documentation]](https://pub.dev/documentation/esc_pos_printer/latest/)

WiFi printing can be used in [Flutter](https://flutter.dev/) or pure [Dart](https://dart.dev/) projects. For Flutter projects, both Android and iOS are supported.

Bluetooth printing can be used only for iOS. Android support will be added soon *(I hope)*.

To discover existing printers in your subnet, consider using [ping_discover_network](https://pub.dev/packages/ping_discover_network) package. Note that most of the ESC/POS printers by default listen on port 9100.

## Main Features

* Connect to Wi-Fi / Bluetooth printers
* Simple text printing using *text* method
* Tables printing using *row* method
* Text styling:
  * size, align, bold, reverse, underline, different fonts, turn 90°
* Print images
* Print barcodes
  * UPC-A, UPC-E, JAN13 (EAN13), JAN8 (EAN8), CODE39, ITF (Interleaved 2 of 5), CODABAR (NW-7)
* Paper cut (partial, full)
* Beeping (with different duration)
* Paper feed, reverse feed

**Note**: Your printer may not support some of the presented features (especially for underline styles, partial/full paper cutting, reverse feed, ...).

## Getting started (Generate a ticket)
```dart
Ticket testTicket() {
  final Ticket ticket = Ticket(PaperSize.mm80);

  ticket.text(
      'Regular: aA bB cC dD eE fF gG hH iI jJ kK lL mM nN oO pP qQ rR sS tT uU vV wW xX yY zZ');
  ticket.text('Special 1: àÀ èÈ éÉ ûÛ üÜ çÇ ôÔ',
      styles: PosStyles(codeTable: PosCodeTable.westEur));
  ticket.text('Special 2: blåbærgrød',
      styles: PosStyles(codeTable: PosCodeTable.westEur));

  ticket.text('Bold text', styles: PosStyles(bold: true));
  ticket.text('Reverse text', styles: PosStyles(reverse: true));
  ticket.text('Underlined text',
      styles: PosStyles(underline: true), linesAfter: 1);
  ticket.text('Align left', styles: PosStyles(align: PosTextAlign.left));
  ticket.text('Align center', styles: PosStyles(align: PosTextAlign.center));
  ticket.text('Align right',
      styles: PosStyles(align: PosTextAlign.right), linesAfter: 1);

  ticket.text('Text size 200%',
      styles: PosStyles(
        height: PosTextSize.size2,
        width: PosTextSize.size2,
      ));

  ticket.feed(2);
  ticket.cut();
  return ticket;
}
```
Print table row:

```dart
ticket.row([
    PosColumn(
      text: 'col3',
      width: 3,
      styles: PosStyles(align: PosTextAlign.center, underline: true),
    ),
    PosColumn(
      text: 'col6',
      width: 6,
      styles: PosStyles(align: PosTextAlign.center, underline: true),
    ),
    PosColumn(
      text: 'col3',
      width: 3,
      styles: PosStyles(align: PosTextAlign.center, underline: true),
    ),
  ]);
```

Print image:

```dart
import 'dart:io';
import 'package:image/image.dart';

const String filename = './logo.png';
final Image image = decodeImage(File(filename).readAsBytesSync());
// Using (ESC *) command
ticket.image(image);
// Using an alternative obsolette (GS v 0) command
ticket.imageRaster(image);
```

Print barcode:
```dart
final List<int> barData = [1, 2, 3, 4, 5, 6, 7, 8, 9, 0, 4];
ticket.barcode(Barcode.upcA(barData));
```

## Getting Started (WiFi printer)

```dart
import 'package:esc_pos_printer/esc_pos_printer.dart';

final PrinterNetworkManager printerManager = PrinterNetworkManager();
printerManager.selectPrinter('192.168.0.123', port: 9100);
final PosPrintResult res = await printerManager.printTicket(testTicket());

print('Print result: ${PosPrintResult.msg(res)}');
```
For more details, check *example/example.dart* and *example/discover_printers*.

## Getting Started (Bluetooth printer)

```dart
PrinterBluetoothManager printerManager = PrinterBluetoothManager();

printerManager.scanResults.listen((printers) async {
  // store found printers
});
printerManager.startScan(Duration(seconds: 4));

// ...

printerManager.selectPrinter(printer);
final PosPrintResult res = await printerManager.printTicket(testTicket());

print('Print result: ${PosPrintResult.msg(res)}');
```

For more details, check demo project *example/blue*.

## TODO
* Bluetooth printers: add Android support
* Print QR codes
* USB printers support

## Test print
<img src="https://github.com/andrey-ushakov/esc_pos_printer/blob/master/example/receipt.jpg?raw=true" alt="test receipt" height="500"/>
