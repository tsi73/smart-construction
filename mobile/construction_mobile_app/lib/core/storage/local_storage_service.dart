import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'database_service.dart';

abstract class LocalStorageService {
  Future<void> init();
  // We can add specific methods later, but for now, let's provide access to the database or a fallback
}

class SqliteLocalStorageService implements LocalStorageService {
  final DatabaseService _databaseService;
  SqliteLocalStorageService(this._databaseService);

  @override
  Future<void> init() async {
    await _databaseService.database;
  }
}

class WebLocalStorageFallbackService implements LocalStorageService {
  @override
  Future<void> init() async {
    // No-op for web fallback
    debugPrint(
        'WebLocalStorageFallbackService initialized (Limited offline mode)');
  }
}

final localStorageServiceProvider = Provider<LocalStorageService>((ref) {
  if (kIsWeb) {
    return WebLocalStorageFallbackService();
  }
  return SqliteLocalStorageService(ref.watch(databaseServiceProvider));
});
