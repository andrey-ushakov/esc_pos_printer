class PosRowException implements Exception {
  PosRowException(this._msg);
  String _msg;

  @override
  String toString() => 'PosRowException: $_msg';
}
