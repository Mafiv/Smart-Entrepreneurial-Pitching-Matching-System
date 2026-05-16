import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../bloc/meetings_bloc.dart';

class MeetingRoomPage extends StatefulWidget {
  final String meetingId;
  const MeetingRoomPage({super.key, required this.meetingId});

  @override
  State<MeetingRoomPage> createState() => _MeetingRoomPageState();
}

class _MeetingRoomPageState extends State<MeetingRoomPage> {
  @override
  void initState() {
    super.initState();
    context
        .read<MeetingsBloc>()
        .add(MeetingTokenRequested(meetingId: widget.meetingId));
  }

  void _launchMeeting(String token) {
    // For now, launch a web URL with the token
    // In production, this would integrate with LiveKit Flutter SDK
    final liveKitUrl = 'https://meet.livekit.io?token=$token';
    launchUrl(Uri.parse(liveKitUrl), mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Video Meeting'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.call_end),
            color: AppColors.destructive,
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
      body: SafeArea(
        child: BlocConsumer<MeetingsBloc, MeetingsState>(
          listener: (context, state) {
            if (state.status == MeetingsStatus.tokenLoaded &&
                state.meetingToken != null) {
              _launchMeeting(state.meetingToken!);
            }
          },
          builder: (context, state) {
            if (state.isLoading) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: AppSpacing.md),
                    Text('Connecting to meeting room...'),
                  ],
                ),
              );
            }

            if (state.status == MeetingsStatus.error) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.videocam_off,
                        size: 64, color: AppColors.mutedForeground),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      'Failed to join meeting',
                      style: theme.textTheme.titleLarge,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      state.error ?? 'Please try again',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: AppColors.mutedForeground,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    FilledButton(
                      onPressed: () => context.read<MeetingsBloc>().add(
                            MeetingTokenRequested(meetingId: widget.meetingId),
                          ),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }

            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.videocam,
                      size: 64, color: AppColors.primary),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    'Meeting Room',
                    style: theme.textTheme.titleLarge,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'ID: ${widget.meetingId}',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppColors.mutedForeground,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  FilledButton.icon(
                    onPressed: () => context.read<MeetingsBloc>().add(
                          MeetingTokenRequested(meetingId: widget.meetingId),
                        ),
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('Join Meeting'),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
