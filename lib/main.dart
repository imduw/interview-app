import 'dart:async';
import 'package:flutter/material.dart';
import 'models/interview_session.dart';
import 'screens/home_screen.dart';
import 'screens/session_form.dart';
import 'screens/session_detail.dart';
import 'services/local_storage_service.dart';
import 'services/sync_service.dart';
import 'services/config.dart';
import 'services/connectivity_service.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final List<InterviewSession> _sessions = [];
  final LocalStorageService _storage = LocalStorageService();
  late final SyncService _syncService;
  final ConnectivityService _connectivityService = ConnectivityService();
  StreamSubscription? _connectivitySub;

  @override
  void initState() {
    super.initState();
    _syncService = SyncService(endpoint: kAppsScriptEndpoint);
    _load();
    _connectivitySub = _connectivityService.onConnectivityChanged.listen((_) {
      _attemptSyncPending();
    });
  }

  @override
  void dispose() {
    _connectivitySub?.cancel();
    super.dispose();
  }

  Future<void> _load() async {
    final list = await _storage.loadSessions();
    setState(() {
      _sessions.clear();
      _sessions.addAll(list);
    });
    // try sync pending on startup
    _attemptSyncPending();
  }

  Future<void> _save() async {
    await _storage.saveSessions(_sessions);
  }

  Future<void> _addSession() async {
    final InterviewSession? result = await navigatorKey.currentState?.push<InterviewSession>(
      MaterialPageRoute(builder: (_) => const SessionForm()),
    );
    if (result != null) {
      setState(() {
        _sessions.add(result);
      });
      await _save();
      _attemptSyncFor(result);
    }
  }

  Future<void> _editSession(InterviewSession session) async {
    final InterviewSession? result = await navigatorKey.currentState?.push<InterviewSession>(
      MaterialPageRoute(builder: (_) => SessionForm(session: session)),
    );
    if (result != null) {
      final idx = _sessions.indexWhere((s) => s.id == result.id);
      if (idx != -1) {
        setState(() {
          _sessions[idx] = result;
        });
        await _save();
        _attemptSyncFor(result);
      }
    }
  }

  Future<void> _deleteSession(InterviewSession session) async {
    setState(() {
      _sessions.removeWhere((s) => s.id == session.id);
    });
    await _save();
  }

  Future<void> _openDetail(InterviewSession session) async {
    await navigatorKey.currentState?.push(
      MaterialPageRoute(builder: (_) => SessionDetail(session: session)),
    );
  }

  Future<void> _attemptSyncFor(InterviewSession s) async {
    if (kAppsScriptEndpoint.contains('<YOUR')) return; // no endpoint configured
    if (s.syncStatus == SyncStatus.synced) return;

    final ok = await _syncService.syncSession(s);
    if (ok) {
      setState(() {
        s.syncStatus = SyncStatus.synced;
      });
      await _save();
      _showMessage('Đồng bộ thành công: ${s.sessionName}');
    } else {
      setState(() {
        s.syncStatus = SyncStatus.failed;
      });
      await _save();
      _showMessage('Đồng bộ thất bại: ${s.sessionName}');
    }
  }

  Future<void> _attemptSyncPending() async {
    if (kAppsScriptEndpoint.contains('<YOUR')) return; // no endpoint configured
    for (final s in List<InterviewSession>.from(_sessions)) {
      if (s.syncStatus != SyncStatus.synced) {
        await _attemptSyncFor(s);
      }
    }
  }

  final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

  void _showMessage(String text) {
    _scaffoldMessengerKey.currentState?.showSnackBar(SnackBar(content: Text(text)));
  }

  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      scaffoldMessengerKey: _scaffoldMessengerKey,
      title: 'Interview App',
      theme: ThemeData(
        colorSchemeSeed: Colors.blue,
        useMaterial3: true,
      ),
      home: HomeScreen(
        sessions: _sessions,
        onAdd: _addSession,
        onOpen: _openDetail,
        onEdit: _editSession,
        onDelete: _deleteSession,
      ),
    );
  }
}
