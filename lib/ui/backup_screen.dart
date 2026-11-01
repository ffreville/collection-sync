import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../db/database.dart';

/// Manual backup/restore of the local sqlite file — the only copy of your
/// data on a device that never talks to a server. Export shares the file
/// through the OS share sheet (Files, Drive, email…); restore replaces the
/// current file with a picked one and asks for an app restart, since a
/// sqlite connection can't be hot-swapped safely mid-session.
class BackupScreen extends StatefulWidget {
  const BackupScreen({super.key});

  @override
  State<BackupScreen> createState() => _BackupScreenState();
}

class _BackupScreenState extends State<BackupScreen> {
  bool _busy = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sauvegarde')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            "Vos données ne vivent que sur cet appareil (et ceux avec qui vous "
            "avez synchronisé) — il n'y a pas de serveur. Exportez régulièrement "
            'une sauvegarde pour ne rien perdre en cas de perte ou de reset du '
            'téléphone.',
          ),
          const SizedBox(height: 24),
          // The backup is a copy of the sqlite *file*; on the web the
          // database lives inside the browser's storage, out of reach.
          if (kIsWeb)
            const Text(
              "La sauvegarde n'est pas encore disponible dans la version web. "
              "En attendant, synchronisez régulièrement avec un autre appareil : "
              'il garde une copie de vos collections.',
            )
          else ...[
            FilledButton.icon(
              onPressed: _busy ? null : _export,
              icon: const Icon(Icons.ios_share),
              label: const Text('Exporter une sauvegarde'),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: _busy ? null : _restore,
              icon: const Icon(Icons.restore),
              label: const Text('Restaurer une sauvegarde'),
            ),
          ],
          if (_busy)
            const Padding(
              padding: EdgeInsets.only(top: 24),
              child: Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }

  Future<void> _export() async {
    setState(() => _busy = true);
    try {
      final file = await resolveDatabaseFile();
      if (!await file.exists()) {
        _showMessage('Aucune donnée à exporter pour le moment.');
        return;
      }
      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(file.path, mimeType: 'application/x-sqlite3')],
          subject: 'Sauvegarde CollectionSync',
        ),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _restore() async {
    final picked = await FilePicker.pickFile(
      type: FileType.custom,
      allowedExtensions: ['sqlite', 'db'],
    );
    if (picked == null || !mounted) return;

    final bytes = await picked.readAsBytes();
    if (bytes.length < 16 ||
        utf8.decode(bytes.sublist(0, 15)) != 'SQLite format 3') {
      _showMessage(
        "Ce fichier ne ressemble pas à une sauvegarde CollectionSync.",
      );
      return;
    }

    if (!mounted) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Restaurer cette sauvegarde ?'),
        content: const Text(
          'Toutes les données actuelles de cet appareil seront remplacées par '
          "celles du fichier sélectionné. L'application devra être "
          'complètement fermée et rouverte ensuite.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Restaurer'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    setState(() => _busy = true);
    try {
      final db = context.read<AppDatabase>();
      await db.close();
      final file = await resolveDatabaseFile();
      if (await file.exists()) {
        await file.copy('${file.path}.bak');
      }
      await file.writeAsBytes(bytes, flush: true);
      // Also drop the -wal/-shm companion files so the copied file isn't
      // shadowed by leftover write-ahead-log pages from the old database.
      for (final suffix in ['-wal', '-shm']) {
        final sidecar = File('${file.path}$suffix');
        if (await sidecar.exists()) await sidecar.delete();
      }
      if (!mounted) return;
      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: const Text('Restauration terminée'),
          content: const Text(
            "Fermez complètement l'application (pas seulement mettre en arrière-plan) "
            'puis relancez-la pour voir les données restaurées.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Compris'),
            ),
          ],
        ),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }
}
