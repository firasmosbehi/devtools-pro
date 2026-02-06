import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
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
      home: const UtilitiesHomePage(),
    );
  }
}

class UtilitiesHomePage extends StatelessWidget {
  const UtilitiesHomePage({super.key});

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
                      color: colorScheme.primary.withOpacity(0.1),
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
                  return utilities[index - 1];
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
            color: colorScheme.primary.withOpacity(.35),
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
              color: colorScheme.onPrimary.withOpacity(.9),
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
  });

  final IconData icon;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outline.withOpacity(.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.04),
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
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('$title is coming soon.')));
        },
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
        color: colorScheme.onPrimary.withOpacity(.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colorScheme.onPrimary.withOpacity(.25)),
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
