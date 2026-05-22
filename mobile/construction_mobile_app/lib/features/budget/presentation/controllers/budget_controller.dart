import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/budget_remote_data_source.dart';

final budgetSummaryProvider =
    FutureProvider.family<Map<String, dynamic>, String>(
  (ref, projectId) async {
    final ds = ref.watch(budgetRemoteDataSourceProvider);
    return ds.getBudgetSummary(projectId);
  },
);

final budgetItemsProvider =
    FutureProvider.family<List<Map<String, dynamic>>, String>(
  (ref, projectId) async {
    final ds = ref.watch(budgetRemoteDataSourceProvider);
    return ds.getBudgetItems(projectId);
  },
);

class BudgetController extends StateNotifier<AsyncValue<void>> {
  final Ref _ref;

  BudgetController(this._ref) : super(const AsyncValue.data(null));

  Future<void> addItem(
      String projectId, double amount, String? description) async {
    state = const AsyncValue.loading();
    try {
      final ds = _ref.read(budgetRemoteDataSourceProvider);
      await ds.addBudgetItem(projectId, amount, description);
      _ref.invalidate(budgetSummaryProvider(projectId));
      _ref.invalidate(budgetItemsProvider(projectId));
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final budgetControllerProvider =
    StateNotifierProvider<BudgetController, AsyncValue<void>>(
  (ref) => BudgetController(ref),
);
