import 'package:flutter/material.dart';
import '../../config/theme.dart';

class TimestampCommentWidget extends StatelessWidget {
  final String timestamp;
  final String content;
  final String authorName;
  final bool isResolved;
  final bool canResolve;
  final VoidCallback? onResolve;

  const TimestampCommentWidget({
    Key? key,
    required this.timestamp,
    required this.content,
    required this.authorName,
    this.isResolved = false,
    this.canResolve = false,
    this.onResolve,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isResolved
              ? AppColors.successColor.withOpacity(0.4)
              : AppColors.borderColor,
        ),
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
              _TimestampBadge(timestamp: timestamp),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  authorName,
                  style: const TextStyle(
                    color: AppColors.textDark,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (isResolved)
                const Icon(
                  Icons.check_circle_rounded,
                  color: AppColors.successColor,
                  size: 20,
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: const TextStyle(
              color: AppColors.textDark,
              fontSize: 14,
              height: 1.4,
            ),
          ),
          if (canResolve && !isResolved) ...[
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: onResolve,
                icon: const Icon(Icons.check_rounded,
                    size: 16, color: AppColors.successColor),
                label: const Text(
                  'Mark Resolved',
                  style: TextStyle(
                    color: AppColors.successColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
                style: TextButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _TimestampBadge extends StatelessWidget {
  final String timestamp;

  const _TimestampBadge({required this.timestamp});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.primaryColor.withOpacity(0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        timestamp,
        style: const TextStyle(
          color: AppColors.primaryColor,
          fontWeight: FontWeight.w700,
          fontSize: 12,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
