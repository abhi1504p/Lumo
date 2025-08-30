import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AISettingsService extends GetxController {
  static const String _aiModeKey = 'ai_mode_enabled';
  
  final RxBool _isAIModeEnabled = false.obs;
  
  bool get isAIModeEnabled => _isAIModeEnabled.value;
  
  @override
  void onInit() {
    super.onInit();
    _loadAISettings();
  }
  
  /// Load AI mode setting from shared preferences
  Future<void> _loadAISettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _isAIModeEnabled.value = prefs.getBool(_aiModeKey) ?? false;
    } catch (e) {
      print('Error loading AI settings: $e');
      _isAIModeEnabled.value = false;
    }
  }
  
  /// Toggle AI mode on/off
  Future<void> toggleAIMode() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _isAIModeEnabled.value = !_isAIModeEnabled.value;
      await prefs.setBool(_aiModeKey, _isAIModeEnabled.value);
      
      // Show feedback to user
      Get.snackbar(
        _isAIModeEnabled.value ? 'AI Mode Enabled' : 'AI Mode Disabled',
        _isAIModeEnabled.value 
            ? 'You are now chatting with AI companion' 
            : 'Switched back to normal chat mode',
        duration: const Duration(seconds: 2),
      );
    } catch (e) {
      print('Error toggling AI mode: $e');
      Get.snackbar(
        'Error',
        'Failed to update AI mode setting',
        duration: const Duration(seconds: 2),
      );
    }
  }
  
  /// Set AI mode state
  Future<void> setAIMode(bool enabled) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _isAIModeEnabled.value = enabled;
      await prefs.setBool(_aiModeKey, enabled);
    } catch (e) {
      print('Error setting AI mode: $e');
    }
  }
  
  /// Get reactive stream of AI mode state
  RxBool get aiModeStream => _isAIModeEnabled;
}
