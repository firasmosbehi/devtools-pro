import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:cron_parser/cron_parser.dart' as cron;
import 'package:toml/toml.dart';
import 'package:yaml/yaml.dart';
import 'package:json2yaml/json2yaml.dart';
import 'package:crypto/crypto.dart';
import 'cron_utils.dart';

void main() {
  ensureTimeZonesInitialized();
  runApp(const DevToolsProApp());
}

class DevToolsProApp extends StatelessWidget {
  const DevToolsProApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DevTools Pro',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
        textTheme: GoogleFonts.spaceGroteskTextTheme(),
      ),
      home: const HomeShell(),
    );
  }
}

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;

  late final _pages = <Widget>[
    UtilitiesHomePage(onSelectUtility: _goToUtility),
    const RegexBuilderPage(),
    const CronDesignerPage(),
    const CidrHelperPage(),
    const ConverterPage(),
    const JwtToolsPage(),
  ];

  void _goToUtility(String title) {
    final map = {
      'Regex Builder': 1,
      'Cron Designer': 2,
      'CIDR Helper': 3,
      'Data Format Converters': 4,
      'JWT/JWS Tools': 5,
    };
    final target = map[title];
    if (target != null) {
      setState(() => _index = target);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 220),
        child: _pages[_index],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (value) => setState(() => _index = value),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(icon: Icon(Icons.code), label: 'Regex'),
          NavigationDestination(icon: Icon(Icons.schedule), label: 'Cron'),
          NavigationDestination(icon: Icon(Icons.route), label: 'CIDR'),
          NavigationDestination(
            icon: Icon(Icons.compare_arrows),
            label: 'Convert',
          ),
          NavigationDestination(icon: Icon(Icons.lock_clock), label: 'JWT'),
        ],
        backgroundColor: colorScheme.surface,
        indicatorColor: colorScheme.primary.withValues(alpha: .12),
      ),
    );
  }
}

class UtilitiesHomePage extends StatelessWidget {
  const UtilitiesHomePage({super.key, this.onSelectUtility});

  final void Function(String title)? onSelectUtility;

  @override
  Widget build(BuildContext context) {
    final utilities = [
      const _UtilityTile(
        icon: Icons.code,
        title: 'Regex Builder',
        description: 'Craft and test expressions with quick presets.',
      ),
      const _UtilityTile(
        icon: Icons.schedule,
        title: 'Cron Designer',
        description: 'Human-friendly cron editor with next-run preview.',
      ),
      const _UtilityTile(
        icon: Icons.route,
        title: 'CIDR Helper',
        description: 'Calculate ranges, masks, and subnet splits.',
      ),
      const _UtilityTile(
        icon: Icons.lock_clock,
        title: 'JWT/JWS Tools',
        description: 'Decode, inspect, and verify signatures.',
      ),
      const _UtilityTile(
        icon: Icons.storage,
        title: 'Data Format Converters',
        description: 'JSON ⇄ YAML ⇄ TOML with validation.',
      ),
    ];

    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              floating: true,
              snap: true,
              backgroundColor: colorScheme.surface,
              elevation: 0,
              titleSpacing: 16,
              title: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: colorScheme.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.bolt, color: colorScheme.primary, size: 18),
                        const SizedBox(width: 6),
                        Text(
                          'DevTools Pro',
                          style: TextStyle(
                            color: colorScheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.search),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Search coming soon.')),
                      );
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.settings_outlined),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Settings coming soon.')),
                      );
                    },
                  ),
                ],
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              sliver: SliverList.separated(
                itemBuilder: (context, index) {
                  if (index == 0) return const _HeroCard();
                  return utilities[index - 1].copyWith(onTap: onSelectUtility);
                },
                separatorBuilder: (context, _) => const SizedBox(height: 12),
                itemCount: utilities.length + 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeroCard extends StatelessWidget {
  const _HeroCard();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [colorScheme.primary, colorScheme.primaryContainer],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withValues(alpha: .35),
            blurRadius: 28,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.rocket_launch, color: colorScheme.onPrimary),
              const SizedBox(width: 8),
              Text(
                'Ship faster',
                style: Theme.of(
                  context,
                ).textTheme.labelLarge?.copyWith(color: colorScheme.onPrimary),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'All your dev utilities, one tap away.',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: colorScheme.onPrimary,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Regexes, crons, CIDRs, converters, JWTs. Offline-first with shareable snippets.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: colorScheme.onPrimary.withValues(alpha: .9),
            ),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 10,
            runSpacing: 8,
            children: const [
              _Pill(text: 'Offline-first'),
              _Pill(text: 'Shareable'),
              _Pill(text: 'Privacy-first'),
            ],
          ),
        ],
      ),
    );
  }
}

