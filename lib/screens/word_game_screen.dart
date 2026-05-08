import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../constants.dart';
import '../theme.dart';
import '../widgets/word_chip.dart';
import '../services/tts_service.dart';
import '../services/translation_service.dart';
import '../widgets/mission_progress_bar.dart';

class WordGameScreen extends StatefulWidget {
  final String letter;
  final List<String>? scannedWords;

  const WordGameScreen({
    required this.letter,
    this.scannedWords,
    super.key,
  });

  @override
  State<WordGameScreen> createState() => _WordGameScreenState();
}

class _WordGameScreenState extends State<WordGameScreen> {
  late List<String> _allWords;
  late List<String> _correctWords;
  final Set<String> _selectedWords = {};
  int _correctCount = 0;
  final _ttsService = TtsService();
  final _translationService = TranslationService();

  // Traductions : mot → traduction arabe
  final Map<String, String> _translations = {};
  bool _translationsLoading = false;

  @override
  void initState() {
    super.initState();
    _initGame();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _ttsService.speak(
        'Clique sur les mots qui commencent par la lettre ${widget.letter} !',
      );
      // Pré-traduire tous les mots en arrière-plan
      _preloadTranslations();
    });
  }

  @override
  void dispose() {
    _ttsService.stop();
    super.dispose();
  }

  void _initGame() {
    // On n'utilise QUE les mots scannés envoyés par la page précédente
    final scanned = widget.scannedWords ?? [];
    
    // 1. Mots qui commencent par la bonne lettre
    _correctWords = scanned
        .where((w) => w[0].toUpperCase() == widget.letter.toUpperCase())
        .toSet()
        .toList();

    // 2. Les autres mots servent de distracteurs
    final distractors = scanned
        .where((w) => w[0].toUpperCase() != widget.letter.toUpperCase())
        .toSet()
        .toList();

    // 3. Si on n'a pas assez de distracteurs dans le scan, on en ajoute quelques-uns
    // pour garder le côté ludique, mais on privilégie le scan.
    if (distractors.length < 3) {
      final additionalDistractors = WORDS_BY_LETTER.entries
          .where((e) => e.key != widget.letter)
          .expand((e) => e.value)
          .toList()..shuffle();
      distractors.addAll(additionalDistractors.take(3 - distractors.length));
    }

    // Mélanger le tout
    _allWords = [..._correctWords, ...distractors.take(5)]..shuffle();
  }

  Future<void> _preloadTranslations() async {
    setState(() => _translationsLoading = true);
    final results = await _translationService.translateAll(_allWords);
    if (!mounted) return;
    setState(() {
      _translations.addAll(results);
      _translationsLoading = false;
    });
  }

  bool get _allCorrectFound => 
    _correctWords.every((w) => _selectedWords.contains(w));

  Future<void> _onWordTap(String word) async {
    final isCorrect = _correctWords.contains(word);
    
    // 1. Lire le mot
    _ttsService.speak(word);

    if (_selectedWords.contains(word)) return;

    setState(() {
      _selectedWords.add(word);
      if (isCorrect) {
        _correctCount++;
      }
    });

    if (isCorrect) {
      _ttsService.speakHappy('Gagné ! $word commence par ${widget.letter}');
    } else {
      _ttsService.speakHappy('Raté ! $word ne commence pas par ${widget.letter}');
    }
  }

  List<_WordEntry> get _selectedEntries => _selectedWords.map((w) {
        return _WordEntry(
          word: w,
          translation: _translations[w] ?? '...',
          isCorrect: _correctWords.contains(w),
        );
      }).toList();

  @override
  Widget build(BuildContext context) {
    final entries = _selectedEntries;
    final correctSelected = entries.where((e) => e.isCorrect).length;
    final total = entries.length;

    return Scaffold(
      appBar: AppBar(title: const Text('🔤 Trouve les mots')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const MissionProgressBar(currentStep: 2),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Clique sur les mots qui commencent par ${widget.letter}',
                    style: Theme.of(context).textTheme.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                ),
                IconButton(
                  onPressed: () => _ttsService.speak(
                    'Clique sur les mots qui commencent par la lettre ${widget.letter} !',
                  ),
                  icon: const Icon(Icons.volume_up_rounded),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Indicateur de chargement des modèles
            if (_translationsLoading)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(
                      width: 12,
                      height: 12,
                      child:
                          CircularProgressIndicator.adaptive(strokeWidth: 1.5),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Chargement des traductions…',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withOpacity(0.4),
                          ),
                    ),
                  ],
                ),
              ),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              alignment: WrapAlignment.center,
              children: _allWords.map((word) {
                final isCorrect = _correctWords.contains(word);
                final isSelected = _selectedWords.contains(word);
                return WordChip(
                  word: word,
                  status: !isSelected
                      ? WordStatus.neutral
                      : (isCorrect ? WordStatus.correct : WordStatus.wrong),
                  onTap: () => _onWordTap(word),
                  isSelected: isSelected,
                );
              }).toList(),
            ),

            if (entries.isNotEmpty) ...[
              const SizedBox(height: 24),
              _TranslationCard(
                entries: entries,
                correctCount: correctSelected,
                total: total,
                onSpeakWord: (w) => _ttsService.speak(w),
              ),
            ],
            const SizedBox(height: 100), // Espace pour le bouton en bas
          ],
        ),
      ),
      bottomNavigationBar: _correctWords.isNotEmpty
          ? Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 30),
              child: _allCorrectFound
                  ? ElevatedButton.icon(
                      onPressed: () {
                        final firstCorrect = _selectedWords.firstWhere(
                            (w) => _correctWords.contains(w));
                        context.push('/object-hunt/${widget.letter}',
                            extra: firstCorrect);
                      },
                      icon: const Icon(Icons.search_rounded),
                      label: const Text(
                        'Super ! Maintenant 🔎',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.brightYellow,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                        elevation: 5,
                      ),
                    )
                  : Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.lightGray.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'Trouve les ${_correctWords.length} mots qui commencent par "${widget.letter}" pour continuer !',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                          color: Colors.black54,
                        ),
                      ),
                    ),
            )
          : null,
    );
  }
}

