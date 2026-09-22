import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../db/database.dart';

/// Every completed sync session, most recent first — who with, when, and a
/// quick summary of what happened. Complements the one-off conflict/review
/// screens with a persistent trail.
class SyncHistoryScreen extends StatelessWidget {
  const SyncHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final db = context.watch<AppDatabase>();

    return Scaffold(
      appBar: AppBar(title: const Text('Historique de synchronisation')),
      body: StreamBuilder<List<SyncLog>>(
        stream: db.watchSyncLogs(),
        builder: (context, snapshot) {
          final logs = snapshot.data ?? const [];
          if (logs.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  "Aucune synchronisation pour l'instant.",
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }
          return ListView.separated(
            itemCount: logs.length,
            separatorBuilder: (_, _) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final log = logs[index];
              final parts = [
                if (log.appliedCount > 0) '${log.appliedCount} appliqué(s)',
                if (log.pendingCount > 0) '${log.pendingCount} proposé(s)',
                if (log.conflictCount > 0) '${log.conflictCount} conflit(s)',
              ];
              return ListTile(
                leading: Icon(
                  log.direction == 'incoming' ? Icons.call_received : Icons.call_made,
                ),
                title: Text(log.peerName),
                subtitle: Text(
                  parts.isEmpty ? 'Déjà à jour' : parts.join(' · '),
                ),
                trailing: Text(_formatDateTime(log.startedAt.toLocal())),
              );
            },
          );
        },
      ),
    );
  }

  String _formatDateTime(DateTime date) {
    final d = '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}';
    final t = '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    return '$d à $t';
  }
}
