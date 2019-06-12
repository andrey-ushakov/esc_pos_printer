import 'package:esc_pos_printer/esc_pos_printer.dart';
import 'package:esc_pos_printer/src/printer.dart';

main() {
  Printer.connect('192.168.0.123').then((printer) {
    printer.reset();
    printer.println('Normal text');
    printer.println('Bold text', bold: true);
    printer.println('Reverse text', reverse: true);
    printer.println('Underlined text', underline: true);
    printer.println('Align left', align: PosTextAlign.left);
    printer.println('Align center', align: PosTextAlign.center);
    printer.println('Align right', align: PosTextAlign.right);

    printer.cut();

    printer.disconnect();
  });
}
