import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/souvenir_photo.dart';

class SouvenirService {
  static const String _souvenirsKey = 'souvenir_photos';

  static Future<SouvenirPhoto> saveSouvenir({
    required String letter,
    required Uint8List imageBytes,
  }) async {
    final directory = await getApplicationDocumentsDirectory();
    final souvenirsDirectory = Directory('${directory.path}/souvenirs');

    if (!await souvenirsDirectory.exists()) {
      await souvenirsDirectory.create(recursive: true);
    }

    final id = DateTime.now().millisecondsSinceEpoch.toString();
    final filePath = '${souvenirsDirectory.path}/souvenir_${letter}_$id.png';

    final file = File(filePath);
    await file.writeAsBytes(imageBytes);

    final souvenir = SouvenirPhoto(
      id: id,
      letter: letter,
      imagePath: filePath,
      createdAt: DateTime.now(),
    );

    final souvenirs = await getSouvenirs();
    final updatedSouvenirs = [souvenir, ...souvenirs];

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _souvenirsKey,
      jsonEncode(updatedSouvenirs.map((item) => item.toJson()).toList()),
    );

    return souvenir;
  }

  static Future<List<SouvenirPhoto>> getSouvenirs() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_souvenirsKey);

    if (jsonString == null) return [];

    try {
      final list = jsonDecode(jsonString) as List;

      return list
          .map((item) => SouvenirPhoto.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  static Future<List<SouvenirPhoto>> getSouvenirsByLetter(String letter) async {
    final souvenirs = await getSouvenirs();

    return souvenirs
        .where((item) => item.letter.toUpperCase() == letter.toUpperCase())
        .toList();
  }

  static Future<void> deleteSouvenir(SouvenirPhoto souvenir) async {
    final file = File(souvenir.imagePath);

    if (await file.exists()) {
      await file.delete();
    }

    final souvenirs = await getSouvenirs();
    souvenirs.removeWhere((item) => item.id == souvenir.id);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _souvenirsKey,
      jsonEncode(souvenirs.map((item) => item.toJson()).toList()),
    );
  }
}
