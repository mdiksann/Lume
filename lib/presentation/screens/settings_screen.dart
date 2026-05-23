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
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(AppStrings.settings, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        physics: const BouncingScrollPhysics(),
        children: [

          
          // Reading Reminders
          Text('Preferences', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: isDark ? Colors.white70 : Colors.black87)),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0x144A5260), width: 0.8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              children: [
                SwitchListTile(
                  title: Text(AppStrings.setReminder, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
                  subtitle: Text('Get a daily nudge to read', style: theme.textTheme.bodySmall),
                  value: _notificationsEnabled,
                  activeColor: Colors.white,
                  activeTrackColor: AppColors.lightAccent,
                  inactiveThumbColor: isDark ? Colors.grey[400] : Colors.white,
                  inactiveTrackColor: isDark ? Colors.grey[800] : Colors.grey[300],
                  secondary: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.lightAccent.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.notifications_active_rounded, color: AppColors.lightAccent),
                  ),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
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
                  Divider(height: 1, color: isDark ? AppColors.darkDivider : AppColors.lightDivider, indent: 64),
                  ListTile(
                    title: Text(AppStrings.reminderTime, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.lightAccent.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: Text(_reminderTime.format(context), style: theme.textTheme.labelLarge?.copyWith(color: AppColors.lightAccent)),
                    ),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    onTap: () async {
                      final picked = await showTimePicker(context: context, initialTime: _reminderTime);
                      if (picked != null) {
                        setState(() => _reminderTime = picked);
                        await NotificationService().scheduleDailyReminder(picked);
                      }
                    },
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 32),
          
          // Lume Core Information
          Text('Lume Core Information', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: isDark ? Colors.white70 : Colors.black87)),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0x144A5260), width: 0.8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkAccentMuted : AppColors.lightAccentMuted.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.info_outline_rounded, color: AppColors.lightAccent),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(AppStrings.appName, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                          Text('Version 2.0 Neo-Bibliophile', style: theme.textTheme.bodySmall),
                        ],
                      ),
                    ),
                  ],
                ),

              ],
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }


}
