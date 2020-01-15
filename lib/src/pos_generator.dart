import 'dart:convert';
// import 'dart:io';
import 'dart:typed_data';
// import 'package:gbk_codec/gbk_codec.dart';
// import 'package:hex/hex.dart';
// import 'package:image/image.dart';
// import 'barcode.dart';
import 'commands.dart';
import 'enums.dart';
// import 'pos_column.dart';
import 'pos_styles.dart';

class PosGenerator {
  static List<int> emptyLines(int n) {
    if (n > 0) {
      return latin1.encode(List.filled(n, '\n').join());
    }
    return [];
  }

  static List<int> text(
    String text, {
    PosStyles styles = const PosStyles(),
    int linesAfter = 0,
  }) {
    List<int> bytes = [];

    bytes += latin1.encode(styles.align == PosTextAlign.left
        ? cAlignLeft
        : (styles.align == PosTextAlign.center ? cAlignCenter : cAlignRight));

    // Set local code table
    if (styles.codeTable != null) {
      bytes += Uint8List.fromList(
        List.from(cCodeTable.codeUnits)..add(styles.codeTable.value),
      );
    }
    bytes += latin1.encode(text + '\n');
    bytes += emptyLines(linesAfter);

    return bytes;
  }
}
