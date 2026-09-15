import 'dart:convert';

enum SyncStatus { pending, synced, failed }

class QuestionItem {
  String question;
  String answer;
  QuestionItem({required this.question, this.answer = ''});

  Map<String, dynamic> toJson() => {'question': question, 'answer': answer};
  factory QuestionItem.fromJson(Map<String, dynamic> j) => QuestionItem(
        question: j['question'] ?? '',
        answer: j['answer'] ?? '',
      );
}

class InterviewSession {
  final String id;
  String sessionName;
  String interviewerName;
  String intervieweeName;
  DateTime dateTime;
  List<QuestionItem> questions;
  double? latitude;
  double? longitude;
  String? photoBase64; // optional base64-encoded image
  SyncStatus syncStatus;

  InterviewSession({
    required this.id,
    required this.sessionName,
    required this.interviewerName,
    required this.intervieweeName,
    required this.dateTime,
    List<QuestionItem>? questions,
    this.latitude,
    this.longitude,
    this.photoBase64,
    this.syncStatus = SyncStatus.pending,
  }) : questions = questions ?? [];

  Map<String, dynamic> toJson() => {
        'id': id,
        'sessionName': sessionName,
        'interviewerName': interviewerName,
        'intervieweeName': intervieweeName,
        'dateTime': dateTime.toUtc().toIso8601String(),
        'questions': questions.map((q) => q.toJson()).toList(),
        'answers': questions.map((q) => q.answer).toList(),
        'latitude': latitude,
        'longitude': longitude,
        'photo': photoBase64,
        'photoBase64': photoBase64,
        'syncStatus': syncStatus.name,
      };

  factory InterviewSession.fromJson(Map<String, dynamic> j) {
    final q = (j['questions'] as List<dynamic>?)?.map((e) {
          if (e is Map<String, dynamic>) return QuestionItem.fromJson(e);
          return QuestionItem.fromJson(Map<String, dynamic>.from(e));
        }).toList() ?? [];
    return InterviewSession(
      id: j['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
      sessionName: j['sessionName'] ?? '',
      interviewerName: j['interviewerName'] ?? '',
      intervieweeName: j['intervieweeName'] ?? '',
      dateTime: DateTime.tryParse(j['dateTime'] ?? '') ?? DateTime.now(),
      questions: q,
      latitude: j['latitude'] == null ? null : (j['latitude'] as num).toDouble(),
      longitude: j['longitude'] == null ? null : (j['longitude'] as num).toDouble(),
      photoBase64: j['photoBase64'],
      syncStatus: _statusFromString(j['syncStatus']),
    );
  }

  static SyncStatus _statusFromString(String? s) {
    switch (s) {
      case 'synced':
        return SyncStatus.synced;
      case 'failed':
        return SyncStatus.failed;
      default:
        return SyncStatus.pending;
    }
  }

  String questionsToString() {
    return jsonEncode(questions.map((q) => q.toJson()).toList());
  }
}
