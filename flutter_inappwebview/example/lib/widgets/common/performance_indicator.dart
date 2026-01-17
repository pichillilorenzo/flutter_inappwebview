import 'package:flutter/material.dart';
import 'package:flutter_inappwebview_example/utils/constants.dart';

/// Widget showing performance duration with color coding
class PerformanceIndicator extends StatelessWidget {
  final Duration duration;

  const PerformanceIndicator({super.key, required this.duration});

  Color get _color {
    final ms = duration.inMilliseconds;
    if (ms < PerformanceThresholds.fast) {
      return PerformanceColors.fast;
    } else if (ms < PerformanceThresholds.medium) {
      return PerformanceColors.medium;
    } else {
      return PerformanceColors.slow;
    }
  }

  String get _durationText {
    final ms = duration.inMilliseconds;
    if (ms < 1000) {
      return '${ms}ms';
    } else if (ms < 60000) {
      return '${(ms / 1000).toStringAsFixed(2)}s';
    } else {
      final minutes = duration.inMinutes;
      final seconds = duration.inSeconds % 60;
      return '$minutes:${seconds.toString().padLeft(2, '0')}';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.timer, size: 14, color: _color),
          const SizedBox(width: 4),
          Text(
            _durationText,
            style: TextStyle(
              fontSize: 12,
              color: _color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
