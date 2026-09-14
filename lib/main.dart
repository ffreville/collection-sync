import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'db/database.dart';
import 'sync/device_identity.dart';
import 'sync/sync_service.dart';
import 'ui/home_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const CollectionSyncApp());
}

class CollectionSyncApp extends StatelessWidget {
  const CollectionSyncApp({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<_AppServices>(
      future: _AppServices.init(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return MaterialApp(
            home: Scaffold(
              body: Center(child: Text('Erreur de démarrage : ${snapshot.error}')),
            ),
          );
        }
        final services = snapshot.data;
        if (services == null) {
          return const MaterialApp(
            home: Scaffold(body: Center(child: CircularProgressIndicator())),
          );
        }
        return MultiProvider(
          providers: [
            Provider<AppDatabase>.value(value: services.db),
            ChangeNotifierProvider<SyncService>.value(value: services.sync),
          ],
          child: MaterialApp(
            title: 'CollectionSync',
            theme: ThemeData(colorSchemeSeed: Colors.indigo, useMaterial3: true),
            home: const HomeScreen(),
          ),
        );
      },
    );
  }
}

class _AppServices {
  final AppDatabase db;
  final SyncService sync;

  _AppServices(this.db, this.sync);

  static Future<_AppServices> init() async {
    final db = AppDatabase();
    final identity = await DeviceIdentity.load();
    final sync = SyncService(db: db, identity: identity);
    await sync.start();
    return _AppServices(db, sync);
  }
}
