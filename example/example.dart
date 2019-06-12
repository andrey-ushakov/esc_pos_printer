import 'package:esc_pos_printer/esc_pos_printer.dart';

main() {
  Printer.connect('192.168.0.123', 9100).then((printer) {
    printer.println('hello world :)');

    printer.cut();

    printer.disconnect();
  });
}
