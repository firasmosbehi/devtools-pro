import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:cron_parser/cron_parser.dart' as cron;

void main() {
  tz.initializeTimeZones();
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
    const ComingSoonPage(title: 'CIDR Helper'),
    const ComingSoonPage(title: 'Converters'),
    const ComingSoonPage(title: 'JWT/JWS Tools'),
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
  String? _error;
  List<RegExpMatch>? _matches;

  void _run() {
    setState(() {
      try {
        final regex = RegExp(
          _patternCtrl.text,
          caseSensitive: _caseSensitive,
          multiLine: _multiLine,
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Regex Builder'),
        actions: [
          IconButton(
            icon: const Icon(Icons.play_circle_fill),
            onPressed: _run,
            tooltip: 'Run',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 12,
              runSpacing: 8,
              children: [
                _regexPresetButton(r"^https?://[\w.-]+", 'URL'),
                _regexPresetButton(
                  r"^[\w.%+-]+@[\w.-]+\\.[A-Za-z]{2,}$",
                  'Email',
                ),
                _regexPresetButton(r"^#[0-9A-Fa-f]{6}$", 'Hex color'),
                _regexPresetButton(r"^\d{4}-\d{2}-\d{2}$", 'Date (YYYY-MM-DD)'),
              ],
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
            Row(
              children: [
                FilterChip(
                  label: const Text('Case-sensitive'),
                  selected: _caseSensitive,
                  onSelected: (v) => setState(() => _caseSensitive = v),
                ),
                const SizedBox(width: 10),
                FilterChip(
                  label: const Text('Multiline'),
                  selected: _multiLine,
                  onSelected: (v) => setState(() => _multiLine = v),
                ),
              ],
            ),
            const SizedBox(height: 10),
            _LabeledField(
              label: 'Test input',
              controller: _testCtrl,
              hint: 'Paste text to test',
              maxLines: 4,
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: _run,
              icon: const Icon(Icons.play_arrow),
              label: const Text('Run'),
            ),
            const SizedBox(height: 12),
            if (_error != null)
              Text(_error!, style: TextStyle(color: colorScheme.error)),
            if (_matches != null && _matches!.isNotEmpty)
              Expanded(
                child: ListView.builder(
                  itemCount: _matches!.length,
                  itemBuilder: (context, index) {
                    final m = _matches![index];
                    final groups = List.generate(
                      m.groupCount + 1,
                      (i) => m.group(i) ?? '',
                    );
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      child: ListTile(
                        title: Text('Match ${index + 1}: "${m.group(0)}"'),
                        subtitle: Text('Groups: ${groups.join(', ')}'),
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

  Widget _regexPresetButton(String pattern, String label) {
    return OutlinedButton(
      onPressed: () => setState(() => _patternCtrl.text = pattern),
      child: Text(label),
    );
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
  final _zoneCtrl = TextEditingController(text: 'UTC');
  List<tz.TZDateTime> _nextRuns = [];
  String? _error;

  @override
  void initState() {
    super.initState();
    _compute();
  }

  void _compute() {
    setState(() {
      try {
        final iterator = cron.Cron().parse(_cronCtrl.text, _zoneCtrl.text);
        final now = tz.TZDateTime.now(tz.getLocation(_zoneCtrl.text));
        final runs = <tz.TZDateTime>[];
        var current = iterator.next();
        while (runs.length < 5) {
          if (current.isAfter(now)) runs.add(current);
          current = iterator.next();
        }
        _nextRuns = runs;
        _error = null;
      } catch (e) {
        _error = 'Invalid cron: $e';
        _nextRuns = [];
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cron Designer'),
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
              label: 'Cron expression',
              controller: _cronCtrl,
              hint: '*/5 * * * *',
              monospace: true,
            ),
            const SizedBox(height: 8),
            _LabeledField(
              label: 'Time zone (IANA)',
              controller: _zoneCtrl,
              hint: 'e.g. UTC, America/New_York',
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: _compute,
              icon: const Icon(Icons.calculate),
              label: const Text('Preview next 5 runs'),
            ),
            const SizedBox(height: 12),
            if (_error != null)
              Text(
                _error!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            if (_nextRuns.isNotEmpty)
              Expanded(
                child: ListView.builder(
                  itemCount: _nextRuns.length,
                  itemBuilder: (context, index) {
                    final run = _nextRuns[index];
                    final formatted = DateFormat.yMMMMd().add_jm().format(run);
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
