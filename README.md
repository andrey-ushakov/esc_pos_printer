# esc_pos_printer

The library allows to print receipts using a ESC/POS (usually thermal) network printer.

It can be used in [Flutter](https://flutter.dev/) or [Dart](https://dart.dev/) projects. In Flutter, both Android and iOS are supported.

[[pub.dev page]](https://pub.dev/packages/esc_pos_printer)
| [[Documentation]](https://pub.dev/documentation/esc_pos_printer/latest/)

To discover existing printers in your subnet, consider using [ping_discover_network](https://pub.dev/packages/ping_discover_network) package. Note that most of ESC/POS printers by default listen on port 9100.

## Features

* Connect to Wi-Fi printers
* Simple text printing using *println* method
* Tables printing using *printRow* method
* Text styling:
  * size, align, bold, reverse, underline, different fonts
* Paper cut (partial, full)
* Beeping (with different duration)
* Paper feed, reverse feed

**Note**: Your printer may not support some of the presented features (especially for underline styles, partial/full paper cutting, reverse feed, ...).

## Getting Started

```dart
import 'package:esc_pos_printer/esc_pos_printer.dart';

Printer.connect('192.168.0.123').then((printer) {
    printer.println(PosString('Normal text'));
    printer.println(PosString('Bold text', bold: true));
    printer.println(PosString('Reverse text', reverse: true));
    printer.println(PosString('Underlined text', underline: true));
    printer.println(PosString('Align center', align: PosTextAlign.center));
    printer.printRow([3, 6, 3],
      [
        PosString('col3'),
        PosString('col6'),
        PosString('col3', underline: true)
      ],
    );
    printer.println(PosString('Text size 200%',
        height: PosTextSize.size2, width: PosTextSize.size2));

    printer.cut();
    printer.disconnect();
  });
```

## TODO
* Add raw print function
* Print images
* Print barcodes
* Print QR codes
* Example project for Flutter (print a receipt template)
* Turn 90° clockwise rotation mode on/off
* Discover active Wi-Fi printers