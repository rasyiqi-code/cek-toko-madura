import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/license_service.dart';

class TrialProvider with ChangeNotifier {
  final SharedPreferences _prefs;
  static const String _trialStartKey = 'trial_start_date';
  static const String _licenseKey = 'license_key';
  static const String _isLicensedKey = 'is_licensed';

  bool _isLicensed = false;
  DateTime? _trialStartDate;
  bool _isLoading = true;

  TrialProvider(this._prefs) {
    _init();
  }

  bool get isLicensed => _isLicensed;
  bool get isLoading => _isLoading;
  
  bool get isTrialActive {
    if (_isLicensed) return true;
    if (_trialStartDate == null) return true;
    
    final now = DateTime.now();
    final difference = now.difference(_trialStartDate!).inDays;
    return difference < 14;
  }

  int get remainingDays {
    if (_isLicensed) return 999;
    if (_trialStartDate == null) return 14;
    
    final now = DateTime.now();
    final difference = now.difference(_trialStartDate!).inDays;
    final remaining = 14 - difference;
    return remaining > 0 ? remaining : 0;
  }

  void _init() {
    _isLicensed = _prefs.getBool(_isLicensedKey) ?? false;
    final trialStartStr = _prefs.getString(_trialStartKey);
    
    if (trialStartStr == null) {
      _trialStartDate = DateTime.now();
      _prefs.setString(_trialStartKey, _trialStartDate!.toIso8601String());
    } else {
      _trialStartDate = DateTime.parse(trialStartStr);
    }
    
    _isLoading = false;
    notifyListeners();
  }

  Future<bool> activateLicense(String key) async {
    _isLoading = true;
    notifyListeners();

    final isValid = await LicenseService.verifyLicense(key);
    
    if (isValid) {
      _isLicensed = true;
      await _prefs.setBool(_isLicensedKey, true);
      await _prefs.setString(_licenseKey, key);
    }

    _isLoading = false;
    notifyListeners();
    return isValid;
  }
}
