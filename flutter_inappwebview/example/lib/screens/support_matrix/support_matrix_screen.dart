import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../utils/support_checker.dart';
import '../../utils/responsive_utils.dart';
import '../../widgets/common/support_badge.dart';
import '../../widgets/common/app_drawer.dart';
import '../../widgets/common/responsive_row.dart';

/// Screen displaying a comprehensive support matrix showing all APIs with platform availability.
class SupportMatrixScreen extends StatefulWidget {
  const SupportMatrixScreen({super.key});

  @override
  State<SupportMatrixScreen> createState() => _SupportMatrixScreenState();
}

class _SupportMatrixScreenState extends State<SupportMatrixScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late List<ApiClassDefinition> _apiDefinitions;
  late SupportSummary _summary;

  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  Set<SupportedPlatform> _selectedPlatforms = {};
  bool _showOnlySupported = false;
  bool _showMethods = true;
  bool _showEvents = true;

  @override
  void initState() {
    super.initState();
    _apiDefinitions = SupportChecker.getAllApiDefinitions();
    _summary = SupportChecker.getSupportSummary();
    _tabController = TabController(length: _apiDefinitions.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  List<ApiMethodDefinition> _getFilteredMethods(ApiClassDefinition classDef) {
    if (!_showMethods) return [];

    return classDef.methods.where((method) {
      final supportedPlatforms = SupportChecker.getSupportedPlatformsForMethod(
        classDef.className,
        method.name,
      );

      // Search filter
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        if (!method.name.toLowerCase().contains(query) &&
            !method.description.toLowerCase().contains(query)) {
          return false;
        }
      }

      // Platform filter
      if (_selectedPlatforms.isNotEmpty) {
        if (!_selectedPlatforms.any((p) => supportedPlatforms.contains(p))) {
          return false;
        }
      }

      // Show only supported filter
      if (_showOnlySupported) {
        if (supportedPlatforms.isEmpty) return false;
      }

      return true;
    }).toList();
  }

  List<ApiEventDefinition> _getFilteredEvents(ApiClassDefinition classDef) {
    if (!_showEvents) return [];

    return classDef.events.where((event) {
      final supportedPlatforms = SupportChecker.getSupportedPlatformsForEvent(
        classDef.className,
        event.name,
      );

      // Search filter
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        if (!event.name.toLowerCase().contains(query) &&
            !event.description.toLowerCase().contains(query)) {
          return false;
        }
      }

      // Platform filter
      if (_selectedPlatforms.isNotEmpty) {
        if (!_selectedPlatforms.any((p) => supportedPlatforms.contains(p))) {
          return false;
        }
      }

      // Show only supported filter
      if (_showOnlySupported) {
        if (supportedPlatforms.isEmpty) return false;
      }

      return true;
    }).toList();
  }

  void _exportAsMarkdown() {
    final buffer = StringBuffer();
    buffer.writeln('# flutter_inappwebview API Support Matrix\n');
    buffer.writeln('Generated: ${DateTime.now().toIso8601String()}\n');

    // Summary
    buffer.writeln('## Summary\n');
    buffer.writeln('| Platform | Methods | Events | Total |');
    buffer.writeln('|----------|---------|--------|-------|');
    for (final platform in SupportedPlatform.values) {
      final methods = _summary.methodsPerPlatform[platform] ?? 0;
      final events = _summary.eventsPerPlatform[platform] ?? 0;
      buffer.writeln(
        '| ${platform.displayName} | $methods | $events | ${methods + events} |',
      );
    }
    buffer.writeln();

    // Per class
    for (final classDef in _apiDefinitions) {
      buffer.writeln('## ${classDef.className}\n');
      if (classDef.description.isNotEmpty) {
        buffer.writeln('${classDef.description}\n');
      }

      if (classDef.methods.isNotEmpty) {
        buffer.writeln('### Methods\n');
        buffer.writeln(
          '| Method | Android | iOS | macOS | Web | Windows | Linux |',
        );
        buffer.writeln(
          '|--------|---------|-----|-------|-----|---------|-------|',
        );
        for (final method in classDef.methods) {
          final supportedPlatforms =
              SupportChecker.getSupportedPlatformsForMethod(
                classDef.className,
                method.name,
              );
          final row = [
            '`${method.name}`',
            _platformMark(supportedPlatforms, SupportedPlatform.android),
            _platformMark(supportedPlatforms, SupportedPlatform.ios),
            _platformMark(supportedPlatforms, SupportedPlatform.macos),
            _platformMark(supportedPlatforms, SupportedPlatform.web),
            _platformMark(supportedPlatforms, SupportedPlatform.windows),
            _platformMark(supportedPlatforms, SupportedPlatform.linux),
          ];
          buffer.writeln('| ${row.join(' | ')} |');
        }
        buffer.writeln();
      }

      if (classDef.events.isNotEmpty) {
        buffer.writeln('### Events\n');
        buffer.writeln(
          '| Event | Android | iOS | macOS | Web | Windows | Linux |',
        );
        buffer.writeln(
          '|-------|---------|-----|-------|-----|---------|-------|',
        );
        for (final event in classDef.events) {
          final supportedPlatforms =
              SupportChecker.getSupportedPlatformsForEvent(
                classDef.className,
                event.name,
              );
          final row = [
            '`${event.name}`',
            _platformMark(supportedPlatforms, SupportedPlatform.android),
            _platformMark(supportedPlatforms, SupportedPlatform.ios),
            _platformMark(supportedPlatforms, SupportedPlatform.macos),
            _platformMark(supportedPlatforms, SupportedPlatform.web),
            _platformMark(supportedPlatforms, SupportedPlatform.windows),
            _platformMark(supportedPlatforms, SupportedPlatform.linux),
          ];
          buffer.writeln('| ${row.join(' | ')} |');
        }
        buffer.writeln();
      }
    }

    Clipboard.setData(ClipboardData(text: buffer.toString()));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Support matrix copied to clipboard as Markdown'),
        backgroundColor: Colors.green,
      ),
    );
  }

  String _platformMark(
    Set<SupportedPlatform> platforms,
    SupportedPlatform platform,
  ) {
    return platforms.contains(platform) ? '✅' : '❌';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('API Support Matrix'),
        actions: [
          IconButton(
            icon: const Icon(Icons.copy),
            tooltip: 'Export as Markdown',
            onPressed: _exportAsMarkdown,
          ),
          IconButton(
            icon: const Icon(Icons.compare_arrows),
            tooltip: 'Platform Comparison',
            onPressed: () {
              Navigator.pushNamed(context, '/platform-comparison');
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: _apiDefinitions.map((def) {
            return Tab(
              text: def.className.length > 18
                  ? '${def.className.substring(0, 15)}...'
                  : def.className,
            );
          }).toList(),
        ),
      ),
      drawer: AppDrawer(),
      body: Column(
        children: [
          _buildSummaryHeader(),
          _buildSearchAndFilters(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: _apiDefinitions.map((classDef) {
                return _buildClassTab(classDef);
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryHeader() {
    final isMobile = context.isMobile;
    return Container(
      padding: EdgeInsets.all(isMobile ? 8 : 12),
      color: Colors.blue.shade50,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            key: const Key('support_matrix_summary_row'),
            children: [
              const Icon(Icons.analytics, color: Colors.blue),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  'Total APIs: ${_summary.totalApis}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: isMobile ? 14 : 16,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  '(${_summary.totalMethods} methods, ${_summary.totalEvents} events)',
                  style: TextStyle(
                    color: Colors.grey.shade700,
                    fontSize: isMobile ? 12 : 14,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: SupportedPlatform.values.map((platform) {
                final total = _summary.totalApisForPlatform(platform);
                final percentage = (_summary.totalApis > 0)
                    ? (total / _summary.totalApis * 100).toStringAsFixed(0)
                    : '0';
                return Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: platform.color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: platform.color.withOpacity(0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(platform.icon, size: 16, color: platform.color),
                      const SizedBox(width: 4),
                      Text(
                        '$total ($percentage%)',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: platform.color,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilters() {
    final isMobile = context.isMobile;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Search field
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search APIs...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        setState(() => _searchQuery = '');
                      },
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 12,
              ),
            ),
            onChanged: (value) => setState(() => _searchQuery = value),
          ),
          const SizedBox(height: 8),

          // Platform filters
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                const Text(
                  'Filter by platform: ',
                  style: TextStyle(fontSize: 12),
                ),
                ...SupportedPlatform.values.map((platform) {
                  final isSelected = _selectedPlatforms.contains(platform);
                  return Padding(
                    padding: const EdgeInsets.only(right: 4),
                    child: FilterChip(
                      selected: isSelected,
                      label: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            platform.icon,
                            size: 14,
                            color: isSelected ? Colors.white : platform.color,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            platform.displayName,
                            style: TextStyle(
                              fontSize: 11,
                              color: isSelected ? Colors.white : null,
                            ),
                          ),
                        ],
                      ),
                      selectedColor: platform.color,
                      checkmarkColor: Colors.white,
                      onSelected: (selected) {
                        setState(() {
                          if (selected) {
                            _selectedPlatforms.add(platform);
                          } else {
                            _selectedPlatforms.remove(platform);
                          }
                        });
                      },
                    ),
                  );
                }),
                if (_selectedPlatforms.isNotEmpty)
                  TextButton(
                    onPressed: () => setState(() => _selectedPlatforms.clear()),
                    child: const Text('Clear', style: TextStyle(fontSize: 11)),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 4),

          // Additional filters - always in a row
          Wrap(
            spacing: 8,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              FilterChip(
                selected: _showMethods,
                label: Text(
                  'Methods',
                  style: TextStyle(fontSize: isMobile ? 10 : 11),
                ),
                onSelected: (v) => setState(() => _showMethods = v),
              ),
              FilterChip(
                selected: _showEvents,
                label: Text(
                  'Events',
                  style: TextStyle(fontSize: isMobile ? 10 : 11),
                ),
                onSelected: (v) => setState(() => _showEvents = v),
              ),
              FilterChip(
                selected: _showOnlySupported,
                label: Text(
                  'Only supported',
                  style: TextStyle(fontSize: isMobile ? 10 : 11),
                ),
                onSelected: (v) => setState(() => _showOnlySupported = v),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildClassTab(ApiClassDefinition classDef) {
    final isMobile = context.isMobile;
    final filteredMethods = _getFilteredMethods(classDef);
    final filteredEvents = _getFilteredEvents(classDef);
    final classSupportedPlatforms =
        SupportChecker.getSupportedPlatformsForClass(classDef.className);

    if (filteredMethods.isEmpty && filteredEvents.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              'No APIs match your filters',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
            ),
          ],
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(8),
      children: [
        // Class header
        Card(
          color: Colors.blue.shade50,
          child: Padding(
            padding: EdgeInsets.all(isMobile ? 8 : 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ResponsiveRow(
                  spacing: 8,
                  runSpacing: 8,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      classDef.className,
                      style: TextStyle(
                        fontSize: isMobile ? 16 : 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (isMobile)
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: SupportBadgesRow(
                          supportedPlatforms: classSupportedPlatforms,
                          compact: true,
                        ),
                      )
                    else
                      Flexible(
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: SupportBadgesRow(
                            supportedPlatforms: classSupportedPlatforms,
                            compact: true,
                          ),
                        ),
                      ),
                  ],
                ),
                if (classDef.description.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    classDef.description,
                    style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
                  ),
                ],
                const SizedBox(height: 8),
                Text(
                  'Showing ${filteredMethods.length} methods, ${filteredEvents.length} events',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                ),
              ],
            ),
          ),
        ),

        // Methods
        if (filteredMethods.isNotEmpty) ...[
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Text(
              'METHODS',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
          ...filteredMethods.map(
            (method) => _buildApiRow(
              name: method.name,
              description: method.description,
              supportedPlatforms: SupportChecker.getSupportedPlatformsForMethod(
                classDef.className,
                method.name,
              ),
              signature: method.signature,
              isStatic: method.isStatic,
              isDeprecated: method.isDeprecated,
              category: method.category,
              isMethod: true,
            ),
          ),
        ],

        // Events
        if (filteredEvents.isNotEmpty) ...[
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Text(
              'EVENTS',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
          ...filteredEvents.map(
            (event) => _buildApiRow(
              name: event.name,
              description: event.description,
              supportedPlatforms: SupportChecker.getSupportedPlatformsForEvent(
                classDef.className,
                event.name,
              ),
              signature: event.signature,
              category: event.category,
              isMethod: false,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildApiRow({
    required String name,
    required String description,
    required Set<SupportedPlatform> supportedPlatforms,
    String? signature,
    bool isStatic = false,
    bool isDeprecated = false,
    String? category,
    required bool isMethod,
  }) {
    final isMobile = context.isMobile;
    return Card(
      margin: EdgeInsets.symmetric(horizontal: isMobile ? 2 : 4, vertical: 2),
      child: ExpansionTile(
        tilePadding: EdgeInsets.symmetric(
          horizontal: isMobile ? 8 : 12,
          vertical: 0,
        ),
        childrenPadding: EdgeInsets.fromLTRB(
          isMobile ? 8 : 12,
          0,
          isMobile ? 8 : 12,
          isMobile ? 8 : 12,
        ),
        title: Row(
          children: [
            Expanded(
              child: Row(
                children: [
                  Icon(
                    isMethod ? Icons.functions : Icons.bolt,
                    size: isMobile ? 14 : 16,
                    color: isMethod ? Colors.blue : Colors.orange,
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      name,
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: isMobile ? 12 : 13,
                        decoration: isDeprecated
                            ? TextDecoration.lineThrough
                            : null,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (isStatic) ...[
                    const SizedBox(width: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 4,
                        vertical: 1,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.purple.shade100,
                        borderRadius: BorderRadius.circular(2),
                      ),
                      child: const Text(
                        'static',
                        style: TextStyle(fontSize: 9, color: Colors.purple),
                      ),
                    ),
                  ],
                  if (category != null) ...[
                    const SizedBox(width: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 4,
                        vertical: 1,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(2),
                      ),
                      child: Text(
                        category,
                        style: TextStyle(
                          fontSize: 9,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: SupportBadgesRow(
            supportedPlatforms: supportedPlatforms,
            compact: true,
          ),
        ),
        children: [
          if (description.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                description,
                style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
              ),
            ),
          if (signature != null && signature.isNotEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                signature,
                style: TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 11,
                  color: Colors.grey.shade800,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
