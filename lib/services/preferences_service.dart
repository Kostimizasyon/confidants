import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data_models/ai_model_config.dart';

class PreferencesService {
  PreferencesService._();

  static final PreferencesService instance = PreferencesService._();

  static const String _keyIsDarkMode = 'is_dark_mode';
  static const String _keyRequireFingerprintLock = 'require_fingerprint_lock';
  static const String _keyIsAiEnabled = 'is_ai_enabled';
  static const String _keySelectedAiModel = 'selected_ai_model';
  static const String _keyCustomAiModelPath = 'custom_ai_model_path';

  SharedPreferences? _prefs;

  final ValueNotifier<bool> isDarkModeNotifier = ValueNotifier<bool>(true);
  final ValueNotifier<bool> requireFingerprintLockNotifier =
      ValueNotifier<bool>(false);
  final ValueNotifier<bool> isAiEnabledNotifier = ValueNotifier<bool>(false);
  final ValueNotifier<String> selectedModelIdNotifier =
      ValueNotifier<String>(AiModelConfig.idQwen25HalfB);
  final ValueNotifier<String?> customModelPathNotifier =
      ValueNotifier<String?>(null);

  Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
    isDarkModeNotifier.value = _prefs!.getBool(_keyIsDarkMode) ?? true;
    requireFingerprintLockNotifier.value =
        _prefs!.getBool(_keyRequireFingerprintLock) ?? false;
    isAiEnabledNotifier.value = _prefs!.getBool(_keyIsAiEnabled) ?? false;
    selectedModelIdNotifier.value =
        _prefs!.getString(_keySelectedAiModel) ?? AiModelConfig.idQwen25HalfB;
    customModelPathNotifier.value = _prefs!.getString(_keyCustomAiModelPath);
  }

  bool get isDarkMode => isDarkModeNotifier.value;

  bool get requireFingerprintLock => requireFingerprintLockNotifier.value;

  bool get isAiEnabled => isAiEnabledNotifier.value;

  String get selectedModelId => selectedModelIdNotifier.value;

  String? get customModelPath => customModelPathNotifier.value;

  AiModelConfig get activeAiModel => AiModelConfig.resolve(
        selectedId: selectedModelIdNotifier.value,
        customPath: customModelPathNotifier.value,
      );

  Future<void> setDarkMode(bool value) async {
    final prefs = _prefs ?? await SharedPreferences.getInstance();
    await prefs.setBool(_keyIsDarkMode, value);
    isDarkModeNotifier.value = value;
  }

  Future<void> setRequireFingerprintLock(bool value) async {
    final prefs = _prefs ?? await SharedPreferences.getInstance();
    await prefs.setBool(_keyRequireFingerprintLock, value);
    requireFingerprintLockNotifier.value = value;
  }

  Future<void> setAiEnabled(bool value) async {
    final prefs = _prefs ?? await SharedPreferences.getInstance();
    await prefs.setBool(_keyIsAiEnabled, value);
    isAiEnabledNotifier.value = value;
  }

  Future<void> setSelectedModelId(String modelId) async {
    final prefs = _prefs ?? await SharedPreferences.getInstance();
    await prefs.setString(_keySelectedAiModel, modelId);
    selectedModelIdNotifier.value = modelId;
  }

  Future<void> setCustomModelPath(String? path) async {
    final prefs = _prefs ?? await SharedPreferences.getInstance();
    if (path == null || path.trim().isEmpty) {
      await prefs.remove(_keyCustomAiModelPath);
      customModelPathNotifier.value = null;
    } else {
      final cleaned = path.trim();
      await prefs.setString(_keyCustomAiModelPath, cleaned);
      customModelPathNotifier.value = cleaned;
    }
  }
}
