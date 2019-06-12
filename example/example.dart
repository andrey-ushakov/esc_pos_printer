import 'package:esc_pos_printer/esc_pos_printer.dart';

main() {
  Printer.connect('192.168.0.123').then((printer) {
    printer.println('Normal text');
    printer.println('Bold text', bold: true);
    printer.println('Reverse text', reverse: true);
    printer.println('Underlined text', underline: true);
    printer.println('Align left', align: TextAlign.left);
    printer.println('Align center', align: TextAlign.center);
    printer.println('Align right', align: TextAlign.right);

    printer.cut();

    printer.disconnect();
  });
}
