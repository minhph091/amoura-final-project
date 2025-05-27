import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class planListView extends StatelessWidget {
  const planListView({super.key});

  @override
  Widget build(BuildContext context) {
    // PlanListViewModel should be provided higher in the widget tree
    return Scaffold(
      appBar: AppBar(
        title: const Text('Subscription Plans'),
      ),
    );
  }
}