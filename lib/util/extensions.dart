import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:h3_flutter/h3_flutter.dart';

extension StringExtensionsForLatLng on String {}

extension LatLngsExtensions on List<LatLng> {
  Iterable<GeoCoord> get toGeoCoords => map((latLng) => GeoCoord(lat: latLng.latitude, lon: latLng.longitude));
}

extension LatLngExtensions on LatLng {
  GeoCoord get toGeoCoord => GeoCoord(lat: latitude, lon: longitude);
}

extension GeoCoordsExtension on List<GeoCoord> {
  bool mergeIfNeighbor(List<GeoCoord> other) {
    var intersection = lastIndexWhere(other.contains);
    if (intersection == -1) return false;
    var otherIntersection = other.indexWhere((e) => e == this[intersection]);

    if (intersection == length - 1) {
      final otherIntersectionCandidate = (otherIntersection - 1) % other.length;
      if (this[0] == other[otherIntersectionCandidate]) {
        intersection = 0;
        otherIntersection = otherIntersectionCandidate;
      }
    }

    if (this[(intersection - 1) % length] != other[(otherIntersection + 1) % other.length]) {
      return false;
    }

    insertAll(intersection, other.sublist(0, otherIntersection));
    if (otherIntersection + 2 < other.length) insertAll(intersection, other.sublist(otherIntersection + 2));
    return true;
  }

  removeIntersections() {
    for (var i = 0; i < length; i++) {
      if (this[i % length] == this[(i + 1) % length]) {
        removeAt(i % length);
        i--;
      }
      if (this[i % length] == this[(i + 2) % length]) {
        removeAt(i % length);
        removeAt(i % length);
        i -= 2;
      }
    }
  }

  List<LatLng> get asLatLng => map((e) => LatLng(e.lat, e.lon)).toList(growable: false);
}
