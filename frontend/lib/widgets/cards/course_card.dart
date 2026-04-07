import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../config/constants.dart';

class CourseCard extends StatelessWidget {
  final String title;
  final String instructor;
  final String? imageUrl;
  final int studentCount;
  final double rating;
  final VoidCallback onTap;

  const CourseCard({
    Key? key,
    required this.title,
    required this.instructor,
    this.imageUrl,
    required this.studentCount,
    required this.rating,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
          color: Colors.white,
          border: Border.all(
            color: Colors.grey.shade200,
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image
                Container(
                  height: 150,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(AppConstants.radiusLarge),
                      topRight: Radius.circular(AppConstants.radiusLarge),
                    ),
                    color: Colors.grey.shade100,
                  ),
                  child: imageUrl != null
                      ? Image.network(
                          imageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Center(
                              child: Icon(
                                Icons.school,
                                size: 50,
                                color: Colors.grey.shade400,
                              ),
                            );
                          },
                        )
                      : Center(
                          child: Icon(
                            Icons.school,
                            size: 50,
                            color: Colors.grey.shade400,
                          ),
                        ),
                ),

                // Content
                Padding(
                  padding: const EdgeInsets.all(AppConstants.paddingMedium),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.bodyLarge.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppColors.textDark,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'by $instructor',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textLight,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.star_rounded,
                                size: 16,
                                color: Colors.amber,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                rating.toStringAsFixed(1),
                                style: AppTextStyles.caption.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textDark,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            '$studentCount students',
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.textLight,
                            ),
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
    );
  }
}