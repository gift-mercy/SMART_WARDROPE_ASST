import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/recommendation_model.dart';

class SettingsProvider extends ChangeNotifier {
  static const _outfitPreferenceKey = 'outfit_preference';
  RecommendationPreference _outfitPreference = RecommendationPreference.balanced;

  RecommendationPreference get outfitPreference => _outfitPreference;

  Future<void> initialize() async {
    final preferences = await SharedPreferences.getInstance();
    final stored = preferences.getString(_outfitPreferenceKey);
    _outfitPreference = RecommendationPreference.values.firstWhere(
      (value) => value.name == stored,
      orElse: () => RecommendationPreference.balanced,
    );
    notifyListeners();
  }

  Future<void> setOutfitPreference(RecommendationPreference preference) async {
    _outfitPreference = preference;
    notifyListeners();
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_outfitPreferenceKey, preference.name);
  }

  String get preferenceLabel => switch (_outfitPreference) {
        RecommendationPreference.balanced => 'Balanced',
        RecommendationPreference.formal => 'Prefer formal outfits',
        RecommendationPreference.casual => 'Prefer casual outfits',
        RecommendationPreference.comfortable => 'Prefer comfortable outfits',
      };
}
