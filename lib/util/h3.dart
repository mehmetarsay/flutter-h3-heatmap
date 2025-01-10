
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_ankara_h3_heatmap/services/data_service.dart';
import 'package:flutter_ankara_h3_heatmap/util/extensions.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:h3_flutter/h3_flutter.dart';
// ignore: depend_on_referenced_packages
import "package:collection/collection.dart";
import 'package:tuple/tuple.dart';

const String colorsString = "{0.8: 0x80FFB8B9, 0.9: 0x80FFB8B9, 0.93: 0x80FF0000, 0.99: 0x80FF0000}";

extension H3Extensions on H3 {
  // Koordinatları poligonlara dönüştürür
  Set<Polygon> toPolygon(List<LatLng> points, {int resulation = 8}) {
    log('Converting points to polygons with resolution: \\$resulation');
    final h3Counts = points.toGeoCoords
        .groupFoldBy(
          (geoCoord) => geoToH3(geoCoord, resulation),
          (int? c, _) => (c ?? 0) + 1,
        )
        .entries
        .where((h3Count) => belowLimit <= h3Count.value)
        .sorted((h3Count1, h3Count2) => h3Count1.value.compareTo(h3Count2.value));

    log('H3 counts calculated: \\${h3Counts.length}');
    final colors = _getColorRate(h3Counts.length);
    return h3Counts.indexed
        .skip(colors.lastOrNull?.item1 ?? 0)
        .groupFoldBy(
          (h3Count) => colors.firstWhere((c) => c.item1 <= h3Count.$1).item2,
          (List<BigInt>? sameColorH3s, hc) => (sameColorH3s ?? [])..add(hc.$2.key),
        )
        .entries
        .expand((colorH3s) => _groupIfNeighbor(colorH3s.value)
            .map(_mergeNeighbors)
            .map((e) => e.asLatLng)
            .mapIndexed((pid, hwd) => _toPolygon(pid, colorH3s.key, hwd)))
        .toSet();
  }

  // Poligon oluşturur
  Polygon _toPolygon(int pid, Color color, List<LatLng> points) {
    return Polygon(
      polygonId: PolygonId('heatmap_${color}_$pid'),
      fillColor: color,
      points: points,
      strokeColor: Colors.transparent,
      strokeWidth: 1,
    );
  }

  // Komşu hücreleri gruplar
  Set<List<BigInt>> _groupIfNeighbor(List<BigInt> cells) {
    log('Grouping neighboring cells');
    final neighborsSet = <List<BigInt>>{};
    for (var h3 in cells) {
      final neighbors = neighborsSet.where((group) => group.any((e) => h3IndexesAreNeighbors(e, h3))).toSet();
      if (neighbors.isEmpty) {
        neighborsSet.add([h3]);
        continue;
      }
      neighbors.first.add(h3);
      if (neighbors.length == 1) continue;

      neighborsSet
        ..removeAll(neighbors)
        ..add(neighbors.reduce((value, element) => value..addAll(element)));
    }
    log('Neighbor groups formed: \\${neighborsSet.length}');
    return neighborsSet;
  }

  // Komşu hücreleri birleştirir
  List<GeoCoord> _mergeNeighbors(List<BigInt> neighborSet) {
    log('Merging neighbor sets');
    List<List<GeoCoord>> neighborList = neighborSet.map(h3ToGeoBoundary).toList();
    final polygon = neighborList.removeLast();
    final maxTrial = neighborList.length;
    for (var i = 0; i < maxTrial && neighborList.isNotEmpty; i++) {
      neighborList.removeWhere(polygon.mergeIfNeighbor);
    }
    polygon.removeIntersections();
    log('Merged polygon size: \\${polygon.length}');
    return polygon;
  }

  // Renk oranını hesaplar
  List<Tuple2<int, Color>> _getColorRate(int factor) {
    log('Calculating color rate with factor: \\$factor');
    return colorsString
        .replaceAll(RegExp(r'[{} ]'), '')
        .split(',')
        .map((e) => e.split(':'))
        .map((e) => Tuple2((double.parse(e.first) * factor).floor(), Color(int.parse(e.last))))
        .where((e) => e.item2 != Colors.transparent)
        .sorted((a, b) => b.item1.compareTo(a.item1));
  }
}
