import 'package:flutter/material.dart';
import '../utils/app_colors.dart';

enum MealType { afternoon, evening }

class MealCard extends StatelessWidget {
  final MealType type;
  final bool isMarked;
  final ValueChanged<bool?> onChanged;
  final bool compact;

  const MealCard({
    super.key,
    required this.type,
    required this.isMarked,
    required this.onChanged,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final bool isAfternoon = type == MealType.afternoon;
    final String title = isAfternoon ? 'Afternoon Meal' : 'Evening Meal';
    final String subtitle = isAfternoon ? 'Lunch • 1:00 PM - 3:00 PM' : 'Dinner • 7:30 PM - 9:30 PM';
    final IconData iconData = isAfternoon ? Icons.wb_sunny_rounded : Icons.nightlight_round;
    final Color iconColor = isAfternoon ? AppColors.afternoon : AppColors.evening;
    final Color activeBorder = isAfternoon ? AppColors.afternoon : AppColors.evening;
    final Color activeBg = isAfternoon ? AppColors.afternoonBg : AppColors.eveningBg;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => onChanged(!isMarked),
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          padding: EdgeInsets.symmetric(
            horizontal: 16,
            vertical: compact ? 12 : 16,
          ),
          decoration: BoxDecoration(
            color: isMarked ? activeBg : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isMarked ? activeBorder : AppColors.border,
              width: isMarked ? 2 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              // Meal Icon
              Container(
                width: compact ? 42 : 48,
                height: compact ? 42 : 48,
                decoration: BoxDecoration(
                  color: isMarked
                      ? iconColor.withValues(alpha: 0.2)
                      : Colors.grey.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  iconData,
                  color: isMarked ? iconColor : AppColors.textMuted,
                  size: compact ? 22 : 26,
                ),
              ),
              const SizedBox(width: 14),

              // Title & Status
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            fontSize: compact ? 15 : 16,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textDark,
                          ),
                        ),
                        if (isMarked) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.secondaryLight,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              'Consumed',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      isMarked ? 'Recorded • Tap to unmark' : subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: isMarked ? AppColors.secondaryDark : AppColors.textMuted,
                        fontWeight: isMarked ? FontWeight.w600 : FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),

              // Custom styled Checkbox
              Transform.scale(
                scale: 1.15,
                child: Checkbox(
                  value: isMarked,
                  activeColor: isAfternoon ? AppColors.afternoon : AppColors.evening,
                  checkColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                  side: const BorderSide(color: AppColors.textLight, width: 1.5),
                  onChanged: onChanged,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
