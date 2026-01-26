import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_inappwebview_example/models/navigation_section.dart';
import 'package:flutter_inappwebview_example/utils/responsive_utils.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';

class AppDrawer extends StatelessWidget {
  AppDrawer({super.key, List<NavigationSection>? sections})
    : sections = sections ?? defaultNavigationSections;

  final List<NavigationSection> sections;

  @override
  Widget build(BuildContext context) {
    final isMobile = context.isMobile;
    return PointerInterceptor(
      child: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: _buildChildren(context, isMobile),
        ),
      ),
    );
  }

  List<Widget> _buildChildren(BuildContext context, bool isMobile) {
    final headerTitleSize = isMobile ? 22.0 : 24.0;
    final headerSubtitleSize = isMobile ? 12.0 : 14.0;
    final sectionTitleSize = isMobile ? 11.0 : 12.0;
    final itemTitleSize = isMobile ? 13.0 : 14.0;
    final tilePadding = EdgeInsets.symmetric(horizontal: 16);
    final tileVerticalPadding = 8.0;
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
                fontSize: headerTitleSize,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'Test Suite',
              style: TextStyle(
                color: Colors.white70,
                fontSize: headerSubtitleSize,
              ),
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
                fontSize: sectionTitleSize,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      }
      for (final item in section.items) {
        children.add(
          ListTile(
            contentPadding: tilePadding,
            minVerticalPadding: tileVerticalPadding,
            title: Text(item.title, style: TextStyle(fontSize: itemTitleSize)),
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
