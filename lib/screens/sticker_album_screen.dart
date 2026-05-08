import 'package:flutter/material.dart';
import '../services/progression_service.dart';
import '../theme.dart';

class StickerAlbumScreen extends StatelessWidget {
  const StickerAlbumScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      appBar: AppBar(
        title: const Text('📒 Mon Album de Stickers'),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.magicPurple,
        elevation: 0,
      ),
      body: FutureBuilder<List<String>>(
        future: ProgressionService.getCollectedStickers(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator.adaptive());
          }

          final stickers = snapshot.data ?? [];

          return Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                color: Colors.white,
                child: Column(
                  children: [
                    const Text('🏆', style: TextStyle(fontSize: 50)),
                    const SizedBox(height: 10),
                    Text(
                      'Tu as trouvé ${stickers.length} objets !',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const Text('Continue de scanner pour remplir ton album.', 
                      style: TextStyle(color: Colors.black54)),
                  ],
                ),
              ),
              Expanded(
                child: stickers.isEmpty
                  ? const Center(child: Text('Ton album est vide. Pars à la chasse aux objets ! 🔎'))
                  : GridView.builder(
                      padding: const EdgeInsets.all(20),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 15,
                        mainAxisSpacing: 15,
                      ),
                      itemCount: stickers.length,
                      itemBuilder: (context, index) {
                        return _StickerTile(label: stickers[index]);
                      },
                    ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _StickerTile extends StatelessWidget {
  final String label;
  const _StickerTile({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.stars_rounded, color: AppColors.brightYellow, size: 40),
          const SizedBox(height: 5),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              label.toUpperCase(),
              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
