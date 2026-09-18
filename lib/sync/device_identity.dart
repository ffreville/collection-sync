import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../db/database.dart';

/// Two different notions of "who this is", kept deliberately separate:
///
///  - [deviceId] is stable for the life of this install — used purely to
///    recognize "that's my own mDNS broadcast, ignore it" during discovery.
///    It is never used as content ownership.
///  - [id] / [name] track whichever local [Profile] is currently *active* —
///    this is what new content gets tagged with (`ownerId`). A device can
///    host several profiles (see docs/spec-universes-collections.md); this
///    class only ever tracks the one you're currently acting as.
class DeviceIdentity {
  final String deviceId;
  String id;
  String name;
  bool isOnboarded;

  DeviceIdentity._({
    required this.deviceId,
    required this.id,
    required this.name,
    required this.isOnboarded,
  });

  static const _deviceIdKey = 'device_id';
  static const _activeProfileIdKey = 'active_profile_id';

  static Future<DeviceIdentity> load() async {
    final prefs = await SharedPreferences.getInstance();
    var deviceId = prefs.getString(_deviceIdKey);
    if (deviceId == null) {
      deviceId = const Uuid().v4();
      await prefs.setString(_deviceIdKey, deviceId);
    }
    // id/name are resolved against the Profiles table right after this by
    // _AppServices.init() (in main.dart) — it needs the database, which
    // isn't this class's concern.
    final activeProfileId = prefs.getString(_activeProfileIdKey);
    return DeviceIdentity._(
      deviceId: deviceId,
      id: activeProfileId ?? '',
      name: '',
      isOnboarded: false,
    );
  }

  Future<void> setActiveProfile(Profile profile) async {
    id = profile.id;
    name = profile.name;
    isOnboarded = true;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_activeProfileIdKey, profile.id);
  }
}
