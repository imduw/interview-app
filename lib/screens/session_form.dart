import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/interview_session.dart';
import '../services/image_service.dart';
import '../services/location_service.dart';

class SessionForm extends StatefulWidget {
  final InterviewSession? session;
  const SessionForm({super.key, this.session});

  @override
  State<SessionForm> createState() => _SessionFormState();
}

class _SessionFormState extends State<SessionForm> {
  final _formKey = GlobalKey<FormState>();
  final _sessionController = TextEditingController();
  final _interviewerController = TextEditingController();
  final _intervieweeController = TextEditingController();

  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  List<QuestionItem> _questions = [];
  double? _latitude;
  double? _longitude;
  String? _photoBase64;

  final ImageService _imageService = ImageService();
  final LocationService _locationService = LocationService();

  @override
  void initState() {
    super.initState();
    if (widget.session != null) {
      final s = widget.session!;
      _sessionController.text = s.sessionName;
      _interviewerController.text = s.interviewerName;
      _intervieweeController.text = s.intervieweeName;
      _selectedDate = s.dateTime;
      _selectedTime = TimeOfDay(hour: s.dateTime.hour, minute: s.dateTime.minute);
      _questions = List.from(s.questions);
      _latitude = s.latitude;
      _longitude = s.longitude;
      _photoBase64 = s.photoBase64;
    }
  }

  @override
  void dispose() {
    _sessionController.dispose();
    _interviewerController.dispose();
    _intervieweeController.dispose();
    super.dispose();
  }

  Future<void> _pickDate(BuildContext context) async {
    final now = DateTime.now();
    final d = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? now,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (d != null && mounted) setState(() => _selectedDate = d);
  }

  Future<void> _pickTime(BuildContext context) async {
    final t = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
    );
    if (t != null && mounted) setState(() => _selectedTime = t);
  }

  void _addQuestion() {
    setState(() {
      _questions.add(QuestionItem(question: ''));
    });
  }

  void _removeQuestion(int index) {
    setState(() {
      _questions.removeAt(index);
    });
  }

  Future<void> _pickImage(ImageSource source) async {
    final b64 = await _imageService.pickImageBase64(source);
    if (!mounted) return;
    if (b64 != null) {
      setState(() => _photoBase64 = b64);
    }
  }

  Future<void> _getLocation() async {
    final pos = await _locationService.getCurrentLocation();
    if (!mounted) return;
    if (pos != null) {
      setState(() {
        _latitude = pos.latitude;
        _longitude = pos.longitude;
      });
    } else {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Không thể lấy vị trí.')));
    }
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    final date = _selectedDate ?? DateTime.now();
    final time = _selectedTime ?? TimeOfDay.now();
    final dateTime = DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );

    final session = InterviewSession(
      id: widget.session?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      sessionName: _sessionController.text.trim(),
      interviewerName: _interviewerController.text.trim(),
      intervieweeName: _intervieweeController.text.trim(),
      dateTime: dateTime,
      questions: _questions,
      latitude: _latitude,
      longitude: _longitude,
      photoBase64: _photoBase64,
      syncStatus: widget.session?.syncStatus ?? SyncStatus.pending,
    );

    Navigator.of(context).pop(session);
  }

  @override
  Widget build(BuildContext context) {
    final dateText = _selectedDate == null
        ? 'Select date'
        : '${_selectedDate!.year}-${_selectedDate!.month.toString().padLeft(2, '0')}-${_selectedDate!.day.toString().padLeft(2, '0')}';
    final timeText = _selectedTime == null
        ? 'Select time'
        : _selectedTime!.format(context);

    return Scaffold(
      appBar: AppBar(title: Text(widget.session == null ? 'New Interview Session' : 'Edit Interview')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _sessionController,
                decoration: const InputDecoration(labelText: 'Session name'),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter session name' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _interviewerController,
                decoration: const InputDecoration(labelText: 'Interviewer name'),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter interviewer name' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _intervieweeController,
                decoration: const InputDecoration(labelText: 'Interviewee name'),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter interviewee name' : null,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _pickDate(context),
                      child: Text(dateText),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _pickTime(context),
                      child: Text(timeText),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  ElevatedButton.icon(
                    onPressed: _getLocation,
                    icon: const Icon(Icons.location_on),
                    label: const Text('Lấy vị trí'),
                  ),
                  const SizedBox(width: 12),
                  if (_latitude != null && _longitude != null) Expanded(child: Text('Lat: ${_latitude!.toStringAsFixed(5)}, Lon: ${_longitude!.toStringAsFixed(5)}')),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  ElevatedButton.icon(
                    onPressed: () => _pickImage(ImageSource.camera),
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('Chụp ảnh'),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    onPressed: () => _pickImage(ImageSource.gallery),
                    icon: const Icon(Icons.photo),
                    label: const Text('Chọn ảnh'),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (_photoBase64 != null)
                Image.memory(
                  base64Decode(_photoBase64!),
                  height: 180,
                  fit: BoxFit.cover,
                ),
              const SizedBox(height: 12),
              const Text('Questions', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              ..._questions.asMap().entries.map((entry) {
                final idx = entry.key;
                final q = entry.value;
                return Column(
                  children: [
                    TextFormField(
                      initialValue: q.question,
                      decoration: InputDecoration(labelText: 'Question ${idx + 1}'),
                      onChanged: (v) => q.question = v,
                    ),
                    TextFormField(
                      initialValue: q.answer,
                      decoration: InputDecoration(labelText: 'Answer ${idx + 1}'),
                      onChanged: (v) => q.answer = v,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => _removeQuestion(idx),
                          child: const Text('Remove'),
                        )
                      ],
                    ),
                    const Divider(),
                  ],
                );
              }),
              TextButton.icon(
                onPressed: _addQuestion,
                icon: const Icon(Icons.add),
                label: const Text('Add question'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _save,
                child: const Text('Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
