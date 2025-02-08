
import 'package:flutter/material.dart';

class SaveScreen extends StatelessWidget {
  const SaveScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2, // Number of tabs
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Save'),
          bottom: const TabBar(
            indicator: UnderlineTabIndicator(
              borderSide: BorderSide(width: 4.0, color: Colors.white),
              insets: EdgeInsets.symmetric(horizontal: 16.0),
            ),
            tabs: [
              Tab(text: 'Dogs'),
              Tab(text: 'Walks'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            DogsTab(),
            WalksTab(),
          ],
        ),
      ),
    );
  }
}

class DogsTab extends StatelessWidget {
  const DogsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Save Dogs',
        style: TextStyle(fontSize: 24),
      ),
    );
  }
}

class WalksTab extends StatelessWidget {
  const WalksTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Save Walks',
        style: TextStyle(fontSize: 24),
      ),
    );
  }
}