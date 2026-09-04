import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class RemoteAPI {
  final String ip;
  final int port;

  RemoteAPI({required this.ip, required this.port});

  Future<bool> sendCommand(String action) async {
    final url = Uri.parse('http://$ip:$port/command');
    try {
      final response = await http
          .post(
            url,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'action': action}),
          )
          .timeout(const Duration(seconds: 2));

      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Command failed: $e');
      return false;
    }
  }
}
