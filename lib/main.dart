import 'package:flutter/material.dart';
import 'package:mysql_dart/mysql_dart.dart';

import './login.dart';

import './panels/dojo.dart';
import './panels/home.dart';
import './panels/diet.dart';
// import './panels/training.dart';
// import './panels/settings.dart';
import './panels/stats.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: .fromSeed(seedColor: Colors.green),
      ),
      home: const LoginScreen(
         targetScreen: MyHomePage(title: 'Witaj Alojzy!')
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class Training extends StatelessWidget {
  const Training({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(child: Text('Trening', style: TextStyle(fontSize: 24)));
  }
}

class Settings extends StatelessWidget {
  const Settings({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(child: Text('Settings', style: TextStyle(fontSize: 24)));
  }
}

class _MyHomePageState extends State<MyHomePage> {
  // int _counter = 0;
  //
  // void _incrementCounter() {
  //   setState(() {
  //     _counter += 2;
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 6,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          centerTitle: true,
          title: Text(widget.title),
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.home), text: 'Home'),
              Tab(icon: Icon(Icons.calendar_today), text: 'Dieta'),
              Tab(icon: Icon(Icons.run_circle), text: 'Trening'),
              Tab(icon: Icon(Icons.train), text: 'Dojo'),
              Tab(icon: Icon(Icons.battery_alert), text: 'Stats'),
              Tab(icon: Icon(Icons.settings), text: 'Settings'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            Home(),
            Diet(),
            // Training(),
            Dojo(a:1),
            Dojo(a:1),
            Stats(),
            // Settings(),
            Dojo(a:1),
          ],
        ),
        // floatingActionButton: FloatingActionButton(
        //   onPressed: _incrementCounter,
        //   tooltip: 'Increment',
        //   child: const Icon(Icons.add),
        // ),
      )
    );
  }
}
