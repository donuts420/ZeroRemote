import 'dart:async';
import 'dart:io';
import 'package:http/http.dart' as http;

class ServerDiscovery {
  bool _isScanning = false;

  Future<void> startScanning({
    required Function(String ip, int port) onFound,
  }) async {
    _isScanning = true;

    try {
      // Find local subnet IP of the phone
      String subnet = '';
      for (var interface in await NetworkInterface.list()) {
        for (var addr in interface.addresses) {
          if (addr.type == InternetAddressType.IPv4 && !addr.isLoopback) {
            final parts = addr.address.split('.');
            subnet = '${parts[0]}.${parts[1]}.${parts[2]}';
            break;
          }
        }
        if (subnet.isNotEmpty) break;
      }

      if (subnet.isEmpty)
        subnet = '192.168.43'; // Default mobile hotspot subnet fallback

      // Concurrently ping all 254 IPs on the subnet
      final List<Future<void>> pingTasks = [];

      for (int i = 1; i < 255; i++) {
        final host = '$subnet.$i';
        pingTasks.add(
          http
              .get(Uri.parse('http://$host:5000/ping'))
              .timeout(const Duration(milliseconds: 1500))
              .then((response) {
                if (_isScanning &&
                    response.statusCode == 200 &&
                    response.body.contains('connected')) {
                  _isScanning = false;
                  onFound(host, 5000);
                }
              })
              .catchError((_) {}),
        );
      }

      await Future.wait(pingTasks);
    } catch (e) {
      print('Discovery error: $e');
    }
  }

  void stopScanning() {
    _isScanning = false;
  }
}
