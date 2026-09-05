import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Colors.black,
        colorScheme: const ColorScheme.dark(
          surface: Colors.black,
          primary: Colors.white,
        ),
        useMaterial3: true,
      ),
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

  void _triggerHaptic() {
    HapticFeedback.lightImpact();
  }

  Widget _buildCircleButton({
    required Widget child,
    required VoidCallback onPressed,
    Color? bgColor,
  }) {
    const defaultBg = Color(0xFFCCCCCC);
    const iconColor = Colors.black;

    return Container(
      width: 76,
      height: 76,
      decoration: BoxDecoration(
        color: bgColor ?? defaultBg,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: () {
            _triggerHaptic();
            onPressed();
          },
          child: Center(
            child: IconTheme(
              data: const IconThemeData(color: iconColor, size: 36),
              child: child,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const touchpadColor = Color(0xFFCCCCCC);
    const dividerColor = Colors.black45;

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8.0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Sleep / Suspend Button
                  IconButton(
                    style: IconButton.styleFrom(
                      backgroundColor: const Color(0xFFCCCCCC),
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.all(12),
                    ),
                    icon: const Icon(Icons.bedtime_outlined, size: 24),
                    tooltip: 'Put PC to Sleep',
                    onPressed: () {
                      _triggerHaptic();
                      _api?.sendCommand('sleep');
                    },
                  ),
                  const Text(
                    'ZeroRemote',
                    style: TextStyle(
                      fontStyle: FontStyle.italic,
                      fontWeight: FontWeight.bold,
                      fontSize: 24,
                      letterSpacing: 0.5,
                      color: Colors.white,
                    ),
                  ),
                  IconButton(
                    style: IconButton.styleFrom(
                      backgroundColor: const Color(0xFFCCCCCC),
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.all(12),
                    ),
                    icon: const Icon(Icons.refresh, size: 24),
                    onPressed: _startAutoDiscovery,
                  ),
                ],
              ),
            ),

            // Connection notification banner if still discovering or disconnected
            if (_isSearching && _api == null)
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20.0,
                  vertical: 8.0,
                ),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.amber.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        _status,
                        style: const TextStyle(
                          color: Colors.amberAccent,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            const Spacer(),

            // Media control row: Replay (Previous) | Play/Pause | End/Skip (Next)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildCircleButton(
                    child: const Icon(Icons.skip_previous),
                    onPressed: () => _api?.sendCommand('prev_track'),
                  ),
                  _buildCircleButton(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(Icons.play_arrow, size: 26),
                        Icon(Icons.pause, size: 26),
                      ],
                    ),
                    onPressed: () => _api?.sendCommand('play_pause'),
                  ),
                  _buildCircleButton(
                    child: const Icon(Icons.skip_next),
                    onPressed: () => _api?.sendCommand('next_track'),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Volume control row: Volume Down | Mute | Volume Up
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildCircleButton(
                    child: const Icon(Icons.volume_down),
                    onPressed: () => _api?.sendCommand('volume_down'),
                  ),
                  _buildCircleButton(
                    child: const Icon(Icons.volume_off),
                    onPressed: () => _api?.sendCommand('volume_mute'),
                  ),
                  _buildCircleButton(
                    child: const Icon(Icons.volume_up),
                    onPressed: () => _api?.sendCommand('volume_up'),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Touchpad and Left/Right buttons
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Container(
                height: 230,
                decoration: BoxDecoration(
                  color: touchpadColor,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.15),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Touchpad Area
                    Expanded(
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onPanUpdate: (details) {
                          // Increased sensitivity multiplier for responsive cursor control
                          final dx = details.delta.dx * 2.8;
                          final dy = details.delta.dy * 2.8;
                          _api?.sendCommand('mouse_move', {'dx': dx, 'dy': dy});
                        },
                        onTap: () {
                          _triggerHaptic();
                          _api?.sendCommand('mouse_click', {'button': 'left'});
                        },
                        child: Container(
                          width: double.infinity,
                          decoration: const BoxDecoration(
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(16),
                            ),
                          ),
                          child: Center(
                            child: Icon(
                              Icons.touch_app_outlined,
                              size: 28,
                              color: Colors.black.withValues(alpha: 0.15),
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Divider between touchpad and bottom click buttons
                    Container(height: 1, color: dividerColor),

                    // Touchpad Click Buttons (Left / Right)
                    SizedBox(
                      height: 52,
                      child: Row(
                        children: [
                          // Left Click
                          Expanded(
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                borderRadius: const BorderRadius.only(
                                  bottomLeft: Radius.circular(16),
                                ),
                                onTap: () {
                                  _triggerHaptic();
                                  _api?.sendCommand('mouse_click', {
                                    'button': 'left',
                                  });
                                },
                                child: const Center(
                                  child: Text(
                                    'L',
                                    style: TextStyle(
                                      color: Colors.black54,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),

                          // Vertical divider
                          Container(
                            width: 1,
                            height: double.infinity,
                            color: dividerColor,
                          ),

                          // Right Click
                          Expanded(
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                borderRadius: const BorderRadius.only(
                                  bottomRight: Radius.circular(16),
                                ),
                                onTap: () {
                                  _triggerHaptic();
                                  _api?.sendCommand('mouse_click', {
                                    'button': 'right',
                                  });
                                },
                                child: const Center(
                                  child: Text(
                                    'R',
                                    style: TextStyle(
                                      color: Colors.black54,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
