# esc_pos_printer

![Pub](https://img.shields.io/pub/v/esc_pos_printer.svg)

The library allows to print receipts using a ESC/POS (usually thermal) network printer.

[[pub.dev page]](https://pub.dev/packages/esc_pos_printer)
| [[Documentation]](https://pub.dev/documentation/esc_pos_printer/latest/)

It can be used in [Flutter](https://flutter.dev/) or [Dart](https://dart.dev/) projects. In Flutter, both Android and iOS are supported.

To discover existing printers in your subnet, consider using [ping_discover_network](https://pub.dev/packages/ping_discover_network) package. Note that most of ESC/POS printers by default listen on port 9100.

USB and Bluetooth printers support will be added later.

## Features

* Connect to Wi-Fi printers
* Simple text printing using *println* method
* Tables printing using *printRow* method
* Text styling:
  * size, align, bold, reverse, underline, different fonts
* Paper cut (partial, full)
* Beeping (with different duration)
* Paper feed, reverse feed

**Note**: Your printer may not support some of presented features (especially for underline styles, partial/full paper cutting, reverse feed, ...).

## Getting Started

```dart
import 'package:esc_pos_printer/esc_pos_printer.dart';

Printer.connect('192.168.0.123', port: 9100).then((printer) {
    printer.println('Normal text');
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

## TODO
* Add raw print function
* Print images
* Print barcodes
* Print QR codes
* ~~Turn 90° clockwise rotation mode on/off~~
* Flutter example: print a demo receipt
* ~~Flutter example: discover active Wi-Fi printers~~
* USB, Bluetooth printers support
* *Add encoding commands*