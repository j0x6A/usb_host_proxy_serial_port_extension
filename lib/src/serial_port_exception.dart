class SerialPortException implements Exception {
  const SerialPortException(this.message, {this.cause});

  final String message;

  final Object? cause;

  @override
  String toString() => 'SerialPortException: $message';
}

class SerialPortDisconnectedException extends SerialPortException {
  const SerialPortDisconnectedException(super.message, {super.cause});

  @override
  String toString() => 'SerialPortDisconnectedException: $message';
}
