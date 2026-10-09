import 'package:flutter/material.dart';

import './login.dart';

import './panels/dojo.dart';
import './panels/home.dart';

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
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          centerTitle: true,
          title: Text(widget.title),
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.home), text: 'Home'),
              Tab(icon: Icon(Icons.run_circle), text: 'Measurements'),
              Tab(icon: Icon(Icons.run_circle), text: 'Stats'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            Home(),
            Unimplemented(a:1),
            Unimplemented(a:1),
          ],
        ),
      )
    );
  }
}
