import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../models/recommendation_model.dart';
import '../../providers/calendar_provider.dart';
import '../../providers/settings_provider.dart';
import '../../providers/theme_provider.dart';
import '../../providers/weather_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _sectionTitle('Appearance'),
            Consumer<ThemeProvider>(
              builder: (context, theme, _) => Card(
                child: SwitchListTile(
                  secondary: const Icon(Icons.dark_mode_outlined),
                  title: const Text('Dark Mode'),
                  subtitle: const Text('Use a darker colour scheme'),
                  value: theme.isDarkMode,
                  onChanged: theme.setDarkMode,
                ),
              ),
            ),
            _sectionTitle('Calendar'),
            Consumer<CalendarProvider>(
              builder: (context, calendar, _) => Card(
                child: ListTile(
                  leading: const Icon(Icons.calendar_month_outlined),
                  title: const Text('Calendar Access'),
                  subtitle: Text(calendar.hasPermission
                      ? 'Enabled — upcoming events are available locally.'
                      : 'Not enabled'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.pushNamed(context, '/calendar'),
                ),
              ),
            ),
            _sectionTitle('Weather'),
            Consumer<WeatherProvider>(
              builder: (context, weather, _) => Card(
                child: ListTile(
                  leading: const Icon(Icons.location_on_outlined),
                  title: const Text('Weather Location'),
                  subtitle: Text(weather.weather?.cityName ?? 'Not available yet'),
                  trailing: TextButton(
                    onPressed: weather.isLoading ? null : weather.refreshWeather,
                    child: const Text('Refresh'),
                  ),
                ),
              ),
            ),
            _sectionTitle('Recommendation Preferences'),
            Consumer<SettingsProvider>(
              builder: (context, settings, _) => Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Outfit style'),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: RecommendationPreference.values.map((preference) {
                          return ChoiceChip(
                            label: Text(_labelFor(preference)),
                            selected: settings.outfitPreference == preference,
                            onSelected: (_) => settings.setOutfitPreference(preference),
                            selectedColor: AppColors.primaryLight,
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 8),
                      Text(settings.preferenceLabel,
                          style: const TextStyle(color: AppColors.textSecondary)),
                    ],
                  ),
                ),
              ),
            ),
            _sectionTitle('About'),
            const Card(
              child: ListTile(
                leading: Icon(Icons.info_outline),
                title: Text('Smart Wardrobe Assistant'),
                subtitle: Text('Version 1.0.0\nOutfit ideas from your wardrobe, weather, and schedule.'),
                isThreeLine: true,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) => Padding(
        padding: const EdgeInsets.only(top: 16, bottom: 8),
        child: Text(title.toUpperCase(),
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              color: AppColors.textSecondary,
            )),
      );

  String _labelFor(RecommendationPreference preference) => switch (preference) {
        RecommendationPreference.balanced => 'Balanced',
        RecommendationPreference.formal => 'Formal',
        RecommendationPreference.casual => 'Casual',
        RecommendationPreference.comfortable => 'Comfortable',
      };
}
