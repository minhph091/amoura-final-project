import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../config/language/app_localizations.dart';
import '../../../infrastructure/services/blocking_service.dart';
import '../../shared/widgets/app_gradient_background.dart';
import 'block_list_viewmodel.dart';
import 'widgets/blocked_messages_tab.dart';
import 'widgets/blocked_users_tab.dart';

/// A view that displays the blocked users and blocked messages
/// with tabs to switch between them.
class BlockListView extends StatefulWidget {
  const BlockListView({super.key});

  @override
  State<BlockListView> createState() => _BlockListViewState();
}

class _BlockListViewState extends State<BlockListView>
    with SingleTickerProviderStateMixin {
  late BlockListViewModel _viewModel;

  @override
  void initState() {
    super.initState();

    // Initialize ViewModel
    final blockingService = Provider.of<BlockingService>(
      context,
      listen: false,
    );
    _viewModel = BlockListViewModel(blockingService, this);

    // Fetch data when the view initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _viewModel.init();
    });
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _viewModel,
      child: AppGradientBackground(
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            title: Text(AppLocalizations.of(context).translate('block_list')),
            backgroundColor: Colors.transparent,
            elevation: 0,
            bottom: TabBar(
              controller: _viewModel.tabController,
              tabs: const [Tab(text: 'Users'), Tab(text: 'Messages')],
            ),
          ),
          body: TabBarView(
            controller: _viewModel.tabController,
            children: const [BlockedUsersTab(), BlockedMessagesTab()],
          ),
        ),
      ),
    );
  }
}
