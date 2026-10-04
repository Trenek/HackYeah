import 'package:flutter/material.dart';
import 'package:mysql_dart/mysql_dart.dart';

import './login.dart';

import './panels/dojo.dart';
import './panels/home.dart';
import './panels/diet.dart';
import './panels/training.dart';
import './panels/settings.dart';

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
        colorScheme: .fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const LoginScreen(
         targetScreen: MyHomePage(title: 'Flutter Demo Home Page')
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

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 5,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: Text(widget.title),
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.home), text: 'Home'),
              Tab(icon: Icon(Icons.calendar_today), text: 'Dieta'),
              Tab(icon: Icon(Icons.run_circle), text: 'Trening'),
              Tab(icon: Icon(Icons.train), text: 'Dojo'),
              Tab(icon: Icon(Icons.settings), text: 'Settings'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            Home(),
            Diet(),
            Training(),
            Dojo(a:1),
            Settings(),
          ],
        ),
      )
    );
  }
}
