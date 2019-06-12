import 'package:esc_pos_printer/esc_pos_printer.dart';
import 'package:esc_pos_printer/src/printer.dart';

void main() {
  Printer.connect('192.168.0.123').then((printer) {
    printer.println(PosString('Normal text'));
    printer.println(PosString('Bold text', bold: true));
    printer.println(PosString('Reverse text', reverse: true));
    printer.println(PosString('Underlined text', underline: true),
        linesAfter: 1);
    printer.println(PosString('Align left', align: PosTextAlign.left));
    printer.println(PosString('Align center', align: PosTextAlign.center));
    printer.println(PosString('Align right', align: PosTextAlign.right),
        linesAfter: 1);
    printer.printRow(
      [3, 6, 3],
      [
        PosString('col3', align: PosTextAlign.center, underline: true),
        PosString('col6', align: PosTextAlign.center, underline: true),
        PosString('col3', align: PosTextAlign.center, underline: true)
      ],
    );
    printer.println(PosString('Text size 200%',
        height: PosTextSize.size2, width: PosTextSize.size2));

    printer.cut();
    printer.disconnect();
  });
}
