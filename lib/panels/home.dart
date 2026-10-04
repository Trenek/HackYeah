import 'package:flutter/material.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image(image: AssetImage('assets/happy_dragon.webp')),
          ElevatedButton(
            onPressed: () {
            },
            child: const Text('Pomiary'),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
            },
            child: const Text('Staty'),
          ),
        ],
      ),
    );
  }
}

