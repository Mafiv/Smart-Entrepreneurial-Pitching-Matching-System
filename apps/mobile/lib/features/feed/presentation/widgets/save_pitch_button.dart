import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../saved_pitches/presentation/bloc/saved_pitches_bloc.dart';

class SavePitchButton extends StatelessWidget {
  final String pitchId;
  final bool isSaved;
  final VoidCallback? onToggle;

  const SavePitchButton({
    Key? key,
    required this.pitchId,
    this.isSaved = false,
    this.onToggle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: isSaved ? 'Remove from saved' : 'Save pitch',
      icon: Icon(
        isSaved ? Icons.bookmark : Icons.bookmark_outline,
        size: 20,
      ),
      color: isSaved ? Colors.blue : null,
      onPressed: () {
        context.read<SavedPitchesBloc>().add(
              SavedPitchToggled(pitchId),
            );
        onToggle?.call();
      },
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(),
    );
  }
}
