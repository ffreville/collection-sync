import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

/// A stable identity for this device/user: a random id generated once and
/// kept forever (used to tell "my own edits" from a peer's during sync, and
/// as the `ownerId` of everything this user creates), and the display name
/// chosen during onboarding, shown to other users during sync.
class DeviceIdentity {
  final String id;
  String name;
  bool isOnboarded;

  DeviceIdentity._(this.id, this.name, this.isOnboarded);

  static const _idKey = 'device_id';
  static const _nameKey = 'device_name';

  static Future<DeviceIdentity> load() async {
    final prefs = await SharedPreferences.getInstance();
    var id = prefs.getString(_idKey);
    if (id == null) {
      id = const Uuid().v4();
      await prefs.setString(_idKey, id);
    }
    final storedName = prefs.getString(_nameKey);
    return DeviceIdentity._(id, storedName ?? 'Moi', storedName != null);
  }

  Future<void> setName(String newName) async {
    name = newName;
    isOnboarded = true;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_nameKey, newName);
  }
}
