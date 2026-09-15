import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/interview_session.dart';

class SyncService {
  final String endpoint;
  SyncService({required this.endpoint});

  // Send one session to Apps Script. Returns true if success.
  Future<bool> syncSession(InterviewSession s) async {
    try {
      final body = jsonEncode(s.toJson());
      final resp = await http.post(Uri.parse(endpoint), headers: {
        'Content-Type': 'application/json'
      }, body: body).timeout(const Duration(seconds: 15));

      if (resp.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(resp.body);
        return data['success'] == true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }
}
