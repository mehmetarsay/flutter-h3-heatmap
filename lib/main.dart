import 'package:flutter/material.dart';
import 'package:flutter_ankara_h3_heatmap/services/data_service.dart';
import 'package:flutter_ankara_h3_heatmap/view/h3_polygon/h3_polygon_view.dart';

void main() {
  DataService().create();
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) => const MaterialApp(home: H3PolyonView());
}
