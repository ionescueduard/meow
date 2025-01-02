import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:badges/badges.dart' as badges;
import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';
import 'search_cats_tab.dart';
import 'breeding_requests_tab.dart';

class BreedingScreen extends StatefulWidget {
  const BreedingScreen({super.key});

  @override
  State<BreedingScreen> createState() => _BreedingScreenState();
}

class _BreedingScreenState extends State<BreedingScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = context.read<AuthService>().currentUser;
    if (currentUser == null) {
      return const Center(child: Text('Please sign in to view breeding section'));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Breeding'),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            const Tab(icon: Icon(Icons.search), text: 'Search'),
            StreamBuilder<int>(
              stream: context.read<FirestoreService>().getUnseenBreedingRequestsCount(currentUser.uid),
              builder: (context, snapshot) {
                final unseenCount = snapshot.data ?? 0;
                return Tab(
                  icon: Icon(Icons.pets),
                  child: badges.Badge(
                    showBadge: unseenCount > 0,
                    badgeContent: Text(
                      unseenCount.toString(),
                      style: const TextStyle(color: Colors.white),
                    ),
                    child: const Text('Requests'),
                  ),
                );
              },
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          SearchCatsTab(),
          BreedingRequestsTab(),
        ],
      ),
    );
  }
} 