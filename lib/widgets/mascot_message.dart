import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/profile_provider.dart';
import '../theme.dart';

class MascotMessage extends StatelessWidget {
  final String message;
  final bool animate;

  const MascotMessage({
    super.key,
    required this.message,
    this.animate = true,
  });

  String _getMascotEmoji(String id) {
    switch (id) {
      case 'lion': return '🦁';
      case 'cat': return '🐱';
      case 'rabbit': return '🐰';
      case 'butterfly': return '🦋';
      case 'panda': return '🐼';
      default: return '🦁';
    }
  }

  String _getMascotName(String id) {
    switch (id) {
      case 'lion': return 'Léo le Lion';
      case 'cat': return 'Mimi la Chatte';
      case 'rabbit': return 'Bibi le Lapin';
      case 'butterfly': return 'Bella le Papillon';
      case 'panda': return 'Pandi le Panda';
      default: return 'Léo';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ProfileProvider>(
      builder: (context, profileProvider, _) {
        final mascotId = profileProvider.profile?.mascotId ?? 'lion';
        final emoji = _getMascotEmoji(mascotId);
        final name = _getMascotName(mascotId);

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _MascotAvatar(emoji: emoji, animate: animate),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.magicPurple,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20),
                          bottomRight: Radius.circular(20),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 10,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Text(
                        message,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _MascotAvatar extends StatefulWidget {
  final String emoji;
  final bool animate;

  const _MascotAvatar({required this.emoji, this.animate = true});

  @override
  State<_MascotAvatar> createState() => _MascotAvatarState();
}

class _MascotAvatarState extends State<_MascotAvatar> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    if (widget.animate) _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: Tween<double>(begin: 1.0, end: 1.1).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
      ),
      child: Container(
        width: 70,
        height: 70,
        decoration: BoxDecoration(
          color: AppColors.brightYellow,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 3),
          boxShadow: const [
            BoxShadow(color: Colors.black12, blurRadius: 8),
          ],
        ),
        child: Center(
          child: Text(
            widget.emoji,
            style: const TextStyle(fontSize: 40),
          ),
        ),
      ),
    );
  }
}
