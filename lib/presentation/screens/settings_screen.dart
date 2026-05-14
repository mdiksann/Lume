import 'package:flutter/material.dart';
import 'package:lume/core/constants/app_colors.dart';
import 'package:lume/core/constants/app_strings.dart';
import 'package:lume/services/notification_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = false;
  TimeOfDay _reminderTime = const TimeOfDay(hour: 20, minute: 0);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(AppStrings.settings, style: theme.textTheme.titleLarge),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        physics: const BouncingScrollPhysics(),
        children: [
          // Notifications section
          Text(AppStrings.notifications, style: theme.textTheme.headlineSmall),
          const SizedBox(height: 16),
          Container(
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: isDark ? AppColors.darkDivider : AppColors.lightDivider),
            ),
            child: Column(children: [
              SwitchListTile(
                title: Text(AppStrings.setReminder, style: theme.textTheme.titleSmall),
                subtitle: Text('Get a daily nudge to read', style: theme.textTheme.bodySmall),
                value: _notificationsEnabled,
                activeTrackColor: isDark ? AppColors.darkAccent : AppColors.lightAccent,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                onChanged: (val) async {
                  setState(() => _notificationsEnabled = val);
                  if (val) {
                    await NotificationService().scheduleDailyReminder(_reminderTime);
                  } else {
                    await NotificationService().cancelReminder();
                  }
                },
              ),
              if (_notificationsEnabled) ...[
                Divider(height: 1, color: isDark ? AppColors.darkDivider : AppColors.lightDivider),
                ListTile(
                  title: Text(AppStrings.reminderTime, style: theme.textTheme.titleSmall),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkAccentMuted : AppColors.lightAccentMuted.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(_reminderTime.format(context), style: theme.textTheme.labelLarge),
                  ),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  onTap: () async {
                    final picked = await showTimePicker(context: context, initialTime: _reminderTime);
                    if (picked != null) {
                      setState(() => _reminderTime = picked);
                      await NotificationService().scheduleDailyReminder(picked);
                    }
                  },
                ),
              ],
            ]),
          ),
          const SizedBox(height: 32),
          // About section
          Text('About', style: theme.textTheme.headlineSmall),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: isDark ? AppColors.darkDivider : AppColors.lightDivider),
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(AppStrings.appName, style: theme.textTheme.titleMedium),
              const SizedBox(height: 4),
              Text(AppStrings.appTagline, style: theme.textTheme.bodyMedium),
              const SizedBox(height: 12),
              Text('Version 1.0.0', style: theme.textTheme.bodySmall),
            ]),
          ),
        ],
      ),
    );
  }
}
