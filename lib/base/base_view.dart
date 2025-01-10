import 'dart:developer';
import 'package:flutter_ankara_h3_heatmap/base/base_view_model.dart';
import 'package:flutter/material.dart';

class BaseView<T extends BaseViewModel> extends StatefulWidget {
  const BaseView({
    super.key,
    required this.viewModel,
    required this.onPageBuilder,
    required this.onModelReady,
    this.onDispose,
  });

  final Widget Function(BuildContext context, T value) onPageBuilder;
  final T viewModel;
  final void Function(T model) onModelReady;
  final Function(T viewModel)? onDispose;

  @override
  _BaseViewState createState() => _BaseViewState<T>();
}

class _BaseViewState<T extends BaseViewModel> extends BaseState<BaseView<T>> {
  late T model;
  @override
  void initState() {
    model = widget.viewModel;
    widget.onModelReady(model);
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    if (widget.onDispose != null) widget.onDispose?.call(model);
    log(name: "$model", widget.onDispose.toString());
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: model,
      builder: (context, child) {
        return widget.onPageBuilder(context, model);
      }
    );
  }
}


abstract class BaseState<T extends StatefulWidget> extends State<T> {
  ThemeData get themeData => Theme.of(context);
  get h => MediaQuery.of(context).size.height;
  get w => MediaQuery.of(context).size.width;
}
