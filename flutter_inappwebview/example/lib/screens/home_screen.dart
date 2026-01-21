import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import '../widgets/common/app_drawer.dart';
import '../utils/constants.dart';
import '../utils/test_registry.dart';
import '../utils/platform_utils.dart';
import 'category_screen.dart';
import 'platform_info_screen.dart';

/// Main dashboard screen showing all test categories.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${InAppWebView} Test Suite'),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Icon(PlatformUtils.getPlatformIcon(), size: 20),
                const SizedBox(width: 8),
                Text(
                  PlatformUtils.getPlatformName(),
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ),
          ),
        ],
      ),
      drawer: AppDrawer(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Test Categories',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Select a category to run tests',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: SingleChildScrollView(
                child: GridView.count(
                  crossAxisCount: 2,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    _buildCategoryCard(
                      context,
                      category: TestCategory.navigation,
                      title: 'Navigation',
                      icon: Icons.navigation,
                      color: Colors.blue,
                    ),
                    _buildCategoryCard(
                      context,
                      category: TestCategory.javascript,
                      title: 'JavaScript',
                      icon: Icons.code,
                      color: Colors.amber,
                    ),
                    _buildCategoryCard(
                      context,
                      category: TestCategory.content,
                      title: 'Content',
                      icon: Icons.article,
                      color: Colors.green,
                    ),
                    _buildCategoryCard(
                      context,
                      category: TestCategory.storage,
                      title: 'Storage & Cookies',
                      icon: Icons.storage,
                      color: Colors.purple,
                    ),
                    _buildCategoryCard(
                      context,
                      category: TestCategory.advanced,
                      title: 'Advanced Features',
                      icon: Icons.settings,
                      color: Colors.orange,
                    ),
                    _buildCategoryCard(
                      context,
                      category: TestCategory.browsers,
                      title: 'Browsers',
                      icon: Icons.web,
                      color: Colors.teal,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const PlatformInfoScreen()),
          );
        },
        tooltip: 'Platform Info',
        child: const Icon(Icons.info_outline),
      ),
    );
  }

  Widget _buildCategoryCard(
    BuildContext context, {
    required TestCategory category,
    required String title,
    required IconData icon,
    required Color color,
  }) {
    final testCount = TestRegistry.getTestsByCategory(category).length;

    return Card(
      elevation: 4,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CategoryScreen(category: category),
            ),
          );
        },
        borderRadius: BorderRadius.circular(4),
        child: Container(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 48, color: color),
              const SizedBox(height: 12),
              Text(
                title,
                textAlign: TextAlign.center,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$testCount test${testCount != 1 ? 's' : ''}',
                  style: TextStyle(
                    fontSize: 12,
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
