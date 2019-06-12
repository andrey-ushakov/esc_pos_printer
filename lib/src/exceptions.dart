/*
 * esc_pos_printer
 * Created by Andrey Ushakov
 * 
 * Copyright (c) 2019. All rights reserved.
 * See LICENSE for distribution and usage details.
 */

/// Used by [Printer.printRow] method
class PosRowException implements Exception {
  PosRowException(this._msg);
  String _msg;

  @override
  String toString() => 'PosRowException: $_msg';
}