class _UtilityTile extends StatelessWidget {
  const _UtilityTile({
    required this.icon,
    required this.title,
    required this.description,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String description;
  final void Function(String title)? onTap;

  _UtilityTile copyWith({void Function(String title)? onTap}) {
    return _UtilityTile(
      icon: icon,
      title: title,
      description: description,
      onTap: onTap ?? this.onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outline.withValues(alpha: .2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: colorScheme.primaryContainer,
          foregroundColor: colorScheme.onPrimaryContainer,
          child: Icon(icon),
        ),
        title: Text(title),
        subtitle: Text(description),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          if (onTap != null) {
            onTap!(title);
          } else {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text('$title is coming soon.')));
          }
        },
      ),
    );
  }
}

/// Regex builder / tester MVP (Issue #2)
class RegexBuilderPage extends StatefulWidget {
  const RegexBuilderPage({super.key});

  @override
  State<RegexBuilderPage> createState() => _RegexBuilderPageState();
}

class _RegexBuilderPageState extends State<RegexBuilderPage> {
  final _patternCtrl = TextEditingController(
    text: r"^([a-z0-9_\.-]+)@([\da-z\.-]+)\.([a-z\.]{2,6})$",
  );
  final _testCtrl = TextEditingController(text: 'dev@example.com');
  bool _caseSensitive = true;
  bool _multiLine = false;
  bool _dotAll = false;
  bool _unicode = true;
  String? _error;
  List<RegExpMatch>? _matches;
  bool _autoRun = true;

  @override
  void initState() {
    super.initState();
    _patternCtrl.addListener(_maybeRun);
    _testCtrl.addListener(_maybeRun);
    _run();
  }

  @override
  void dispose() {
    _patternCtrl.dispose();
    _testCtrl.dispose();
    super.dispose();
  }

  void _maybeRun() {
    if (_autoRun) _run();
  }

