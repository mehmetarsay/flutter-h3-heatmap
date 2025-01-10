import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_ankara_h3_heatmap/base/base_view.dart';
import 'package:flutter_ankara_h3_heatmap/services/data_service.dart';
import 'package:flutter_ankara_h3_heatmap/view/h3_polygon/h3_polygon_view_model.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class H3PolyonView extends StatelessWidget {
  const H3PolyonView({super.key});

  final String mapStyle = '[{"featureType": "road","elementType": "labels","stylers": [{"visibility": "off"}]}]';

  @override
  Widget build(BuildContext context) => BaseView<H3PolygonViewModel>(
        onModelReady: (model) => model.init(),
        viewModel: H3PolygonViewModel(),
        onPageBuilder: (context, model) => Scaffold(
          body: Stack(
            children: [
              GestureDetector(
                onDoubleTap: () => model.setIsShowButton(!model.isShowButton),
                child: GoogleMap(
                  mapType: MapType.normal,
                  initialCameraPosition: CameraPosition(target: ankaraCenter, zoom: 12),
                  onMapCreated: (GoogleMapController controller) {
                    model.onMapCreated(controller);
                    controller.setMapStyle(mapStyle);
                  },
                  myLocationEnabled: false,
                  myLocationButtonEnabled: false,
                  markers: model.enableMarkers ? model.markers : {},
                  polygons: model.enablePolygons ? model.polygons : {},
                  heatmaps: model.enableHeatmaps ? model.heatmaps : {},
                ),
              ),
              if (model.isShowButton) ...[
                Positioned(
                  top: 50,
                  left: 10,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.7),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Markers'),
                            Switch(
                              value: model.enableMarkers,
                              onChanged: (value) => model.setEnableMarkers(value),
                              activeColor: Colors.green,
                              padding: EdgeInsets.zero,
                              inactiveThumbColor: Colors.black,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 10),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.7),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Heatmaps'),
                            Switch(
                              value: model.enableHeatmaps,
                              onChanged: (value) => model.setEnableHeatmaps(value),
                              activeColor: Colors.green,
                              padding: EdgeInsets.zero,
                              inactiveThumbColor: Colors.black,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 10),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.7),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            DropdownButton<int>(
                              value: model.selectResulation,
                              items: model.resulations.map((int value) {
                                return DropdownMenuItem<int>(
                                  value: value,
                                  child: Text('Resolution $value'),
                                );
                              }).toList(),
                              onChanged: (int? newValue) => model.setSelectResulation(newValue),
                            ),
                            Switch(
                              value: model.enablePolygons,
                              onChanged: (value) => model.setEnablePolygons(value),
                              activeColor: Colors.green,
                              padding: EdgeInsets.zero,
                              inactiveThumbColor: Colors.black,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  bottom: 80,
                  left: 10,
                  right: 10,
                  child: SizedBox(
                    height: 50,
                    child: ListView.builder(
                      itemBuilder: (context, index) => Card(
                        color: model.selectLength == model.lengths[index]
                            ? Colors.blue.withValues(alpha: 0.7)
                            : Colors.white.withValues(alpha: 0.9),
                        child: InkWell(
                          onTap: () => model.setSelectLength(model.lengths[index]),
                          borderRadius: BorderRadius.circular(10),
                          child: Center(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              child: Text(
                                model.lengths[index].toString(),
                                style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: model.selectLength == model.lengths[index]
                                        ? Colors.white
                                        : Colors.black.withValues(alpha: 0.7)),
                              ),
                            ),
                          ),
                        ),
                      ),
                      shrinkWrap: true,
                      scrollDirection: Axis.horizontal,
                      itemCount: model.lengths.length,
                    ),
                  ),
                ),
                Positioned(
                  bottom: 30,
                  left: 10,
                  right: 10,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.deepPurple.withValues(alpha: 0.7), foregroundColor: Colors.white),
                          onPressed: () => model.startStopAddMarkers(),
                          child: Text(model.markerTimer?.isActive ?? false ? 'STOP ADDING' : 'START ADDING',
                              style: TextStyle(fontWeight: FontWeight.w600)),
                        ),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue.withValues(alpha: 0.7), foregroundColor: Colors.white),
                          onLongPress: () => model.regenerate(),
                          onPressed: () => model.create(),
                          child: Text('REGENERATE', style: TextStyle(fontWeight: FontWeight.w600)),
                        ),
                      ),
                    ],
                  ),
                )
              ]
            ],
          ),
        ),
      );
}
