// The default counter smoke test doesn't apply to this app. A real widget
// test here would need AppDatabase/SyncService test doubles, since
// SyncService.start() talks to the bonsoir mDNS platform channels, which
// aren't wired up under `flutter test`. Left as a placeholder for now.
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('placeholder', () {
    expect(1 + 1, 2);
  });
}
