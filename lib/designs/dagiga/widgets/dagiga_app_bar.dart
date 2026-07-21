import 'dart:ui';

import 'package:flutter/material.dart';

import '../constants/dagiga_constants.dart';
import 'dagiga_icons.dart';

/// Top chrome matching Dagiga Figma: back + label | title | Save pill.
class DagigaAppBar extends StatelessWidget implements PreferredSizeWidget {
  /// Creates a [DagigaAppBar].
  const DagigaAppBar({
    super.key,
    required this.title,
    required this.onBack,
    required this.onSave,
    this.backLabel = 'Image',
    this.saveLabel = 'Save',
    this.saveEnabled = true,
    this.backgroundColor = kDagigaBackground,
  });

  /// Center title (e.g. "Add text").
  final String title;

  /// Back navigation label next to the chevron.
  final String backLabel;

  /// Save button label.
  final String saveLabel;

  /// When false, Save matches Figma’s 50% opacity disabled state.
  final bool saveEnabled;

  /// Called when back is tapped.
  final VoidCallback onBack;

  /// Called when Save is tapped.
  final VoidCallback onSave;

  /// App bar background.
  final Color backgroundColor;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: backgroundColor,
      elevation: 0,
      scrolledUnderElevation: 0,
      automaticallyImplyLeading: false,
      centerTitle: true,
      titleSpacing: 0,
      leadingWidth: 120,
      // Gives enough horizontal room for the back button & text label

      // 1. LEFT SLOT
      leading: Align(
        alignment: Alignment.centerLeft,
        child: Padding(
          padding: const EdgeInsets.only(left: 12),
          child: InkWell(
            onTap: onBack,
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DagigaIcons.chevronBack(width: 11, height: 7),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      backLabel,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        height: 1.2,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),

      // 2. CENTER SLOT
      title: Text(
        title,
        textAlign: TextAlign.center,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.w400,
          height: 1.2,
        ),
      ),

      // 3. RIGHT SLOT
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 16),
          child: Center(
            child: Opacity(
              opacity: saveEnabled ? 1 : 0.5,
              child: _SavePillButton(
                label: saveLabel,
                onPressed: saveEnabled ? onSave : null,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _SavePillButton extends StatelessWidget {
  const _SavePillButton({required this.label, required this.onPressed});

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10000),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Material(
          color: kDagigaAccent,
          child: InkWell(
            onTap: onPressed,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                label,
                style: const TextStyle(
                  color: kDagigaAccentForeground,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  height: 1.2,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