  void _run() {
    setState(() {
      try {
        final regex = RegExp(
          _patternCtrl.text,
          caseSensitive: _caseSensitive,
          multiLine: _multiLine,
          dotAll: _dotAll,
          unicode: _unicode,
        );
        _matches = regex.allMatches(_testCtrl.text).toList();
        _error = _matches!.isEmpty ? 'No matches found' : null;
      } catch (e) {
        _error = 'Invalid regex: $e';
        _matches = null;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    return Scaffold(
      appBar: AppBar(title: const Text('Regex Builder')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                padding: EdgeInsets.only(bottom: bottomInset + 24),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const _SectionHeader(
                        label: 'Presets',
                        description:
                            'Tap to load a common pattern and sample text.',
                      ),
                      Column(
                        children: [
                          _presetTile(
                            'URL',
                            r"^https?://[\w.-]+",
                            sample: 'https://example.dev/path',
                          ),
                          _presetTile(
                            'Email',
                            r"^[\w.%+-]+@[\w.-]+\.[A-Za-z]{2,}$",
                            sample: 'dev@example.com',
                          ),
                          _presetTile(
                            'Hex color',
                            r"^#[0-9A-Fa-f]{6}$",
                            sample: '#FF00AA',
                          ),
                          _presetTile(
                            'Date (YYYY-MM-DD)',
                            r"^\d{4}-\d{2}-\d{2}$",
                            sample: '2026-02-06',
                          ),
                          _presetTile(
                            'UUID v1-5',
                            r"^[a-f0-9]{8}-[a-f0-9]{4}-[1-5][a-f0-9]{3}-[89ab][a-f0-9]{3}-[a-f0-9]{12}$",
                            sample: '123e4567-e89b-12d3-a456-426614174000',
                          ),
                          _presetTile(
                            'IPv4',
                            r"^(?:\d{1,3}\.){3}\d{1,3}$",
                            sample: '192.168.10.5',
                          ),
                          _presetTile(
                            'IPv6 (loose)',
                            r"^[0-9a-fA-F:]+$",
                            sample: '2001:0db8:85a3:0000:0000:8a2e:0370:7334',
                          ),
                          _presetTile(
                            'Slug',
                            r"^[a-z0-9]+(?:-[a-z0-9]+)*$",
                            sample: 'dev-tools-pro',
                          ),
                          _presetTile(
                            'Phone (basic)',
                            r"^\+?[0-9 ()-]{7,}$",
                            sample: '+1 (415) 555-0101',
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Write a regex (Dart RegExp syntax). We run it against the test text below and highlight matches.',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 12),
                      _LabeledField(
                        label: 'Pattern',
                        controller: _patternCtrl,
                        hint: 'Enter a regex pattern',
                        monospace: true,
                        maxLines: 3,
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          FilterChip(
                            label: const Text('Case-sensitive'),
                            selected: _caseSensitive,
                            onSelected: (v) =>
                                setState(() => _caseSensitive = v),
                          ),
                          FilterChip(
                            label: const Text('Multiline'),
                            selected: _multiLine,
                            onSelected: (v) => setState(() => _multiLine = v),
                          ),
                          FilterChip(
                            label: const Text('DotAll'),
                            selected: _dotAll,
                            onSelected: (v) => setState(() => _dotAll = v),
                          ),
                          FilterChip(
                            label: const Text('Unicode'),
                            selected: _unicode,
                            onSelected: (v) => setState(() => _unicode = v),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Building blocks',
                        style: Theme.of(context).textTheme.labelLarge,
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _snippetButton('^ start', '^'),
                          _snippetButton(r'$ end', r'$'),
                          _snippetButton(r'\b word boundary', r'\b'),
                          _snippetButton(r'\d digits', r'\d'),
                          _snippetButton(r'\w word chars', r'\w'),
                          _snippetButton(r'\s whitespace', r'\s'),
                          _snippetButton('.', '.'),
                          _snippetButton('*', '*'),
                          _snippetButton('+', '+'),
                          _snippetButton('?', '?'),
                          _snippetButton('{n,m}', '{1,3}'),
                          _snippetButton('[abc]', '[abc]'),
                          _snippetButton('(group)', '(...)'),
                          _snippetButton('(?:non-capt)', '(?:...)'),
                        ],
                      ),
                      const SizedBox(height: 10),
                      _LabeledField(
                        label: 'Test input',
                        controller: _testCtrl,
                        hint:
                            'This is the text your regex will be tested against.',
                        maxLines: 8,
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _sampleButton(
                            'Emails',
                            'dev@example.com\nops@acme.io',
                          ),
                          _sampleButton(
                            'URLs',
                            'https://api.dev.com/v1\nhttp://localhost:8080',
                          ),
                          _sampleButton(
                            'JSON',
                            '{"user":"dev","id":42,"roles":["admin","dev"]}',
                          ),
                          _sampleButton(
                            'Logs',
                            '[INFO] ready\n[WARN] slow query\n[ERROR] panic',
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          ElevatedButton.icon(
                            onPressed: _run,
                            icon: const Icon(Icons.play_arrow),
                            label: const Text('Run'),
                          ),
                          const SizedBox(width: 12),
                          OutlinedButton.icon(
                            onPressed: () {
                              Clipboard.setData(
                                ClipboardData(text: _patternCtrl.text),
                              );
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Pattern copied')),
                              );
                            },
                            icon: const Icon(Icons.copy),
                            label: const Text('Copy pattern'),
                          ),
                          const SizedBox(width: 12),
                          FilterChip(
                            label: const Text('Auto-run'),
                            selected: _autoRun,
                            onSelected: (v) => setState(() => _autoRun = v),
                          ),
                          const SizedBox(width: 12),
                          if (_matches != null)
                            Chip(
                              avatar: const Icon(Icons.check),
                              label: Text('${_matches!.length} match(es)'),
                              backgroundColor: colorScheme.primaryContainer
                                  .withValues(alpha: .35),
                            ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      if (_error != null)
                        Text(
                          _error!,
                          style: TextStyle(color: colorScheme.error),
                        ),
                      if (_matches != null)
                        Card(
                          margin: const EdgeInsets.only(top: 8),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Highlighted',
                                  style: Theme.of(context).textTheme.labelLarge,
                                ),
                                const SizedBox(height: 8),
                                _HighlightedText(
                                  text: _testCtrl.text,
                                  matches: _matches!,
                                  color: colorScheme.primary,
                                ),
                              ],
                            ),
                          ),
                        ),
                      if (_matches != null && _matches!.isNotEmpty)
                        ..._matches!.asMap().entries.map((entry) {
                          final index = entry.key;
                          final m = entry.value;
                          final groups = List.generate(
                            m.groupCount + 1,
                            (i) => m.group(i) ?? '',
                          );
                          return Card(
                            margin: const EdgeInsets.symmetric(vertical: 6),
                            child: ListTile(
                              title: Text(
                                'Match ${index + 1}: "${m.group(0)}"',
                              ),
                              subtitle: Text('Groups: ${groups.join(', ')}'),
                            ),
                          );
                        }),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _sampleButton(String label, String text) {
    return OutlinedButton.icon(
      icon: const Icon(Icons.article_outlined, size: 16),
      label: Text(label),
      onPressed: () => setState(() {
        _testCtrl.text = text;
        if (_autoRun) _run();
      }),
    );
  }

  Widget _presetTile(String title, String pattern, {String? sample}) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        dense: true,
        title: Text(title),
        subtitle: Text(pattern),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => setState(() {
          _patternCtrl.text = pattern;
          if (sample != null) _testCtrl.text = sample;
          if (_autoRun) _run();
        }),
      ),
    );
  }

  Widget _snippetButton(String label, String snippet) {
    return OutlinedButton(
      onPressed: () => _insertSnippet(snippet),
      child: Text(label),
    );
  }

  void _insertSnippet(String snippet) {
    final selection = _patternCtrl.selection;
    final text = _patternCtrl.text;
    final newText = selection.isValid
        ? text.replaceRange(selection.start, selection.end, snippet)
        : text + snippet;
    final cursor = selection.isValid
        ? selection.start + snippet.length
        : newText.length;
    _patternCtrl.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: cursor),
    );
    if (_autoRun) _run();
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.label, required this.description});

  final String label;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 4),
          Text(description, style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }
}

