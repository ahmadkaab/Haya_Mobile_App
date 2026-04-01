class DuaModel {
  final String arabic;
  final String transliteration;
  final String english;
  final String category;
  final String title;

  const DuaModel({
    required this.arabic,
    required this.transliteration,
    required this.english,
    required this.category,
    required this.title,
  });
}

class AyahModel {
  final String arabic;
  final String english;
  final String transliteration;
  final String reference;

  const AyahModel({
    required this.arabic,
    required this.english,
    required this.transliteration,
    required this.reference,
  });
}
