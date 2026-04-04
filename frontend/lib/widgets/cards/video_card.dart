import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../config/constants.dart';
import '../../models/video_model.dart';
import '../animations/scale_animation.dart';

class VideoCard extends StatelessWidget {
  final Video video;
  final VoidCallback onTap;

  const VideoCard({
    Key? key,
    required this.video,
    required this.onTap,
  }) : super(key: key);

  String _formatDuration(int seconds) {
    int minutes = seconds ~/ 60;
    int secs = seconds % 60;
    return '$minutes\'m ${secs}s';
  }

  @override
  Widget build(BuildContext context) {
    return ScaleAnimation(
      beginScale: 0.8,
      child: GestureDetector(
        onTap: onTap,
        child: Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Thumbnail with play button
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(AppConstants.radiusLarge),
                      topRight: Radius.circular(AppConstants.radiusLarge),
                    ),
                    child: Container(
                      height: 140,
                      width: double.infinity,
                      color: AppColors.backgroundColor,
                      child: video.thumbnail != null
                          ? Image.network(
                              video.thumbnail!,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return _buildPlaceholder();
                              },
                            )
                          : _buildPlaceholder(),
                    ),
                  ),
                  // Play button overlay
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.3),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.play_circle_filled,
                          size: 48,
                          color: AppColors.surfaceColor,
                        ),
                      ),
                    ),
                  ),
                  // Duration badge
                  if (video.duration > 0)
                    Positioned(
                      bottom: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.7),
                          borderRadius: BorderRadius.circular(
                            AppConstants.radiusSmall,
                          ),
                        ),
                        child: Text(
                          _formatDuration(video.duration),
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.surfaceColor,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              // Content
              Padding(
                padding: const EdgeInsets.all(AppConstants.paddingMedium),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text(
                      video.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.headingSmall,
                    ),
                    const SizedBox(height: 4),
                    // Instructor and course
                    Text(
                      '${video.instructor} • ${video.courseName}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textLight,
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Stats
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.visibility,
                              size: 14,
                              color: AppColors.textLight,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              video.views.toString(),
                              style: AppTextStyles.caption.copyWith(
                                color: AppColors.textLight,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            const Icon(
                              Icons.thumb_up,
                              size: 14,
                              color: AppColors.accentColor,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              video.upvotes.toString(),
                              style: AppTextStyles.caption.copyWith(
                                color: AppColors.accentColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            const Icon(
                              Icons.download,
                              size: 14,
                              color: AppColors.secondaryColor,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              video.downloads.toString(),
                              style: AppTextStyles.caption.copyWith(
                                color: AppColors.secondaryColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
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
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      color: AppColors.backgroundColor,
      child: const Center(
        child: Icon(
          Icons.video_library,
          size: 48,
          color: AppColors.textLight,
        ),
      ),
    );
  }
}