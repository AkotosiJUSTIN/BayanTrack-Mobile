import 'dart:async';

import 'package:bayantrack_mobile/core/constants/urdaneta_barangays.dart';
import 'package:bayantrack_mobile/core/domain/result.dart';
import 'package:bayantrack_mobile/features/auth/auth_di.dart';
import 'package:bayantrack_mobile/features/auth/data/auth_models.dart';
import 'package:bayantrack_mobile/features/auth/domain/auth_repository.dart';
import 'package:bayantrack_mobile/features/auth/presentation/barangays_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _AuthRepositoryMock extends Mock implements AuthRepository {}

void main() {
  test(
    'municipality refresh completion is ignored after auto-dispose',
    () async {
      final repository = _AuthRepositoryMock();
      final pending = Completer<Result<List<BarangayModel>>>();
      when(
        () => repository.getBarangays(municipalityId: defaultMunicipalityId),
      ).thenAnswer((_) => pending.future);

      final provider = municipalityBarangaysProvider(defaultMunicipalityId);
      final container = ProviderContainer(
        overrides: [authRepositoryProvider.overrideWithValue(repository)],
      );
      addTearDown(container.dispose);

      expect(await container.read(provider.future), bundledUrdanetaBarangays);
      await container.pump();
      expect(container.exists(provider), isFalse);

      pending.complete(Success(bundledUrdanetaBarangays));
      await Future<void>.delayed(Duration.zero);
      await container.pump();

      expect(container.exists(provider), isFalse);
      verify(
        () => repository.getBarangays(municipalityId: defaultMunicipalityId),
      ).called(1);
    },
  );
}
