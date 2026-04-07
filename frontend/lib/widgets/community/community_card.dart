import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../animations/fade_animation.dart';

class CommunityCard extends StatelessWidget {
  final String name;
  final String description;
  final int memberCount;
  final bool isPrivate;
  final String category;
  final VoidCallback onTap;

  const CommunityCard({
    Key? key,
    required this.name,
    required this.description,
    required this.memberCount,
    required this.isPrivate,
    required this.category,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FadeAnimation(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 6),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.borderColor),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _CategoryIcon(category: category),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            name,
                            style: const TextStyle(
                              color: AppColors.textDark,
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        _VisibilityBadge(isPrivate: isPrivate),
                      ],
                    ),
                    if (description.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        description,
                        style: const TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 13,
                          height: 1.4,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.people_outline_rounded,
                            size: 14, color: AppColors.textLight),
                        const SizedBox(width: 4),
                        Text(
                          '$memberCount ${memberCount == 1 ? 'member' : 'members'}',
                          style: const TextStyle(
                            color: AppColors.textLight,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
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
    );
  }
}

class _CategoryIcon extends StatelessWidget {
  final String category;

  const _CategoryIcon({required this.category});

  IconData _icon() {
    switch (category.toLowerCase()) {
      case 'study':
        return Icons.menu_book_rounded;
      case 'project':
        return Icons.work_outline_rounded;
      case 'announcement':
        return Icons.campaign_outlined;
      default:
        return Icons.groups_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: AppColors.primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(_icon(), color: AppColors.primaryColor, size: 24),
    );
  }
}

class _VisibilityBadge extends StatelessWidget {
  final bool isPrivate;

  const _VisibilityBadge({required this.isPrivate});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: isPrivate
            ? AppColors.warningColor.withOpacity(0.12)
            : AppColors.successColor.withOpacity(0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        isPrivate ? 'Private' : 'Public',
        style: TextStyle(
          color: isPrivate ? AppColors.warningColor : AppColors.successColor,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