class _HighlightedText extends StatelessWidget {
  const _HighlightedText({
    required this.text,
    required this.matches,
    required this.color,
  });

  final String text;
  final List<RegExpMatch> matches;
  final Color color;

  @override
  Widget build(BuildContext context) {
    if (matches.isEmpty) return Text(text);
    if (text.isEmpty) return const Text('No test text provided.');
    final spans = <TextSpan>[];
    var cursor = 0;
    for (final m in matches) {
      final start = m.start;
      final end = m.end;
      if (start > cursor) {
        spans.add(TextSpan(text: text.substring(cursor, start)));
      }
      spans.add(
        TextSpan(
          text: text.substring(start, end),
          style: TextStyle(
            backgroundColor: color.withValues(alpha: .2),
            fontWeight: FontWeight.bold,
          ),
        ),
      );
      cursor = end;
    }
    if (cursor < text.length) {
      spans.add(TextSpan(text: text.substring(cursor)));
    }
    return SelectableText.rich(TextSpan(children: spans));
  }
}

/// Cron designer MVP (Issue #3)
class CronDesignerPage extends StatefulWidget {
  const CronDesignerPage({super.key});

  @override
  State<CronDesignerPage> createState() => _CronDesignerPageState();
}

class _CronDesignerPageState extends State<CronDesignerPage> {
  final _cronCtrl = TextEditingController(text: '0 12 * * 1-5');
  ZoneChoice? _selectedZone;
  List<tz.TZDateTime> _nextRuns = [];
  String? _error;
  bool _isLoading = false;
  List<ZoneChoice> _zones = const [];

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    setState(() => _isLoading = true);
    try {
      _zones = buildZoneChoices();
      _selectedZone = _zones.first;
      await _compute();
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _compute() async {
    setState(() {
      _error = null;
      _nextRuns = [];
    });
    final zoneName = _selectedZone?.name ?? 'UTC';
    try {
      final result = _parseCron(_cronCtrl.text, zoneName);
      final now = tz.TZDateTime.now(result.location);
      final runs = <tz.TZDateTime>[];
      var current = result.iterator.next();
      while (runs.length < 5) {
        if (current.isAfter(now)) runs.add(current);
        current = result.iterator.next();
      }
      setState(() {
        _nextRuns = runs;
        _error = null;
      });
    } catch (e, stack) {
      debugPrint('Cron compute failed: $e\n$stack');
      setState(() {
        _error = 'Invalid cron: $e';
        _nextRuns = [];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cron Studio'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _compute),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _LabeledField(
                    label: 'Cron expression (5 fields)',
                    controller: _cronCtrl,
                    hint: '*/5 * * * *',
                    monospace: true,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Time zone',
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<ZoneChoice>(
                    value: _selectedZone,
                    isExpanded: true,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                    ),
                    items: _zones
                        .map(
                          (z) => DropdownMenuItem(
                            value: z,
                            child: Text(
                              z.label,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      setState(() => _selectedZone = value);
                      _compute();
                    },
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: _compute,
                    icon: const Icon(Icons.calculate),
                    label: const Text('Preview next 5 runs'),
                  ),
                  const SizedBox(height: 12),
                  if (_error != null)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: colorScheme.errorContainer,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        _error!,
                        style: TextStyle(color: colorScheme.onErrorContainer),
                      ),
                    ),
                  if (_nextRuns.isNotEmpty)
                    Expanded(
                      child: ListView.builder(
                        itemCount: _nextRuns.length,
                        itemBuilder: (context, index) {
                          final run = _nextRuns[index];
                          final formatted = DateFormat.yMMMMd().add_jm().format(
                            run,
                          );
                          return Card(
                            margin: const EdgeInsets.symmetric(vertical: 6),
                            child: ListTile(
                              leading: const Icon(Icons.schedule),
                              title: Text(formatted),
                              subtitle: Text(
                                'In ${run.difference(DateTime.now()).inMinutes} minutes',
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                ],
              ),
            ),
    );
  }
}

class _CronParseResult {
  _CronParseResult({required this.iterator, required this.location});

  final cron.CronIterator<tz.TZDateTime> iterator;
  final tz.Location location;
}

_CronParseResult _parseCron(String expr, String rawZone) {
  final canonicalName = canonicalZoneName(rawZone);
  final location = resolveZone(canonicalName);
  final iterator = cron.Cron().parse(expr, location.name);
  return _CronParseResult(iterator: iterator, location: location);
}

class ComingSoonPage extends StatelessWidget {
  const ComingSoonPage({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(child: Text('$title is coming soon.')),
    );
  }
}

class _LabeledField extends StatelessWidget {
  const _LabeledField({
    required this.label,
    required this.controller,
    this.hint,
    this.maxLines = 1,
    this.monospace = false,
  });

  final String label;
  final TextEditingController controller;
  final String? hint;
  final int maxLines;
  final bool monospace;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          maxLines: maxLines,
          style: monospace
              ? const TextStyle(fontFamily: 'FiraCode, monospace')
              : null,
          decoration: InputDecoration(
            hintText: hint,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ],
    );
  }
}

/// CIDR calculator MVP (Issue #4)
class CidrHelperPage extends StatefulWidget {
  const CidrHelperPage({super.key});

  @override
  State<CidrHelperPage> createState() => _CidrHelperPageState();
}

class _CidrHelperPageState extends State<CidrHelperPage> {
  final _cidrCtrl = TextEditingController(text: '192.168.1.0/24');
  String? _error;
  _CidrResult? _result;

  @override
  void initState() {
    super.initState();
    _compute();
  }

  void _compute() {
    setState(() {
      try {
        _result = _computeCidr(_cidrCtrl.text);
        _error = null;
      } catch (e) {
        _error = 'Invalid CIDR: $e';
        _result = null;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('CIDR Helper'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _compute),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _LabeledField(
              label: 'CIDR',
              controller: _cidrCtrl,
              hint: 'e.g. 10.0.0.0/16',
              monospace: true,
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: _compute,
              icon: const Icon(Icons.calculate),
              label: const Text('Calculate'),
            ),
            const SizedBox(height: 12),
            if (_error != null)
              Text(
                _error!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            if (_result != null) ...[
              _StatRow(label: 'Network', value: _result!.network),
              _StatRow(label: 'Broadcast', value: _result!.broadcast),
              _StatRow(label: 'Prefix', value: '/${_result!.prefix}'),
              _StatRow(
                label: 'Total hosts',
                value: _result!.hostCount.toString(),
              ),
              _StatRow(
                label: 'Usable range',
                value: '${_result!.firstUsable} – ${_result!.lastUsable}',
              ),
              const SizedBox(height: 10),
              Text(
                'First 5 addresses',
                style: Theme.of(context).textTheme.labelLarge,
              ),
              ..._result!.sample.map((ip) => Text(ip)),
            ],
          ],
        ),
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  const _StatRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 140,
            child: Text(label, style: Theme.of(context).textTheme.bodyMedium),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CidrResult {
  _CidrResult({
    required this.network,
    required this.broadcast,
    required this.prefix,
    required this.hostCount,
    required this.firstUsable,
    required this.lastUsable,
    required this.sample,
  });

  final String network;
  final String broadcast;
  final int prefix;
  final BigInt hostCount;
  final String firstUsable;
  final String lastUsable;
  final List<String> sample;
}

_CidrResult _computeCidr(String cidr) {
  final parts = cidr.split('/');
  if (parts.length != 2) throw 'Use format A.B.C.D/nn';
  final ip = parts[0].trim();
  final prefix = int.tryParse(parts[1]) ?? -1;
  if (prefix < 0 || prefix > 32) throw 'Prefix must be 0-32';
  final baseInt = _ipv4ToInt(ip);
  final hostBits = 32 - prefix;
  final mask = hostBits == 0
      ? (BigInt.one << 32) - BigInt.one
      : (BigInt.one << hostBits) - BigInt.one;
  final networkInt = baseInt & ~mask;
  final broadcastInt = networkInt | mask;
  final hostCount = BigInt.one << hostBits;
  final firstUsable = prefix >= 31 ? networkInt : networkInt + BigInt.one;
  final lastUsable = prefix >= 31 ? broadcastInt : broadcastInt - BigInt.one;
  final sample = <String>[];
  for (var i = 0; i < 5; i++) {
    final candidate = networkInt + BigInt.from(i);
    if (candidate <= broadcastInt) sample.add(_intToIpv4(candidate));
  }
  return _CidrResult(
    network: _intToIpv4(networkInt),
    broadcast: _intToIpv4(broadcastInt),
    prefix: prefix,
    hostCount: hostCount,
    firstUsable: _intToIpv4(firstUsable),
    lastUsable: _intToIpv4(lastUsable),
    sample: sample,
  );
}

BigInt _ipv4ToInt(String ip) {
  final octets = ip.split('.').map(int.tryParse).toList();
  final parsed = octets.whereType<int>().toList();
  if (parsed.length != 4 || parsed.any((o) => o < 0 || o > 255)) {
    throw 'Invalid IPv4 address';
  }
  return BigInt.from(
    parsed[0] << 24 | parsed[1] << 16 | parsed[2] << 8 | parsed[3],
  );
}

String _intToIpv4(BigInt value) {
  final v = value.toInt();
  return '${(v >> 24) & 255}.${(v >> 16) & 255}.${(v >> 8) & 255}.${v & 255}';
}

/// Data converters (Issue #6)
class ConverterPage extends StatefulWidget {
  const ConverterPage({super.key});

  @override
  State<ConverterPage> createState() => _ConverterPageState();
}

class _ConverterPageState extends State<ConverterPage> {
  final _inputCtrl = TextEditingController(
    text: '{"hello": "world", "items": [1,2,3]}',
  );
  String _source = 'json';
  String? _error;
  String _jsonOut = '';
  String _yamlOut = '';
  String _tomlOut = '';

  void _convert() {
    setState(() {
      try {
        final parsed = _parseInput(_inputCtrl.text, _source);
        _jsonOut = const JsonEncoder.withIndent('  ').convert(parsed);
        _yamlOut = json2yaml(parsed);
        final mapForToml = parsed is Map
            ? Map<String, Object?>.from(parsed)
            : {'root': parsed};
        _tomlOut = TomlDocument.fromMap(mapForToml).toString();
        _error = null;
      } catch (e) {
        _error = 'Conversion failed: $e';
        _jsonOut = _yamlOut = _tomlOut = '';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Data Converters'),
        actions: [
          IconButton(onPressed: _convert, icon: const Icon(Icons.play_arrow)),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text('Source format:'),
                  const SizedBox(width: 10),
                  DropdownButton<String>(
                    value: _source,
                    items: const [
                      DropdownMenuItem(value: 'json', child: Text('JSON')),
                      DropdownMenuItem(value: 'yaml', child: Text('YAML')),
                      DropdownMenuItem(value: 'toml', child: Text('TOML')),
                    ],
                    onChanged: (v) => setState(() => _source = v ?? 'json'),
                  ),
                ],
              ),
              _LabeledField(
                label: 'Input',
                controller: _inputCtrl,
                maxLines: 6,
                monospace: true,
              ),
              const SizedBox(height: 12),
              ElevatedButton(onPressed: _convert, child: const Text('Convert')),
              const SizedBox(height: 12),
              if (_error != null)
                Text(
                  _error!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              _OutputBlock(title: 'JSON', content: _jsonOut),
              _OutputBlock(title: 'YAML', content: _yamlOut),
              _OutputBlock(title: 'TOML', content: _tomlOut),
            ],
          ),
        ),
      ),
    );
  }
}

dynamic _parseInput(String text, String format) {
  switch (format) {
    case 'json':
      return jsonDecode(text);
    case 'yaml':
      final yaml = loadYaml(text);
      return jsonDecode(jsonEncode(yaml));
    case 'toml':
      return TomlDocument.parse(text).toMap();
    default:
      throw 'Unsupported format';
  }
}

class _OutputBlock extends StatelessWidget {
  const _OutputBlock({required this.title, required this.content});

  final String title;
  final String content;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 6),
            SelectableText(content.isEmpty ? '—' : content),
          ],
        ),
      ),
    );
  }
}

