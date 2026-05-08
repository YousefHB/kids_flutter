import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:gal/gal.dart';
import 'package:share_plus/share_plus.dart';

import '../models/souvenir_photo.dart';
import '../services/souvenir_service.dart';
import '../theme.dart';

class SouvenirGalleryScreen extends StatefulWidget {
  const SouvenirGalleryScreen({super.key});

  @override
  State<SouvenirGalleryScreen> createState() => _SouvenirGalleryScreenState();
}

class _SouvenirGalleryScreenState extends State<SouvenirGalleryScreen> {
  late Future<List<SouvenirPhoto>> _souvenirsFuture;

  @override
  void initState() {
    super.initState();
    _refreshSouvenirs();
  }

  void _refreshSouvenirs() {
    setState(() {
      _souvenirsFuture = SouvenirService.getSouvenirs();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      appBar: AppBar(
        title: const Text('🌟 Galerie des Souvenirs'),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.magicPurple,
        elevation: 0,
      ),
      body: FutureBuilder<List<SouvenirPhoto>>(
        future: _souvenirsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator.adaptive());
          }

          final souvenirs = snapshot.data ?? [];

          if (souvenirs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('📸', style: TextStyle(fontSize: 80)),
                  const SizedBox(height: 16),
                  Text(
                    'Aucun souvenir encore !',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: AppColors.magicPurple,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Termine des missions pour gagner des photos.',
                    style: TextStyle(color: Colors.black54),
                  ),
                ],
              ),
            );
          }

          return GridView.builder(
            padding: const EdgeInsets.all(20),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 0.85,
            ),
            itemCount: souvenirs.length,
            itemBuilder: (context, index) {
              final souvenir = souvenirs[index];
              return _SouvenirCard(
                souvenir: souvenir,
                onTap: () => _showSouvenirDetail(souvenir),
              );
            },
          );
        },
      ),
    );
  }

  void _showSouvenirDetail(SouvenirPhoto souvenir) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _SouvenirDetailSheet(
        souvenir: souvenir,
        onDelete: () {
          _refreshSouvenirs();
          Navigator.pop(context);
        },
      ),
    );
  }
}

class _SouvenirCard extends StatelessWidget {
  final SouvenirPhoto souvenir;
  final VoidCallback onTap;

  const _SouvenirCard({required this.souvenir, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                child: Image.file(
                  File(souvenir.imagePath),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CircleAvatar(
                    radius: 14,
                    backgroundColor: AppColors.brightYellow,
                    child: Text(
                      souvenir.letter,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  Text(
                    '${souvenir.createdAt.day}/${souvenir.createdAt.month}',
                    style: const TextStyle(fontSize: 12, color: Colors.black45),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SouvenirDetailSheet extends StatefulWidget {
  final SouvenirPhoto souvenir;
  final VoidCallback onDelete;

  const _SouvenirDetailSheet({required this.souvenir, required this.onDelete});

  @override
  State<_SouvenirDetailSheet> createState() => _SouvenirDetailSheetState();
}

class _SouvenirDetailSheetState extends State<_SouvenirDetailSheet> {
  bool _isExporting = false;

  Future<void> _share() async {
    await Share.shareXFiles(
      [XFile(widget.souvenir.imagePath)],
      text: 'Regardez le souvenir LetterQuest de mon enfant ! 🌟',
    );
  }

  Future<void> _saveToGallery() async {
    setState(() => _isExporting = true);
    try {
      final hasAccess = await Gal.hasAccess();
      if (!hasAccess) {
        await Gal.requestAccess();
      }
      await Gal.putImage(widget.souvenir.imagePath);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Photo enregistrée dans la galerie ! 📸')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors de l\'enregistrement : $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isExporting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Image.file(
                  File(widget.souvenir.imagePath),
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _isExporting ? null : _saveToGallery,
                        icon: _isExporting 
                          ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                          : const Icon(Icons.download_rounded),
                        label: const Text('Enregistrer'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.brightYellow,
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _share,
                        icon: const Icon(Icons.share_rounded),
                        label: const Text('Partager'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.magicPurple,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextButton.icon(
                  onPressed: () => _confirmDelete(),
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  label: const Text('Supprimer', style: TextStyle(color: Colors.red)),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _confirmDelete() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer ?'),
        content: const Text('Voulez-vous vraiment supprimer ce souvenir ?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annuler')),
          TextButton(
            onPressed: () async {
              await SouvenirService.deleteSouvenir(widget.souvenir);
              if (mounted) {
                Navigator.pop(context);
                widget.onDelete();
              }
            },
            child: const Text('Supprimer', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
