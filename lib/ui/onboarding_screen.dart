import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../sync/sync_service.dart';
import 'users_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _controller = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _continue() async {
    if (!_formKey.currentState!.validate()) return;
    final sync = context.read<SyncService>();
    await sync.identity.setName(_controller.text.trim());
    await sync.refreshBroadcast();
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const UsersScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(28, 24, 28, 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    'CS',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Theme.of(context).colorScheme.onPrimary,
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                ),
                const SizedBox(height: 20),
                Text('CollectionSync', style: Theme.of(context).textTheme.headlineMedium),
                const SizedBox(height: 10),
                Text(
                  "Gérez vos collections et synchronisez-les directement entre vos "
                  "appareils, sur le même Wi-Fi. Sans compte, sans serveur.",
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const Spacer(),
                Text(
                  "Comment voulez-vous qu'on vous appelle ?",
                  style: Theme.of(context).textTheme.labelLarge,
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _controller,
                  decoration: const InputDecoration(hintText: 'Ex. Fred'),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Requis' : null,
                  onFieldSubmitted: (_) => _continue(),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: _continue,
                    child: const Text('Continuer'),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Ce nom sera visible par les autres appareils lors '
                  "d'une synchronisation.",
                  textAlign: TextAlign.center,
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: Theme.of(context).colorScheme.outline),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
