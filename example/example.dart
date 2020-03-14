// import 'dart:io';
// import 'dart:typed_data';
// import 'package:flutter/services.dart';
// import 'package:image/image.dart';
import 'package:esc_pos_printer/esc_pos_printer.dart';
import 'package:esc_pos_utils/esc_pos_utils.dart';

void main() async {
  final PrinterNetworkManager printerManager = PrinterNetworkManager();
  // To discover network printers in your subnet, consider using
  // ping_discover_network package (https://pub.dev/packages/ping_discover_network).
  // Note that most of ESC/POS printers are available on port 9100 by default.
  printerManager.selectPrinter('192.168.0.123', port: 9100);

  final PosPrintResult res =
      await printerManager.printTicket(await testTicket());
  print('Print result: ${res.msg}');
}

Future<Ticket> testTicket() async {
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

  ticket.text('Text size 200%',
      styles: PosStyles(
        height: PosTextSize.size2,
        width: PosTextSize.size2,
      ));

  // Print image
  // final ByteData data = await rootBundle.load('assets/logo.png');
  // final Uint8List bytes = data.buffer.asUint8List();
  // final Image image = decodeImage(bytes);
  // ticket.image(image);
  // Print image using alternative commands
  // ticket.imageRaster(image);
  // ticket.imageRaster(image, imageFn: PosImageFn.graphics);

  // Print barcode
  final List<int> barData = [1, 2, 3, 4, 5, 6, 7, 8, 9, 0, 4];
  ticket.barcode(Barcode.upcA(barData));

  // Print mixed (chinese + latin) text. Only for printers supporting Kanji mode
  // ticket.text(
  //   'hello ! 中文字 # world @ éphémère &',
  //   styles: PosStyles(codeTable: PosCodeTable.westEur),
  //   containsChinese: true,
  // );

  ticket.feed(2);

  ticket.cut();
  return ticket;
}
