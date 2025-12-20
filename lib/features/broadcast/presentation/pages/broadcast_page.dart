import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import '../../data/datasources/broadcast_remote_data_source.dart';
import '../../data/repositories/broadcast_repository.dart';
import '../controllers/broadcast_controller.dart';
import '../widgets/broadcast_widget.dart';
import '../widgets/broadcast_create_event_dialog.dart';

class BroadcastPage extends StatefulWidget {
  const BroadcastPage({super.key});

  @override
  State<BroadcastPage> createState() => _BroadcastPageState();
}

class _BroadcastPageState extends State<BroadcastPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ScrollController _scrollController = ScrollController();
  BroadcastController? _controller;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_onTabChanged);
    _scrollController.addListener(_onScroll);
  }

  void _onTabChanged() {
    if (!_tabController.indexIsChanging) {
      final controller = _controller;
      if (controller == null) return;
      controller.switchTab(
        _tabController.index == 0
            ? BroadcastTab.trending
            : BroadcastTab.latest,
      );
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _controller?.loadMore();
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<BroadcastController>(
      create: (ctx) {
        final cookieRequest = ctx.read<CookieRequest>();
        final controller = BroadcastController(
          BroadcastRepository(
            BroadcastRemoteDataSource(cookieRequest),
          ),
        );
        controller.loadEvents(refresh: true);
        return controller;
      },
      child: Builder(
        builder: (ctx) {
          _controller = ctx.read<BroadcastController>();

          return Scaffold(
            appBar: AppBar(
              title: const Text('Events'),
              bottom: TabBar(
                controller: _tabController,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white70,
                tabs: const [
                  Tab(text: 'Trending'),
                  Tab(text: 'Latest'),
                ],
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () => _showCreateEventDialog(ctx),
                ),
              ],
            ),
            body: Consumer<BroadcastController>(
              builder: (context, controller, _) {
                if (controller.isLoading && controller.events.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (controller.error != null && controller.events.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Error: ${controller.error}'),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => controller.refresh(),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }

                if (controller.events.isEmpty) {
                  return const Center(child: Text('No events found'));
                }

                return RefreshIndicator(
                  onRefresh: () => controller.refresh(),
                  child: ListView.builder(
                    controller: _scrollController,
                    itemCount: controller.events.length +
                        (controller.isLoading ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == controller.events.length) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(16.0),
                            child: CircularProgressIndicator(),
                          ),
                        );
                      }

                      final event = controller.events[index];
                      return EventCard(event: event);
                    },
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  void _showCreateEventDialog(BuildContext context) {
    final controller = context.read<BroadcastController>();
    showDialog(
      context: context,
      builder: (dialogContext) => ChangeNotifierProvider.value(
        value: controller,
        child: const BroadcastCreateEventDialog(),
      ),
    );
  }
}
