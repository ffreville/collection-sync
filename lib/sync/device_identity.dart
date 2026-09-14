import 'dart:io';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

/// A stable identity for this device: a random id generated once and kept
/// forever (used to tell "my own edits" from a peer's during sync), and a
/// human-readable name shown to other devices during discovery.
class DeviceIdentity {
  final String id;
  String name;

  DeviceIdentity._(this.id, this.name);

  static const _idKey = 'device_id';
  static const _nameKey = 'device_name';

  static Future<DeviceIdentity> load() async {
    final prefs = await SharedPreferences.getInstance();
    var id = prefs.getString(_idKey);
    if (id == null) {
      id = const Uuid().v4();
      await prefs.setString(_idKey, id);
    }
    final name = prefs.getString(_nameKey) ?? _defaultName();
    return DeviceIdentity._(id, name);
  }

  Future<void> setName(String newName) async {
    name = newName;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_nameKey, newName);
  }

  static String _defaultName() {
    if (Platform.isIOS) return 'iPhone';
    if (Platform.isAndroid) return 'Android';
    return 'Appareil';
  }
}
