import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_button.dart';
import '../bloc/portfolio_bloc.dart';
import '../widgets/ledger_list_widget.dart';
import '../widgets/portfolio_stats_widget.dart';
import '../widgets/project_list_widget.dart';

class PortfolioPage extends StatefulWidget {
  const PortfolioPage({super.key});

  @override
  State<PortfolioPage> createState() => _PortfolioPageState();
}

class _PortfolioPageState extends State<PortfolioPage> {
  late PortfolioBloc _bloc;

  @override
  void initState() {
    super.initState();
    _bloc = sl<PortfolioBloc>();
    _bloc.add(const PortfolioSummaryRequested());
  }

  @override
  void dispose() {
    _bloc.close();
    super.dispose();
  }

  void _onRefresh() {
    _bloc.add(const PortfolioRefresh());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocBuilder<PortfolioBloc, PortfolioState>(
      bloc: _bloc,
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('My Portfolio'),
            elevation: 0,
            centerTitle: false,
            backgroundColor: Colors.transparent,
          ),
          body: SafeArea(
            child: _buildBody(context, state, theme),
          ),
        );
      },
    );
  }

  Widget _buildBody(
    BuildContext context,
    PortfolioState state,
    ThemeData theme,
  ) {
    if (state.isLoading && state.summary == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Loading your portfolio...',
              style: theme.textTheme.bodyMedium,
            ),
          ],
        ),
      );
    }

    if (state.status == PortfolioStatus.error) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 64,
                color: AppColors.primary,
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                'Failed to load portfolio',
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                state.errorMessage ?? 'An unexpected error occurred',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall,
              ),
              const SizedBox(height: AppSpacing.lg),
              AppButton(
                text: 'Try Again',
                onPressed: _onRefresh,
              ),
            ],
          ),
        ),
      );
    }

    if (state.summary == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.inbox_outlined,
              size: 64,
              color: AppColors.mutedForeground,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'No portfolio data available',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: AppSpacing.lg),
            AppButton(
              text: 'Refresh',
              onPressed: _onRefresh,
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        _onRefresh();
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Stats section
            PortfolioStatsWidget(summary: state.summary!),
            const SizedBox(height: AppSpacing.lg),

            // Projects section
            if (state.summary!.projects.isNotEmpty) ...[
              Text(
                'Investments (${state.summary!.projects.length})',
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: AppSpacing.md),
              ProjectListWidget(projects: state.summary!.projects),
              const SizedBox(height: AppSpacing.lg),
            ],

            // Recent transactions section
            if (state.recentLedger != null &&
                state.recentLedger!.isNotEmpty) ...[
              Text(
                'Recent Transactions',
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: AppSpacing.md),
              LedgerListWidget(entries: state.recentLedger!),
            ],

            const SizedBox(height: AppSpacing.lg),
          ],
        ),
      ),
    );
  }
}
