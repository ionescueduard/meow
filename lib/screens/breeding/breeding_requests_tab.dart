import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/cat_model.dart';
import '../../models/user_model.dart';
import '../../models/breeding_request_model.dart';
import '../../services/firestore_service.dart';
import '../../services/auth_service.dart';
import '../../services/chat_service.dart';
import '../cat/cat_details_screen.dart';
import '../chat/chat_detail_screen.dart';
import '../breeding/breeding_request_details_screen.dart';

class BreedingRequestsTab extends StatefulWidget {
  const BreedingRequestsTab({super.key});

  @override
  State<BreedingRequestsTab> createState() => _BreedingRequestsTabState();
}

class _BreedingRequestsTabState extends State<BreedingRequestsTab>
    with SingleTickerProviderStateMixin {
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
      return const Center(
        child: Text('Please sign in to view breeding requests'),
      );
    }

    return Column(
      children: [
        TabBar(
          controller: _tabController,
          labelColor: Theme.of(context).colorScheme.primary,
          tabs: const [
            Tab(text: 'Received'),
            Tab(text: 'Sent'),
          ],
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _RequestsList(
                stream: context
                    .read<FirestoreService>()
                    .getReceivedBreedingRequests(currentUser.uid),
                isReceived: true,
              ),
              _RequestsList(
                stream: context
                    .read<FirestoreService>()
                    .getSentBreedingRequests(currentUser.uid),
                isReceived: false,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _RequestsList extends StatefulWidget {
  final Stream<List<BreedingRequest>> stream;
  final bool isReceived;

  const _RequestsList({
    required this.stream,
    required this.isReceived,
  });

  @override
  State<_RequestsList> createState() => _RequestsListState();
}

class _RequestsListState extends State<_RequestsList> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    
    return StreamBuilder<List<BreedingRequest>>(
      stream: widget.stream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final requests = snapshot.data ?? [];
        if (requests.isEmpty) {
          return Center(
            child: Text(
              widget.isReceived
                  ? 'No breeding requests received'
                  : 'No breeding requests sent',
            ),
          );
        }

        return ListView.builder(
          itemCount: requests.length,
          itemBuilder: (context, index) {
            final request = requests[index];
            return _buildRequestCard(context, request);
          },
        );
      },
    );
  }

  Widget _buildRequestCard(BuildContext context, BreedingRequest request) {
    final firestoreService = context.read<FirestoreService>();
    final isUnseen = widget.isReceived && !request.seen;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isUnseen 
          ? BorderSide(
              color: Theme.of(context).colorScheme.primary,
              width: 1,
            )
          : BorderSide.none,
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => BreedingRequestDetailsScreen(
                request: request,
                isReceived: widget.isReceived,
              ),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: FutureBuilder<CatModel?>(
                      future: firestoreService.getCat(
                        widget.isReceived ? request.requesterCatId : request.catId,
                      ),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return const SizedBox.shrink();
                        }
                        final cat = snapshot.data!;
                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: CircleAvatar(
                            backgroundImage: cat.photoUrls.isNotEmpty
                                ? NetworkImage(cat.photoUrls.first)
                                : null,
                            child: cat.photoUrls.isEmpty
                                ? const Icon(Icons.pets)
                                : null,
                          ),
                          title: Text(cat.name),
                          subtitle: Text(cat.breed.toString().split('.').last),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => CatDetailsScreen(cat: cat),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                  const Icon(Icons.arrow_forward),
                  Expanded(
                    child: FutureBuilder<CatModel?>(
                      future: firestoreService.getCat(
                        widget.isReceived ? request.catId : request.requesterCatId,
                      ),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return const SizedBox.shrink();
                        }
                        final cat = snapshot.data!;
                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: CircleAvatar(
                            backgroundImage: cat.photoUrls.isNotEmpty
                                ? NetworkImage(cat.photoUrls.first)
                                : null,
                            child: cat.photoUrls.isEmpty
                                ? const Icon(Icons.pets)
                                : null,
                          ),
                          title: Text(cat.name),
                          subtitle: Text(cat.breed.toString().split('.').last),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => CatDetailsScreen(cat: cat),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Message: ${request.message}',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 8),
              Text(
                'Status: ${request.status}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: _getStatusColor(request.status),
                    ),
              ),
              if (widget.isReceived && request.status == 'pending')
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () async {
                        await firestoreService.updateBreedingRequestStatus(
                          request.id,
                          'rejected',
                        );
                      },
                      child: const Text('Reject'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () async {
                        await firestoreService.updateBreedingRequestStatus(
                          request.id,
                          'accepted',
                        );
                      },
                      child: const Text('Accept'),
                    ),
                  ],
                ),
              if (request.status == 'accepted')
                FutureBuilder<UserModel?>(
                  future: firestoreService.getUser(
                    widget.isReceived ? request.requesterId : request.receiverId,
                  ),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) return const SizedBox.shrink();
                    final otherUser = snapshot.data!;
                    
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        ElevatedButton.icon(
                          icon: const Icon(Icons.chat),
                          label: const Text('Start Chat'),
                          onPressed: () async {
                            final currentUser = context.read<AuthService>().currentUser;
                            if (currentUser == null) return;

                            final chatRoom = await context.read<ChatService>().getChatRoom(
                              participantIds: [currentUser.uid, otherUser.id],
                            );

                            if (chatRoom != null && context.mounted) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ChatDetailScreen(
                                    chatRoom: chatRoom,
                                    otherUser: otherUser,
                                  ),
                                ),
                              );
                            }
                          },
                        ),
                      ],
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'accepted':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
} 