// lib/core/base/base_view.dart

import 'package:flutter/material.dart';

/// Base cho các View, giúp inject ViewModel và context
class BaseView<T extends ChangeNotifier> extends StatelessWidget {
  final Widget Function(BuildContext context, T viewModel, Widget? child) builder;
  final T viewModel;
  final Widget? child;

  const BaseView({
    super.key,
    required this.builder,
    required this.viewModel,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return builder(context, viewModel, child);
  }
}