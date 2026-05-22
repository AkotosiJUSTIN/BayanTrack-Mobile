import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../core/constants/urdaneta_barangays.dart';
import '../../auth/auth_di.dart';
import '../data/auth_models.dart';

part 'barangays_provider.g.dart';

/// Provider that fetches and caches the list of barangays from the API.
/// Used by the new report screen for the location dropdown.
@riverpod
class Barangays extends _$Barangays {
  @override
  FutureOr<List<BarangayModel>> build() async {
    unawaited(_refreshFromApi());
    return bundledUrdanetaBarangays;
  }

  Future<List<BarangayModel>> _fetchFromApiOrBundle() async {
    final authRepo = ref.read(authRepositoryProvider);
    final result = await authRepo.getBarangays();
    
    return result.when(
      success: (barangays) => barangays,
      failure: (_) => bundledUrdanetaBarangays,
    );
  }

  Future<void> _refreshFromApi() async {
    final barangays = await _fetchFromApiOrBundle();
    state = AsyncValue.data(barangays);
  }
  
  /// Refresh barangays list
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(_fetchFromApiOrBundle);
  }
}
