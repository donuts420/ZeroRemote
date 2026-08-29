import 'package:flutter/material.dart';
import 'network/discovery.dart';
import 'network/api.dart';

void main() {
  runApp(const ZeroRemoteApp());
}

class ZeroRemoteApp extends StatelessWidget {
  const ZeroRemoteApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ZeroRemote',
      theme: ThemeData.dark(),
      home: const ConnectionScreen(),
    );
  }
}

// 1. The StatefulWidget definition
class ConnectionScreen extends StatefulWidget {
  const ConnectionScreen({super.key});

  @override
  State<ConnectionScreen> createState() => _ConnectionScreenState();
}

// 2. The State logic definition
class _ConnectionScreenState extends State<ConnectionScreen> {
  final ServerDiscovery _discovery = ServerDiscovery();
  RemoteAPI? _api;

  @override
  void initState() {
    super.initState();
    _discovery.startScanning(
      onFound: (String ip, int port) {
        setState(() {
          _api = RemoteAPI(ip: ip, port: port);
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ZeroRemote')),
      body: Center(
        child: _api == null
            ? const Text(
                "Scanning Wi-Fi...",
                style: TextStyle(fontSize: 24, color: Colors.greenAccent),
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Connected!",
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 40),
                  ElevatedButton(
                    onPressed: () => _api!.sendCommand('space'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.all(20),
                    ),
                    child: const Icon(Icons.play_arrow, size: 50),
                  ),
                  const SizedBox(height: 30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: () => _api!.sendCommand('volume_down'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.all(15),
                        ),
                        child: const Icon(Icons.volume_down, size: 40),
                      ),
                      const SizedBox(width: 30),
                      ElevatedButton(
                        onPressed: () => _api!.sendCommand('volume_up'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.all(15),
                        ),
                        child: const Icon(Icons.volume_up, size: 40),
                      ),
                    ],
                  ),
                ],
              ),
      ),
    );
  }
}
