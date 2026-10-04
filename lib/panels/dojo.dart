import 'package:flutter/material.dart';
import 'package:flutter_cube/flutter_cube.dart';
import 'dart:math';


class Dojo extends StatefulWidget {
  final String title="Aaaa";
  const Dojo({super.key, required this.a});
  final int a;
 @override
  State<Dojo> createState() => _DojoState();

}

/*
class _DojoState() extends State<Dojo>{
  @override
  Widget build(BuildContext context) {
    return Center(child: Text('Dojo nowe'+32.toString(), style: TextStyle(fontSize: 24)));
  }
}
*/
















































class _DojoState extends State<Dojo> with SingleTickerProviderStateMixin {
  late Scene _scene;
  Object? _cube;
  Object? _dragon_plane;
  late AnimationController _controller;

  void _onSceneCreated(Scene scene) {
    _scene = scene;
    scene.camera.position.z = 50;
    scene.camera.fov=75;
    _cube = Object(scale: Vector3(2.0, 2.0, 2.0), backfaceCulling: false);
    _dragon_plane = Object(scale: Vector3(50.0, 50.0, 0.01),fileName: 'assets/cube.obj');

    final int samples = 100;
    final double radius = 8;
    final double offset = 2 / samples;
    final double increment = pi * (3 - sqrt(5));
    for (var i = 0; i < samples; i++) {
      final y = (i * offset - 1) + offset / 2;
      final r = sqrt(1 - pow(y, 2));
      final phi = ((i + 1) % samples) * increment;
      final x = cos(phi) * r;
      final z = sin(phi) * r;
      /*
      final Object cube = Object(
        position: Vector3(x, y, z)..scale(radius),
        scale: Vector3(0.3, 0.3, 0.3),
        fileName: 'assets/cube/cube.obj',
      );
      _cube!.add(cube);
      */
    }
    scene.world.add(_cube!);
    _cube!.rotation.x=180;
     scene.world.add(_dragon_plane!);
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: Duration(milliseconds: 30000), vsync: this)
      ..addListener(() {
        if (_cube != null) {
          _cube!.rotation.y = _controller.value * 360;
          _cube!.updateTransform();
          _scene.update();
        }
        _dragon_plane!.rotation.x = _controller.value * 360;
        _dragon_plane!.updateTransform();
      })
      ..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title!),
      ),
      body: Center(
        child: Cube(
          onSceneCreated: _onSceneCreated,
        ),
      ),
    );
  }
}