/// JWT/JWS decode & verify (Issue #5)
class JwtToolsPage extends StatefulWidget {
  const JwtToolsPage({super.key});

  @override
  State<JwtToolsPage> createState() => _JwtToolsPageState();
}

class _JwtToolsPageState extends State<JwtToolsPage> {
  final _tokenCtrl = TextEditingController(text: 'header.payload.signature');
  final _secretCtrl = TextEditingController();
  String _header = '';
  String _payload = '';
  String _status = '';

  void _decode() {
    setState(() {
      try {
        final parts = _tokenCtrl.text.split('.');
        if (parts.length < 2) throw 'Token must have at least 2 parts';
        final headerJson = _jsonFromSegment(parts[0]);
        final payloadJson = _jsonFromSegment(parts[1]);
        _header = const JsonEncoder.withIndent('  ').convert(headerJson);
        _payload = const JsonEncoder.withIndent('  ').convert(payloadJson);
        _status = 'Decoded';
        if (_secretCtrl.text.isNotEmpty && parts.length == 3) {
          _status = _verifyHs(parts, headerJson, _secretCtrl.text);
        }
      } catch (e) {
        _status = 'Error: $e';
        _header = _payload = '';
      }
    });
  }

  Map<String, dynamic> _jsonFromSegment(String segment) {
    final normalized = base64Url.normalize(segment);
    final decoded = utf8.decode(base64Url.decode(normalized));
    final obj = jsonDecode(decoded);
    return obj is Map<String, dynamic>
        ? obj
        : {'data': obj}; // wrap primitives for display
  }

