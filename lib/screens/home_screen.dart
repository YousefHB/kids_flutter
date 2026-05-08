import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../providers/profile_provider.dart';
import '../services/progression_service.dart';
import '../services/tts_service.dart';
import '../theme.dart';
import '../widgets/mascot_message.dart';
import '../widgets/star_counter.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _unlockedIndex = 0;
  bool _isLoading = true;
  final TtsService _ttsService = TtsService();

  @override
  void initState() {
    super.initState();
    _loadProgression();
  }

  Future<void> _loadProgression() async {
    final index = await ProgressionService.getUnlockedLevelIndex();
    if (mounted) {
      setState(() {
        _unlockedIndex = index;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
          body: Center(child: CircularProgressIndicator.adaptive()));
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF0F4FF),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 120,
            floating: true,
            pinned: true,
            backgroundColor: Colors.white,
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              title: const Text('🚀 LetterQuest',
                  style: TextStyle(
                      color: AppColors.magicPurple,
                      fontWeight: FontWeight.bold)),
              centerTitle: true,
            ),
            actions: [
              IconButton(
                onPressed: () => context.push('/parent'),
                icon: const Icon(Icons.settings_rounded,
                    color: AppColors.magicPurple),
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: _MascotWelcome(unlockedCount: _unlockedIndex + 1),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 25,
                crossAxisSpacing: 20,
                childAspectRatio: 0.9,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final letter = ProgressionService.alphabet[index];
                  final isUnlocked = index <= _unlockedIndex;
                  final isCurrent = index == _unlockedIndex;

                  return _LetterLevelNode(
                    letter: letter,
                    isUnlocked: isUnlocked,
                    isCurrent: isCurrent,
                    onTap: () {
                      if (isUnlocked) {
                        context
                            .push('/guided-tracing/$letter')
                            .then((_) => _loadProgression());
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text(
                                  'Réussis le niveau précédent pour débloquer cette lettre ! 🔒')),
                        );
                      }
                    },
                  );
                },
                childCount: ProgressionService.alphabet.length,
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton.extended(
            heroTag: 'stickers',
            onPressed: () => context.push('/stickers'),
            backgroundColor: AppColors.brightYellow,
            icon: const Icon(Icons.auto_awesome_rounded, color: Colors.black),
            label: const Text('ALBUM STICKERS',
                style: TextStyle(color: Colors.black)),
          ),
          const SizedBox(height: 12),
          FloatingActionButton.extended(
            heroTag: 'souvenirs',
            onPressed: () => context.push('/souvenirs'),
            backgroundColor: AppColors.magicPurple,
            icon: const Icon(Icons.collections_rounded, color: Colors.white),
            label: const Text('MES SOUVENIRS',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

class _MascotWelcome extends StatefulWidget {
  final int unlockedCount;
  const _MascotWelcome({required this.unlockedCount});

  @override
  State<_MascotWelcome> createState() => _MascotWelcomeState();
}

class _MascotWelcomeState extends State<_MascotWelcome>
    with SingleTickerProviderStateMixin {
  final TtsService _ttsService = TtsService();
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _sayHello() {
    final profile = context.read<ProfileProvider>().profile;
    final mascotId = profile?.mascotId ?? 'lion';
    
    String name;
    switch (mascotId) {
      case 'lion': name = 'Léo le Lion'; break;
      case 'cat': name = 'Mimi la Chatte'; break;
      case 'rabbit': name = 'Bibi le Lapin'; break;
      case 'butterfly': name = 'Bella le Papillon'; break;
      case 'panda': name = 'Pandi le Panda'; break;
      default: name = 'ton ami';
    }

    _ttsService.speakHappy(
        "Salut ! Je suis $name. Tu as déjà débloqué ${widget.unlockedCount} lettres. C'est super ! Quelle lettre allons-nous apprendre aujourd'hui ?");
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _sayHello,
      child: MascotMessage(
        message: "Salut Champion ! Tu as déjà débloqué ${widget.unlockedCount} lettres. Prêt pour la suite ?",
      ),
    );
  }
}

class _LetterLevelNode extends StatelessWidget {
  final String letter;
  final bool isUnlocked;
  final bool isCurrent;
  final VoidCallback onTap;

  const _LetterLevelNode({
    required this.letter,
    required this.isUnlocked,
    required this.isCurrent,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: 75,
                height: 75,
                decoration: BoxDecoration(
                  color: isUnlocked
                      ? (isCurrent
                          ? AppColors.brightYellow
                          : AppColors.softBlue)
                      : Colors.grey[300],
                  shape: BoxShape.circle,
                  boxShadow: isCurrent
                      ? [
                          BoxShadow(
                              color: AppColors.brightYellow.withOpacity(0.5),
                              blurRadius: 15,
                              spreadRadius: 2)
                        ]
                      : null,
                  border: isCurrent
                      ? Border.all(color: Colors.white, width: 4)
                      : null,
                ),
                child: Center(
                  child: isUnlocked
                      ? Text(letter,
                          style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: AppColors.magicPurple))
                      : const Icon(Icons.lock_rounded,
                          color: Colors.white, size: 30),
                ),
              ),
              if (isCurrent)
                Positioned(
                  top: -5,
                  right: -5,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                        color: Colors.redAccent, shape: BoxShape.circle),
                    child: const Icon(Icons.play_arrow_rounded,
                        color: Colors.white, size: 16),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            isUnlocked
                ? 'Niveau ${ProgressionService.alphabet.indexOf(letter) + 1}'
                : 'Verrouillé',
            style: TextStyle(
              fontSize: 12,
              fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
              color: isUnlocked ? Colors.black87 : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}
