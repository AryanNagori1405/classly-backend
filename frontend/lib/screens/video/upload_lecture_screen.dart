import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../config/constants.dart';
import '../../widgets/animations/fade_animation.dart';
import '../../widgets/animations/slide_animation.dart';

class UploadLectureScreen extends StatefulWidget {
  UploadLectureScreen({Key? key}) : super(key: key);

  @override
  State<UploadLectureScreen> createState() => _UploadLectureScreenState();
}

class _UploadLectureScreenState extends State<UploadLectureScreen> {
  int _currentStep = 0;
  bool _isLoading = false;

  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _subjectController = TextEditingController();
  final _categoryController = TextEditingController();

  String _selectedVideo = '';
  String _selectedNotes = '';
  String _selectedSchedule = '';

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _subjectController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Upload Lecture',
          style: AppTextStyles.headingMedium.copyWith(
            fontSize: 24,
            color: Colors.black87,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.paddingLarge),
          child: FadeAnimation(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Step Indicator
                _buildStepIndicator(),
                const SizedBox(height: AppConstants.paddingXLarge),

                // Step Content
                _buildStepContent(),
                const SizedBox(height: AppConstants.paddingXLarge),

                // Navigation Buttons
                _buildNavigationButtons(),
                const SizedBox(height: AppConstants.paddingLarge),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStepIndicator() {
    List<String> steps = ['Video', 'Details', 'Notes', 'Schedule', 'Review'];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Step ${_currentStep + 1} of ${steps.length}',
          style: AppTextStyles.caption.copyWith(
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: List.generate(
            steps.length,
            (index) => Expanded(
              child: Column(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: index <= _currentStep
                          ? AppColors.primaryColor
                          : Colors.grey.shade200,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: index < _currentStep
                          ? const Icon(
                              Icons.check,
                              color: Colors.white,
                              size: 20,
                            )
                          : Text(
                              '${index + 1}',
                              style: TextStyle(
                                color: index <= _currentStep
                                    ? Colors.white
                                    : Colors.grey.shade600,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    steps[index],
                    textAlign: TextAlign.center,
                    style: AppTextStyles.caption.copyWith(
                      color: index <= _currentStep
                          ? AppColors.primaryColor
                          : Colors.grey.shade600,
                      fontWeight: index <= _currentStep
                          ? FontWeight.w700
                          : FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStepContent() {
    switch (_currentStep) {
      case 0:
        return _buildVideoSelectionStep();
      case 1:
        return _buildDetailsStep();
      case 2:
        return _buildNotesStep();
      case 3:
        return _buildScheduleStep();
      case 4:
        return _buildReviewStep();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildVideoSelectionStep() {
    return SlideAnimation(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Select Video File',
            style: AppTextStyles.headingSmall.copyWith(
              fontSize: 20,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: AppConstants.paddingMedium),
          Container(
            height: 200,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
              border: Border.all(
                color: Colors.grey.shade200,
                width: 2,
              ),
              color: Colors.grey.shade50,
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  setState(() => _selectedVideo = 'lecture_001.mp4');
                },
                borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: AppColors.primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(
                        Icons.video_library_outlined,
                        size: 30,
                        color: AppColors.primaryColor,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Click to select video',
                      style: AppTextStyles.bodyLarge.copyWith(
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'MP4, WebM, or OGG (max 2GB)',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: AppConstants.paddingMedium),
          if (_selectedVideo.isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.all(AppConstants.paddingMedium),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
                border: Border.all(
                  color: Colors.green.withOpacity(0.3),
                  width: 1.2,
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.check_circle,
                    color: Colors.green,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _selectedVideo,
                          style: AppTextStyles.bodyMedium.copyWith(
                            fontWeight: FontWeight.w700,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '1.2 GB • 45:30',
                          style: AppTextStyles.caption.copyWith(
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDetailsStep() {
    return SlideAnimation(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Lecture Details',
            style: AppTextStyles.headingSmall.copyWith(
              fontSize: 20,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: AppConstants.paddingMedium),
          _buildTextField(
            controller: _titleController,
            label: 'Lecture Title',
            hint: 'e.g., Advanced Flutter Patterns',
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _descriptionController,
            label: 'Description',
            hint: 'Describe what this lecture covers',
            maxLines: 4,
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _subjectController,
            label: 'Subject',
            hint: 'e.g., Mobile Development',
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _categoryController,
            label: 'Category',
            hint: 'e.g., Programming',
          ),
        ],
      ),
    );
  }

  Widget _buildNotesStep() {
    return SlideAnimation(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Add Notes/Documents',
            style: AppTextStyles.headingSmall.copyWith(
              fontSize: 20,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: AppConstants.paddingMedium),
          Container(
            padding: const EdgeInsets.all(AppConstants.paddingMedium),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
              border: Border.all(
                color: Colors.grey.shade200,
                width: 1.2,
              ),
              color: Colors.grey.shade50,
            ),
            child: Column(
              children: [
                const Icon(
                  Icons.file_download_outlined,
                  size: 40,
                  color: AppColors.primaryColor,
                ),
                const SizedBox(height: 16),
                Text(
                  'Upload Study Notes',
                  style: AppTextStyles.bodyLarge.copyWith(
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'PDF, DOC, or Image files',
                  style: AppTextStyles.caption.copyWith(
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () {
                    setState(() => _selectedNotes = 'lecture_notes.pdf');
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Select File'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                  ),
                ),
              ],
            ),
          ),
          if (_selectedNotes.isNotEmpty) ...[
            const SizedBox(height: AppConstants.paddingMedium),
            Container(
              padding: const EdgeInsets.all(AppConstants.paddingMedium),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.insert_drive_file,
                    color: Colors.green,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    _selectedNotes,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildScheduleStep() {
    return SlideAnimation(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Schedule & Visibility',
            style: AppTextStyles.headingSmall.copyWith(
              fontSize: 20,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: AppConstants.paddingMedium),
          Text(
            'When should this be visible?',
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          _buildScheduleOption(
            title: 'Publish Now',
            description: 'Make it visible immediately',
            isSelected: _selectedSchedule == 'now',
            onTap: () => setState(() => _selectedSchedule = 'now'),
          ),
          const SizedBox(height: 12),
          _buildScheduleOption(
            title: 'Schedule for Later',
            description: 'Choose a specific date and time',
            isSelected: _selectedSchedule == 'later',
            onTap: () => setState(() => _selectedSchedule = 'later'),
          ),
          const SizedBox(height: 12),
          Text(
            'Auto-delete after 7 days',
            style: AppTextStyles.bodySmall.copyWith(
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewStep() {
    return SlideAnimation(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Review & Publish',
            style: AppTextStyles.headingSmall.copyWith(
              fontSize: 20,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: AppConstants.paddingMedium),
          _buildReviewItem('Video File', _selectedVideo),
          _buildReviewItem('Title', _titleController.text),
          _buildReviewItem('Subject', _subjectController.text),
          _buildReviewItem('Notes', _selectedNotes.isEmpty ? 'None' : _selectedNotes),
          _buildReviewItem('Schedule', _selectedSchedule == 'now' ? 'Now' : 'Later'),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.bodyMedium.copyWith(
            fontWeight: FontWeight.w700,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Colors.grey.shade200,
                width: 1.2,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Colors.grey.shade200,
                width: 1.2,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: AppColors.primaryColor,
                width: 2,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildScheduleOption({
    required String title,
    required String description,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected
                ? AppColors.primaryColor
                : Colors.grey.shade200,
            width: isSelected ? 2 : 1.2,
          ),
          borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
          color: isSelected
              ? AppColors.primaryColor.withOpacity(0.05)
              : Colors.white,
        ),
        padding: const EdgeInsets.all(AppConstants.paddingMedium),
        child: Row(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                border: Border.all(
                  color: isSelected
                      ? AppColors.primaryColor
                      : Colors.grey.shade300,
                  width: 2,
                ),
                shape: BoxShape.circle,
                color: isSelected ? AppColors.primaryColor : Colors.transparent,
              ),
              child: isSelected
                  ? const Icon(
                      Icons.check,
                      size: 14,
                      color: Colors.white,
                    )
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: AppTextStyles.caption.copyWith(
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReviewItem(String label, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(AppConstants.paddingMedium),
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.grey.shade200,
          width: 1.2,
        ),
        borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTextStyles.bodySmall.copyWith(
              color: Colors.grey.shade600,
            ),
          ),
          Text(
            value,
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationButtons() {
    return Row(
      children: [
        if (_currentStep > 0)
          Expanded(
            child: OutlinedButton(
              onPressed: () => setState(() => _currentStep--),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(
                  color: AppColors.primaryColor,
                  width: 1.5,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: const Text('Back'),
            ),
          ),
        if (_currentStep > 0) const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton(
            onPressed: () {
              if (_currentStep < 4) {
                setState(() => _currentStep++);
              } else {
                _publishLecture();
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            child: Text(
              _currentStep == 4 ? 'Publish' : 'Next',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _publishLecture() {
    setState(() => _isLoading = true);

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✓ Lecture published successfully!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
        // Reset form
        setState(() {
          _currentStep = 0;
          _selectedVideo = '';
          _selectedNotes = '';
          _selectedSchedule = '';
          _titleController.clear();
          _descriptionController.clear();
          _subjectController.clear();
          _categoryController.clear();
        });
      }
    });
  }
}