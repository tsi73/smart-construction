import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:construction_mobile_app/features/team/data/repositories/contractor_repository_impl.dart';
import 'package:construction_mobile_app/features/team/domain/repositories/contractor_repository.dart';
import 'package:construction_mobile_app/features/team/domain/entities/contractor.dart';
import 'package:construction_mobile_app/core/errors/failures.dart';
import 'package:construction_mobile_app/features/auth/presentation/providers/auth_provider.dart';

class ContractorState {
  final bool isLoading;
  final List<Contractor> contractors;
  final String? error;

  ContractorState({
    this.isLoading = false,
    this.contractors = const [],
    this.error,
  });

  ContractorState copyWith({
    bool? isLoading,
    List<Contractor>? contractors,
    String? error,
  }) {
    return ContractorState(
      isLoading: isLoading ?? this.isLoading,
      contractors: contractors ?? this.contractors,
      error: error,
    );
  }
}

class ContractorController extends StateNotifier<ContractorState> {
  final ContractorRepository _repository;
  final Ref _ref;

  ContractorController(this._repository, this._ref) : super(ContractorState()) {
    loadContractors();
  }

  Future<void> loadContractors() async {
    state = state.copyWith(isLoading: true, error: null);
    final result = await _repository.getContractors();
    result.fold(
      (failure) {
        if (failure is AuthFailure) {
          _ref.read(authProvider.notifier).handleSessionExpired();
        }
        state = state.copyWith(isLoading: false, error: failure.message);
      },
      (contractors) {
        state = state.copyWith(isLoading: false, contractors: contractors);
      },
    );
  }

  Future<bool> createContractor(String name) async {
    state = state.copyWith(isLoading: true, error: null);
    final result = await _repository.createContractor(name);
    return result.fold(
      (failure) {
        if (failure is AuthFailure) {
          _ref.read(authProvider.notifier).handleSessionExpired();
        }
        state = state.copyWith(isLoading: false, error: failure.message);
        return false;
      },
      (_) {
        loadContractors();
        return true;
      },
    );
  }

  Future<bool> updateContractor(String contractorId, String? name) async {
    state = state.copyWith(isLoading: true, error: null);
    final result = await _repository.updateContractor(contractorId, name);
    return result.fold(
      (failure) {
        if (failure is AuthFailure) {
          _ref.read(authProvider.notifier).handleSessionExpired();
        }
        state = state.copyWith(isLoading: false, error: failure.message);
        return false;
      },
      (_) {
        loadContractors();
        return true;
      },
    );
  }

  Future<bool> deleteContractor(String contractorId) async {
    state = state.copyWith(isLoading: true, error: null);
    final result = await _repository.deleteContractor(contractorId);
    return result.fold(
      (failure) {
        if (failure is AuthFailure) {
          _ref.read(authProvider.notifier).handleSessionExpired();
        }
        state = state.copyWith(isLoading: false, error: failure.message);
        return false;
      },
      (_) {
        loadContractors();
        return true;
      },
    );
  }
}

final contractorControllerProvider =
    StateNotifierProvider<ContractorController, ContractorState>((ref) {
  return ContractorController(
    ref.watch(contractorRepositoryProvider),
    ref,
  );
});
