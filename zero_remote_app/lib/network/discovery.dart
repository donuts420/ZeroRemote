import 'dart:async';
import 'package:nsd/nsd.dart';
import 'package:flutter/foundation.dart';

class ServerDiscovery {
  bool _isScanning = false;
  Discovery? _nsdDiscovery;

  Future<void> startScanning({
    required Function(String ip, int port) onFound,
  }) async {
    if (_isScanning) return;
    _isScanning = true;

    try {
      _nsdDiscovery = await startDiscovery(
        '_zeroremote._tcp',
        autoResolve: true,
      );

      _nsdDiscovery!.addListener(() {
        if (!_isScanning) return;

        for (final service in _nsdDiscovery!.services) {
          if (service.host != null && service.port != null) {
            _isScanning = false;
            final hostIp = service.host!;
            final port = service.port!;
            stopDiscovery(_nsdDiscovery!);
            onFound(hostIp, port);
            return;
          }
        }
      });
    } catch (e) {
      debugPrint('Discovery error: $e');
      _isScanning = false;
      if (_nsdDiscovery != null) {
        stopDiscovery(_nsdDiscovery!);
      }
    }
  }

  void stopScanning() {
    _isScanning = false;
    if (_nsdDiscovery != null) {
      stopDiscovery(_nsdDiscovery!);
      _nsdDiscovery = null;
    }
  }
}
