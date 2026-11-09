class SerialPortLineStatus {
  const SerialPortLineStatus({
    this.parityError,
    this.framingError,
    this.overrunError,
    this.breakDetected,
  });

  final bool? parityError;

  final bool? framingError;

  final bool? overrunError;

  final bool? breakDetected;
}
