# esc_pos_printer

![Pub](https://img.shields.io/pub/v/esc_pos_printer.svg)

The library allows to print receipts using an ESC/POS thermal WiFi/Ethernet printer. For Bluetooth printers, use [esc_pos_bluetooth](https://github.com/andrey-ushakov/esc_pos_bluetooth) library.

[[pub.dev page]](https://pub.dev/packages/esc_pos_printer)
| [[Documentation]](https://pub.dev/documentation/esc_pos_printer/latest/)

It can be used in [Flutter](https://flutter.dev/) or pure [Dart](https://dart.dev/) projects. For Flutter projects, both Android and iOS are supported.

To scan for printers in your network, consider using [ping_discover_network](https://pub.dev/packages/ping_discover_network) package. Note that most of the ESC/POS printers by default listen on port 9100.

## Tested Printers
Here are some [printers tested with this library](printers.md). Please add your models you have tested to maintain and improve this library and help others to choose the right printer.

## Main Features
* Connect to Wi-Fi / Ethernet printers
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

## Getting started: Generate a Ticket

### Simple ticket:
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
  ticket.text('Align left', styles: PosStyles(align: PosAlign.left));
  ticket.text('Align center', styles: PosStyles(align: PosAlign.center));
  ticket.text('Align right',
      styles: PosStyles(align: PosAlign.right), linesAfter: 1);

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

### Print a table row:

```dart
ticket.row([
    PosColumn(
      text: 'col3',
      width: 3,
      styles: PosStyles(align: PosAlign.center, underline: true),
    ),
    PosColumn(
      text: 'col6',
      width: 6,
      styles: PosStyles(align: PosAlign.center, underline: true),
    ),
    PosColumn(
      text: 'col3',
      width: 3,
      styles: PosStyles(align: PosAlign.center, underline: true),
    ),
  ]);
```

### Print an image:

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

### Print a barcode:

```dart
final List<int> barData = [1, 2, 3, 4, 5, 6, 7, 8, 9, 0, 4];
ticket.barcode(Barcode.upcA(barData));
```

### Print a QR Code:

To print a QR Code, add [qr_flutter](https://pub.dev/packages/qr_flutter) and [path_provider](https://pub.dev/packages/path_provider) as a dependency in your `pubspec.yaml` file.
```dart
String qrData = "google.com";
const double qrSize = 200;
try {
  final uiImg = await QrPainter(
    data: qrData,
    version: QrVersions.auto,
    gapless: false,
  ).toImageData(qrSize);
  final dir = await getTemporaryDirectory();
  final pathName = '${dir.path}/qr_tmp.png';
  final qrFile = File(pathName);
  final imgFile = await qrFile.writeAsBytes(uiImg.buffer.asUint8List());
  final img = decodeImage(imgFile.readAsBytesSync());

  ticket.image(img);
} catch (e) {
  print(e);
}
```

## Getting Started: Print a Ticket

```dart
import 'package:esc_pos_printer/esc_pos_printer.dart';

final PrinterNetworkManager printerManager = PrinterNetworkManager();
printerManager.selectPrinter('192.168.0.123', port: 9100);
final PosPrintResult res = await printerManager.printTicket(testTicket());

print('Print result: ${res.msg}');
```
For more details, check `example/example.dart` and `example/discover_printers`.


## Using Code Tables
Thanks to the [charset_converter](https://pub.dev/packages/charset_converter) package, it's possible to print in different languages. The source text should be encoded using the corresponding charset and the correct charset should be passed to the `Ticket.textEncoded` method.

Here are some examples:
```dart
/// Portuguese
Uint8List encTxt1 = await CharsetConverter.encode(
    "cp860", "Portuguese: Olá, Não falo português, Cão");
ticket.textEncoded(encTxt1,
    styles: PosStyles(codeTable: PosCodeTable.pc860_1));

/// Greek
Uint8List encTxt2 =
    await CharsetConverter.encode("windows-1253", "Greek: αβγδώ");
ticket.textEncoded(encTxt2,
    styles: PosStyles(codeTable: PosCodeTable.greek));

/// Polish
Uint8List encTxt3 = await CharsetConverter.encode(
    "cp852", "Polish: Dzień dobry! Dobry wieczór! Cześć!");
ticket.textEncoded(encTxt3,
    styles: PosStyles(codeTable: PosCodeTable.pc852_1));

/// Russian / Cyrillic
Uint8List encTxt4 =
    await CharsetConverter.encode("cp866", "Russian: Привет мир!");
ticket.textEncoded(encTxt4,
    styles: PosStyles(codeTable: PosCodeTable.pc866_2));
```

Note that `CharsetConverter.encode` takes a platform-specific charset (check the [library documentation](https://pub.dev/packages/charset_converter) for more info).

Note that different printers may support different sets of codetables and the above examples may not work on some printer models. It's also possible to pass a codetable by its code (according to your printer's documentation): `PosStyles(codeTable: PosCodeTable(7))`.


## Test Print
<img src="https://github.com/andrey-ushakov/esc_pos_printer/blob/master/example/receipt.jpg?raw=true" alt="test receipt" height="500"/>

## Support
If this package was helpful, a cup of coffee would be highly appreciated :)

[<img src="https://az743702.vo.msecnd.net/cdn/kofi2.png?v=2" width="200">](https://ko-fi.com/andreydev)