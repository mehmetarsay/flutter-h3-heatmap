import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_ankara_h3_heatmap/util/coord_generate.dart';
import 'package:flutter_ankara_h3_heatmap/util/h3.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:h3_flutter/h3_flutter.dart';

// Ankara şehrinin merkezi koordinatları
const ankaraCenter = LatLng(39.9334, 32.8597);
// Aşağıdaki limitin altındaki koordinatlar için bir sabit
const belowLimit = 1;

class DataService {
  DataService._privateConstructor();
  static final DataService _instance = DataService._privateConstructor();

  factory DataService() {
    return _instance;
  }
  late final _h3 = const H3Factory().load();

  List<LatLng> coords = [];
  int coordsLength = 1000;
  List<int> lengths = [10, 100, 1000, 2000, 3000, 4000, 5000, 6000, 7000, 8000, 9000, 10000, 99999];
  List<int> resulations = [4, 5, 6, 7, 8, 9];

  // Çözünürlüğe göre poligonlar haritası
  Map<int, Set<Polygon>> polygons = {};
  Set<Marker> markers = {};
  Set<Heatmap> heatmaps = {};

  // Verileri oluştur
  create({bool createCoords = true, bool isCreate = true}) async {
    // Koordinatlar oluşturulmamışsa veya boşsa, koordinatları oluştur
    if (isCreate || coords.isEmpty) await _createCoords(createCoords: createCoords);
    _createMarkers();
    _createPolygons();
    _createHeatmaps();
    log('coords: ${coords.length}');
  }

  // Koordinatları oluştur
  _createCoords({bool createCoords = true}) async {
    // Koordinatlar oluşturulacaksa, Ankara şehrinde rastgele koordinatlar oluştur
    if (createCoords) return coords = await generateRandomCoordinatesInAnkara(coordsLength);
    // Aksi halde, yeni koordinatlar oluştur ve mevcut koordinatlara ekle
    var newCoords = await generateRandomCoordinatesInAnkara(coordsLength);
    return coords.addAll(newCoords);
  }

  // Marker'ları oluştur
  void _createMarkers() => markers = coords
      .map((coord) =>
          Marker(position: coord, markerId: MarkerId(coord.latitude.toString() + coord.longitude.toString())))
      .toSet();

  // Poligonları oluştur
  void _createPolygons() => polygons = Map.fromEntries(
      resulations.map((resulation) => MapEntry(resulation, _h3.toPolygon(coords, resulation: resulation))));

  // Heatmap'leri oluştur
  void _createHeatmaps() => heatmaps = {
        Heatmap(
          heatmapId: HeatmapId('heatmap'),
          data: coords.map((coord) => WeightedLatLng(coord)).toList(),
          gradient: HeatmapGradient([
            HeatmapGradientColor(Colors.yellow.withValues(alpha: 0.5), 0.1),
            HeatmapGradientColor(Colors.yellow.withValues(alpha: 1), 0.2),
            HeatmapGradientColor(Colors.red.withValues(alpha: 0.5), 0.3),
            HeatmapGradientColor(Colors.red.withValues(alpha: 1), 1)
          ]),
          opacity: 0.5,
          radius: HeatmapRadius.fromPixels(100),
        )
      };
}
