import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../config/constants.dart';
import '../../providers/auth_provider.dart';
import '../../services/api_service.dart';
import '../../widgets/animations/fade_animation.dart';

class StudentDoubtsScreen extends StatefulWidget {
  const StudentDoubtsScreen({Key? key}) : super(key: key);

  @override
  State<StudentDoubtsScreen> createState() => _StudentDoubtsScreenState();
}

class _StudentDoubtsScreenState extends State<StudentDoubtsScreen> {
  bool _videosLoading = false;
  List<dynamic> _videos = [];
  int? _selectedVideoId;
  String? _selectedVideoTitle;
  bool _doubtsLoading = false;
  List<dynamic> _doubts = [];
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadVideos();
  }

  Future<void> _loadVideos() async {
    if (!mounted) return;
    setState(() => _videosLoading = true);
    final token = context.read<AuthProvider>().token;
    if (token == null) {
      if (mounted) setState(() => _videosLoading = false);
      return;
    }
    try {
      final data = await ApiService().getVideos(token: token);
      if (!mounted) return;
      setState(() {
        _videos = data['videos'] as List? ?? [];
        _videosLoading = false;
      });
    } catch (e) {
      if (mounted) setState(() { _error = e.toString(); _videosLoading = false; });
    }
  }

  Future<void> _loadDoubts(int videoId) async {
    if (!mounted) return;
    setState(() { _doubtsLoading = true; _doubts = []; });
    final token = context.read<AuthProvider>().token;
    if (token == null) {
      if (mounted) setState(() => _doubtsLoading = false);
      return;
    }
    try {
      final data = await ApiService().getTimestamps(token: token, videoId: videoId);
      if (!mounted) return;
      setState(() {
        _doubts = data['timestamps'] as List? ?? [];
        _doubtsLoading = false;
      });
    } catch (e) {
      if (mounted) setState(() { _error = e.toString(); _doubtsLoading = false; });
    }
  }

  Future<void> _resolveDoubt(int timestampId, int index) async {
    final token = context.read<AuthProvider>().token;
    if (token == null) return;
    try {
      await ApiService().resolveDoubt(token: token, timestampId: timestampId);
      if (!mounted) return;
      setState(() {
        _doubts[index] = {..._doubts[index] as Map<String, dynamic>, 'is_resolved': true};
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('✓ Doubt resolved!'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        title: const Text('Student Doubts'),
        backgroundColor: AppColors.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Video selector
          Padding(
            padding: const EdgeInsets.all(AppConstants.paddingLarge),
            child: _videosLoading
                ? const Center(child: CircularProgressIndicator())
                : Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade200),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.06),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: DropdownButtonHideUnderline(
                      child: ButtonTheme(
                        alignedDropdown: true,
                        child: DropdownButton<int>(
                          value: _selectedVideoId,
                          isExpanded: true,
                          hint: Text(
                            _videos.isEmpty ? 'No videos found' : 'Select a video',
                            style: TextStyle(color: Colors.grey.shade500),
                          ),
                          items: _videos.map<DropdownMenuItem<int>>((v) {
                            final id = v['id'] as int;
                            final title = v['title'] ?? 'Video $id';
                            return DropdownMenuItem(
                              value: id,
                              child: Text(title, overflow: TextOverflow.ellipsis),
                            );
                          }).toList(),
                          onChanged: (id) {
                            if (id == null) return;
                            final video = _videos.firstWhere((v) => v['id'] == id);
                            setState(() {
                              _selectedVideoId = id;
                              _selectedVideoTitle = video['title'];
                            });
                            _loadDoubts(id);
                          },
                        ),
                      ),
                    ),
                  ),
          ),

          // Doubts list
          Expanded(
            child: _selectedVideoId == null
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.help_outline, color: Colors.grey.shade400, size: 56),
                        const SizedBox(height: 12),
                        Text(
                          'Select a video to view student doubts',
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                  )
                : _doubtsLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _error != null
                        ? Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.error_outline, color: Colors.red.shade300, size: 48),
                                const SizedBox(height: 12),
                                Text(_error!, style: TextStyle(color: Colors.grey.shade600)),
                                const SizedBox(height: 12),
                                TextButton(
                                  onPressed: () {
                                    if (_selectedVideoId != null) _loadDoubts(_selectedVideoId!);
                                  },
                                  child: const Text('Retry'),
                                ),
                              ],
                            ),
                          )
                        : _doubts.isEmpty
                            ? Center(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.check_circle_outline,
                                        color: Colors.green.shade400, size: 56),
                                    const SizedBox(height: 12),
                                    Text(
                                      'No doubts for "${_selectedVideoTitle ?? ''}"',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(color: Colors.grey.shade600),
                                    ),
                                  ],
                                ),
                              )
                            : ListView.builder(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: AppConstants.paddingLarge,
                                  vertical: 8,
                                ),
                                itemCount: _doubts.length,
                                itemBuilder: (context, index) {
                                  return _buildDoubtCard(index);
                                },
                              ),
          ),
        ],
      ),
    );
  }

  Widget _buildDoubtCard(int index) {
    final doubt = _doubts[index] as Map<String, dynamic>;
    final isResolved = doubt['is_resolved'] == true;
    final questionText = doubt['question_text'] ?? 'No question text';
    final timestamp = doubt['timestamp_value'] ?? '';
    final studentName = doubt['student_name'] ?? 'Anonymous';
    final timestampId = doubt['id'] as int?;

    return FadeAnimation(
      child: Card(
        margin: const EdgeInsets.only(bottom: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
          side: BorderSide(
            color: isResolved
                ? Colors.green.withOpacity(0.3)
                : Colors.orange.withOpacity(0.3),
            width: 1.5,
          ),
        ),
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.paddingMedium),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: isResolved
                          ? Colors.green.withOpacity(0.1)
                          : Colors.orange.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isResolved ? Icons.check_circle : Icons.help_outline,
                      color: isResolved ? Colors.green : Colors.orange,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          studentName,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                          ),
                        ),
                        if (timestamp.isNotEmpty)
                          Text(
                            'At $timestamp',
                            style: TextStyle(
                              color: Colors.grey.shade500,
                              fontSize: 11,
                            ),
                          ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: isResolved
                          ? Colors.green.withOpacity(0.1)
                          : Colors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      isResolved ? 'Resolved' : 'Pending',
                      style: TextStyle(
                        color: isResolved ? Colors.green : Colors.orange,
                        fontWeight: FontWeight.w700,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                questionText,
                style: const TextStyle(fontSize: 14, color: Colors.black87),
              ),
              if (!isResolved && timestampId != null) ...[
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => _resolveDoubt(timestampId, index),
                    icon: const Icon(Icons.check, size: 18),
                    label: const Text('Mark as Resolved'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
