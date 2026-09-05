import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class RemoteAPI {
  final String ip;
  final int port;

  RemoteAPI({required this.ip, required this.port});

  Future<bool> sendCommand(
    String action, [
    Map<String, dynamic>? extraData,
  ]) async {
    final url = Uri.parse('http://$ip:$port/command');
    try {
      final Map<String, dynamic> body = {'action': action};
      if (extraData != null) {
        body.addAll(extraData);
      }
      final response = await http
          .post(
            url,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(body),
          )
          .timeout(const Duration(milliseconds: 1500));

      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Command failed: $e');
      return false;
    }
  }
}
