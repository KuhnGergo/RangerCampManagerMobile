// Custom tile provider with caching for offline support
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_map/flutter_map.dart';

class CachedTileProvider extends TileProvider {
  final DefaultCacheManager _cacheManager = DefaultCacheManager();

  @override
  ImageProvider getImage(TileCoordinates coordinates, TileLayer options) {
    final url = getTileUrl(coordinates, options);
    return CachedImageProvider(url, _cacheManager);
  }
}

// Custom image provider that uses cache manager
class CachedImageProvider extends ImageProvider<CachedImageProvider> {
  final String url;
  final DefaultCacheManager cacheManager;

  CachedImageProvider(this.url, this.cacheManager);

  @override
  ImageStreamCompleter loadImage(
    CachedImageProvider key,
    ImageDecoderCallback decode,
  ) {
    return MultiFrameImageStreamCompleter(
      codec: _loadAsync(key, decode),
      scale: 1.0,
    );
  }

  Future<Codec> _loadAsync(
    CachedImageProvider key,
    ImageDecoderCallback decode,
  ) async {
    try {
      final file = await cacheManager.getSingleFile(url);
      final bytes = await file.readAsBytes();
      final buffer = await ImmutableBuffer.fromUint8List(bytes);
      return decode(buffer);
    } catch (e) {
      // If offline and not cached, return empty image
      rethrow;
    }
  }

  @override
  Future<CachedImageProvider> obtainKey(ImageConfiguration configuration) {
    return SynchronousFuture<CachedImageProvider>(this);
  }

  @override
  bool operator ==(Object other) {
    if (other.runtimeType != runtimeType) return false;
    return other is CachedImageProvider && other.url == url;
  }

  @override
  int get hashCode => url.hashCode;
}
