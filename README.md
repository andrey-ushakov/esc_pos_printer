# esc_pos_printer

![Pub](https://img.shields.io/pub/v/esc_pos_printer.svg)

The library allows to print receipts using a ESC/POS (usually thermal) network printer.

[[pub.dev page]](https://pub.dev/packages/esc_pos_printer)
| [[Documentation]](https://pub.dev/documentation/esc_pos_printer/latest/)

It can be used in [Flutter](https://flutter.dev/) or [Dart](https://dart.dev/) projects. In Flutter, both Android and iOS are supported.

To discover existing printers in your subnet, consider using [ping_discover_network](https://pub.dev/packages/ping_discover_network) package. Note that most of the ESC/POS printers by default listen on port 9100.

## Main Features

* Connect to Wi-Fi printers
* Simple text printing using *println* method
* Tables printing using *printRow* method
* Text styling:
  * size, align, bold, reverse, underline, different fonts, turn 90°
* Print images
* Print barcodes
  * UPC-A, UPC-E, JAN13 (EAN13), JAN8 (EAN8), CODE39, ITF (Interleaved 2 of 5), CODABAR (NW-7)
* Paper cut (partial, full)
* Beeping (with different duration)
* Paper feed, reverse feed

**Note**: Your printer may not support some of the presented features (especially for underline styles, partial/full paper cutting, reverse feed, ...).

## Getting Started

```dart
import 'package:esc_pos_printer/esc_pos_printer.dart';

Printer.connect('192.168.0.123', port: 9100).then((printer) {
    printer.println('Regular: aA bB cC dD eE fF gG hH iI jJ kK lL mM nN oO pP qQ rR sS tT uU vV wW xX yY zZ');
    printer.println('Special 1: àÀ èÈ éÉ ûÛ üÜ çÇ ôÔ',
        styles: PosStyles(codeTable: PosCodeTable.westEur));
    printer.println('Special 2: blåbærgrød',
        styles: PosStyles(codeTable: PosCodeTable.westEur));

    printer.println('Bold text', styles: PosStyles(bold: true));
    printer.println('Reverse text', styles: PosStyles(reverse: true));
    printer.println('Underlined text',
        styles: PosStyles(underline: true), linesAfter: 1);

    printer.println('Align left', styles: PosStyles(align: PosTextAlign.left));
    printer.println('Align center',
        styles: PosStyles(align: PosTextAlign.center));
    printer.println('Align right',
        styles: PosStyles(align: PosTextAlign.right), linesAfter: 1);
    
    printer.println('Text size 200%',
        styles: PosStyles(
          height: PosTextSize.size2,
          width: PosTextSize.size2,
        ));

    printer.cut();
    printer.disconnect();
  });
```

Print table row:

```dart
printer.printRow([
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
printer.printImage(image);
// Using an alternative obsolette (GS v 0) command
printer.printImageRaster(image);
```

Print barcode:
```dart
final List<int> barData = [1, 2, 3, 4, 5, 6, 7, 8, 9, 0, 4];
printer.printBarcode(Barcode.upcA(barData));
```

## TODO
* ~~Add raw print function~~
* ~~Print images~~
* ~~Print barcodes~~
* Print QR codes
* ~~Turn 90° clockwise rotation mode on/off~~
* ~~Flutter example: discover active Wi-Fi printers~~
* USB printers support
* ~~Add encoding commands~~

## Test print
<img src="https://github.com/andrey-ushakov/esc_pos_printer/blob/master/example/receipt.jpg?raw=true" alt="test receipt" height="500"/>
