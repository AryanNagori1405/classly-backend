import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../config/constants.dart';
import '../../providers/auth_provider.dart';
import '../../services/api_service.dart';
import '../../widgets/animations/fade_animation.dart';
import '../../widgets/animations/slide_animation.dart';

class VideoListScreen extends StatefulWidget {
  const VideoListScreen({Key? key}) : super(key: key);

  @override
  State<VideoListScreen> createState() => _VideoListScreenState();
}

class _VideoListScreenState extends State<VideoListScreen>
    with TickerProviderStateMixin {
  late TextEditingController _searchController;
  String _selectedFilter = 'all';
  late AnimationController _appBarController;
  late Animation<Offset> _appBarSlideAnimation;
  late Animation<double> _appBarFadeAnimation;

  bool _isLoading = false;
  List<dynamic> _videos = [];
  String? _error;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();

    _appBarController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _appBarSlideAnimation = Tween<Offset>(
      begin: const Offset(0, -0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _appBarController, curve: Curves.easeOutCubic));
    _appBarFadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _appBarController, curve: Curves.easeInCubic),
    );
    _appBarController.forward();
    _loadVideos();
  }

  Future<void> _loadVideos() async {
    if (!mounted) return;
    setState(() { _isLoading = true; _error = null; });
    final token = context.read<AuthProvider>().token;
    if (token == null) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }
    try {
      final data = await ApiService().getVideos(token: token);
      if (!mounted) return;
      setState(() {
        _videos = data['videos'] as List? ?? [];
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) setState(() { _error = e.toString(); _isLoading = false; });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _appBarController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: Stack(
        children: [
          // Animated Background Gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primaryColor.withOpacity(0.08),
                  AppColors.primaryLight.withOpacity(0.04),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),

          // Animated Background Shapes
          Positioned(
            top: -100,
            right: -80,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primaryColor.withOpacity(0.1),
              ),
            ),
          ),

          Positioned(
            bottom: -120,
            left: -60,
            child: Container(
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.purple.withOpacity(0.08),
              ),
            ),
          ),

          // Main Content
          SafeArea(
            child: Column(
              children: [
                // Header
                SlideTransition(
                  position: _appBarSlideAnimation,
                  child: FadeTransition(
                    opacity: _appBarFadeAnimation,
                    child: _buildHeader(),
                  ),
                ),

                // Search Bar
                FadeAnimation(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppConstants.paddingLarge,
                      vertical: AppConstants.paddingMedium,
                    ),
                    child: _buildSearchBar(),
                  ),
                ),

                // Filter Chips
                FadeAnimation(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppConstants.paddingLarge,
                      vertical: AppConstants.paddingMedium,
                    ),
                    child: Row(
                      children: [
                        _buildFilterChip('All', 'all', 0),
                        const SizedBox(width: 10),
                        _buildFilterChip('New', 'new', 100),
                        const SizedBox(width: 10),
                        _buildFilterChip('Trending', 'expiring', 200),
                        const SizedBox(width: 10),
                        _buildFilterChip('Downloaded', 'downloaded', 300),
                      ],
                    ),
                  ),
                ),

                // Video List
                Expanded(
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : _error != null
                          ? Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.error_outline,
                                      color: Colors.grey.shade400, size: 48),
                                  const SizedBox(height: 12),
                                  Text(_error!,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(color: Colors.grey.shade600)),
                                  const SizedBox(height: 12),
                                  TextButton(
                                    onPressed: _loadVideos,
                                    child: const Text('Retry'),
                                  ),
                                ],
                              ),
                            )
                          : _videos.isEmpty
                              ? Center(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.video_library_outlined,
                                          color: Colors.grey.shade400, size: 48),
                                      const SizedBox(height: 12),
                                      Text('No lectures available yet',
                                          style: TextStyle(color: Colors.grey.shade600)),
                                    ],
                                  ),
                                )
                              : ListView.builder(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: AppConstants.paddingLarge,
                                    vertical: AppConstants.paddingMedium,
                                  ),
                                  itemCount: _videos.length,
                                  itemBuilder: (context, index) {
                                    return _buildVideoItem(index, _videos[index]);
                                  },
                                ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.paddingLarge,
        vertical: AppConstants.paddingMedium,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Lectures',
            style: AppTextStyles.headingLarge.copyWith(
              fontSize: 32,
              color: Colors.black87,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Browse and watch all available lectures',
            style: AppTextStyles.bodyMedium.copyWith(
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (value) => setState(() {}),
        decoration: InputDecoration(
          hintText: 'Search lectures...',
          hintStyle: AppTextStyles.bodyMedium.copyWith(
            color: Colors.grey.shade400,
            fontWeight: FontWeight.w500,
          ),
          prefixIcon: Icon(
            Icons.search_rounded,
            color: AppColors.primaryColor.withOpacity(0.6),
            size: 24,
          ),
          suffixIcon: _searchController.text.isNotEmpty
              ? GestureDetector(
                  onTap: () {
                    _searchController.clear();
                    setState(() {});
                  },
                  child: Icon(
                    Icons.close_rounded,
                    color: AppColors.primaryColor.withOpacity(0.6),
                    size: 20,
                  ),
                )
              : null,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(
              color: Colors.grey.shade200,
              width: 1.5,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(
              color: Colors.grey.shade200,
              width: 1.5,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(
              color: AppColors.primaryColor,
              width: 2.5,
            ),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 16,
          ),
        ),
        style: AppTextStyles.bodyMedium.copyWith(
          color: Colors.black87,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, String value, int delay) {
    bool isSelected = _selectedFilter == value;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 800 + delay),
      curve: Curves.easeOut,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 30 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: child,
          ),
        );
      },
      child: GestureDetector(
        onTap: () => setState(() => _selectedFilter = value),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 18,
            vertical: 10,
          ),
          decoration: BoxDecoration(
            gradient: isSelected ? AppGradients.primaryGradient : null,
            color: isSelected ? null : Colors.white,
            border: Border.all(
              color: isSelected
                  ? Colors.transparent
                  : Colors.grey.shade200,
              width: 1.5,
            ),
            borderRadius: BorderRadius.circular(14),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: AppColors.primaryColor.withOpacity(0.3),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ]
                : [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
          ),
          child: Text(
            label,
            style: AppTextStyles.bodySmall.copyWith(
              color: isSelected ? Colors.white : Colors.black87,
              fontWeight: FontWeight.w700,
              fontSize: 13,
              letterSpacing: 0.3,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildVideoItem(int index, Map<String, dynamic> video) {
    final title = video['title'] ?? 'Untitled';
    final teacherName = video['teacher_name'] ?? 'Unknown';
    final subject = video['subject'] ?? 'General';
    final viewCount = (video['view_count'] ?? 0).toString();
    final upvoteCount = (video['upvote_count'] ?? 0).toString();
    final downloadCount = (video['download_count'] ?? 0).toString();
    final daysLeft = video['days_remaining'] as int?;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 800 + (index * 100)),
      curve: Curves.easeOut,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 40 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: child,
          ),
        );
      },
      child: SlideAnimation(
        child: Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {},
              borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
              splashColor: AppColors.primaryColor.withOpacity(0.1),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Thumbnail with Overlay
                  Stack(
                    children: [
                      // Gradient Background
                      Container(
                        width: double.infinity,
                        height: 180,
                        decoration: BoxDecoration(
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(AppConstants.radiusLarge),
                            topRight: Radius.circular(AppConstants.radiusLarge),
                          ),
                          gradient: LinearGradient(
                            colors: [
                              AppColors.primaryColor.withOpacity(0.3),
                              AppColors.primaryColor.withOpacity(0.05),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                      ),

                      // Play Button
                      Positioned(
                        top: 0,
                        left: 0,
                        right: 0,
                        bottom: 0,
                        child: Center(
                          child: Container(
                            width: 70,
                            height: 70,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.primaryColor,
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primaryColor.withOpacity(0.4),
                                  blurRadius: 20,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.play_arrow_rounded,
                              size: 36,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),

                      // Expiry Badge (only if days_remaining available)
                      if (daysLeft != null)
                        Positioned(
                          top: 12,
                          left: 12,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  const Color(0xFFF59E0B),
                                  const Color(0xFFF59E0B).withOpacity(0.7),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFFF59E0B).withOpacity(0.3),
                                  blurRadius: 8,
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.timer_rounded,
                                  size: 12,
                                  color: Colors.white,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '$daysLeft day${daysLeft != 1 ? 's' : ''}',
                                  style: AppTextStyles.caption.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),

                  // Content Section
                  Padding(
                    padding: const EdgeInsets.all(AppConstants.paddingMedium),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title
                        Text(
                          title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.bodyLarge.copyWith(
                            fontWeight: FontWeight.w800,
                            color: Colors.black87,
                            fontSize: 15,
                          ),
                        ),

                        const SizedBox(height: 8),

                        // Instructor Info
                        Row(
                          children: [
                            Container(
                              width: 28,
                              height: 28,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: LinearGradient(
                                  colors: [
                                    AppColors.primaryColor.withOpacity(0.3),
                                    AppColors.primaryColor.withOpacity(0.1),
                                  ],
                                ),
                                border: Border.all(
                                  color: AppColors.primaryColor.withOpacity(0.2),
                                  width: 1,
                                ),
                              ),
                              child: const Icon(
                                Icons.person_rounded,
                                size: 14,
                                color: AppColors.primaryColor,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    teacherName,
                                    style: AppTextStyles.caption.copyWith(
                                      color: Colors.black87,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 12,
                                    ),
                                  ),
                                  Text(
                                    subject,
                                    style: AppTextStyles.caption.copyWith(
                                      color: Colors.grey.shade600,
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 12),

                        // Stats Row
                        Row(
                          children: [
                            _buildStatBadge(
                              icon: Icons.thumb_up_rounded,
                              label: upvoteCount,
                              color: const Color(0xFFFCD34D),
                            ),

                            const SizedBox(width: 10),

                            _buildStatBadge(
                              icon: Icons.visibility_rounded,
                              label: '$viewCount views',
                              color: const Color(0xFF06B6D4),
                            ),

                            const SizedBox(width: 10),

                            _buildStatBadge(
                              icon: Icons.download_rounded,
                              label: downloadCount,
                              color: const Color(0xFF10B981),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatBadge({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              color.withOpacity(0.12),
              color.withOpacity(0.05),
            ],
          ),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: color.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 14,
              color: color,
            ),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                label,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.caption.copyWith(
                  color: Colors.black87,
                  fontWeight: FontWeight.w700,
                  fontSize: 11,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}