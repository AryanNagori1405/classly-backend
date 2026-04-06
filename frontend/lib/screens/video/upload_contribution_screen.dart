import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../providers/auth_provider.dart';
import '../../services/api_service.dart';

class UploadContributionScreen extends StatefulWidget {
  final int? relatedVideoId;
  final String? relatedVideoTitle;

  const UploadContributionScreen({
    Key? key,
    this.relatedVideoId,
    this.relatedVideoTitle,
  }) : super(key: key);

  @override
  State<UploadContributionScreen> createState() =>
      _UploadContributionScreenState();
}

class _UploadContributionScreenState extends State<UploadContributionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _fileUrlController = TextEditingController();

  String _fileType = 'video';
  bool _isLoading = false;

  final List<String> _fileTypes = ['video', 'pdf', 'doc', 'ppt', 'other'];

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _fileUrlController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      final auth = context.read<AuthProvider>();
      final api = ApiService();

      await api.uploadContribution(
        token: auth.token!,
        title: _titleController.text.trim(),
        fileUrl: _fileUrlController.text.trim(),
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        fileType: _fileType,
        relatedVideoId: widget.relatedVideoId,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Contribution uploaded successfully!'),
          backgroundColor: AppColors.successColor,
        ),
      );
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: AppColors.errorColor,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        title: const Text('Upload Contribution',
            style: TextStyle(fontWeight: FontWeight.w700)),
        backgroundColor: AppColors.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (widget.relatedVideoTitle != null) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                        color: AppColors.primaryColor.withOpacity(0.2)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.link, color: AppColors.primaryColor,
                          size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Linked to: ${widget.relatedVideoTitle}',
                          style: const TextStyle(
                              color: AppColors.primaryColor,
                              fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],
              _buildLabel('Title *'),
              const SizedBox(height: 6),
              TextFormField(
                controller: _titleController,
                decoration: _inputDecoration('Enter contribution title'),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Title is required' : null,
              ),
              const SizedBox(height: 16),
              _buildLabel('Description'),
              const SizedBox(height: 6),
              TextFormField(
                controller: _descriptionController,
                decoration:
                    _inputDecoration('Briefly describe your contribution'),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              _buildLabel('File URL *'),
              const SizedBox(height: 6),
              TextFormField(
                controller: _fileUrlController,
                decoration: _inputDecoration('Paste the hosted file URL'),
                keyboardType: TextInputType.url,
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'File URL is required' : null,
              ),
              const SizedBox(height: 16),
              _buildLabel('File Type'),
              const SizedBox(height: 6),
              DropdownButtonFormField<String>(
                value: _fileType,
                decoration: _inputDecoration(''),
                items: _fileTypes
                    .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                    .toList(),
                onChanged: (v) => setState(() => _fileType = v ?? 'video'),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2.5),
                        )
                      : const Text('Upload Contribution',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w700)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) => Text(
        text,
        style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textDark),
      );

  InputDecoration _inputDecoration(String hint) => InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: AppColors.textLight),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.borderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide:
              const BorderSide(color: AppColors.primaryColor, width: 1.5),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      );
}