  String _verifyHs(
    List<String> parts,
    Map<String, dynamic> header,
    String secret,
  ) {
    final alg = (header['alg'] ?? 'HS256') as String;
    Hmac? hmac;
    if (alg == 'HS256') hmac = Hmac(sha256, utf8.encode(secret));
    if (alg == 'HS384') hmac = Hmac(sha384, utf8.encode(secret));
    if (alg == 'HS512') hmac = Hmac(sha512, utf8.encode(secret));
    if (hmac == null) return 'Unsupported alg for inline verify: $alg';

    final signingInput = '${parts[0]}.${parts[1]}';
    final digest = hmac.convert(utf8.encode(signingInput));
    final expectedSig = _base64UrlNoPad(digest.bytes);
    final providedSig = _normalizeSig(parts[2]);
    return expectedSig == providedSig
        ? 'Signature verified ($alg)'
        : 'Invalid signature';
  }

  String _base64UrlNoPad(List<int> bytes) =>
      base64Url.encode(bytes).replaceAll('=', '');

  String _normalizeSig(String sig) => sig.replaceAll('=', '');
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('JWT/JWS Tools'),
        actions: [
          IconButton(onPressed: _decode, icon: const Icon(Icons.play_arrow)),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _LabeledField(
                label: 'JWT / JWS',
                controller: _tokenCtrl,
                maxLines: 3,
                monospace: true,
              ),
              const SizedBox(height: 8),
              _LabeledField(
                label: 'Secret (HS256/384/512)',
                controller: _secretCtrl,
                hint: 'Optional: for verification',
                monospace: true,
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: _decode,
                child: const Text('Decode / Verify'),
              ),
              const SizedBox(height: 12),
              Text('Status: $_status'),
              _OutputBlock(title: 'Header', content: _header),
              _OutputBlock(title: 'Payload', content: _payload),
            ],
          ),
        ),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: colorScheme.onPrimary.withValues(alpha: .15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colorScheme.onPrimary.withValues(alpha: .25)),
      ),
      child: Text(
        text,
        style: Theme.of(
          context,
        ).textTheme.labelLarge?.copyWith(color: colorScheme.onPrimary),
      ),
    );
  }
}
