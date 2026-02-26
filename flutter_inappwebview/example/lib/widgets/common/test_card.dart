import 'package:flutter/material.dart';
import 'package:flutter_inappwebview_example/models/test_case.dart';

/// Test status enum
enum TestStatus { none, running, passed, failed }

/// Widget displaying a test case with run button, status indicator, and expandable details
class TestCard extends StatefulWidget {
  final TestCase testCase;
  final VoidCallback onRun;
  final TestStatus status;

  const TestCard({
    super.key,
    required this.testCase,
    required this.onRun,
    this.status = TestStatus.none,
  });

  @override
  State<TestCard> createState() => _TestCardState();
}

class _TestCardState extends State<TestCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8),
      child: InkWell(
        onTap: () {
          setState(() {
            _isExpanded = !_isExpanded;
          });
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.testCase.title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.testCase.description,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  _buildStatusIndicator(),
                  IconButton(
                    icon: const Icon(Icons.play_arrow),
                    onPressed: widget.onRun,
                    color: Theme.of(context).primaryColor,
                  ),
                ],
              ),
              if (_isExpanded) ...[const Divider(), _buildDetails()],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusIndicator() {
    switch (widget.status) {
      case TestStatus.running:
        return const SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(strokeWidth: 2),
        );
      case TestStatus.passed:
        return const Icon(Icons.check_circle, color: Colors.green);
      case TestStatus.failed:
        return const Icon(Icons.error, color: Colors.red);
      case TestStatus.none:
        return const SizedBox.shrink();
    }
  }

  Widget _buildDetails() {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDetailRow('Category:', widget.testCase.category.name),
          const SizedBox(height: 4),
          _buildDetailRow('Complexity:', widget.testCase.complexity.name),
          const SizedBox(height: 8),
          const Text(
            'Supported Platforms:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Wrap(
            spacing: 4,
            children: widget.testCase.supportedPlatforms
                .map(
                  (p) => Chip(
                    label: Text(p, style: const TextStyle(fontSize: 12)),
                    padding: const EdgeInsets.all(2),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(width: 4),
        Text(value),
      ],
    );
  }
}
