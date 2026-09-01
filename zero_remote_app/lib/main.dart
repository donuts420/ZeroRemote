import 'package:flutter/material.dart';
import 'network/discovery.dart';
import 'network/api.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const ZeroRemoteApp());
}

class ZeroRemoteApp extends StatelessWidget {
  const ZeroRemoteApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ZeroRemote',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(useMaterial3: true),
      home: const RemoteScreen(),
    );
  }
}

class RemoteScreen extends StatefulWidget {
  const RemoteScreen({super.key});

  @override
  State<RemoteScreen> createState() => _RemoteScreenState();
}

class _RemoteScreenState extends State<RemoteScreen> {
  final ServerDiscovery _discovery = ServerDiscovery();
  RemoteAPI? _api;
  String _status = 'Auto-discovering PC...';
  bool _isSearching = true;

  @override
  void initState() {
    super.initState();
    _startAutoDiscovery();
  }

  void _startAutoDiscovery() {
    setState(() {
      _isSearching = true;
      _status = 'Auto-discovering PC...';
    });

    _discovery.startScanning(
      onFound: (ip, port) {
        if (!mounted) return;
        setState(() {
          _api = RemoteAPI(ip: ip, port: port);
          _isSearching = false;
          _status = 'Connected to $ip:$port';
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ZeroRemote'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _startAutoDiscovery,
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _api != null
                      ? Colors.green.withOpacity(0.2)
                      : Colors.amber.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      _api != null ? Icons.check_circle : Icons.sync,
                      color: _api != null
                          ? Colors.greenAccent
                          : Colors.amberAccent,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _status,
                      style: TextStyle(
                        color: _api != null
                            ? Colors.greenAccent
                            : Colors.amberAccent,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              if (_isSearching && _api == null) ...[
                const CircularProgressIndicator(),
                const SizedBox(height: 20),
                const Text('Looking for ZeroRemote PC server on Wi-Fi...'),
              ] else if (_api != null) ...[
                ElevatedButton(
                  onPressed: () => _api!.sendCommand('space'),
                  style: ElevatedButton.styleFrom(
                    shape: const CircleBorder(),
                    padding: const EdgeInsets.all(36),
                    backgroundColor: Colors.blueAccent,
                  ),
                  child: const Icon(
                    Icons.play_arrow,
                    size: 54,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 48),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: () => _api!.sendCommand('volume_down'),
                      style: ElevatedButton.styleFrom(
                        shape: const CircleBorder(),
                        padding: const EdgeInsets.all(24),
                      ),
                      child: const Icon(Icons.volume_down, size: 36),
                    ),
                    ElevatedButton(
                      onPressed: () => _api!.sendCommand('volume_up'),
                      style: ElevatedButton.styleFrom(
                        shape: const CircleBorder(),
                        padding: const EdgeInsets.all(24),
                      ),
                      child: const Icon(Icons.volume_up, size: 36),
                    ),
                  ],
                ),
              ],
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}
