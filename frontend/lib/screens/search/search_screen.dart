import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../config/constants.dart';
import '../../widgets/animations/fade_animation.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen>
    with TickerProviderStateMixin {
  late AnimationController _headerController;
  late Animation<Offset> _headerSlideAnimation;
  late Animation<double> _headerFadeAnimation;

  final _searchController = TextEditingController();
  String _selectedFilter = 'all';
  bool _isSearching = false;

  final List<Map<String, dynamic>> _allResults = [
    {
      'type': 'video',
      'title': 'Introduction to Flutter',
      'subtitle': 'Learn Flutter from scratch',
      'instructor': 'John Doe',
      'views': '1.2K',
      'rating': 4.5,
      'icon': Icons.video_library_rounded,
      'color': const Color(0xFFEF4444),
    },
    {
      'type': 'video',
      'title': 'Advanced Dart Programming',
      'subtitle': 'Master Dart language',
      'instructor': 'Jane Smith',
      'views': '856',
      'rating': 4.8,
      'icon': Icons.video_library_rounded,
      'color': const Color(0xFFEF4444),
    },
    {
      'type': 'doubt',
      'title': 'How to implement state management?',
      'subtitle': 'Provider vs Riverpod',
      'author': 'Student A',
      'replies': 5,
      'icon': Icons.help_rounded,
      'color': const Color(0xFF8B5CF6),
    },
    {
      'type': 'doubt',
      'title': 'Widget lifecycle in Flutter',
      'subtitle': 'Understanding stateful widgets',
      'author': 'Student B',
      'replies': 3,
      'icon': Icons.help_rounded,
      'color': const Color(0xFF8B5CF6),
    },
    {
      'type': 'community',
      'title': 'Flutter Developers',
      'subtitle': '2.5K members',
      'description': 'Community for Flutter enthusiasts',
      'icon': Icons.groups_rounded,
      'color': const Color(0xFF06B6D4),
    },
    {
      'type': 'community',
      'title': 'Web Development',
      'subtitle': '1.8K members',
      'description': 'Learn web technologies',
      'icon': Icons.groups_rounded,
      'color': const Color(0xFF06B6D4),
    },
  ];

  late List<Map<String, dynamic>> _filteredResults;

  @override
  void initState() {
    super.initState();

    _headerController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _headerSlideAnimation = Tween<Offset>(
      begin: const Offset(0, -0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _headerController, curve: Curves.easeOutCubic));
    _headerFadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _headerController, curve: Curves.easeInCubic),
    );
    _headerController.forward();

    _filteredResults = _allResults;
  }

  @override
  void dispose() {
    _headerController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _updateSearch(String query) {
    setState(() {
      _isSearching = query.isNotEmpty;

      if (query.isEmpty) {
        _filteredResults = _allResults;
      } else {
        _filteredResults = _allResults
            .where((item) =>
                item['title'].toLowerCase().contains(query.toLowerCase()) ||
                item['subtitle'].toLowerCase().contains(query.toLowerCase()))
            .toList();
      }

      // Apply filter
      if (_selectedFilter != 'all') {
        _filteredResults =
            _filteredResults.where((item) => item['type'] == _selectedFilter).toList();
      }
    });
  }

  void _updateFilter(String filter) {
    setState(() {
      _selectedFilter = filter;
      _updateSearch(_searchController.text);
    });
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
                  position: _headerSlideAnimation,
                  child: FadeTransition(
                    opacity: _headerFadeAnimation,
                    child: _buildHeader(),
                  ),
                ),

                // Search Bar
                Padding(
                  padding: const EdgeInsets.all(AppConstants.paddingLarge),
                  child: FadeAnimation(
                    child: _buildSearchBar(),
                  ),
                ),

                // Filter Chips
                if (!_isSearching || _filteredResults.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppConstants.paddingLarge,
                    ),
                    child: FadeAnimation(
                      child: _buildFilterChips(),
                    ),
                  ),

                const SizedBox(height: 12),

                // Results
                Expanded(
                  child: _buildResults(),
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
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 12,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                Icons.arrow_back_rounded,
                color: Colors.black87,
                size: 24,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Search',
                  style: AppTextStyles.headingMedium.copyWith(
                    fontSize: 28,
                    color: Colors.black87,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Find videos, doubts & communities',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return StatefulBuilder(
      builder: (context, setState) {
        bool isFocused = false;

        return Focus(
          onFocusChange: (hasFocus) {
            setState(() => isFocused = hasFocus);
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: isFocused
                      ? AppColors.primaryColor.withOpacity(0.5)
                      : Colors.black.withOpacity(0.08),
                  blurRadius: isFocused ? 24 : 16,
                  offset: const Offset(0, 6),
                  spreadRadius: isFocused ? 2 : 0,
                ),
                if (isFocused)
                  BoxShadow(
                    color: AppColors.primaryColor.withOpacity(0.25),
                    blurRadius: 40,
                    offset: const Offset(0, 12),
                    spreadRadius: 4,
                  ),
              ],
            ),
            child: TextField(
              controller: _searchController,
              onChanged: _updateSearch,
              style: const TextStyle(
                color: Colors.black87,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
              decoration: InputDecoration(
                hintText: 'Search videos, doubts, communities...',
                hintStyle: TextStyle(
                  color: Colors.grey.shade400,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
                prefixIcon: Icon(
                  Icons.search_rounded,
                  color: isFocused
                      ? AppColors.primaryColor
                      : AppColors.primaryColor.withOpacity(0.6),
                  size: 22,
                ),
                suffixIcon: _searchController.text.isNotEmpty
                    ? GestureDetector(
                        onTap: () {
                          _searchController.clear();
                          _updateSearch('');
                        },
                        child: Icon(
                          Icons.close_rounded,
                          color: AppColors.primaryColor.withOpacity(0.6),
                          size: 22,
                        ),
                      )
                    : null,
                filled: true,
                fillColor: isFocused
                    ? AppColors.primaryColor.withOpacity(0.05)
                    : Colors.white,
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
                  vertical: 18,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildFilterChips() {
    final filters = [
      {'label': 'All', 'value': 'all'},
      {'label': 'Videos', 'value': 'video'},
      {'label': 'Doubts', 'value': 'doubt'},
      {'label': 'Communities', 'value': 'community'},
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppConstants.paddingLarge),
        child: Row(
          children: filters
              .map((filter) => Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(filter['label'] as String),
                      selected: _selectedFilter == filter['value'],
                      onSelected: (_) => _updateFilter(filter['value'] as String),
                      backgroundColor: Colors.white,
                      selectedColor: AppColors.primaryColor.withOpacity(0.2),
                      side: BorderSide(
                        color: _selectedFilter == filter['value']
                            ? AppColors.primaryColor
                            : Colors.grey.shade300,
                        width: 1.5,
                      ),
                      labelStyle: AppTextStyles.bodySmall.copyWith(
                        color: _selectedFilter == filter['value']
                            ? AppColors.primaryColor
                            : Colors.grey.shade600,
                        fontWeight: FontWeight.w700,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ))
              .toList(),
        ),
      ),
    );
  }

  Widget _buildResults() {
    if (!_isSearching && _selectedFilter == 'all') {
      return _buildEmptyState();
    }

    if (_filteredResults.isEmpty) {
      return _buildNoResults();
    }

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppConstants.paddingLarge),
        child: Column(
          children: [
            Text(
              'Found ${_filteredResults.length} results',
              style: AppTextStyles.bodySmall.copyWith(
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _filteredResults.length,
              itemBuilder: (context, index) {
                final item = _filteredResults[index];
                return _buildResultCard(item, index);
              },
            ),
            const SizedBox(height: AppConstants.paddingLarge),
          ],
        ),
      ),
    );
  }

  Widget _buildResultCard(Map<String, dynamic> item, int index) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 400 + (index * 100)),
      curve: Curves.easeOut,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: child,
          ),
        );
      },
      child: GestureDetector(
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Opening ${item['title']}...'),
              backgroundColor: AppColors.accentColor,
              behavior: SnackBarBehavior.floating,
              margin: const EdgeInsets.all(16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
        },
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: Colors.grey.shade200,
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 12,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              // Icon
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: (item['color'] as Color).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: (item['color'] as Color).withOpacity(0.2),
                    width: 1.5,
                  ),
                ),
                child: Icon(
                  item['icon'] as IconData,
                  color: item['color'] as Color,
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),

              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item['title'] as String,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: Colors.black87,
                        fontWeight: FontWeight.w700,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item['subtitle'] as String,
                      style: AppTextStyles.caption.copyWith(
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (item['type'] == 'video') ...[
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(
                            Icons.visibility_rounded,
                            size: 14,
                            color: Colors.grey.shade500,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${item['views']} views',
                            style: AppTextStyles.caption.copyWith(
                              color: Colors.grey.shade500,
                              fontSize: 11,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(
                            Icons.star_rounded,
                            size: 14,
                            color: Colors.amber,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${item['rating']}',
                            style: AppTextStyles.caption.copyWith(
                              color: Colors.grey.shade500,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ],
                    if (item['type'] == 'doubt') ...[
                      const SizedBox(height: 6),
                      Text(
                        '${item['replies']} replies',
                        style: AppTextStyles.caption.copyWith(
                          color: Colors.grey.shade500,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(width: 12),

              // Arrow
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16,
                color: Colors.grey.shade300,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.paddingXLarge),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: AppColors.primaryColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.search_rounded,
                size: 50,
                color: AppColors.primaryColor.withOpacity(0.5),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Start Searching',
              style: AppTextStyles.headingSmall.copyWith(
                color: Colors.black87,
                fontSize: 20,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Find videos, doubts, and communities to enhance your learning',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodySmall.copyWith(
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoResults() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.paddingXLarge),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: AppColors.errorColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.search_off_rounded,
                size: 50,
                color: AppColors.errorColor.withOpacity(0.5),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No Results Found',
              style: AppTextStyles.headingSmall.copyWith(
                color: Colors.black87,
                fontSize: 20,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try searching with different keywords',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodySmall.copyWith(
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}