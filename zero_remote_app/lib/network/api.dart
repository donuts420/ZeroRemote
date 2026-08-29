import 'dart:convert';
import 'package:http/http.dart' as http;

class RemoteAPI {
  final String ip;
  final int port;

  RemoteAPI({required this.ip, required this.port});

  Future<void> sendCommand(String action) async {
    final url = Uri.parse('http://$ip:$port/command');

    try {
      await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'action': action}),
      );
      print('Sent: $action');
    } catch (e) {
      print('Failed to send $action: $e');
    }
  }
}