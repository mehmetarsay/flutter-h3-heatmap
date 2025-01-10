import 'dart:async';
import 'package:flutter_ankara_h3_heatmap/base/base_view_model.dart';
import 'package:flutter_ankara_h3_heatmap/services/data_service.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class H3PolygonViewModel extends BaseViewModel {
  final _data = DataService();

  final Completer<GoogleMapController> _mapController = Completer<GoogleMapController>();

  Set<Marker> get markers => _data.markers;
  Set<Polygon> get polygons => _data.polygons[selectResulation] ?? {};
  Set<Heatmap> get heatmaps => _data.heatmaps;
  List<int> get resulations => _data.resulations;
  List<int> get lengths => _data.lengths;
  int get selectLength => _data.coordsLength;
  int selectResulation = 6;
  bool enableMarkers = true;
  bool enablePolygons = true;
  bool enableHeatmaps = true;
  bool isShowButton = false;

  Timer? markerTimer;

  void onMapCreated(GoogleMapController controller) => _mapController.complete(controller);

  void setEnableMarkers(bool value) {
    enableMarkers = value;
    notifyListeners();
  }

  void setEnablePolygons(bool value) {
    enablePolygons = value;
    notifyListeners();
  }

  void setSelectResulation(int? value) {
    if (value == null) return;
    selectResulation = value;
    notifyListeners();
  }

  void regenerate() async {
    await _data.create();
    notifyListeners();
  }

  void create() async {
    await _data.create(isCreate: false);
    notifyListeners();
  }

  void setIsShowButton(bool value) {
    isShowButton = value;
    notifyListeners();
  }

  void setSelectLength(int value) {
    _data.coordsLength = value;
    notifyListeners();
  }

  void startStopAddMarkers() {
    if (markerTimer != null) return _stopAddingMarkers();
    return _startAddingMarkers();
  }

  void _addMarkers() async {
    await _data.create(createCoords: false);
    notifyListeners();
  }

  void _startAddingMarkers() {
    markerTimer = Timer.periodic(Duration(seconds: 1), (timer) => _addMarkers());
  }

  void _stopAddingMarkers() {
    markerTimer?.cancel();
    markerTimer = null;
    notifyListeners();
  }

  void setEnableHeatmaps(bool value) {
    enableHeatmaps = value;
    notifyListeners();
  }

  @override
  void init() {}
}
