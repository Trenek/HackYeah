import 'package:flutter/material.dart';

import './login.dart';

import './panels/unimplemented.dart';
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
            home: LoginScreen(
                targetScreen: builder
            ),
        );
    }

    Widget builder(int id, String userName) {
        return MyHomePage(
            userID: id,
            userName: userName
        );
    }
}

class MyHomePage extends StatefulWidget {
    final int userID;
    final String userName;

    const MyHomePage({super.key, required this.userID, required this.userName});

    @override
    State<MyHomePage> createState() => _MyHomePageState();
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
                    title: Text('Witaj ${widget.userName}!'),
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
