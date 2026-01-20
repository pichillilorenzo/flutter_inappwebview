import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_inappwebview_example/models/navigation_section.dart';

class AppDrawer extends StatelessWidget {
  AppDrawer({super.key, List<NavigationSection>? sections})
    : sections = sections ?? defaultNavigationSections;

  final List<NavigationSection> sections;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: _buildChildren(context),
      ),
    );
  }

  List<Widget> _buildChildren(BuildContext context) {
    final children = <Widget>[
      DrawerHeader(
        decoration: const BoxDecoration(color: Colors.blue),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              '$InAppWebView',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Text(
              'Test Suite',
              style: TextStyle(color: Colors.white70, fontSize: 14),
            ),
          ],
        ),
      ),
    ];

    for (var i = 0; i < sections.length; i++) {
      final section = sections[i];
      if (i > 0) {
        children.add(const Divider());
      }
      if (section.title != null) {
        children.add(
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              section.title!,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      }
      for (final item in section.items) {
        children.add(
          ListTile(
            title: Text(item.title),
            leading: Icon(item.icon),
            onTap: () => _navigateTo(context, item),
          ),
        );
      }
    }

    return children;
  }

  void _navigateTo(BuildContext context, NavigationItem item) {
    if (item.useReplacement) {
      Navigator.pushReplacementNamed(context, item.routeName);
      return;
    }
    Navigator.pushNamed(context, item.routeName);
  }
}
