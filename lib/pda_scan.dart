import 'dart:async';

import 'package:flutter/services.dart';
import 'package:meta/meta.dart' show visibleForTesting;

class PdaScan {
  static PdaScan? _instance;
  final EventChannel _eventChannel;
  final MethodChannel _methodChannel;
  Stream<String>? _onScanString;

  factory PdaScan() {
    if (_instance == null) {
      final EventChannel eventChannel =
      const EventChannel("plugins.flutter.io/missfresh.scan");
      final MethodChannel methodChannel =
      const MethodChannel("plugins.flutter.io/missfresh.qrcode");
      _instance = PdaScan.private(eventChannel, methodChannel);
    }
    return _instance!;
  }

  Future<bool?> get isPDA {
    return _methodChannel.invokeMethod('isPDA');
  }

  Future<String?> get scanResult {
    return _methodChannel.invokeMethod("scan");
  }


  Future<String?> get scanStatus {
    return _methodChannel.invokeMethod("scanStatus");
  }

  Future<void> openBroadcastModel(){
    return _methodChannel.invokeMethod('switchModel0');
  }

  Future<void> openInputModel(){
    return _methodChannel.invokeMethod('switchModel1');
  }

  @visibleForTesting
  PdaScan.private(this._eventChannel, this._methodChannel);

  Stream<String>? get onScanResult {
    if (_onScanString == null) {
      _onScanString = _eventChannel
          .receiveBroadcastStream()
          .map((dynamic event) => event.toString());
    }
    return _onScanString;
  }
}
