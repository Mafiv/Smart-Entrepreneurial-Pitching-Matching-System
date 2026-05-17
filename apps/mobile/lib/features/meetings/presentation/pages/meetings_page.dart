import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/widgets.dart';
import '../../../../core/widgets/verification_required_widget.dart';
import '../../../entrepreneur_profile/presentation/bloc/entrepreneur_profile_bloc.dart';
import '../meeting_display.dart';
import '../bloc/meetings_bloc.dart';
import 'meeting_room_page.dart';

class MeetingsPage extends StatefulWidget {
  const MeetingsPage({super.key});

  @override
  State<MeetingsPage> createState() => _MeetingsPageState();
}

class _MeetingsPageState extends State<MeetingsPage> {
  String? _status;
  String _category = 'all';

  void _refresh() {
    context.read<MeetingsBloc>().add(MeetingsRequested(status: _status));
  }

  @override
  void initState() {
    super.initState();
    context.read<MeetingsBloc>().add(const MeetingsRequested());
    context.read<EntrepreneurProfileBloc>().add(const EntrepreneurProfileLoaded());
  }

  void _scheduleDialog() {
    final title = TextEditingController();
    final when = TextEditingController(
      text: DateTime.now().add(const Duration(days: 1)).toIso8601String(),
    );
    final duration = TextEditingController(text: '30');
    final participants = TextEditingController();
    final meetingUrl = TextEditingController();

    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Schedule meeting'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppTextField(label: 'Title', controller: title),
              AppSpacing.gapSm,
              AppTextField(label: 'ScheduledAt (ISO)', controller: when),
              AppSpacing.gapSm,
              AppTextField(
                label: 'Duration minutes',
                controller: duration,
                keyboardType: TextInputType.number,
              ),
              AppSpacing.gapSm,
              AppTextField(
                label: 'Participants (comma userIds)',
                controller: participants,
              ),
              AppSpacing.gapSm,
              AppTextField(
                label: 'Meeting URL (optional)',
                controller: meetingUrl,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              final ids = participants.text
                  .split(',')
                  .map((e) => e.trim())
                  .where((e) => e.isNotEmpty)
                  .toList();
              context.read<MeetingsBloc>().add(
                    MeetingScheduled({
                      'title': title.text.trim(),
                      'scheduledAt': when.text.trim(),
                      'durationMinutes':
                          int.tryParse(duration.text.trim()) ?? 30,
                      'participants': ids,
                      if (meetingUrl.text.trim().isNotEmpty)
                        'meetingUrl': meetingUrl.text.trim(),
                    }),
                  );
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  void _setStatus(String? v) {
    setState(() => _status = v);
  }

  void _setCategory(String v) {
    setState(() => _category = v);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Meetings',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            Text(
              'Schedule & follow-ups',
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.mutedForeground,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'New meeting',
            icon: const Icon(Icons.add_rounded),
            onPressed: _scheduleDialog,
          ),
          IconButton(
            tooltip: 'Refresh',
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _refresh,
          ),
        ],
      ),
      body: SafeArea(
        child: BlocBuilder<EntrepreneurProfileBloc, EntrepreneurProfileState>(
          builder: (context, profileState) {
            final profile = profileState.profile;
            final isVerified = profile?.isVerified ?? false;

            if (!isVerified) {
              return const VerificationRequiredWidget();
            }

            return BlocBuilder<MeetingsBloc, MeetingsState>(
              builder: (context, state) {
                if (state.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (state.status == MeetingsStatus.error) {
                  return EmptyStateView(
                    icon: Icons.event_busy_rounded,
                    title: 'Could not load meetings',
                    message: state.error ?? 'Please try again.',
                    actionLabel: 'Retry',
                    onAction: _refresh,
                  );
                }
                if (state.items.isEmpty) {
                  return EmptyStateView(
                    icon: Icons.event_available_rounded,
                    title: 'No meetings',
                    message: _status != null
                        ? 'No meetings for this status filter.'
                        : 'Schedule your first meeting to align with investors.',
                    actionLabel: _status != null ? 'Clear filter' : 'Schedule',
                    onAction:
                        _status != null ? () => _setStatus(null) : _scheduleDialog,
                  );
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Padding(
                      padding: AppSpacing.screenPaddingHorizontal
                          .copyWith(top: AppSpacing.sm),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            _CategoryChip(
                              label: 'All',
                              selected: _category == 'all',
                              onTap: () => _setCategory('all'),
                            ),
                            _CategoryChip(
                              label: 'Upcoming',
                              selected: _category == 'upcoming',
                              onTap: () => _setCategory('upcoming'),
                            ),
                            _CategoryChip(
                              label: 'Past',
                              selected: _category == 'past',
                              onTap: () => _setCategory('past'),
                            ),
                          ],
                        ),
                      ),
                    ),
                    AppSpacing.gapSm,
                    Padding(
                      padding: AppSpacing.screenPaddingHorizontal,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            _StatusChip(
                              label: 'All',
                              selected: _status == null,
                              onTap: () => _setStatus(null),
                            ),
                            _StatusChip(
                              label: 'Scheduled',
                              selected: _status == 'scheduled',
                              onTap: () => _setStatus('scheduled'),
                            ),
                            _StatusChip(
                              label: 'Ongoing',
                              selected: _status == 'ongoing',
                              onTap: () => _setStatus('ongoing'),
                            ),
                            _StatusChip(
                              label: 'Completed',
                              selected: _status == 'completed',
                              onTap: () => _setStatus('completed'),
                            ),
                            _StatusChip(
                              label: 'Cancelled',
                              selected: _status == 'cancelled',
                              onTap: () => _setStatus('cancelled'),
                            ),
                          ],
                        ),
                      ),
                    ),
                    AppSpacing.gapMd,
                    Expanded(
                      child: _buildMeetingsList(state.items),
                    ),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildMeetingsList(List<dynamic> allMeetings) {
    final theme = Theme.of(context);
    final now = DateTime.now();
    final upcomingMeetings = allMeetings.where((m) => m.scheduledAt.isAfter(now)).toList();
    final pastMeetings = allMeetings.where((m) => m.scheduledAt.isBefore(now) || m.scheduledAt.isAtSameMomentAs(now)).toList();

    List<dynamic> filteredMeetings;
    if (_category == 'upcoming') {
      filteredMeetings = upcomingMeetings;
    } else if (_category == 'past') {
      filteredMeetings = pastMeetings;
    } else {
      filteredMeetings = allMeetings;
    }

    if (_status != null) {
      filteredMeetings = filteredMeetings.where((m) => m.status == _status).toList();
    }

    if (filteredMeetings.isEmpty) {
      return EmptyStateView(
        icon: Icons.event_available_rounded,
        title: 'No meetings',
        message: _category != 'all' || _status != null
            ? 'No meetings match your filters.'
            : 'Schedule your first meeting to align with investors.',
        actionLabel: _category != 'all' || _status != null ? 'Clear filters' : 'Schedule',
        onAction: _category != 'all' || _status != null
            ? () {
                setState(() {
                  _category = 'all';
                  _status = null;
                });
              }
            : _scheduleDialog,
      );
    }

    return ListView.separated(
      padding: AppSpacing.screenPadding.copyWith(bottom: 32),
      itemCount: filteredMeetings.length,
      separatorBuilder: (_, __) => AppSpacing.gapMd,
      itemBuilder: (context, i) {
        final m = filteredMeetings[i];
        final when = m.scheduledAt.toLocal().toString();
        final statusLabel = meetingStatusLabel(m.status);

        return Material(
          color: AppColors.card,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
            side: const BorderSide(color: AppColors.border),
          ),
          child: Padding(
            padding: AppSpacing.paddingMd,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        m.title.isEmpty ? 'Meeting' : m.title,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    DecoratedBox(
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(
                          AppSpacing.radiusFull,
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm,
                          vertical: AppSpacing.xs,
                        ),
                        child: Text(
                          statusLabel.toUpperCase(),
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                if (when.isNotEmpty) ...[
                  AppSpacing.gapSm,
                  Text(
                    when,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.mutedForeground,
                    ),
                  ),
                ],
                if ((m.meetingUrl ?? '').isNotEmpty) ...[
                  AppSpacing.gapXs,
                  SelectableText(
                    m.meetingUrl!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                ],
                AppSpacing.gapMd,
                Row(
                  children: [
                    if (m.status == 'scheduled' || m.status == 'ongoing')
                      Expanded(
                        child: FilledButton.tonal(
                          onPressed: m.id.isEmpty
                              ? null
                              : () {
                                  Navigator.push<void>(
                                    context,
                                    MaterialPageRoute<void>(
                                      builder: (_) => BlocProvider.value(
                                        value: context.read<MeetingsBloc>(),
                                        child: MeetingRoomPage(meetingId: m.id),
                                      ),
                                    ),
                                  );
                                },
                          style: FilledButton.styleFrom(
                              backgroundColor: AppColors.success),
                          child: const Text('Join'),
                        ),
                      ),
                    if (m.status == 'scheduled' || m.status == 'ongoing')
                      OutlinedButton(
                        onPressed: m.id.isEmpty
                            ? null
                            : () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Status updated'),
                                  ),
                                );
                              },
                        child: const Text('Complete'),
                      ),
                    OutlinedButton(
                      onPressed: m.id.isEmpty
                          ? null
                          : () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Meeting cancelled'),
                                ),
                              );
                            },
                      style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red),
                      child: const Text('Cancel'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: AppSpacing.sm),
      child: Material(
        color: selected
            ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.14)
            : AppColors.muted,
        borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            child: Text(
              label,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: selected
                        ? Theme.of(context).colorScheme.primary
                        : AppColors.mutedForeground,
                  ),
            ),
          ),
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: AppSpacing.sm),
      child: Material(
        color: selected
            ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.14)
            : AppColors.muted,
        borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            child: Text(
              label,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: selected
                        ? Theme.of(context).colorScheme.primary
                        : AppColors.mutedForeground,
                  ),
            ),
          ),
        ),
      ),
    );
  }
}
