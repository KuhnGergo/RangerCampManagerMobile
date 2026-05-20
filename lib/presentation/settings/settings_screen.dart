import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mastercs_mobile/presentation/components/widgets/offline_indicator.dart';
import 'package:mastercs_mobile/presentation/components/widgets/pull_to_refresh.dart';
import 'package:mastercs_mobile/presentation/settings/widgets/account.dart';
import 'package:mastercs_mobile/presentation/settings/widgets/hazard_section.dart';
import 'package:mastercs_mobile/presentation/settings/widgets/general_section.dart';
import 'package:mastercs_mobile/presentation/settings/widgets/location_permissions_section.dart';
import 'package:mastercs_mobile/presentation/settings/widgets/preferences_section.dart';

import 'package:mastercs_mobile/providers/actions/account_actions_provider.dart';
import 'package:mastercs_mobile/providers/theme_provider.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final _refreshController = PullToRefreshController();

  @override
  void dispose() {
    _refreshController.dispose();
    super.dispose();
  }

  Future<void> _onRefresh(WidgetRef ref) async {
    try {
      await ref.read(accountActionsProvider.notifier).refreshMyAccount();
    } finally {
      _refreshController.completeRefresh();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final themeMode = ref.watch(themeProvider);
    final isDarkMode = themeMode == ThemeMode.dark;

    return Scaffold(
      appBar: AppBar(
        forceMaterialTransparency: true,
        title: Text(
          'Account & Settings',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        systemOverlayStyle: isDarkMode
            ? SystemUiOverlayStyle.light
            : SystemUiOverlayStyle.dark,
      ),
      body: SafeArea(
        child: Column(
          children: [
            const OfflineIndicator(),
            Expanded(
              child: PullToRefresh(
                controller: _refreshController,
                minVisibleOffset: 60,
                triggerOffset: 60,
                dragFactor: 0.2,
                onRefresh: () => _onRefresh(ref),
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.only(
                    left: 12,
                    bottom: 40,
                    right: 12,
                  ),
                  children: const [
                    AccountWidget(),
                    SizedBox(height: 8),
                    PreferencesSection(),
                    SizedBox(height: 8),
                    LocationPermissionsSection(),
                    SizedBox(height: 8),
                    GeneralSection(),
                    SizedBox(height: 8),
                    HazardSection(),
                    SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
