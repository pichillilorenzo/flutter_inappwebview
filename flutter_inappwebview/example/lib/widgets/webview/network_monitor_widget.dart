import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:flutter_inappwebview_example/models/network_request.dart';
import 'package:flutter_inappwebview_example/providers/network_monitor.dart';

/// Widget to display and monitor network requests
class NetworkMonitorWidget extends StatelessWidget {
  const NetworkMonitorWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(child: _buildHeader(context)),
        _buildRequestList(),
      ],
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
      ),
      child: Row(
        children: [
          const Text(
            'Network',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(width: 16),
          Consumer<NetworkMonitor>(
            builder: (context, monitor, child) {
              return Row(
                children: [
                  Switch(
                    value: monitor.isMonitoring,
                    onChanged: (_) {
                      monitor.toggleMonitoring();
                    },
                  ),
                  const Text('Monitor Network'),
                ],
              );
            },
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.clear_all),
            tooltip: 'Clear',
            onPressed: () {
              context.read<NetworkMonitor>().clearRequests();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildRequestList() {
    return Consumer<NetworkMonitor>(
      builder: (context, monitor, child) {
        final requests = monitor.requests;

        if (requests.isEmpty) {
          return const SliverFillRemaining(
            hasScrollBody: false,
            child: Center(
              child: Text(
                'No network requests yet',
                style: TextStyle(color: Colors.grey),
              ),
            ),
          );
        }

        return SliverList(
          delegate: SliverChildBuilderDelegate((context, index) {
            final request = requests[requests.length - 1 - index];
            return _buildRequestItem(request);
          }, childCount: requests.length),
        );
      },
    );
  }

  Widget _buildRequestItem(NetworkRequest request) {
    final timeFormat = DateFormat('HH:mm:ss');

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ExpansionTile(
        leading: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: _getMethodColor(request.method),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            request.method,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        title: Text(
          request.url,
          style: const TextStyle(fontSize: 13),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Row(
          children: [
            Text(
              timeFormat.format(request.timestamp),
              style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
            ),
            const SizedBox(width: 8),
            if (request.duration != null)
              Text(
                '${request.duration!.inMilliseconds}ms',
                style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
              ),
          ],
        ),
        trailing: request.statusCode != null
            ? Chip(
                label: Text(
                  request.statusCode.toString(),
                  style: const TextStyle(fontSize: 11),
                ),
                backgroundColor: _getStatusCodeColor(request.statusCode!),
                padding: EdgeInsets.zero,
              )
            : const Chip(
                label: Text('Pending', style: TextStyle(fontSize: 11)),
                backgroundColor: Colors.orange,
                padding: EdgeInsets.zero,
              ),
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            color: Colors.grey.shade50,
            width: double.infinity,
            child: _buildRequestDetails(request),
          ),
        ],
      ),
    );
  }

  Widget _buildRequestDetails(NetworkRequest request) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (request.headers != null && request.headers!.isNotEmpty) ...[
          const Text(
            'Request Headers',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          ),
          const SizedBox(height: 4),
          ...request.headers!.entries.map((entry) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Text(
                '${entry.key}: ${entry.value}',
                style: const TextStyle(fontSize: 11),
              ),
            );
          }),
          const SizedBox(height: 8),
        ],
        if (request.body != null) ...[
          const Text(
            'Request Body',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              request.body!,
              style: const TextStyle(fontSize: 11, fontFamily: 'monospace'),
            ),
          ),
          const SizedBox(height: 8),
        ],
        if (request.response != null) ...[
          const Text(
            'Response',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              request.response!,
              style: const TextStyle(fontSize: 11, fontFamily: 'monospace'),
            ),
          ),
        ],
      ],
    );
  }

  Color _getMethodColor(String method) {
    switch (method.toUpperCase()) {
      case 'GET':
        return Colors.blue;
      case 'POST':
        return Colors.green;
      case 'PUT':
        return Colors.orange;
      case 'DELETE':
        return Colors.red;
      case 'PATCH':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  Color _getStatusCodeColor(int statusCode) {
    if (statusCode >= 200 && statusCode < 300) {
      return Colors.green.shade100;
    } else if (statusCode >= 300 && statusCode < 400) {
      return Colors.blue.shade100;
    } else if (statusCode >= 400 && statusCode < 500) {
      return Colors.orange.shade100;
    } else if (statusCode >= 500) {
      return Colors.red.shade100;
    }
    return Colors.grey.shade100;
  }
}
