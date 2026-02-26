import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../utils/support_checker.dart';
import '../../utils/responsive_utils.dart';
import '../../widgets/common/support_badge.dart';
import '../../widgets/common/app_drawer.dart';

/// Screen for comparing API support between two platforms.
class PlatformComparisonScreen extends StatefulWidget {
  const PlatformComparisonScreen({super.key});

  @override
  State<PlatformComparisonScreen> createState() =>
      _PlatformComparisonScreenState();
}

class _PlatformComparisonScreenState extends State<PlatformComparisonScreen> {
  SupportedPlatform _platform1 = SupportedPlatform.android;
  SupportedPlatform _platform2 = SupportedPlatform.ios;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  // View mode: 'all', 'common', 'platform1Only', 'platform2Only', 'differences'
  String _viewMode = 'all';

  late List<ApiClassDefinition> _apiDefinitions;

  @override
  void initState() {
    super.initState();
    _apiDefinitions = SupportChecker.getAllApiDefinitions();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// Get comparison statistics
  _ComparisonStats _getStats() {
    int commonMethods = 0;
    int platform1OnlyMethods = 0;
    int platform2OnlyMethods = 0;
    int commonEvents = 0;
    int platform1OnlyEvents = 0;
    int platform2OnlyEvents = 0;

    for (final classDef in _apiDefinitions) {
      for (final method in classDef.methods) {
        final supported = SupportChecker.getSupportedPlatformsForMethod(
          classDef.className,
          method.name,
        );
        final p1 = supported.contains(_platform1);
        final p2 = supported.contains(_platform2);
        if (p1 && p2) {
          commonMethods++;
        } else if (p1) {
          platform1OnlyMethods++;
        } else if (p2) {
          platform2OnlyMethods++;
        }
      }
      for (final event in classDef.events) {
        final supported = SupportChecker.getSupportedPlatformsForEvent(
          classDef.className,
          event.name,
        );
        final p1 = supported.contains(_platform1);
        final p2 = supported.contains(_platform2);
        if (p1 && p2) {
          commonEvents++;
        } else if (p1) {
          platform1OnlyEvents++;
        } else if (p2) {
          platform2OnlyEvents++;
        }
      }
    }

    return _ComparisonStats(
      commonMethods: commonMethods,
      platform1OnlyMethods: platform1OnlyMethods,
      platform2OnlyMethods: platform2OnlyMethods,
      commonEvents: commonEvents,
      platform1OnlyEvents: platform1OnlyEvents,
      platform2OnlyEvents: platform2OnlyEvents,
    );
  }

  /// Filter APIs based on view mode and search
  List<_ComparisonItem> _getFilteredItems() {
    final items = <_ComparisonItem>[];

    for (final classDef in _apiDefinitions) {
      // Methods
      for (final method in classDef.methods) {
        final supported = SupportChecker.getSupportedPlatformsForMethod(
          classDef.className,
          method.name,
        );
        final p1 = supported.contains(_platform1);
        final p2 = supported.contains(_platform2);

        if (!_matchesViewMode(p1, p2)) continue;
        if (!_matchesSearch(method.name, method.description)) continue;

        items.add(
          _ComparisonItem(
            className: classDef.className,
            name: method.name,
            description: method.description,
            isMethod: true,
            isStatic: method.isStatic,
            category: method.category,
            platform1Supported: p1,
            platform2Supported: p2,
          ),
        );
      }

      // Events
      for (final event in classDef.events) {
        final supported = SupportChecker.getSupportedPlatformsForEvent(
          classDef.className,
          event.name,
        );
        final p1 = supported.contains(_platform1);
        final p2 = supported.contains(_platform2);

        if (!_matchesViewMode(p1, p2)) continue;
        if (!_matchesSearch(event.name, event.description)) continue;

        items.add(
          _ComparisonItem(
            className: classDef.className,
            name: event.name,
            description: event.description,
            isMethod: false,
            category: event.category,
            platform1Supported: p1,
            platform2Supported: p2,
          ),
        );
      }
    }

    return items;
  }

  bool _matchesViewMode(bool p1, bool p2) {
    switch (_viewMode) {
      case 'common':
        return p1 && p2;
      case 'platform1Only':
        return p1 && !p2;
      case 'platform2Only':
        return !p1 && p2;
      case 'differences':
        return p1 != p2;
      default:
        return true;
    }
  }

  bool _matchesSearch(String name, String description) {
    if (_searchQuery.isEmpty) return true;
    final query = _searchQuery.toLowerCase();
    return name.toLowerCase().contains(query) ||
        description.toLowerCase().contains(query);
  }

  void _exportComparison() {
    final stats = _getStats();
    final items = _getFilteredItems();

    final buffer = StringBuffer();
    buffer.writeln(
      '# Platform Comparison: ${_platform1.displayName} vs ${_platform2.displayName}\n',
    );
    buffer.writeln('Generated: ${DateTime.now().toIso8601String()}\n');

    buffer.writeln('## Summary\n');
    buffer.writeln(
      '| Category | ${_platform1.displayName} | ${_platform2.displayName} | Common |',
    );
    buffer.writeln('|----------|---------|---------|--------|');
    buffer.writeln(
      '| Methods | ${stats.commonMethods + stats.platform1OnlyMethods} | ${stats.commonMethods + stats.platform2OnlyMethods} | ${stats.commonMethods} |',
    );
    buffer.writeln(
      '| Events | ${stats.commonEvents + stats.platform1OnlyEvents} | ${stats.commonEvents + stats.platform2OnlyEvents} | ${stats.commonEvents} |',
    );
    buffer.writeln();

    buffer.writeln(
      '## Common APIs (${stats.commonMethods + stats.commonEvents})\n',
    );
    buffer.writeln('| Class | API | Type |');
    buffer.writeln('|-------|-----|------|');
    for (final item in items.where(
      (i) => i.platform1Supported && i.platform2Supported,
    )) {
      buffer.writeln(
        '| ${item.className} | ${item.name} | ${item.isMethod ? "Method" : "Event"} |',
      );
    }
    buffer.writeln();

    buffer.writeln(
      '## ${_platform1.displayName} Only (${stats.platform1OnlyMethods + stats.platform1OnlyEvents})\n',
    );
    buffer.writeln('| Class | API | Type |');
    buffer.writeln('|-------|-----|------|');
    for (final item in items.where(
      (i) => i.platform1Supported && !i.platform2Supported,
    )) {
      buffer.writeln(
        '| ${item.className} | ${item.name} | ${item.isMethod ? "Method" : "Event"} |',
      );
    }
    buffer.writeln();

    buffer.writeln(
      '## ${_platform2.displayName} Only (${stats.platform2OnlyMethods + stats.platform2OnlyEvents})\n',
    );
    buffer.writeln('| Class | API | Type |');
    buffer.writeln('|-------|-----|------|');
    for (final item in items.where(
      (i) => !i.platform1Supported && i.platform2Supported,
    )) {
      buffer.writeln(
        '| ${item.className} | ${item.name} | ${item.isMethod ? "Method" : "Event"} |',
      );
    }

    Clipboard.setData(ClipboardData(text: buffer.toString()));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Comparison exported to clipboard as Markdown'),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final stats = _getStats();
    final items = _getFilteredItems();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Platform Comparison'),
        actions: [
          IconButton(
            icon: const Icon(Icons.copy),
            tooltip: 'Export as Markdown',
            onPressed: _exportComparison,
          ),
        ],
      ),
      drawer: AppDrawer(),
      body: Column(
        children: [
          // Platform selectors
          _buildPlatformSelectors(),

          // Statistics
          _buildStatistics(stats),

          // View mode selector
          _buildViewModeSelector(stats),

          // Search
          _buildSearchBar(),

          // Results
          Expanded(
            child: items.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off,
                          size: 64,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No APIs match your criteria',
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                  )
                : _buildComparisonList(items),
          ),
        ],
      ),
    );
  }

  Widget _buildPlatformSelectors() {
    return Container(
      padding: const EdgeInsets.all(12),
      color: Colors.blue.shade50,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final swapWidget = Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.compare_arrows, color: Colors.blue),
              const SizedBox(height: 4),
              TextButton(
                onPressed: () {
                  setState(() {
                    final temp = _platform1;
                    _platform1 = _platform2;
                    _platform2 = temp;
                  });
                },
                child: const Text('Swap', style: TextStyle(fontSize: 12)),
              ),
            ],
          );

          // Always use Row layout - expand to fill available space
          return Row(
            key: const Key('platform_comparison_selectors_row'),
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: _buildPlatformDropdown(
                  value: _platform1,
                  label: 'Platform 1',
                  onChanged: (p) => setState(() => _platform1 = p!),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: swapWidget,
              ),
              Expanded(
                child: _buildPlatformDropdown(
                  value: _platform2,
                  label: 'Platform 2',
                  onChanged: (p) => setState(() => _platform2 = p!),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildPlatformDropdown({
    required SupportedPlatform value,
    required String label,
    required ValueChanged<SupportedPlatform?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: value.color.withOpacity(0.5)),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<SupportedPlatform>(
              value: value,
              isExpanded: true,
              items: SupportedPlatform.values.map((p) {
                return DropdownMenuItem(
                  value: p,
                  child: Row(
                    children: [
                      Icon(p.icon, size: 18, color: p.color),
                      const SizedBox(width: 8),
                      Text(p.displayName),
                    ],
                  ),
                );
              }).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatistics(_ComparisonStats stats) {
    final p1Total =
        stats.commonMethods +
        stats.platform1OnlyMethods +
        stats.commonEvents +
        stats.platform1OnlyEvents;
    final p2Total =
        stats.commonMethods +
        stats.platform2OnlyMethods +
        stats.commonEvents +
        stats.platform2OnlyEvents;
    final commonTotal = stats.commonMethods + stats.commonEvents;

    return Container(
      padding: const EdgeInsets.all(12),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: IntrinsicWidth(
          child: Row(
            key: const Key('platform_comparison_stats_row'),
            children: [
              _buildStatCard(
                _platform1.displayName,
                p1Total.toString(),
                _platform1.color,
                _platform1.icon,
              ),
              const SizedBox(width: 12),
              _buildStatCard(
                'Common',
                commonTotal.toString(),
                Colors.green,
                Icons.handshake,
              ),
              const SizedBox(width: 12),
              _buildStatCard(
                _platform2.displayName,
                p2Total.toString(),
                _platform2.color,
                _platform2.icon,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(
    String label,
    String value,
    Color color,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(label, style: TextStyle(fontSize: 11, color: color)),
        ],
      ),
    );
  }

  Widget _buildViewModeSelector(_ComparisonStats stats) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          _buildViewModeChip('all', 'All', null, Icons.list),
          _buildViewModeChip(
            'common',
            'Common (${stats.commonMethods + stats.commonEvents})',
            Colors.green,
            Icons.handshake,
          ),
          _buildViewModeChip(
            'platform1Only',
            '${_platform1.displayName} Only (${stats.platform1OnlyMethods + stats.platform1OnlyEvents})',
            _platform1.color,
            _platform1.icon,
          ),
          _buildViewModeChip(
            'platform2Only',
            '${_platform2.displayName} Only (${stats.platform2OnlyMethods + stats.platform2OnlyEvents})',
            _platform2.color,
            _platform2.icon,
          ),
          _buildViewModeChip(
            'differences',
            'Differences',
            Colors.orange,
            Icons.difference,
          ),
        ],
      ),
    );
  }

  Widget _buildViewModeChip(
    String mode,
    String label,
    Color? color,
    IconData icon,
  ) {
    final isSelected = _viewMode == mode;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        selected: isSelected,
        label: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 14,
              color: isSelected ? Colors.white : (color ?? Colors.grey),
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: isSelected ? Colors.white : null,
              ),
            ),
          ],
        ),
        selectedColor: color ?? Colors.blue,
        onSelected: (_) => setState(() => _viewMode = mode),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search APIs...',
          prefixIcon: const Icon(Icons.search, size: 20),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, size: 20),
                  onPressed: () {
                    _searchController.clear();
                    setState(() => _searchQuery = '');
                  },
                )
              : null,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 10,
          ),
        ),
        onChanged: (v) => setState(() => _searchQuery = v),
      ),
    );
  }

  Widget _buildComparisonList(List<_ComparisonItem> items) {
    // Group by class
    final grouped = <String, List<_ComparisonItem>>{};
    for (final item in items) {
      grouped.putIfAbsent(item.className, () => []).add(item);
    }

    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: grouped.length,
      itemBuilder: (context, index) {
        final className = grouped.keys.elementAt(index);
        final classItems = grouped[className]!;

        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ExpansionTile(
            initiallyExpanded: grouped.length <= 3,
            title: Row(
              children: [
                const Icon(Icons.class_, size: 18, color: Colors.blue),
                const SizedBox(width: 8),
                Text(
                  className,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                Text(
                  '${classItems.length} APIs',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
              ],
            ),
            children: classItems
                .map((item) => _buildComparisonRow(item))
                .toList(),
          ),
        );
      },
    );
  }

  Widget _buildComparisonRow(_ComparisonItem item) {
    Color rowColor;
    IconData statusIcon;
    String statusText;

    if (item.platform1Supported && item.platform2Supported) {
      rowColor = Colors.green.shade50;
      statusIcon = Icons.check_circle;
      statusText = 'Both';
    } else if (item.platform1Supported) {
      rowColor = _platform1.color.withOpacity(0.1);
      statusIcon = Icons.arrow_back;
      statusText = '${_platform1.displayName} only';
    } else if (item.platform2Supported) {
      rowColor = _platform2.color.withOpacity(0.1);
      statusIcon = Icons.arrow_forward;
      statusText = '${_platform2.displayName} only';
    } else {
      rowColor = Colors.grey.shade100;
      statusIcon = Icons.block;
      statusText = 'Neither';
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = ResponsiveBreakpoints.isMobileWidth(
          constraints.maxWidth,
        );

        if (isMobile) {
          return Container(
            color: rowColor,
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      item.isMethod ? Icons.functions : Icons.bolt,
                      size: 16,
                      color: item.isMethod ? Colors.blue : Colors.orange,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        item.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
                if (item.description.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    item.description,
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    SupportBadge(
                      platform: _platform1,
                      isSupported: item.platform1Supported,
                      compact: true,
                    ),
                    Tooltip(
                      message: statusText,
                      child: Icon(
                        statusIcon,
                        size: 18,
                        color:
                            item.platform1Supported && item.platform2Supported
                            ? Colors.green
                            : item.platform1Supported
                            ? _platform1.color
                            : item.platform2Supported
                            ? _platform2.color
                            : Colors.grey,
                      ),
                    ),
                    SupportBadge(
                      platform: _platform2,
                      isSupported: item.platform2Supported,
                      compact: true,
                    ),
                  ],
                ),
              ],
            ),
          );
        }

        return Container(
          color: rowColor,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Expanded(
                flex: 3,
                child: Row(
                  children: [
                    Icon(
                      item.isMethod ? Icons.functions : Icons.bolt,
                      size: 16,
                      color: item.isMethod ? Colors.blue : Colors.orange,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 13,
                            ),
                          ),
                          if (item.description.isNotEmpty)
                            Text(
                              item.description,
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey.shade600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Center(
                  child: SupportBadge(
                    platform: _platform1,
                    isSupported: item.platform1Supported,
                    compact: true,
                  ),
                ),
              ),
              Expanded(
                child: Center(
                  child: Tooltip(
                    message: statusText,
                    child: Icon(
                      statusIcon,
                      size: 18,
                      color: item.platform1Supported && item.platform2Supported
                          ? Colors.green
                          : item.platform1Supported
                          ? _platform1.color
                          : item.platform2Supported
                          ? _platform2.color
                          : Colors.grey,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Center(
                  child: SupportBadge(
                    platform: _platform2,
                    isSupported: item.platform2Supported,
                    compact: true,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ComparisonStats {
  final int commonMethods;
  final int platform1OnlyMethods;
  final int platform2OnlyMethods;
  final int commonEvents;
  final int platform1OnlyEvents;
  final int platform2OnlyEvents;

  _ComparisonStats({
    required this.commonMethods,
    required this.platform1OnlyMethods,
    required this.platform2OnlyMethods,
    required this.commonEvents,
    required this.platform1OnlyEvents,
    required this.platform2OnlyEvents,
  });
}

class _ComparisonItem {
  final String className;
  final String name;
  final String description;
  final bool isMethod;
  final bool isStatic;
  final String? category;
  final bool platform1Supported;
  final bool platform2Supported;

  _ComparisonItem({
    required this.className,
    required this.name,
    required this.description,
    required this.isMethod,
    this.isStatic = false,
    this.category,
    required this.platform1Supported,
    required this.platform2Supported,
  });
}
