import 'package:flutter/material.dart';
import 'status_badge.dart';

class SyncBadge extends StatelessWidget {
  final String label;
  final bool failed;

  const SyncBadge({
    super.key,
    required this.label,
    this.failed = false,
  });

  @override
  Widget build(BuildContext context) {
    return StatusBadge(
      status: failed ? 'sync_failed' : 'pending_sync',
      label: label,
    );
  }
}
