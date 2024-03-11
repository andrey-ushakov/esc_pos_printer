import 'package:esc_pos_printer/esc_pos_utils/src/capability_profile.dart';
import 'package:esc_pos_printer/esc_pos_utils/src/enums.dart';
import 'package:esc_pos_printer/esc_pos_utils/src/font_config/font_size_config.dart';
import 'package:esc_pos_printer/esc_pos_utils/src/generator.dart';
import 'package:esc_pos_printer/esc_pos_utils/src/pos_styles.dart';
import 'package:esc_pos_printer/src/models.dart';

import '../esc_pos_utils/src/barcode.dart';
import '../esc_pos_utils/src/pos_column.dart';
import '../esc_pos_utils/src/qrcode.dart';
import './enums.dart';

class EscPosGenerator {
  static List<List<int>> generateCommands(
    List<PrinterCommand> printerCommands, {
    PaperSize paperSize = PaperSize.mm80,
    FontSizeConfig fontSizeConfig = PosTextSize.defaultFontSizeConfig,
  }) {
    final List<List<int>> commands = [];
    final generator = Generator(paperSize, CapabilityProfile.load(), fontSizeConfig);

    for (var command in printerCommands) {
      switch (command) {
        case InitCommand(
            leftMargin: final int leftMargin,
            dpi: final int dpi,
            globalCodeTable: final String globalCodeTable,
            characterSet: final PrinterCharacterSet characterSet,
          ):
          // set print position to the beginning of the line
          commands.add([10]);
          // reset settings
          commands.add([27, 64]);
          // enter standard mode
          commands.add([27, 83]);

          // character set
          commands.add([27, 82, characterSet.value]);
          // set global code table
          commands.add(generator.setGlobalCodeTable(globalCodeTable));
          // set absolute print position
          commands.add([27, 36, 0, 0]);
          // Calculate dots based on dpi (dots per inch)
          // 1 inch is approximately 25.4 millimeters
          final dots = (leftMargin * dpi / 25.4).round();
          final nL = dots % 256;
          final nH = (dots / 256).floor();
          // set left margin
          commands.add([29, 76, nL, nH]);
          // set print area width
          final areaWidthL = paperSize.value % 256;
          final areaWidthH = paperSize.value ~/ 256;
          commands.add([29, 87, areaWidthL, areaWidthH]);

        case OpenCashDrawerCommand(pin: final int pin):
          commands.add(generator.openCashDrawer(pin: pin));

        case HrCommand(
            ch: final String ch,
            len: final int? len,
            linesAfter: final int linesAfter,
            styles: final PosStyles styles,
          ):
          commands.add(generator.hr(ch: ch, len: len, linesAfter: linesAfter, styles: styles));

        case QrcodeCommand(
            text: final String text,
            align: final PosAlign align,
            size: final QRSize size,
            cor: final QRCorrection cor,
          ):
          commands.add(generator.qrcode(text, align: align, size: size, cor: cor));

        case BarcodeCommand(
            barcode: final Barcode barcode,
            width: final int? width,
            height: final int? height,
            font: final BarcodeFont? font,
            textPos: final BarcodeText textPos,
            align: final PosAlign align,
          ):
          commands.add(generator.barcode(barcode,
              width: width, height: height, font: font, textPos: textPos, align: align));

        case RowCommand(cols: final List<PosColumn> cols):
          commands.add(generator.row(cols));

        case ReverseFeedCommand(n: final int n):
          commands.add(generator.reverseFeed(n));

        case BeepCommand(
            n: final int n,
            duration: final PosBeepDuration duration,
          ):
          commands.add(generator.beep(n: n, duration: duration));

        case CutCommand(mode: final PosCutMode mode):
          commands.add(generator.cut(mode: mode));

        case FeedCommand(n: final int n):
          commands.add(generator.feed(n));

        case EmptyLinesCommand(n: final int n):
          commands.add(generator.emptyLines(n));

        case RawBytesCommand(
            cmd: final List<int> cmd,
            isKanji: final bool isKanji,
          ):
          commands.add(generator.rawBytes(cmd, isKanji: isKanji));

        case TextCommand(
            text: final String text,
            styles: final PosStyles styles,
            linesAfter: final int linesAfter,
            containsChinese: final bool containsChinese,
          ):
          commands.add(generator.text(
            text,
            styles: styles,
            linesAfter: linesAfter,
            containsChinese: containsChinese,
          ));
      }
    }

    return commands;
  }
}
