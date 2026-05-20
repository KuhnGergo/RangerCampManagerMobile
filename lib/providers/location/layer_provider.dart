import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:mastercs_mobile/providers/shared_preferences_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Enum representing available map tile layers
enum MapLayer {
  basic,
  outdoor,
  winter,
  aerial;

  /// Returns the human-readable name of the layer
  String get displayName {
    switch (this) {
      case MapLayer.basic:
        return 'Basic';
      case MapLayer.outdoor:
        return 'Outdoor';
      case MapLayer.winter:
        return 'Winter';
      case MapLayer.aerial:
        return 'Aerial';
    }
  }

  /// Returns the environment variable key for this layer's URL
  String get _envKey {
    switch (this) {
      case MapLayer.basic:
        return 'MAPY_BASIC_URL';
      case MapLayer.outdoor:
        return 'MAPY_OUTDOOR_URL';
      case MapLayer.winter:
        return 'MAPY_WINTER_URL';
      case MapLayer.aerial:
        return 'MAPY_AERIAL_URL';
    }
  }

  /// Returns the complete URL for this layer including the API key
  String get url {
    final baseUrl = dotenv.env[_envKey];
    final apiKey = dotenv.env['MAPY_KEY'];

    if (baseUrl == null || baseUrl.isEmpty) {
      throw Exception('Map layer URL not found in environment: $_envKey');
    }

    if (apiKey == null || apiKey.isEmpty) {
      throw Exception('Map API key not found in environment: MAPY_KEY');
    }

    return '$baseUrl$apiKey';
  }

  /// Returns the maximum zoom level for this layer
  double get maxZoom {
    switch (this) {
      case MapLayer.basic:
      case MapLayer.outdoor:
      case MapLayer.winter:
        return 22.0;
      case MapLayer.aerial:
        return 13.0;
    }
  }
}

/// State notifier for managing the currently selected map layer
class LayerNotifier extends StateNotifier<MapLayer> {
  static const String _layerKey = 'map_layer_key';

  static String get layerKey => _layerKey;

  final SharedPreferences _prefs;

  LayerNotifier(this._prefs, super.initialLayer);

  /// Switch to a specific layer
  void selectLayer(MapLayer layer) {
    state = layer;
    _prefs.setInt(_layerKey, layer.index);
  }

  /// Cycle to the next layer in the enum
  void nextLayer() {
    final currentIndex = MapLayer.values.indexOf(state);
    final nextIndex = (currentIndex + 1) % MapLayer.values.length;
    selectLayer(MapLayer.values[nextIndex]);
  }

  /// Cycle to the previous layer in the enum
  void previousLayer() {
    final currentIndex = MapLayer.values.indexOf(state);
    final previousIndex =
        (currentIndex - 1 + MapLayer.values.length) % MapLayer.values.length;
    selectLayer(MapLayer.values[previousIndex]);
  }
}

/// Provider for the currently selected map layer
final layerProvider = StateNotifierProvider<LayerNotifier, MapLayer>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  final initial = ref.watch(initialLayerProvider);
  return LayerNotifier(prefs, initial);
});

final initialLayerProvider = Provider<MapLayer>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  final savedIndex = prefs.getInt(LayerNotifier.layerKey);
  if (savedIndex != null &&
      savedIndex >= 0 &&
      savedIndex < MapLayer.values.length) {
    return MapLayer.values[savedIndex];
  }
  return MapLayer.basic; // fallback to basic if no saved layer
});

/// Provider that returns the URL for the currently selected layer
final currentLayerUrlProvider = Provider<String>((ref) {
  final layer = ref.watch(layerProvider);
  return layer.url;
});
