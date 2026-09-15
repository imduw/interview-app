import 'dart:convert';
import 'package:flutter/material.dart';
import '../models/interview_session.dart';

class SessionDetail extends StatelessWidget {
  final InterviewSession session;
  const SessionDetail({super.key, required this.session});

  String _formatDateTime(DateTime d) {
    String two(int v) => v.toString().padLeft(2, '0');
    final local = d.toLocal();
    return '${local.year}-${two(local.month)}-${two(local.day)} ${two(local.hour)}:${two(local.minute)}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Session Details')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(session.sessionName, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              Text('Interviewer: ${session.interviewerName}'),
              const SizedBox(height: 4),
              Text('Interviewee: ${session.intervieweeName}'),
              const SizedBox(height: 12),
              Text('Date & time: ${_formatDateTime(session.dateTime)}'),
              const SizedBox(height: 12),
              if (session.latitude != null && session.longitude != null) Text('Location: ${session.latitude}, ${session.longitude}'),
              const SizedBox(height: 12),
              if (session.photoBase64 != null)
                Image.memory(
                  base64Decode(session.photoBase64!),
                  height: 220,
                  fit: BoxFit.cover,
                ),
              const SizedBox(height: 12),
              const Text('Questions', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              ...session.questions.map((q) => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('- ${q.question}', style: const TextStyle(fontWeight: FontWeight.w600)),
                      const SizedBox(height: 4),
                      Text('Answer: ${q.answer}'),
                      const SizedBox(height: 8),
                    ],
                  )),
              const SizedBox(height: 12),
              Text('Sync status: ${session.syncStatus.name}'),
              const SizedBox(height: 20),
              Text('Session id: ${session.id}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
            ],
          ),
        ),
      ),
    );
  }
}
