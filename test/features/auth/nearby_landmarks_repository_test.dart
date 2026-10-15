import 'package:bayantrack_mobile/core/constants/api_constants.dart';
import 'package:bayantrack_mobile/core/domain/failures.dart';
import 'package:bayantrack_mobile/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _DioMock extends Mock implements Dio {}

void main() {
  late _DioMock dio;
  late AuthRepositoryImpl repository;

  setUp(() {
    dio = _DioMock();
    repository = AuthRepositoryImpl(dio);
  });

  void respond(Map<String, dynamic> body) {
    when(
      () => dio.get(
        ApiConstants.nearbyLandmarks,
        queryParameters: any(named: 'queryParameters'),
      ),
    ).thenAnswer(
      (_) async => Response(
        data: body,
        statusCode: 200,
        requestOptions: RequestOptions(path: ApiConstants.nearbyLandmarks),
      ),
    );
  }

  test(
    'maps nearby landmark contract and sends the selected coordinates',
    () async {
      respond({
        'radius_meters': 250,
        'landmarks': [
          {
            'name': 'Market Road',
            'distance_meters': 12.5,
            'category': 'residential',
          },
        ],
      });

      final result = await repository.getNearbyLandmarks(
        latitude: 15.974355,
        longitude: 120.569434,
      );
      final landmark = result.dataOrNull!.single;
      expect(landmark.name, 'Market Road');
      expect(landmark.distanceMeters, 12.5);
      expect(landmark.category, 'residential');
      verify(
        () => dio.get(
          ApiConstants.nearbyLandmarks,
          queryParameters: {'latitude': 15.974355, 'longitude': 120.569434},
        ),
      ).called(1);
    },
  );

  test(
    'an empty successful lookup remains distinct from provider outage',
    () async {
      respond({'radius_meters': 250, 'landmarks': []});
      final result = await repository.getNearbyLandmarks(
        latitude: 15,
        longitude: 120,
      );
      expect(result.isSuccess, isTrue);
      expect(result.dataOrNull, isEmpty);
    },
  );

  test(
    '503 is a failure and the same pin can recover on the next lookup',
    () async {
      final options = RequestOptions(path: ApiConstants.nearbyLandmarks);
      when(
        () => dio.get(
          ApiConstants.nearbyLandmarks,
          queryParameters: any(named: 'queryParameters'),
        ),
      ).thenThrow(
        DioException(
          requestOptions: options,
          type: DioExceptionType.badResponse,
          response: Response(
            requestOptions: options,
            statusCode: 503,
            data: {'code': 'nearby_landmarks_unavailable', 'landmarks': []},
          ),
        ),
      );
      final failed = await repository.getNearbyLandmarks(
        latitude: 15,
        longitude: 120,
      );
      expect(failed.failureOrNull, isA<ServerFailure>());
      expect(failed.dataOrNull, isNull);

      respond({
        'radius_meters': 250,
        'landmarks': [
          {
            'name': 'Recovered School',
            'distance_meters': 0,
            'category': 'school',
          },
        ],
      });
      final recovered = await repository.getNearbyLandmarks(
        latitude: 15,
        longitude: 120,
      );
      expect(recovered.dataOrNull!.single.name, 'Recovered School');
    },
  );
}
