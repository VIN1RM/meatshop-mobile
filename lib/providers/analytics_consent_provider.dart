import 'package:flutter/foundation.dart';
import 'package:meatshop_mobile/services/analytics_consent_store.dart';

typedef AnalyticsConsentApplier = Future<void> Function(bool granted);

class AnalyticsConsentProvider extends ChangeNotifier {
  AnalyticsConsentProvider({
    required AnalyticsConsentApplier apply,
    AnalyticsConsentStore store = const AnalyticsConsentStore(),
  }) : _apply = apply,
       _store = store;

  final AnalyticsConsentApplier _apply;
  final AnalyticsConsentStore _store;

  bool _granted = AnalyticsConsentStore.defaultConsent;
  bool _saving = false;
  String? _error;

  bool get granted => _granted;
  bool get saving => _saving;
  String? get error => _error;

  Future<void> load() async {
    _granted = await _store.read();
    notifyListeners();
  }

  Future<bool> setGranted(bool granted) async {
    if (_saving) return false;
    final previous = _granted;
    _granted = granted;
    _saving = true;
    _error = null;
    notifyListeners();
    try {
      await _store.write(granted);
      await _apply(granted);
      return true;
    } catch (error) {
      debugPrint('[AnalyticsConsentProvider] save error: $error');
      _granted = previous;
      await _store.write(previous).catchError((_) {});
      _error = 'Não foi possível salvar sua escolha. Tente novamente.';
      return false;
    } finally {
      _saving = false;
      notifyListeners();
    }
  }
}
