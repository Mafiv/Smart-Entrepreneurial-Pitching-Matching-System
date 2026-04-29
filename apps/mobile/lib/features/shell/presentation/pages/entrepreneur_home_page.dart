import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../documents/presentation/bloc/documents_bloc.dart';
import '../../../documents/presentation/pages/documents_page.dart';
import '../../../invitations/presentation/bloc/invitations_bloc.dart';
import '../../../invitations/presentation/pages/invitations_page.dart';
import '../../../meetings/presentation/bloc/meetings_bloc.dart';
import '../../../meetings/presentation/pages/meetings_page.dart';
import '../../../milestones/presentation/bloc/milestones_bloc.dart';
import '../../../milestones/presentation/pages/milestones_page.dart';
import '../../../feedback/presentation/bloc/feedback_bloc.dart';
import '../../../feedback/presentation/pages/feedback_page.dart';

class EntrepreneurHomePage extends StatelessWidget {
  const EntrepreneurHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: AppSpacing.screenPadding,
        child: ListView(
          children: [
            Text('Welcome back', style: Theme.of(context).textTheme.bodyMedium),
            AppSpacing.gapXs,
            Text(
              'Entrepreneur Workspace',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            AppSpacing.gapMd,
            Container(
              padding: AppSpacing.paddingMd,
              decoration: BoxDecoration(
                borderRadius: AppSpacing.borderRadiusLg,
                gradient: const LinearGradient(
                  colors: [Color(0xFF2563EB), Color(0xFF1D4ED8)],
                ),
              ),
              child: Text(
                'Manage documents, milestones, meetings, and investor communication in one place.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.white,
                    ),
              ),
            ),
            AppSpacing.gapLg,
            _HomeActionCard(
              icon: Icons.folder_open_outlined,
              title: 'Documents',
              subtitle: 'Upload pitch deck and supporting files',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => BlocProvider(
                      create: (_) => sl<DocumentsBloc>(),
                      child: const DocumentsPage(),
                    ),
                  ),
                );
              },
            ),
            AppSpacing.gapMd,
            _HomeActionCard(
              icon: Icons.mail_outline,
              title: 'Invitations',
              subtitle: 'View and respond to invitations',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => BlocProvider(
                      create: (_) => sl<InvitationsBloc>(),
                      child: const InvitationsPage(),
                    ),
                  ),
                );
              },
            ),
            AppSpacing.gapMd,
            _HomeActionCard(
              icon: Icons.calendar_month_outlined,
              title: 'Meetings',
              subtitle: 'Schedule and manage meetings',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => BlocProvider(
                      create: (_) => sl<MeetingsBloc>(),
                      child: const MeetingsPage(),
                    ),
                  ),
                );
              },
            ),
            AppSpacing.gapMd,
            _HomeActionCard(
              icon: Icons.flag_outlined,
              title: 'Milestones',
              subtitle: 'Track and verify milestones',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => BlocProvider(
                      create: (_) => sl<MilestonesBloc>(),
                      child: const MilestonesPage(),
                    ),
                  ),
                );
              },
            ),
            AppSpacing.gapMd,
            _HomeActionCard(
              icon: Icons.star_outline,
              title: 'Feedback',
              subtitle: 'View and submit feedback',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => BlocProvider(
                      create: (_) => sl<FeedbackBloc>(),
                      child: const FeedbackPage(),
                    ),
                  ),
                );
              },
            ),
            AppSpacing.gapLg,
            Text(
              'More collaboration tools are coming soon.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.mutedForeground,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HomeActionCard extends StatelessWidget {
  const _HomeActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
        onTap: onTap,
      ),
    );
  }
}
