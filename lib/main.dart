import 'package:flutter/material.dart';

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

    return Scaffold(
      appBar: AppBar(title: const Text('DevTools Pro'), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: ListView.separated(
          itemBuilder: (context, index) {
            if (index == 0) {
              return const _HeroCard();
            }
            return utilities[index - 1];
          },
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemCount: utilities.length + 1,
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
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'All your developer utilities in one place.',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(color: colorScheme.onPrimary),
          ),
          const SizedBox(height: 8),
          Text(
            'Regexes, crons, CIDRs, converters, and more. Each tool is offline-first with shareable snippets.',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: colorScheme.onPrimary),
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
