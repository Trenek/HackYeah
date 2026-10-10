import 'package:flutter/material.dart';
import 'package:flutter_cube/flutter_cube.dart';

class Unimplemented extends StatefulWidget {
    final String title = "Dragon is Unresponsive";
    final int a;

    const Unimplemented({super.key, required this.a});

    @override
    State<Unimplemented> createState() => _UnimplementedState();
}

class _UnimplementedState extends State<Unimplemented> with SingleTickerProviderStateMixin {
    late Scene scene;
    late AnimationController controller;
    Object? cube;
    Object? dragonPlane;
    Object? w;

    void _onSceneCreated(Scene scene) {
        this.scene = scene;
        scene.camera.position.z = 50;
        scene.camera.fov=75;
        cube = Object(scale: Vector3(2.0, 2.0, 2.0), backfaceCulling: false);
        dragonPlane = Object(scale: Vector3(50.0, 50.0, 0.01),fileName: 'assets/cube.obj');

        w = Object(position: Vector3(0.0, -24.0, 0.0),scale: Vector3(30.0, 3.0, 30.0),fileName: 'assets/w.obj');

        scene.world.add(cube!);
        cube!.rotation.x=180;
        scene.world.add(dragonPlane!);
        scene.world.add(w!);
    }
    
    void listener() {
        if (cube != null) {
            cube!.rotation.y = controller.value * 360;
            cube!.updateTransform();
            scene.update();
        }

        dragonPlane!.rotation.x = controller.value * 360;
        dragonPlane!.updateTransform();
    }

    @override
    void initState() {
        super.initState();
        controller = AnimationController(duration: Duration(milliseconds: 30000), vsync: this)
            ..addListener(listener)
            ..repeat();
    }

    @override
    void dispose() {
        controller.dispose();
        super.dispose();
    }

    @override
    Widget build(BuildContext context) {
        return Scaffold(
            appBar: AppBar(
                title: Text(widget.title),
                centerTitle: true
            ),
            body: Center(
                child: Cube(
                    onSceneCreated: _onSceneCreated,
                ),
            ),
        );
    }
}