// --- Modèles et widgets identiques à avant ---
class _WordEntry {
  final String word;
  final String translation;
  final bool isCorrect;
  const _WordEntry({
    required this.word,
    required this.translation,
    required this.isCorrect,
  });
}

class _TranslationCard extends StatelessWidget {
  final List<_WordEntry> entries;
  final int correctCount;
  final int total;
  final void Function(String) onSpeakWord;

  const _TranslationCard({
    required this.entries,
    required this.correctCount,
    required this.total,
    required this.onSpeakWord,
  });

  @override
  Widget build(BuildContext context) {
    final pct = total > 0 ? (correctCount / total * 100).round() : 0;

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).dividerColor.withOpacity(0.3),
          width: 0.5,
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Traduction en arabe',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color:
                      Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                ),
          ),
          const SizedBox(height: 12),
          ...entries.map((e) => _TranslationRow(
                entry: e,
                onSpeak: () => onSpeakWord(e.word),
              )),
          const SizedBox(height: 12),
          Divider(
              height: 1,
              color: Theme.of(context).dividerColor.withOpacity(0.3)),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$correctCount bon${correctCount > 1 ? 's' : ''} sur $total',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withOpacity(0.5),
                    ),
              ),
              Text(
                '$pct %',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).colorScheme.primary,
                    ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TranslationRow extends StatelessWidget {
  final _WordEntry entry;
  final VoidCallback onSpeak;

  const _TranslationRow({required this.entry, required this.onSpeak});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: entry.isCorrect
                  ? const Color(0xFFEAF3DE)
                  : const Color(0xFFFCEBEB),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              entry.isCorrect ? 'Correct' : 'Faux',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: entry.isCorrect
                    ? const Color(0xFF27500A)
                    : const Color(0xFF791F1F),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: GestureDetector(
              onTap: onSpeak,
              child: Row(
                children: [
                  Text(
                    entry.word,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.volume_up_rounded,
                    size: 15,
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withOpacity(0.35),
                  ),
                ],
              ),
            ),
          ),
          // '...' pendant le chargement, arabe après
          entry.translation == '...'
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator.adaptive(strokeWidth: 1.5),
                )
              : Text(
                  entry.translation,
                  style: const TextStyle(
                    fontSize: 20,
                    fontFamily: 'Amiri',
                    color: Color(0xFF185FA5),
                  ),
                  textDirection: TextDirection.rtl,
                ),
        ],
      ),
    );
  }
}
