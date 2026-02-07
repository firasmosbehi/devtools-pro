import 'package:devtools_pro/cron_utils.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cron_parser/cron_parser.dart' as cron;
import 'package:timezone/timezone.dart' as tz;

void main() {
  setUp(() => ensureTimeZonesInitialized());

  group('normalizeZone', () {
    test('returns UTC for empty', () {
      expect(normalizeZone('  '), 'UTC');
    });

    test('upper/lower UTC variants become UTC', () {
      expect(normalizeZone('utc'), 'UTC');
      expect(normalizeZone('UTC'), 'UTC');
    });

    test('keeps other zones trimmed', () {
      expect(normalizeZone('  America/New_York '), 'America/New_York');
    });
  });

  group('resolveZone', () {
    test('resolves UTC directly', () {
      final loc = resolveZone('utc');
      final offset = tz.TZDateTime.from(DateTime.utc(2020), loc).timeZoneOffset;
      expect(offset.inMinutes, 0);
    });

    test('resolves Etc/UTC to UTC', () {
      final loc = resolveZone('Etc/UTC');
      final offset = tz.TZDateTime.from(DateTime.utc(2020), loc).timeZoneOffset;
      expect(offset.inMinutes, 0);
    });

    test('resolves common IANA zones', () {
      expect(resolveZone('America/New_York').name, 'America/New_York');
      expect(resolveZone('Europe/Paris').name, 'Europe/Paris');
    });

    test('throws for unknown zones', () {
      expect(() => resolveZone('Not/AZone'), throwsA(isA<Exception>()));
    });
  });
}
