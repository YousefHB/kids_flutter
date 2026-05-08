import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../providers/profile_provider.dart';
import '../theme.dart';
import '../widgets/lettrobot_avatar.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();

  bool _isCheckingSavedProfile = true;

  String _selectedMascot = 'lion';

  final List<Map<String, String>> _mascots = [
    {'id': 'lion', 'emoji': '🦁'},
    {'id': 'cat', 'emoji': '🐱'},
    {'id': 'rabbit', 'emoji': '🐰'},
    {'id': 'butterfly', 'emoji': '🦋'},
    {'id': 'panda', 'emoji': '🐼'},
  ];

  @override
  void initState() {
    super.initState();
    _loadSavedData();
  }

  Future<void> _loadSavedData() async {
    final authProvider = context.read<AuthProvider>();
    final profileProvider = context.read<ProfileProvider>();

    await authProvider.loadAuthState();
    await profileProvider.loadProfile();

    if (!mounted) return;

    if (authProvider.isLoggedIn && profileProvider.profile != null) {
      context.go('/home');
      return;
    }

    setState(() => _isCheckingSavedProfile = false);
  }

  Future<void> _startAdventure() async {
    if (!_formKey.currentState!.validate()) return;

    final name = _nameController.text.trim();
    final age = int.tryParse(_ageController.text.trim()) ?? 0;

    final authProvider = context.read<AuthProvider>();
    final profileProvider = context.read<ProfileProvider>();

    final success = await authProvider.login(
      childName: name,
      childAge: age,
    );

    if (!mounted) return;

    if (success) {
      await profileProvider.initProfile(name, age, _selectedMascot);

      if (!mounted) return;
      context.go('/home');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.errorMessage ?? 'Erreur inconnue'),
        ),
      );
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isCheckingSavedProfile) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator.adaptive(),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.skyBlue,
      body: SafeArea(
        child: Consumer<AuthProvider>(
          builder: (context, auth, _) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const SizedBox(height: 24),
                  const Text('🚀', style: TextStyle(fontSize: 60)),
                  const SizedBox(height: 16),
                  Text(
                    'LetterQuest Kids',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.w900,
                          color: AppColors.magicPurple,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(32),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          Text(
                            'Nouveau héros !',
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          const SizedBox(height: 24),
                          _buildTextField(_nameController, 'Ton prénom',
                              Icons.person_rounded),
                          const SizedBox(height: 16),
                          _buildTextField(
                              _ageController, 'Ton âge', Icons.cake_rounded,
                              isNumber: true),
                          const SizedBox(height: 32),
                          const Text(
                            'Choisis ton meilleur ami :',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 16),
                          Wrap(
                            spacing: 12,
                            runSpacing: 12,
                            alignment: WrapAlignment.center,
                            children: _mascots
                                .map((m) => _buildMascotOption(m))
                                .toList(),
                          ),
                          const SizedBox(height: 32),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed:
                                  auth.isLoading ? null : _startAdventure,
                              icon: const Icon(Icons.play_arrow_rounded,
                                  size: 28),
                              label: const Text('C\'EST PARTI !'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildTextField(
      TextEditingController controller, String label, IconData icon,
      {bool isNumber = false}) {
    return TextFormField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        filled: true,
        fillColor: const Color(0xFFF8F9FE),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide.none,
        ),
      ),
      validator: (value) =>
          value == null || value.isEmpty ? 'Obligatoire' : null,
    );
  }

  Widget _buildMascotOption(Map<String, String> mascot) {
    final isSelected = _selectedMascot == mascot['id'];
    return GestureDetector(
      onTap: () => setState(() => _selectedMascot = mascot['id']!),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.brightYellow : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.magicPurple : Colors.black12,
            width: 2,
          ),
        ),
        child: Text(mascot['emoji']!, style: const TextStyle(fontSize: 32)),
      ),
    );
  }
}
