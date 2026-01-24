import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class NavigationItem {
  const NavigationItem({
    required this.title,
    required this.icon,
    required this.routeName,
    this.useReplacement = false,
  });

  final String title;
  final IconData icon;
  final String routeName;
  final bool useReplacement;
}

class NavigationSection {
  const NavigationSection({this.title, required this.items});

  final String? title;
  final List<NavigationItem> items;
}

final List<NavigationSection> defaultNavigationSections = [
  NavigationSection(
    items: [
      NavigationItem(
        title: 'WebView Tester',
        icon: Icons.web,
        routeName: '/',
        useReplacement: true,
      ),
      NavigationItem(
        title: 'Settings Editor',
        icon: Icons.settings,
        routeName: '/settings',
      ),
      NavigationItem(
        title: 'Environment Settings',
        icon: Icons.memory,
        routeName: '/environment-settings',
      ),
      NavigationItem(
        title: 'Platform Info',
        icon: Icons.info_outline,
        routeName: '/platform-info',
      ),
    ],
  ),
  NavigationSection(
    title: 'Storage & Cookies',
    items: [
      NavigationItem(
        title: 'Cookie Manager',
        icon: Icons.cookie_outlined,
        routeName: '/storage/cookies',
      ),
      NavigationItem(
        title: 'Web Storage',
        icon: Icons.storage_outlined,
        routeName: '/storage/webstorage',
      ),
      NavigationItem(
        title: 'HTTP Auth Credentials',
        icon: Icons.lock_outline,
        routeName: '/storage/http-auth',
      ),
    ],
  ),
  NavigationSection(
    title: 'Browsers',
    items: [
      NavigationItem(
        title: '$InAppBrowser',
        icon: Icons.open_in_browser,
        routeName: '/browsers/inapp-browser',
      ),
      NavigationItem(
        title: 'Chrome/Safari Browser',
        icon: Icons.public,
        routeName: '/browsers/chrome-safari-browser',
      ),
      NavigationItem(
        title: 'Headless WebView',
        icon: Icons.visibility_off_outlined,
        routeName: '/browsers/headless',
      ),
    ],
  ),
  NavigationSection(
    title: 'Advanced',
    items: [
      NavigationItem(
        title: 'Controllers',
        icon: Icons.tune,
        routeName: '/advanced/controllers',
      ),
      NavigationItem(
        title: 'Service Controllers',
        icon: Icons.settings_applications,
        routeName: '/advanced/service-controllers',
      ),
      NavigationItem(
        title: 'Static Methods',
        icon: Icons.functions,
        routeName: '/advanced/static-methods',
      ),
    ],
  ),
  NavigationSection(
    title: 'Testing',
    items: [
      NavigationItem(
        title: 'Automated Test Runner',
        icon: Icons.science,
        routeName: '/test-automation',
      ),
      NavigationItem(
        title: 'Test Configuration',
        icon: Icons.tune,
        routeName: '/test-configuration',
      ),
    ],
  ),
  NavigationSection(
    title: 'Documentation',
    items: [
      NavigationItem(
        title: 'API Support Matrix',
        icon: Icons.grid_on,
        routeName: '/support-matrix',
      ),
      NavigationItem(
        title: 'Platform Comparison',
        icon: Icons.compare_arrows,
        routeName: '/platform-comparison',
      ),
    ],
  ),
];
