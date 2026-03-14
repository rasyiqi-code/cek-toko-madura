import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cek_toko_madura/providers/trial_provider.dart';

void main() {
  group('TrialProvider Logic Tests', () {
    late SharedPreferences prefs;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      prefs = await SharedPreferences.getInstance();
    });

    test('New install should start trial with 14 days remaining', () async {
      final provider = TrialProvider(prefs);
      
      expect(provider.isLicensed, false);
      expect(provider.isTrialActive, true);
      expect(provider.remainingDays, 14);
    });

    test('Trial should be active if less than 14 days passed', () async {
      final startDate = DateTime.now().subtract(const Duration(days: 10));
      await prefs.setString('trial_start_date', startDate.toIso8601String());
      
      final provider = TrialProvider(prefs);
      
      expect(provider.isTrialActive, true);
      expect(provider.remainingDays, 4);
    });

    test('Trial should expire if 14 days or more passed', () async {
      final startDate = DateTime.now().subtract(const Duration(days: 15));
      await prefs.setString('trial_start_date', startDate.toIso8601String());
      
      final provider = TrialProvider(prefs);
      
      expect(provider.isTrialActive, false);
      expect(provider.remainingDays, 0);
    });

    test('Licensed users should bypass trial check', () async {
      await prefs.setBool('is_licensed', true);
      await prefs.setString('trial_start_date', DateTime.now().subtract(const Duration(days: 20)).toIso8601String());
      
      final provider = TrialProvider(prefs);
      
      expect(provider.isLicensed, true);
      expect(provider.isTrialActive, true); // Active means "can use app"
      expect(provider.remainingDays, 999);
    });
  });
}
