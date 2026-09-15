import 'package:flutter/material.dart';
import '../models/interview_session.dart';

class HomeScreen extends StatelessWidget {
  final List<InterviewSession> sessions;
  final VoidCallback onAdd;
  final void Function(InterviewSession) onOpen;
  final void Function(InterviewSession)? onEdit;
  final void Function(InterviewSession)? onDelete;

  const HomeScreen({
    super.key,
    required this.sessions,
    required this.onAdd,
    required this.onOpen,
    this.onEdit,
    this.onDelete,
  });

  Widget _statusIcon(SyncStatus s) {
    switch (s) {
      case SyncStatus.synced:
        return const Icon(Icons.check_circle, color: Colors.green);
      case SyncStatus.failed:
        return const Icon(Icons.error, color: Colors.orange);
      default:
        return const Icon(Icons.hourglass_top, color: Colors.grey);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Interview Sessions'),
      ),
      body: sessions.isEmpty
          ? const Center(child: Text('No sessions yet. Tap + to add one.'))
          : ListView.builder(
              itemCount: sessions.length,
              itemBuilder: (context, index) {
                final s = sessions[index];
                return Dismissible(
                  key: ValueKey(s.id),
                  background: Container(color: Colors.red, alignment: Alignment.centerRight, padding: const EdgeInsets.only(right: 16), child: const Icon(Icons.delete, color: Colors.white)),
                  direction: DismissDirection.endToStart,
                  onDismissed: (_) {
                    if (onDelete != null) onDelete!(s);
                  },
                  child: ListTile(
                    title: Text(s.sessionName),
                    subtitle: Text('${s.interviewerName} • ${s.dateTime.toLocal().toString().split('.')..removeLast()}'),
                    trailing: _statusIcon(s.syncStatus),
                    onTap: () => onOpen(s),
                    onLongPress: () {
                      if (onEdit != null) onEdit!(s);
                    },
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: onAdd,
        child: const Icon(Icons.add),
      ),
    );
  }
}
