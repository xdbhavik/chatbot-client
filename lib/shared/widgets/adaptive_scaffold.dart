import 'package:flutter/material.dart';

import '../../core/constants/app_constants.dart';
import '../extensions/context_extensions.dart';
import 'app_drawer.dart';

class AdaptiveScaffold extends StatelessWidget {
  const AdaptiveScaffold({
    super.key,
    required this.body,
    this.title,
    this.actions,
  });

  final Widget body;
  final String? title;
  final List<Widget>? actions;

  @override
  Widget build(BuildContext context) {
    if (context.isDesktop) {
      return Scaffold(
        body: Row(
          children: [
            const SizedBox(width: AppConstants.sidebarWidth, child: AppDrawer()),
            Expanded(child: body),
          ],
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(title ?? 'LM Studio Chat'), actions: actions),
      drawer: const Drawer(child: AppDrawer()),
      body: body,
    );
  }
}
