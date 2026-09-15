import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/interview_session.dart';

class LocalStorageService {
  static const _key = 'interview_sessions_v1';

  Future<List<InterviewSession>> loadSessions() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null) return [];
    try {
      final List<dynamic> list = jsonDecode(raw);
      return list.map((e) => InterviewSession.fromJson(e)).toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> saveSessions(List<InterviewSession> sessions) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = jsonEncode(sessions.map((s) => s.toJson()).toList());
    await prefs.setString(_key, raw);
  }
}
