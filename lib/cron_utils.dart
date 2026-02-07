import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

class ZoneChoice {
  ZoneChoice({required this.name, required this.offset});

  final String name;
  final Duration offset;

  String get label => '$name (${_offsetString(offset)})';
}

bool _tzInitialized = false;

/// Ensure time zone data is initialized once for utilities and tests.
void ensureTimeZonesInitialized() {
  if (_tzInitialized) return;
  tzdata.initializeTimeZones();
  final db = tz.timeZoneDatabase.locations;

  // Some bundled tzdata builds omit explicit UTC/GMT identifiers.
  // Rewire aliases to a known zero-offset location so lookups always work.
  final fallback = db['Etc/Greenwich'] ?? db['Africa/Abidjan'];
  if (fallback != null) {
    for (final key in ['UTC', 'Etc/UTC', 'GMT', 'Etc/GMT']) {
      db.putIfAbsent(key, () => fallback);
    }
  }
  _tzInitialized = true;
}

/// Returns a best-effort normalized IANA zone string.
///
/// - Empty input -> 'UTC'
/// - Upper/lowercase UTC variants -> 'UTC'
/// - Otherwise trims whitespace and returns unchanged text.
String normalizeZone(String raw) {
  final trimmed = raw.trim();
  if (trimmed.isEmpty) return 'UTC';
  if (trimmed.toUpperCase().contains('UTC')) return 'UTC';
  return trimmed;
}

/// Resolve an IANA timezone with forgiving fallbacks.
///
/// Order:
/// 1) If the name contains 'UTC' (any case), return `Etc/UTC` (or [tz.UTC] fallback)
/// 2) Exact match on normalized string
/// 3) Try capitalizing first letter (helps common typos like 'europe/london')
///
/// Throws if no match is found.
tz.Location resolveZone(String raw) {
  ensureTimeZonesInitialized();
  final name = normalizeZone(raw);
  if (name.toUpperCase().contains('UTC')) {
    return _firstResolvableUtcLocation();
  }

  try {
    return tz.getLocation(name);
  } catch (_) {
    if (name.isNotEmpty) {
      final upperFirst = '${name[0].toUpperCase()}${name.substring(1)}';
      return tz.getLocation(upperFirst);
    }
    rethrow;
  }
}

/// Returns a canonical zone name for display or parser use.
String canonicalZoneName(String raw) {
  ensureTimeZonesInitialized();
  final norm = normalizeZone(raw);
  if (norm.toUpperCase().contains('UTC')) {
    return _firstResolvableUtcName();
  }
  return norm;
}

List<ZoneChoice> buildZoneChoices() {
  ensureTimeZonesInitialized();
  final nowUtc = DateTime.now().toUtc();

  final choices = tz.timeZoneDatabase.locations.entries.map((entry) {
    final location = entry.value;
    final offset = tz.TZDateTime.from(nowUtc, location).timeZoneOffset;
    return ZoneChoice(name: entry.key, offset: offset);
  }).toList();

  choices.sort((a, b) {
    final offsetCompare = a.offset.compareTo(b.offset);
    if (offsetCompare != 0) return offsetCompare;
    return a.name.compareTo(b.name);
  });

  // Guarantee a canonical UTC entry at the top for quick selection.
  final utcName = _firstResolvableUtcName();
  final utcChoice = choices.firstWhere(
    (c) => c.name == utcName,
    orElse: () => ZoneChoice(name: utcName, offset: Duration.zero),
  );
  choices.removeWhere((c) => c.name == utcName);
  choices.insert(0, utcChoice);
  return choices;
}

String _firstResolvableUtcName() {
  for (final key in ['Etc/UTC', 'UTC', 'GMT', 'Etc/GMT']) {
    try {
      tz.getLocation(key);
      return key;
    } catch (_) {
      continue;
    }
  }
  // Fall back to the first zero-offset location in the bundled DB.
  final nowUtc = DateTime.utc(2020);
  for (final entry in tz.timeZoneDatabase.locations.entries) {
    final loc = entry.value;
    final offset = tz.TZDateTime.from(nowUtc, loc).timeZoneOffset;
    if (offset.inMinutes == 0) return entry.key;
  }
  return 'UTC';
}

tz.Location _firstResolvableUtcLocation() {
  for (final key in ['Etc/UTC', 'UTC', 'GMT', 'Etc/GMT']) {
    try {
      return tz.getLocation(key);
    } catch (_) {
      continue;
    }
  }
  final nowUtc = DateTime.utc(2020);
  for (final entry in tz.timeZoneDatabase.locations.entries) {
    final loc = entry.value;
    final offset = tz.TZDateTime.from(nowUtc, loc).timeZoneOffset;
    if (offset.inMinutes == 0) return loc;
  }
  // Fallback: construct a zero-offset location tied to system UTC.
  return tz.Location('UTC', [tz.minTime], [0], const [tz.TimeZone.UTC]);
}

String _offsetString(Duration offset) {
  final sign = offset.isNegative ? '-' : '+';
  final abs = offset.abs();
  final hours = abs.inHours.toString().padLeft(2, '0');
  final minutes = (abs.inMinutes % 60).toString().padLeft(2, '0');
  return 'UTC $sign$hours:$minutes';
}
