import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_liblinphone/flutter_liblinphone.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key, required this.core});

  final Core core;

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("dieKlingel"),
      ),
      body: const Center(
        child: Text('Home'),
      ),
    );
  }
}
