import 'package:nsd/nsd.dart';

class ServerDiscovery {
  // Matches the service type we broadcast from Python
  final String serviceType = '_zeroremote._tcp';

  Future<void> startScanning({
    required Function(String ip, int port) onFound,
  }) async {
    final discovery = await startDiscovery(serviceType);

    discovery.addListener(() {
      for (final service in discovery.services) {
        // Matches the service name from Python
        if (service.name != null && service.name!.contains('Laptop')) {
          final ip = service.addresses?.first.address;
          final port = service.port;

          if (ip != null && port != null) {
            onFound(ip, port);
            stopDiscovery(
              discovery,
            ); // Stop scanning once connected to save battery
          }
        }
      }
    });
  }
}
