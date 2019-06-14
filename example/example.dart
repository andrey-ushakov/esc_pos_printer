import 'package:esc_pos_printer/esc_pos_printer.dart';
import 'package:esc_pos_printer/src/pos_column.dart';

void main() {
  // To discover existing printers in your subnet, consider using
  // ping_discover_network package (https://pub.dev/packages/ping_discover_network).
  // Note that most of ESC/POS printers by default listen on port 9100.
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
    printer.println('Text size 200%',
        styles: PosStyles(
          height: PosTextSize.size2,
          width: PosTextSize.size2,
        ));

    printer.cut();
    printer.disconnect();
  });
}
