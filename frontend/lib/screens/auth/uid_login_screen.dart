import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../providers/auth_provider.dart';
import '../home/student_home.dart';
import '../home/teacher_home.dart';
import '../home/admin_home_screen.dart';

// ── Step 1: Enter UID or RegId ───
class UIDLoginScreen extends StatefulWidget {
  const UIDLoginScreen({Key? key}) : super(key: key);

  @override
  State<UIDLoginScreen> createState() => _UIDLoginScreenState();
}

class _UIDLoginScreenState extends State<UIDLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _uidController = TextEditingController();
  final _regIdController = TextEditingController();
  bool _useUID = true; // toggle between UID and RegId

  @override
  void dispose() {
    _uidController.dispose();
    _regIdController.dispose();
    super.dispose();
  }

  Future<void> _handleContinue() async {
    if (!_formKey.currentState!.validate()) return;

    final auth = context.read<AuthProvider>();
    final uid = _useUID ? _uidController.text.trim() : null;
    final regId = !_useUID ? _regIdController.text.trim() : null;

    final success = await auth.verifyUID(uid: uid, regId: regId);

    if (!mounted) return;
    if (success) {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const OTPVerificationScreen()),
      );
    } else {
      final errorMsg = auth.error ?? 'Verification failed';
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(errorMsg),
        backgroundColor: AppColors.errorColor,
        duration: const Duration(seconds: 5),
        action: auth.isNetworkError
            ? SnackBarAction(
                label: 'Retry',
                textColor: Colors.white,
                onPressed: _handleContinue,
              )
            : null,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const BackButton(color: Colors.black87),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                // Logo
                Center(
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.primaryColor.withOpacity(0.1),
                    ),
                    child: const Icon(Icons.school_rounded,
                        size: 52, color: AppColors.primaryColor),
                  ),
                ),
                const SizedBox(height: 32),
                Center(
                  child: Text('Welcome to Classly',
                      style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[900])),
                ),
                const SizedBox(height: 8),
                Center(
                  child: Text('Enter your University ID or Registration Number',
                      style:
                          TextStyle(fontSize: 14, color: Colors.grey[600])),
                ),
                const SizedBox(height: 32),

                // Toggle UID / RegId
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _useUID = true),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: _useUID
                                ? AppColors.primaryColor
                                : Colors.grey[100],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: Text('UID',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: _useUID
                                        ? Colors.white
                                        : Colors.grey[600])),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _useUID = false),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: !_useUID
                                ? AppColors.primaryColor
                                : Colors.grey[100],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: Text('Registration ID',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: !_useUID
                                        ? Colors.white
                                        : Colors.grey[600])),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                if (_useUID)
                  TextFormField(
                    controller: _uidController,
                    decoration: InputDecoration(
                      labelText: 'University ID (UID)',
                      prefixIcon: const Icon(Icons.badge_outlined),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    validator: (v) =>
                        v == null || v.trim().isEmpty ? 'UID is required' : null,
                  )
                else
                  TextFormField(
                    controller: _regIdController,
                    decoration: InputDecoration(
                      labelText: 'Registration Number',
                      prefixIcon: const Icon(Icons.numbers_outlined),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    validator: (v) => v == null || v.trim().isEmpty
                        ? 'Registration number is required'
                        : null,
                  ),

                const SizedBox(height: 32),

                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: auth.isLoading ? null : _handleContinue,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryColor,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                    child: auth.isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2))
                        : const Text('Continue',
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white)),
                  ),
                ),

                const SizedBox(height: 24),
                Center(
                  child: Text(
                    'An OTP will be sent to verify your identity.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Step 2: Enter OTP ────────────────────────────────────────────────────────
class OTPVerificationScreen extends StatefulWidget {
  const OTPVerificationScreen({Key? key}) : super(key: key);

  @override
  State<OTPVerificationScreen> createState() => _OTPVerificationScreenState();
}

class _OTPVerificationScreenState extends State<OTPVerificationScreen> {
  final _otpController = TextEditingController();

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _handleVerify() async {
    final otp = _otpController.text.trim();
    if (otp.length < 4) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Please enter the complete OTP'),
      ));
      return;
    }

    final auth = context.read<AuthProvider>();
    final success = await auth.verifyOTP(otp: otp);

    if (!mounted) return;
    if (success) {
      final role = auth.user?.role ?? 'student';
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (_) => role == 'admin'
              ? const AdminHomeScreen()
              : role == 'teacher'
                  ? const TeacherHomeScreen()
                  : const StudentHomeScreen(),
        ),
        (route) => false,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(auth.error ?? 'Invalid OTP'),
        backgroundColor: AppColors.errorColor,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const BackButton(color: Colors.black87),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Center(
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primaryColor.withOpacity(0.1),
                  ),
                  child: Icon(Icons.lock_open_rounded,
                      size: 52, color: AppColors.primaryColor),
                ),
              ),
              const SizedBox(height: 32),
              Text('Verify your Identity',
                  style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[900])),
              const SizedBox(height: 8),
              Text(
                  'Enter the 6-digit OTP sent to your registered contact.',
                  style: TextStyle(fontSize: 14, color: Colors.grey[600])),
              const SizedBox(height: 32),

              TextFormField(
                controller: _otpController,
                keyboardType: TextInputType.number,
                maxLength: 6,
                decoration: InputDecoration(
                  labelText: 'One-Time Password',
                  prefixIcon: const Icon(Icons.pin_outlined),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                  counterText: '',
                ),
              ),

              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: auth.isLoading ? null : _handleVerify,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                  child: auth.isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2))
                      : const Text('Verify & Login',
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white)),
                ),
              ),

              const SizedBox(height: 20),
              Center(
                child: TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text('Wrong ID? Go back',
                      style: TextStyle(color: AppColors.primaryColor)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
