import 'package:flutter/material.dart';
import 'search_cats_tab.dart';
import 'breeding_requests_tab.dart';

class BreedingScreen extends StatelessWidget {
  const BreedingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Breeding'),
          bottom: TabBar(
            tabs: const [
              Tab(
                icon: Icon(Icons.search),
                text: 'Search',
              ),
              Tab(
                icon: Icon(Icons.pets),
                text: 'Requests',
              ),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            SearchCatsTab(),
            BreedingRequestsTab(),
          ],
        ),
      ),
    );
  }
} 