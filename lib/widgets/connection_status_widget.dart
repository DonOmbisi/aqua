import 'package:flutter/material.dart';
import '../services/offline_supabase_service.dart';

class ConnectionStatusWidget extends StatefulWidget {
  const ConnectionStatusWidget({Key? key}) : super(key: key);

  @override
  State<ConnectionStatusWidget> createState() => _ConnectionStatusWidgetState();
}

class _ConnectionStatusWidgetState extends State<ConnectionStatusWidget> {
  final OfflineSupabaseService _offlineService = OfflineSupabaseService();
  bool _isOnline = false;
  int _pendingItems = 0;

  @override
  void initState() {
    super.initState();
    _updateStatus();
    
    // Listen to connection changes
    _offlineService.connectionChanges.listen((isOnline) {
      if (mounted) {
        setState(() {
          _isOnline = isOnline;
        });
        _updatePendingItems();
      }
    });
  }

  Future<void> _updateStatus() async {
    if (mounted) {
      setState(() {
        _isOnline = _offlineService.isOnline;
      });
      await _updatePendingItems();
    }
  }

  Future<void> _updatePendingItems() async {
    final count = await _offlineService.getPendingItemsCount();
    if (mounted) {
      setState(() {
        _pendingItems = count;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: _isOnline ? Colors.green.shade100 : Colors.orange.shade100,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _isOnline ? Icons.cloud_done : Icons.cloud_off,
            color: _isOnline ? Colors.green : Colors.orange,
            size: 16,
          ),
          const SizedBox(width: 8),
          Text(
            _isOnline ? 'Online' : 'Offline',
            style: TextStyle(
              color: _isOnline ? Colors.green.shade800 : Colors.orange.shade800,
              fontWeight: FontWeight.w500,
              fontSize: 12,
            ),
          ),
          if (_pendingItems > 0) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.blue.shade600,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '$_pendingItems pending',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
