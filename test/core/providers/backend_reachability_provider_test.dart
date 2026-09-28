import 'package:bayantrack_mobile/core/constants/api_constants.dart';
import 'package:bayantrack_mobile/core/network/dio_provider.dart';
import 'package:bayantrack_mobile/core/providers/backend_reachability_provider.dart';
import 'package:bayantrack_mobile/core/providers/connectivity_provider.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _DioMock extends Mock implements Dio {}

class _OptionsFake extends Fake implements Options {}

class _InitiallyOfflineConnectivity extends ConnectivityNotifier {
  @override
  bool build() => false;
}

void main() {
  setUpAll(() => registerFallbackValue(_OptionsFake()));

  test('connectivity restoration probes Backend separately', () async {
    final dio = _DioMock();
    when(
      () => dio.get(ApiConstants.health, options: any(named: 'options')),
    ).thenAnswer(
      (_) async => Response<dynamic>(
        data: {'status': 'healthy'},
        statusCode: 200,
        requestOptions: RequestOptions(path: ApiConstants.health),
      ),
    );
    final container = ProviderContainer(
      overrides: [
        dioRawProvider.overrideWithValue(dio),
        isOnlineProvider.overrideWith(_InitiallyOfflineConnectivity.new),
      ],
    );
    addTearDown(container.dispose);

    expect(
      container.read(backendReachabilityProvider),
      BackendReachability.unreachable,
    );
    container.read(isOnlineProvider.notifier).setOnline(true);
    await Future<void>.delayed(const Duration(milliseconds: 1));

    expect(
      container.read(backendReachabilityProvider),
      BackendReachability.reachable,
    );
    verify(
      () => dio.get(ApiConstants.health, options: any(named: 'options')),
    ).called(1);
  });

  test('Backend 503 is unavailable despite device connectivity', () async {
    final dio = _DioMock();
    when(
      () => dio.get(ApiConstants.health, options: any(named: 'options')),
    ).thenAnswer(
      (_) async => Response<dynamic>(
        data: {'status': 'unhealthy'},
        statusCode: 503,
        requestOptions: RequestOptions(path: ApiConstants.health),
      ),
    );
    final container = ProviderContainer(
      overrides: [
        dioRawProvider.overrideWithValue(dio),
        isOnlineProvider.overrideWith(_InitiallyOfflineConnectivity.new),
      ],
    );
    addTearDown(container.dispose);
    final reachability = container.read(backendReachabilityProvider.notifier);
    container.read(isOnlineProvider.notifier).setOnline(true);
    await reachability.checkNow();

    expect(container.read(isOnlineProvider), isTrue);
    expect(
      container.read(backendReachabilityProvider),
      BackendReachability.unreachable,
    );
  });
}
