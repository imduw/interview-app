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
        ? 'Chọn ngày'
        : '${_selectedDate!.year}-${_selectedDate!.month.toString().padLeft(2, '0')}-${_selectedDate!.day.toString().padLeft(2, '0')}';
    final timeText = _selectedTime == null
        ? 'Chọn giờ'
        : _selectedTime!.format(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.session == null ? 'Tạo phiên' : 'Chỉnh sửa'),
        centerTitle: false,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(22),
                    gradient: LinearGradient(
                      colors: [Colors.indigo.shade600, Colors.blue.shade500],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.edit_note_rounded, color: Colors.white, size: 30),
                      const SizedBox(height: 10),
                      Text(
                        widget.session == null ? 'Tạo phiên phỏng vấn mới' : 'Cập nhật phiên phỏng vấn',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                _buildSectionTitle(context, 'Thông tin cơ bản'),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _sessionController,
                  decoration: const InputDecoration(
                    labelText: 'Tên phiên phỏng vấn',
                    prefixIcon: Icon(Icons.title),
                  ),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Vui lòng nhập tên phiên' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _interviewerController,
                  decoration: const InputDecoration(
                    labelText: 'Tên người phỏng vấn',
                    prefixIcon: Icon(Icons.person),
                  ),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Vui lòng nhập tên người phỏng vấn' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _intervieweeController,
                  decoration: const InputDecoration(
                    labelText: 'Tên người được phỏng vấn',
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Vui lòng nhập tên người được phỏng vấn' : null,
                ),
                const SizedBox(height: 18),
                _buildSectionTitle(context, 'Thời gian & địa điểm'),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _pickDate(context),
                        icon: const Icon(Icons.calendar_month),
                        label: Text(dateText),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _pickTime(context),
                        icon: const Icon(Icons.access_time),
                        label: Text(timeText),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _getLocation,
                            icon: const Icon(Icons.location_on),
                            label: const Text('Lấy vị trí'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        if (_latitude != null && _longitude != null)
                          Expanded(
                            child: Text(
                              'Lat: ${_latitude!.toStringAsFixed(5)}\nLon: ${_longitude!.toStringAsFixed(5)}',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                _buildSectionTitle(context, 'Ảnh & minh chứng'),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _pickImage(ImageSource.camera),
                        icon: const Icon(Icons.camera_alt),
                        label: const Text('Chụp ảnh'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _pickImage(ImageSource.gallery),
                        icon: const Icon(Icons.photo_library),
                        label: const Text('Chọn ảnh'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (_photoBase64 != null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(18),
                    child: Image.memory(
                      base64Decode(_photoBase64!),
                      height: 200,
                      fit: BoxFit.cover,
                    ),
                  ),
                const SizedBox(height: 18),
                _buildSectionTitle(context, 'Câu hỏi & câu trả lời'),
                const SizedBox(height: 10),
                ..._questions.asMap().entries.map((entry) {
                  final idx = entry.key;
                  final q = entry.value;
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Text('Câu ${idx + 1}', style: const TextStyle(fontWeight: FontWeight.w700)),
                              const Spacer(),
                              TextButton.icon(
                                onPressed: () => _removeQuestion(idx),
                                icon: const Icon(Icons.delete_outline),
                                label: const Text('Xóa'),
                              ),
                            ],
                          ),
                          TextFormField(
                            initialValue: q.question,
                            decoration: InputDecoration(
                              labelText: 'Câu hỏi',
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            onChanged: (v) => q.question = v,
                          ),
                          const SizedBox(height: 10),
                          TextFormField(
                            initialValue: q.answer,
                            decoration: InputDecoration(
                              labelText: 'Câu trả lời',
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            onChanged: (v) => q.answer = v,
                          ),
                        ],
                      ),
                    ),
                  );
                }),
                OutlinedButton.icon(
                  onPressed: _addQuestion,
                  icon: const Icon(Icons.add_circle_outline),
                  label: const Text('Thêm câu hỏi'),
                ),
                const SizedBox(height: 20),
                FilledButton.icon(
                  onPressed: _save,
                  icon: const Icon(Icons.save),
                  label: const Text('Lưu phiên'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.w800,
      ),
    );
  }
}
