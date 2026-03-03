import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../auth/auth_di.dart';
import '../data/auth_models.dart';

part 'barangays_provider.g.dart';

/// Provider that fetches and caches the list of barangays from the API.
/// Used by the new report screen for the location dropdown.
@riverpod
class Barangays extends _$Barangays {
  @override
  FutureOr<List<BarangayModel>> build() async {
    // Fetch barangays from the repository
    final authRepo = ref.read(authRepositoryProvider);
    final result = await authRepo.getBarangays();
    
    return result.when(
      success: (barangays) => barangays,
      failure: (failure) => throw failure,
    );
  }
  
  /// Refresh barangays list
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final authRepo = ref.read(authRepositoryProvider);
      final result = await authRepo.getBarangays();
      return result.when(
        success: (barangays) => barangays,
        failure: (failure) => throw failure,
      );
    });
  }
}
