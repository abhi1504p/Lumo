import 'package:flutter/material.dart';
import 'package:lumo/Pages/my_drawer/my_drawer_view.dart';
import 'app_text.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final VoidCallback? onBack;
  final List<Widget>? actions;
  final Color? backgroundColor;
  final My_drawerWidget? drawer;

  const CustomAppBar({
    super.key,
    required this.title,
    this.onBack,
    this.actions,
    this.backgroundColor, this.drawer,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = backgroundColor ?? Theme.of(context).colorScheme.primary;

    return Container(
      height: preferredSize.height + MediaQuery.of(context).padding.top, // include status bar height
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top, // push content below status bar
        left: 16,
        right: 16,
      ),
      decoration: BoxDecoration(
        color: bgColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Back Button
          if (onBack != null)
            IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black),
              onPressed: onBack,
            )
          else
            const SizedBox(width: 48), // Keep space if no back button

          // Title
          Expanded(
            child: Center(
              child: AppText.body(
                title,
                fontSize: 18,
                fontWeight: FontWeight.bold,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),

          // Actions
          if (actions != null && actions!.isNotEmpty)
            Row(children: actions!)
          else
            const SizedBox(width: 48), // Keep symmetry
        ],
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(60);
}
