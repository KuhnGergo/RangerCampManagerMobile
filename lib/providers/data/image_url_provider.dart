import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mastercs_mobile/core/api/api.dart';
import 'package:mastercs_mobile/repositories/image_repository.dart';

final imageUrlProvider = Provider<ImageUrlProvider>((ref) {
  final apiConfig = ref.watch(apiConfigProvider);
  final imageRepository = ref.watch(imageRepositoryProvider);
  return ImageUrlProvider(
    apiConfig: apiConfig,
    imageRepository: imageRepository,
  );
});

class ImageUrlProvider {
  final ApiConfig apiConfig;
  final ImageRepository imageRepository;

  ImageUrlProvider({required this.apiConfig, required this.imageRepository});

  String? getProfilePictureUrl(String? filename) {
    if (filename == null || filename.isEmpty) return null;
    return imageRepository.buildUrl(filename);
  }
}
