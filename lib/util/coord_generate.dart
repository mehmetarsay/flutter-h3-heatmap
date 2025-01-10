import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

// Ankara şehrinin enlem ve boylam aralıkları
const double minLat = 39.5; // En düşük enlem
const double maxLat = 40.1; // En yüksek enlem
const double minLon = 32.5; // En düşük boylam
const double maxLon = 33.5; // En yüksek boylam

// Ankara şehrinde rastgele koordinatlar oluşturur.
Future<List<LatLng>> generateRandomCoordinatesInAnkara(int numPoints) async {
  return await compute(_generateCoordinates, numPoints);
}

// Rastgele koordinatlar oluşturur.
List<LatLng> _generateCoordinates(int numPoints) {
  final random = Random();
  List<LatLng> coordinates = [];
  for (int i = 0; i < numPoints; i++) {
    // Rastgele bir enlem değeri oluşturur.
    double latitude = minLat + (maxLat - minLat) * random.nextDouble();
    // Rastgele bir boylam değeri oluşturur.
    double longitude = minLon + (maxLon - minLon) * random.nextDouble();
    // Oluşturulan koordinatı listeye ekler.
    coordinates.add(LatLng(latitude, longitude));
  }
  return coordinates;
}
