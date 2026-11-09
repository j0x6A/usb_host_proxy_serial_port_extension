import 'dart:typed_data';

import 'serial_port_config.dart';
import 'serial_port_exception.dart';
import 'serial_port_line_status.dart';

enum SerialPortInputSignal {
  cts,
  dsr,
  ri,
  dcd,
}

/// Asynchronous byte-oriented serial port contract.
///
/// Instances start closed and may be reopened after [close]. Invalid arguments
/// fail with [ArgumentError]; invalid state and overlapping calls fail with
/// [StateError].
///
/// A [SerialPortException] leaves the session usable only when connection and
/// resources are known to be intact. Otherwise, invalidate the session and fail
/// pending operations. Use [SerialPortDisconnectedException] only for confirmed
/// disconnection. Call [close] after invalidation or incomplete cleanup. A failed
/// write may have accepted an unknown prefix and can be unsafe to retry.
///
/// [isOpen] is local state; [rts] and [dtr] are hardware readbacks. Reads may
/// overlap writes. Serialize operations within each direction and configuration
/// changes with I/O or signal setters. Serialize setters for the same signal;
/// await changes before ordered queries. Conflicts fail without queuing. [close]
/// may interrupt operations; await it before another lifecycle call.
abstract interface class SerialPort {
  /// Local session state. False before open, from close start, and after
  /// invalidation; it does not confirm device presence or resource release.
  bool get isOpen;

  Future<bool> get rts;

  Future<bool> get dtr;

  /// Opens the port without configuring it. Call [close] after incomplete
  /// cleanup before retrying.
  Future<void> open();

  /// Applies all five settings in [configuration].
  ///
  /// Requires an open session. The baud rate must be positive; invalid values
  /// fail with [ArgumentError] before changes. The selected flow-control mode
  /// replaces other modes; [SerialPortFlowControl.none] disables flow control.
  /// Does not drain output. Call [drain] first if pending output must finish with
  /// the old settings. No byte-stream boundary or glitch-free line change is
  /// guaranteed.
  ///
  /// Unsupported settings detected before any change fail with
  /// [UnsupportedError]. Failures after partial application use
  /// [SerialPortException]; rollback is not guaranteed. [close] may interrupt.
  Future<void> setConfiguration(SerialPortConfig configuration);

  /// Closes the port; a closed port is a no-op.
  ///
  /// Stops new operations and interrupts pending ones with [StateError]. On
  /// success, pending operations cannot access caller-owned buffers. Old-session
  /// work must not touch a reopened session. Does not [drain]; accepted output
  /// may be lost. If close fails, retry before reuse.
  Future<void> close();

  /// Reads up to [maxBytes] bytes. [maxBytes] must be positive.
  ///
  /// Returns when data is available, possibly fewer than requested. A null
  /// timeout waits indefinitely; zero polls; a positive timeout limits waiting.
  /// Negative timeouts are invalid. Empty means no data arrived before timeout.
  /// Once complete, the operation must not consume more input. The returned
  /// buffer belongs to the caller. A failure may consume input without returning it.
  Future<Uint8List> read(int maxBytes, {Duration? timeout});

  /// Accepts bytes from [data] for transmission and returns the accepted count.
  ///
  /// The count identifies the accepted prefix; acceptance does not guarantee
  /// transmission or peer receipt. A null timeout waits for capacity; zero
  /// polls; a positive timeout limits waiting and returns zero without progress.
  /// Negative timeouts are invalid; empty data returns zero. Do not modify
  /// [data] until this future completes. The implementation must not access it
  /// afterward. A failed or interrupted write may have accepted an unknown
  /// prefix, so retrying can duplicate bytes.
  Future<int> write(Uint8List data, {Duration? timeout});

  /// Waits for accepted output to leave the transmitter, not for peer receipt.
  /// May wait indefinitely or fail with [UnsupportedError] if completion is
  /// unknown. [close] can interrupt the wait.
  Future<void> drain();

  /// Discards unread input under the implementation's control. Data arriving
  /// during or after the discard may be returned by a later [read].
  Future<void> discardInput();

  /// Discards pending output under the implementation's control. Transmitted
  /// bytes cannot be retracted.
  Future<void> discardOutput();

  Future<bool> getSignal(SerialPortInputSignal signal);

  /// Reads the device-reported UART line status.
  ///
  /// Requires an open session. Unknown fields are null; unsupported diagnostics
  /// fail with [UnsupportedError]. Flags may be latched or cleared on read; no
  /// atomic snapshot or affected-byte mapping is guaranteed. Received BREAK is
  /// distinct from outgoing BREAK set by [setBreak].
  Future<SerialPortLineStatus> getLineStatus();

  Future<void> setRts(bool asserted);

  Future<void> setDtr(bool asserted);

  /// While enabled, BREAK blocks normal output.
  Future<void> setBreak(bool enabled);
}
