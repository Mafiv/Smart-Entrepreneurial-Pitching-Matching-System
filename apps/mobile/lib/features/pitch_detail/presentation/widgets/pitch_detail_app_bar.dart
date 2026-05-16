import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

class PitchDetailAppBar extends StatelessWidget {
  final bool isSaved;
  final VoidCallback onSaveToggle;
  final bool isTogglingState;

  const PitchDetailAppBar({
    super.key,
    required this.isSaved,
    required this.onSaveToggle,
    required this.isTogglingState,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: const Text('Pitch Details'),
      centerTitle: false,
      actions: [
        if (isTogglingState)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Center(
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                ),
              ),
            ),
          )
        else
          IconButton(
            icon: Icon(
              isSaved ? Icons.bookmark : Icons.bookmark_border,
              color: isSaved ? AppColors.primary : null,
            ),
            onPressed: onSaveToggle,
            tooltip: isSaved ? 'Remove from saved' : 'Save pitch',
          ),
      ],
    );
  }
}
