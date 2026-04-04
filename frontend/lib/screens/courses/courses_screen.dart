import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../config/constants.dart';
import '../../models/course_model.dart';
import '../../widgets/animations/fade_animation.dart';
import '../../widgets/animations/slide_animation.dart';

class CoursesScreen extends StatefulWidget {
  const CoursesScreen({Key? key}) : super(key: key);

  @override
  State<CoursesScreen> createState() => _CoursesScreenState();
}

class _CoursesScreenState extends State<CoursesScreen> {
  late List<Course> _courses;
  String _selectedFilter = 'all';
  late TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _loadMockCourses();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _loadMockCourses() {
    _courses = [
      Course(
        id: 1,
        title: 'Flutter Development',
        description: 'Learn Flutter from scratch',
        instructor: 'Aryan Nagori',
        thumbnail: 'https://via.placeholder.com/300x200?text=Flutter',
        videosCount: 15,
        enrolledCount: 324,
        rating: 4.8,
        level: 'beginner',
        tags: ['Flutter', 'Mobile'],
        isEnrolled: true,
        createdAt: DateTime.now(),
      ),
      Course(
        id: 2,
        title: 'Advanced React',
        description: 'Master React with hooks and context',
        instructor: 'Jane Doe',
        thumbnail: 'https://via.placeholder.com/300x200?text=React',
        videosCount: 22,
        enrolledCount: 512,
        rating: 4.9,
        level: 'advanced',
        tags: ['React', 'JavaScript'],
        isEnrolled: false,
        createdAt: DateTime.now(),
      ),
      Course(
        id: 3,
        title: 'Python Basics',
        description: 'Start your Python journey',
        instructor: 'John Smith',
        thumbnail: 'https://via.placeholder.com/300x200?text=Python',
        videosCount: 18,
        enrolledCount: 678,
        rating: 4.7,
        level: 'beginner',
        tags: ['Python', 'Programming'],
        isEnrolled: true,
        createdAt: DateTime.now(),
      ),
      Course(
        id: 4,
        title: 'Web Design Masterclass',
        description: 'Create beautiful websites',
        instructor: 'Sarah Johnson',
        thumbnail: 'https://via.placeholder.com/300x200?text=WebDesign',
        videosCount: 25,
        enrolledCount: 445,
        rating: 4.6,
        level: 'intermediate',
        tags: ['Design', 'CSS', 'HTML'],
        isEnrolled: false,
        createdAt: DateTime.now(),
      ),
      Course(
        id: 5,
        title: 'Data Science Fundamentals',
        description: 'Learn data science with Python',
        instructor: 'Mike Chen',
        thumbnail: 'https://via.placeholder.com/300x200?text=DataScience',
        videosCount: 28,
        enrolledCount: 523,
        rating: 4.7,
        level: 'intermediate',
        tags: ['Data Science', 'Python'],
        isEnrolled: false,
        createdAt: DateTime.now(),
      ),
    ];
  }

  List<Course> get _filteredCourses {
    var filtered = _selectedFilter == 'enrolled'
        ? _courses.where((course) => course.isEnrolled).toList()
        : _courses;

    if (_searchController.text.isNotEmpty) {
      filtered = filtered
          .where((course) =>
              course.title.toLowerCase().contains(
                  _searchController.text.toLowerCase()) ||
              course.instructor.toLowerCase().contains(
                  _searchController.text.toLowerCase()))
          .toList();
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Courses',
          style: AppTextStyles.headingMedium.copyWith(
            fontSize: 24,
            color: Colors.black87,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(AppConstants.paddingMedium),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.grey.shade200,
                  width: 1.2,
                ),
              ),
              child: const Icon(
                Icons.notifications_outlined,
                color: AppColors.primaryColor,
                size: 20,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          FadeAnimation(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppConstants.paddingLarge,
                vertical: AppConstants.paddingMedium,
              ),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: Colors.grey.shade200,
                    width: 1.2,
                  ),
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: (value) => setState(() {}),
                  decoration: InputDecoration(
                    hintText: 'Search courses...',
                    hintStyle: AppTextStyles.bodyMedium.copyWith(
                      color: Colors.grey.shade400,
                    ),
                    prefixIcon: Icon(
                      Icons.search_outlined,
                      color: Colors.grey.shade400,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                  ),
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: Colors.black87,
                  ),
                ),
              ),
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
                  _buildFilterChip('All Courses', 'all'),
                  const SizedBox(width: 10),
                  _buildFilterChip('My Courses', 'enrolled'),
                ],
              ),
            ),
          ),

          // Courses List
          Expanded(
            child: _filteredCourses.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppConstants.paddingLarge,
                      vertical: AppConstants.paddingMedium,
                    ),
                    itemCount: _filteredCourses.length,
                    itemBuilder: (context, index) {
                      return SlideAnimation(
                        direction: index.isEven
                            ? SlideDirection.fromLeft
                            : SlideDirection.fromRight,
                        child: _buildCourseItem(
                          _filteredCourses[index],
                          index,
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    bool isSelected = _selectedFilter == value;
    return GestureDetector(
      onTap: () => setState(() => _selectedFilter = value),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 10,
        ),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryColor : Colors.white,
          border: Border.all(
            color: isSelected
                ? AppColors.primaryColor
                : Colors.grey.shade200,
            width: 1.2,
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primaryColor.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(
            color: isSelected ? Colors.white : Colors.black87,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  Widget _buildCourseItem(Course course, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
        border: Border.all(
          color: Colors.grey.shade200,
          width: 1.2,
        ),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Opened ${course.title}'),
                backgroundColor: AppColors.primaryColor,
                duration: const Duration(seconds: 1),
              ),
            );
          },
          borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
          child: Padding(
            padding: const EdgeInsets.all(AppConstants.paddingMedium),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Row
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Thumbnail
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        width: 80,
                        height: 80,
                        color: Colors.grey.shade100,
                        child: course.thumbnail != null
                            ? Image.network(
                                course.thumbnail!,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Center(
                                    child: Icon(
                                      Icons.book_outlined,
                                      color: Colors.grey.shade400,
                                    ),
                                  );
                                },
                              )
                            : Center(
                                child: Icon(
                                  Icons.book_outlined,
                                  color: Colors.grey.shade400,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Course Info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            course.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.bodyLarge.copyWith(
                              fontWeight: FontWeight.w700,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'by ${course.instructor}',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: Colors.grey.shade500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(
                                Icons.star_rounded,
                                size: 16,
                                color: Colors.amber,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                course.rating.toStringAsFixed(1),
                                style: AppTextStyles.caption.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                width: 4,
                                height: 4,
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade300,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '${course.videosCount} videos',
                                style: AppTextStyles.caption.copyWith(
                                  color: Colors.grey.shade500,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    if (course.isEnrolled)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Colors.green.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          'Enrolled',
                          style: AppTextStyles.caption.copyWith(
                            color: Colors.green,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                // Tags
                Wrap(
                  spacing: 6,
                  children: course.tags
                      .take(2)
                      .map(
                        (tag) => Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: AppColors.primaryColor
                                  .withOpacity(0.2),
                              width: 0.8,
                            ),
                          ),
                          child: Text(
                            tag,
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.primaryColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(
              Icons.school_outlined,
              size: 40,
              color: AppColors.primaryColor,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'No Courses Found',
            style: AppTextStyles.headingSmall.copyWith(
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try different filters or search',
            style: AppTextStyles.bodySmall.copyWith(
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }
}