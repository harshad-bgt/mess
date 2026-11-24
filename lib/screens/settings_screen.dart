import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/meal_provider.dart';
import '../providers/settings_provider.dart';
import '../services/notification_service.dart';
import '../utils/app_colors.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  Future<void> _editTotalMeals(BuildContext context, SettingsProvider provider) async {
    final controller = TextEditingController(text: provider.totalMeals.toString());
    final result = await showDialog<int>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Total Prepaid Meals'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Number of Meals',
            hintText: 'e.g. 30',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final val = int.tryParse(controller.text.trim());
              if (val != null && val > 0) {
                Navigator.pop(context, val);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (result != null) {
      await provider.updateTotalMeals(result);
    }
  }

  Future<void> _editAmountPaid(BuildContext context, SettingsProvider provider) async {
    final controller = TextEditingController(text: provider.amountPaid.toStringAsFixed(0));
    final result = await showDialog<double>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Total Amount Paid'),
        content: TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(
            labelText: 'Amount (₹)',
            prefixText: '₹ ',
            hintText: 'e.g. 2000',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final val = double.tryParse(controller.text.trim());
              if (val != null && val >= 0) {
                Navigator.pop(context, val);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (result != null) {
      await provider.updateAmountPaid(result);
    }
  }

  Future<void> _pickReminderTime({
    required BuildContext context,
    required SettingsProvider provider,
    required bool isAfternoon,
  }) async {
    final currentTimeStr = isAfternoon
        ? provider.afternoonReminder
        : provider.eveningReminder;
    
    final parts = currentTimeStr.split(':');
    final initialHour = parts.isNotEmpty ? (int.tryParse(parts[0]) ?? 14) : 14;
    final initialMinute = parts.length > 1 ? (int.tryParse(parts[1]) ?? 0) : 0;

    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: initialHour, minute: initialMinute),
    );

    if (picked != null) {
      final hourStr = picked.hour.toString().padLeft(2, '0');
      final minStr = picked.minute.toString().padLeft(2, '0');
      final newTime = '$hourStr:$minStr';

      if (isAfternoon) {
        await provider.updateAfternoonReminder(newTime);
      } else {
        await provider.updateEveningReminder(newTime);
      }

      if (context.mounted) {
        final mealProvider = context.read<MealProvider>();
        await mealProvider.loadMeals(settingsProvider: provider);
      }
    }
  }

  String _formatTimeDisplay(String timeStr) {
    try {
      final parts = timeStr.split(':');
      final hour = int.parse(parts[0]);
      final minute = int.parse(parts[1]);
      final tod = TimeOfDay(hour: hour, minute: minute);
      final period = tod.period == DayPeriod.am ? 'AM' : 'PM';
      final formattedHour = tod.hourOfPeriod == 0 ? 12 : tod.hourOfPeriod;
      final formattedMinute = tod.minute.toString().padLeft(2, '0');
      return '$formattedHour:$formattedMinute $period';
    } catch (_) {
      return timeStr;
    }
  }

  Future<void> _confirmResetData(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: AppColors.error),
            SizedBox(width: 8),
            Text('Reset Meal Records?'),
          ],
        ),
        content: const Text(
          'This will permanently delete all logged afternoon and evening meals. Your remaining balance will reset to full package. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Reset Everything'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      final mealProvider = context.read<MealProvider>();
      final settingsProvider = context.read<SettingsProvider>();
      await mealProvider.resetAllMeals(settingsProvider);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('All meal records have been reset.'),
            backgroundColor: AppColors.primary,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final settingsProvider = context.watch<SettingsProvider>();
    final mealProvider = context.watch<MealProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Settings',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: AppColors.textDark,
            letterSpacing: -0.5,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        children: [
          // Section: Mess Plan Settings
          _buildSectionHeader('MESS PLAN & BILLING'),
          const SizedBox(height: 8),
          _buildSettingsCard([
            _buildSettingTile(
              title: 'Total Prepaid Meals',
              subtitle: 'Default package meal count',
              trailing: '${settingsProvider.totalMeals} meals',
              icon: Icons.confirmation_number_outlined,
              iconColor: AppColors.primary,
              onTap: () => _editTotalMeals(context, settingsProvider),
            ),
            const Divider(height: 1, indent: 56),
            _buildSettingTile(
              title: 'Amount Paid',
              subtitle: 'Total payment for the package',
              trailing: '₹${settingsProvider.amountPaid.toStringAsFixed(0)}',
              icon: Icons.currency_rupee_rounded,
              iconColor: AppColors.secondaryDark,
              onTap: () => _editAmountPaid(context, settingsProvider),
            ),
            const Divider(height: 1, indent: 56),
            _buildSettingTile(
              title: 'Calculated Cost Per Meal',
              subtitle: 'Amount paid ÷ Total meals',
              trailing: '₹${settingsProvider.costPerMeal.toStringAsFixed(2)}',
              icon: Icons.price_check_rounded,
              iconColor: AppColors.warning,
              onTap: null,
            ),
          ]),
          const SizedBox(height: 24),

          // Section: Notifications & Reminders
          _buildSectionHeader('NOTIFICATIONS & REMINDERS'),
          const SizedBox(height: 8),
          _buildSettingsCard([
            SwitchListTile(
              secondary: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.secondaryLight,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.notifications_active_outlined,
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
              title: const Text(
                'Meal Reminders',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDark,
                ),
              ),
              subtitle: const Text(
                'Receive reminders for unmarked meals',
                style: TextStyle(fontSize: 12, color: AppColors.textMuted),
              ),
              value: settingsProvider.notificationsEnabled,
              activeTrackColor: AppColors.primaryLight,
              activeThumbColor: AppColors.primary,
              onChanged: (val) async {
                await settingsProvider.toggleNotifications(val);
                if (context.mounted) {
                  await mealProvider.loadMeals(settingsProvider: settingsProvider);
                }
              },
            ),
            if (settingsProvider.notificationsEnabled) ...[
              const Divider(height: 1, indent: 56),
              _buildSettingTile(
                title: 'Afternoon Reminder',
                subtitle: 'Daily lunch notification time',
                trailing: _formatTimeDisplay(settingsProvider.afternoonReminder),
                icon: Icons.wb_sunny_outlined,
                iconColor: AppColors.afternoon,
                onTap: () => _pickReminderTime(
                  context: context,
                  provider: settingsProvider,
                  isAfternoon: true,
                ),
              ),
              const Divider(height: 1, indent: 56),
              _buildSettingTile(
                title: 'Evening Reminder',
                subtitle: 'Daily dinner notification time',
                trailing: _formatTimeDisplay(settingsProvider.eveningReminder),
                icon: Icons.nightlight_outlined,
                iconColor: AppColors.evening,
                onTap: () => _pickReminderTime(
                  context: context,
                  provider: settingsProvider,
                  isAfternoon: false,
                ),
              ),
              const Divider(height: 1, indent: 56),
              _buildSettingTile(
                title: 'Test Notification Now',
                subtitle: 'Sends an instant reminder alert',
                trailing: 'Send',
                icon: Icons.send_rounded,
                iconColor: AppColors.primary,
                onTap: () async {
                  await NotificationService.instance.showTestNotification(
                    title: '🍱 Afternoon Meal Reminder',
                    body: "Have you eaten your afternoon meal? Don't forget to update your Mess app!",
                  );
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Test notification sent! Check your notification bar.'),
                        backgroundColor: AppColors.primary,
                      ),
                    );
                  }
                },
              ),
            ],
          ]),
          const SizedBox(height: 24),

          // Section: Data & Storage
          _buildSectionHeader('DATA & RESET'),
          const SizedBox(height: 8),
          _buildSettingsCard([
            _buildSettingTile(
              title: 'Reset All Meal Records',
              subtitle: 'Delete all logged meals and restore remaining balance',
              trailing: 'Reset',
              trailingColor: AppColors.error,
              icon: Icons.delete_outline_rounded,
              iconColor: AppColors.error,
              onTap: () => _confirmResetData(context),
            ),
          ]),
          const SizedBox(height: 24),

          // Section: About App
          _buildSectionHeader('ABOUT APPLICATION'),
          const SizedBox(height: 8),
          _buildSettingsCard([
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.restaurant_rounded,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Mess – Meal Tracker',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textDark,
                            ),
                          ),
                          Text(
                            'Version 1.0.0 • Offline-First',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textMuted,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Mess is an offline-first college mess meal tracker. It stores all data securely on your device using SQLite, calculates remaining balances instantly, and schedules local notifications without requiring any server or internet connection.',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textMuted,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ]),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w700,
        color: AppColors.textLight,
        letterSpacing: 0.8,
      ),
    );
  }

  Widget _buildSettingsCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.015),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: children,
      ),
    );
  }

  Widget _buildSettingTile({
    required String title,
    required String subtitle,
    required String trailing,
    Color? trailingColor,
    required IconData icon,
    required Color iconColor,
    required VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: iconColor.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: iconColor, size: 20),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w700,
          color: AppColors.textDark,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            trailing,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: trailingColor ?? AppColors.primary,
            ),
          ),
          if (onTap != null) ...[
            const SizedBox(width: 4),
            const Icon(
              Icons.chevron_right_rounded,
              color: AppColors.textLight,
              size: 18,
            ),
          ],
        ],
      ),
      onTap: onTap,
    );
  }
}
