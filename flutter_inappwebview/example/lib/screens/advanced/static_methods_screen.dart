import 'package:flutter/material.dart';
import 'package:flutter_inappwebview_example/widgets/webview/static_method_tester_widget.dart';
import 'package:flutter_inappwebview_example/widgets/common/app_drawer.dart';

/// Screen for testing static methods from various InAppWebView classes
/// without requiring a WebView instance.
class StaticMethodsScreen extends StatelessWidget {
  const StaticMethodsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Static Methods'),
        backgroundColor: Colors.blue,
      ),
      drawer: AppDrawer(),
      body: const StaticMethodTesterWidget(),
    );
  }
}
