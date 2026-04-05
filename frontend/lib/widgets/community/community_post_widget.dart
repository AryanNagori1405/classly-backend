import 'package:flutter/material.dart';
import '../../config/theme.dart';

class CommunityPostWidget extends StatelessWidget {
  final String content;
  final String authorName;
  final DateTime createdAt;
  final int likesCount;
  final bool isLiked;
  final VoidCallback? onLike;

  const CommunityPostWidget({
    Key? key,
    required this.content,
    required this.authorName,
    required this.createdAt,
    this.likesCount = 0,
    this.isLiked = false,
    this.onLike,
  }) : super(key: key);

  String _relativeTime() {
    final diff = DateTime.now().difference(createdAt);
    if (diff.inMinutes < 1) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: AppColors.primaryColor.withOpacity(0.15),
                child: Text(
                  authorName.isNotEmpty ? authorName[0].toUpperCase() : '?',
                  style: const TextStyle(
                    color: AppColors.primaryColor,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      authorName,
                      style: const TextStyle(
                        color: AppColors.textDark,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                    Text(
                      _relativeTime(),
                      style: const TextStyle(
                        color: AppColors.textLight,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            content,
            style: const TextStyle(
              color: AppColors.textDark,
              fontSize: 14,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 10),
          GestureDetector(
            onTap: onLike,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isLiked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                  size: 18,
                  color: isLiked ? AppColors.errorColor : AppColors.textLight,
                ),
                const SizedBox(width: 4),
                Text(
                  '$likesCount',
                  style: TextStyle(
                    color: isLiked ? AppColors.errorColor : AppColors.textLight,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
