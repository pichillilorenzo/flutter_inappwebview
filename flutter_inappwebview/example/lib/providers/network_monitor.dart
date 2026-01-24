import 'package:flutter/foundation.dart';
import 'package:flutter_inappwebview_example/models/network_request.dart';

/// Network monitor for tracking network requests
class NetworkMonitor extends ChangeNotifier {
  final List<NetworkRequest> _requests = [];
  bool _isMonitoring = false;

  /// Get all network requests
  List<NetworkRequest> get requests => List.unmodifiable(_requests);

  /// Check if monitoring is enabled
  bool get isMonitoring => _isMonitoring;

  /// Toggle network monitoring
  void toggleMonitoring() {
    _isMonitoring = !_isMonitoring;
    notifyListeners();
  }

  /// Add a network request to the monitor
  void addRequest(NetworkRequest request) {
    _requests.add(request);
    notifyListeners();
  }

  /// Update an existing request with response data
  void updateRequest(
    String id, {
    String? response,
    int? statusCode,
    Duration? duration,
  }) {
    final index = _requests.indexWhere((req) => req.id == id);
    if (index != -1) {
      _requests[index] = _requests[index].copyWith(
        response: response,
        statusCode: statusCode,
        duration: duration,
      );
      notifyListeners();
    }
  }

  /// Clear all network requests
  void clearRequests() {
    _requests.clear();
    notifyListeners();
  }
}
