class Validators {
  Validators._();

  static String? validateEmail(String? email) {
    if (email == null || email.trim().isEmpty) {
      return 'Email is required';
    }
    final emailRegex = RegExp(r'^[a-zA-Z0-9._%+\-]+@[a-zA-Z0-9.\-]+\.[a-zA-Z]{2,}$');
    if (!emailRegex.hasMatch(email.trim())) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  static String? validateUID(String? uid) {
    if (uid == null || uid.trim().isEmpty) {
      return 'University ID is required';
    }
    final trimmed = uid.trim();
    if (trimmed.length < 4 || trimmed.length > 20) {
      return 'UID must be between 4 and 20 characters';
    }
    final uidRegex = RegExp(r'^[a-zA-Z0-9\-_]+$');
    if (!uidRegex.hasMatch(trimmed)) {
      return 'UID can only contain letters, numbers, hyphens and underscores';
    }
    return null;
  }

  static String? validateRegId(String? regId) {
    if (regId == null || regId.trim().isEmpty) {
      return 'Registration ID is required';
    }
    final trimmed = regId.trim();
    if (trimmed.length < 4 || trimmed.length > 30) {
      return 'Registration ID must be between 4 and 30 characters';
    }
    final regIdRegex = RegExp(r'^[a-zA-Z0-9\-_/]+$');
    if (!regIdRegex.hasMatch(trimmed)) {
      return 'Registration ID contains invalid characters';
    }
    return null;
  }

  static String? validateName(String? name) {
    if (name == null || name.trim().isEmpty) {
      return 'Name is required';
    }
    final trimmed = name.trim();
    if (trimmed.length < 2) {
      return 'Name must be at least 2 characters';
    }
    if (trimmed.length > 100) {
      return 'Name must be under 100 characters';
    }
    final nameRegex = RegExp(r"^[a-zA-Z\s'\-\.]+$");
    if (!nameRegex.hasMatch(trimmed)) {
      return 'Name can only contain letters, spaces, hyphens and apostrophes';
    }
    return null;
  }

  /// Validates HH:MM:SS format timestamp.
  static String? validateTimestamp(String? ts) {
    if (ts == null || ts.trim().isEmpty) {
      return 'Timestamp is required';
    }
    final tsRegex = RegExp(r'^\d{2}:\d{2}:\d{2}$');
    if (!tsRegex.hasMatch(ts.trim())) {
      return 'Timestamp must be in HH:MM:SS format';
    }
    final parts = ts.split(':');
    final hours = int.tryParse(parts[0]) ?? -1;
    final minutes = int.tryParse(parts[1]) ?? -1;
    final seconds = int.tryParse(parts[2]) ?? -1;
    if (hours < 0 || minutes < 0 || minutes > 59 || seconds < 0 || seconds > 59) {
      return 'Invalid timestamp value';
    }
    return null;
  }

  static String? validateFeedback(String? text) {
    if (text == null || text.trim().isEmpty) {
      return 'Feedback cannot be empty';
    }
    final trimmed = text.trim();
    if (trimmed.length < 10) {
      return 'Feedback must be at least 10 characters';
    }
    if (trimmed.length > 1000) {
      return 'Feedback must be under 1000 characters';
    }
    return null;
  }
}
