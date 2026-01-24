import 'package:flutter/material.dart';
import '../utils/constants.dart';
import '../utils/support_checker.dart';
import '../models/test_case.dart';
import '../utils/test_registry.dart';
import '../widgets/common/test_card.dart';
import '../widgets/common/platform_filter.dart';
import '../widgets/common/empty_state.dart';

/// Screen displaying all tests for a specific category.
class CategoryScreen extends StatefulWidget {
  final TestCategory category;

  const CategoryScreen({super.key, required this.category});

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  List<SupportedPlatform> _selectedPlatforms = [];

  @override
  Widget build(BuildContext context) {
    final allTests = TestRegistry.getTestsByCategory(widget.category);
    final filteredTests = _filterTests(allTests);

    return Scaffold(
      appBar: AppBar(
        title: Text('${_getCategoryName()} Tests'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
            tooltip: 'Filter by platform',
          ),
        ],
      ),
      body: Column(
        children: [
          if (_selectedPlatforms.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(8.0),
              color: Theme.of(context).primaryColor.withOpacity(0.1),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Filtered: ${_selectedPlatforms.map((p) => p.displayName).join(", ")}',
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 8),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _selectedPlatforms = [];
                      });
                    },
                    child: const Text('Clear'),
                  ),
                ],
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Icon(_getCategoryIcon(), color: Theme.of(context).primaryColor),
                const SizedBox(width: 8),
                Text(
                  '${filteredTests.length} test${filteredTests.length != 1 ? 's' : ''}',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
          ),
          Expanded(
            child: filteredTests.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.all(16.0),
                    itemCount: filteredTests.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: TestCard(
                          testCase: filteredTests[index],
                          onRun: () {
                            // TODO: Execute test in Phase 3
                          },
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  List<TestCase> _filterTests(List<TestCase> tests) {
    if (_selectedPlatforms.isEmpty) {
      return tests;
    }

    return tests.where((test) {
      return _selectedPlatforms.any(
        (platform) => test.supportedPlatforms.contains(platform.name),
      );
    }).toList();
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter by Platform'),
        content: SingleChildScrollView(
          child: PlatformFilter(
            selectedPlatforms: _selectedPlatforms,
            onChanged: (newSelection) {
              setState(() {
                _selectedPlatforms = newSelection;
              });
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                _selectedPlatforms = [];
              });
              Navigator.pop(context);
            },
            child: const Text('Close'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return EmptyState(
      icon: Icons.search_off,
      title: 'No tests available',
      description: _selectedPlatforms.isNotEmpty
          ? 'No tests match the selected platforms'
          : 'No tests registered for this category',
    );
  }

  String _getCategoryName() {
    switch (widget.category) {
      case TestCategory.navigation:
        return 'Navigation';
      case TestCategory.javascript:
        return 'JavaScript';
      case TestCategory.content:
        return 'Content';
      case TestCategory.storage:
        return 'Storage & Cookies';
      case TestCategory.advanced:
        return 'Advanced Features';
      case TestCategory.browsers:
        return 'Browsers';
    }
  }

  IconData _getCategoryIcon() {
    switch (widget.category) {
      case TestCategory.navigation:
        return Icons.navigation;
      case TestCategory.javascript:
        return Icons.code;
      case TestCategory.content:
        return Icons.article;
      case TestCategory.storage:
        return Icons.storage;
      case TestCategory.advanced:
        return Icons.settings;
      case TestCategory.browsers:
        return Icons.web;
    }
  }
}
