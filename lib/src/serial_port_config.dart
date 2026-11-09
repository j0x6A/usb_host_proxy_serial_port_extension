enum SerialPortDataBits {
  five,
  six,
  seven,
  eight,
}

enum SerialPortParity {
  none,
  odd,
  even,
  mark,
  space,
}

enum SerialPortStopBits {
  one,
  onePointFive,
  two,
}

enum SerialPortFlowControl {
  none,
  rtsCts,
  xonXoff,
  dsrDtr,
}

class SerialPortConfig {
  const SerialPortConfig({
    required this.baudRate,
    required this.dataBits,
    required this.parity,
    required this.stopBits,
    required this.flowControl,
  });

  final int baudRate;

  final SerialPortDataBits dataBits;

  final SerialPortParity parity;

  final SerialPortStopBits stopBits;

  final SerialPortFlowControl flowControl;
}
