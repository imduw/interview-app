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

  String _formatDate(DateTime date) {
    final local = date.toLocal();
    return '${local.day.toString().padLeft(2, '0')}/${local.month.toString().padLeft(2, '0')}/${local.year}';
  }

  @override
  Widget build(BuildContext context) {
    final completedCount = sessions.where((s) => s.syncStatus == SyncStatus.synced).length;
    final pendingCount = sessions.where((s) => s.syncStatus != SyncStatus.synced).length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Interview App'),
        centerTitle: false,
        actions: [
          IconButton(
            onPressed: onAdd,
            icon: const Icon(Icons.add_circle_outline),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          child: sessions.isEmpty
              ? _buildEmptyState(context)
              : ListView(
                  children: [
                    _buildHeroCard(context, completedCount, pendingCount),
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        const Icon(Icons.calendar_month_outlined, size: 18, color: Colors.blue),
                        const SizedBox(width: 8),
                        Text(
                          'Danh sách phiên phỏng vấn',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ...sessions.map((s) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Dismissible(
                            key: ValueKey(s.id),
                            background: Container(
                              decoration: BoxDecoration(
                                color: Colors.red,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.only(right: 20),
                              child: const Icon(Icons.delete, color: Colors.white),
                            ),
                            direction: DismissDirection.endToStart,
                            onDismissed: (_) {
                              if (onDelete != null) onDelete!(s);
                            },
                            child: Card(
                              elevation: 2,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18),
                              ),
                              child: ListTile(
                                contentPadding: const EdgeInsets.all(16),
                                leading: CircleAvatar(
                                  backgroundColor: Colors.blue.withValues(alpha: 0.12),
                                  child: Icon(
                                    Icons.record_voice_over_rounded,
                                    color: Colors.blue.shade700,
                                  ),
                                ),
                                title: Text(
                                  s.sessionName,
                                  style: const TextStyle(fontWeight: FontWeight.w700),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 6),
                                    Text('${s.interviewerName} • ${s.intervieweeName}'),
                                    const SizedBox(height: 4),
                                    Text(_formatDate(s.dateTime)),
                                  ],
                                ),
                                trailing: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    _statusIcon(s.syncStatus),
                                    const SizedBox(height: 4),
                                    Text(
                                      s.syncStatus.name,
                                      style: Theme.of(context).textTheme.labelSmall,
                                    ),
                                  ],
                                ),
                                onTap: () => onOpen(s),
                                onLongPress: () {
                                  if (onEdit != null) onEdit!(s);
                                },
                              ),
                            ),
                          ),
                        )),
                  ],
                ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: onAdd,
        icon: const Icon(Icons.add),
        label: const Text('Tạo mới'),
      ),
    );
  }

  Widget _buildHeroCard(BuildContext context, int completedCount, int pendingCount) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          colors: [Colors.blue.shade700, Colors.indigo.shade600],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.insights_rounded, color: Colors.white),
              const SizedBox(width: 8),
              Text(
                'Tổng quan',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '${sessions.length}',
            style: Theme.of(context).textTheme.displaySmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Phiên phỏng vấn đang quản lý',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.white70),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: _MetricChip(
                  label: 'Đã sync',
                  value: '$completedCount',
                  color: Colors.green,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _MetricChip(
                  label: 'Chờ sync',
                  value: '$pendingCount',
                  color: Colors.orange,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 42,
                backgroundColor: Colors.blue.withValues(alpha: 0.12),
                child: const Icon(Icons.groups_2_rounded, size: 42, color: Colors.blue),
              ),
              const SizedBox(height: 16),
              Text(
                'Chưa có phiên phỏng vấn nào',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              Text(
                'Bắt đầu bằng một phiên mới để ghi lại câu hỏi, vị trí và ảnh thực tế.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey[700]),
              ),
              const SizedBox(height: 20),
              FilledButton.icon(
                onPressed: onAdd,
                icon: const Icon(Icons.add),
                label: const Text('Tạo phiên mới'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MetricChip extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _MetricChip({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }
}
