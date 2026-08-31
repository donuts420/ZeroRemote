import 'package:multicast_dns/multicast_dns.dart';

class ServerDiscovery {
  final String serviceName = '_zeroremote._tcp.local';
  MDnsClient? _client;
  bool _isScanning = false;

  Future<void> startScanning({
    required Function(String ip, int port) onFound,
  }) async {
    _isScanning = true;
    _client = MDnsClient();
    await _client!.start();

    try {
      await for (final PtrResourceRecord ptr
          in _client!.lookup<PtrResourceRecord>(
            ResourceRecordQuery.serverPointer(serviceName),
          )) {
        if (!_isScanning) break;

        await for (final SrvResourceRecord srv
            in _client!.lookup<SrvResourceRecord>(
              ResourceRecordQuery.service(ptr.domainName),
            )) {
          if (!_isScanning) break;

          await for (final IPAddressResourceRecord ipRecord
              in _client!.lookup<IPAddressResourceRecord>(
                ResourceRecordQuery.addressIPv4(srv.target),
              )) {
            if (!_isScanning) break;

            onFound(ipRecord.address.address, srv.port);
            stopScanning();
            return;
          }
        }
      }
    } catch (e) {
      print('Discovery error: $e');
    }
  }

  void stopScanning() {
    _isScanning = false;
    _client?.stop();
    _client = null;
  }
}
