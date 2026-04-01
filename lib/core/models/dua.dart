class Dua {
  final String id;
  final String category;
  final String arabic;
  final String transliteration;
  final String english;
  final String context;
  final String source;

  Dua({
    required this.id,
    required this.category,
    required this.arabic,
    required this.transliteration,
    required this.english,
    required this.context,
    required this.source,
  });

  factory Dua.fromJson(Map<String, dynamic> json) {
    return Dua(
      id: json['id'] as String,
      category: json['category'] as String,
      arabic: json['arabic'] as String,
      transliteration: json['transliteration'] as String,
      english: json['english'] as String,
      context: json['context'] as String,
      source: json['source'] as String,
    );
  }
}
