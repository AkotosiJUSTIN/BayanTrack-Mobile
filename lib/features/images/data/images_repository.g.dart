// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'images_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(imagesRepository)
final imagesRepositoryProvider = ImagesRepositoryProvider._();

final class ImagesRepositoryProvider
    extends
        $FunctionalProvider<
          ImagesRepository,
          ImagesRepository,
          ImagesRepository
        >
    with $Provider<ImagesRepository> {
  ImagesRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'imagesRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$imagesRepositoryHash();

  @$internal
  @override
  $ProviderElement<ImagesRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  ImagesRepository create(Ref ref) {
    return imagesRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ImagesRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ImagesRepository>(value),
    );
  }
}

String _$imagesRepositoryHash() => r'eeb9e165ef6d2e58c316be03f4fa7c51a8095bf9';
