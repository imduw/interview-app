import 'package:flutter/material.dart';
import '../models/interview_session.dart';

class SessionItem extends StatelessWidget {
  final InterviewSession session;
  final VoidCallback? onTap;
  const SessionItem({super.key, required this.session, this.onTap});

  String _formatDateTime(DateTime d) {
    String two(int v) => v.toString().padLeft(2, '0');
    final local = d.toLocal();
    return '${local.year}-${two(local.month)}-${two(local.day)} ${two(local.hour)}:${two(local.minute)}';
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(session.sessionName),
      subtitle: Text('${session.interviewerName} • ${_formatDateTime(session.dateTime)}'),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}
