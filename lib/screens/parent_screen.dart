// Écran parent : tableau de bord avec progression
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../providers/profile_provider.dart';
import '../constants.dart';
import '../theme.dart';

class ParentScreen extends StatefulWidget {
  const ParentScreen({super.key});

  @override
  State<ParentScreen> createState() => _ParentScreenState();
}

class _ParentScreenState extends State<ParentScreen> {
  Future<void> _resetProfile() async {
    await context.read<ProfileProvider>().resetProfile();

    if (!mounted) return;

    context.go('/login');
  }

  void _showResetConfirmation() {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Réinitialiser le profil ?'),
          content: const Text(
            'Toutes les étoiles et les lettres complétées seront supprimées.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Annuler'),
            ),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(dialogContext);
                _resetProfile();
              },
              icon: const Icon(Icons.restart_alt_rounded),
              label: const Text('Réinitialiser'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('👨‍👩‍👧 Espace Parent'),
      ),
      body: Consumer<ProfileProvider>(
        builder: (context, profileProvider, _) {
          final child = profileProvider.profile;

          if (child == null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(AppBorders.radius),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 10,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.info_outline_rounded,
                        size: 48,
                        color: AppColors.magicPurple,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Aucun profil créé',
                        style: Theme.of(context).textTheme.titleLarge,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Crée d’abord un profil enfant pour voir la progression.',
                        style: Theme.of(context).textTheme.bodyLarge,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton.icon(
                        onPressed: () => context.go('/login'),
                        icon: const Icon(Icons.person_add_alt_1_rounded),
                        label: const Text('Créer un profil'),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(AppBorders.radius),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 10,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Profil',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 12),
                      Text('Nom : ${child.name}'),
                      Text('Âge : ${child.age} ans'),
                      Text('Total étoiles : ⭐ ${child.totalStars}'),
                      const SizedBox(height: 16),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: LinearProgressIndicator(
                          value: child.completionPercentage / 100,
                          minHeight: 10,
                          backgroundColor: AppColors.lightGray,
                          color: AppColors.successGreen,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Progression : ${child.completionPercentage}%',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Lettres complétées',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: ALPHABET.map((letter) {
                    final completed = child.lettersCompleted[letter] ?? false;

                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: completed
                            ? AppColors.successGreen
                            : AppColors.lightGray,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: completed
                              ? AppColors.successGreen
                              : Colors.black12,
                          width: 1,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          letter,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                            color: completed ? Colors.white : Colors.black54,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => context.push('/souvenirs'),
                    icon: const Icon(Icons.photo_library_rounded),
                    label: const Text('Voir les souvenirs'),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: _showResetConfirmation,
                    icon: const Icon(Icons.restart_alt_rounded),
                    label: const Text('Réinitialiser le profil'),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
