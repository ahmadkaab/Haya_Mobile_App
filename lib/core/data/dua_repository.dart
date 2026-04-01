import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/dua_model.dart';

// ─── Static Islamic Content ─────────────────────────────────────────────────

const List<AyahModel> _ayat = [
  AyahModel(
    arabic: 'فَإِنَّ مَعَ الْعُسْرِ يُسْرًا',
    transliteration: "Fa-inna ma'al-'usri yusra",
    english: 'For indeed, with hardship will be ease.',
    reference: 'Quran 94:5',
  ),
  AyahModel(
    arabic: 'وَلَا تَيْأَسُوا مِن رَّوْحِ اللَّهِ',
    transliteration: "Wa laa tay'asuu mir-rawhillah",
    english: 'And do not despair of the mercy of Allah.',
    reference: 'Quran 12:87',
  ),
  AyahModel(
    arabic: 'إِنَّ اللَّهَ مَعَ الصَّابِرِينَ',
    transliteration: "Innallaaha ma'as-saabireen",
    english: 'Indeed, Allah is with the patient.',
    reference: 'Quran 2:153',
  ),
  AyahModel(
    arabic: 'وَمَن يَتَّقِ اللَّهَ يَجْعَل لَّهُ مَخْرَجًا',
    transliteration: "Wa may-yattaqillaaha yaj'al lahuu makhraja",
    english: 'And whoever fears Allah — He will make a way out for him.',
    reference: 'Quran 65:2',
  ),
  AyahModel(
    arabic: 'قُل يَا عِبَادِيَ الَّذِينَ أَسْرَفُوا عَلَىٰ أَنفُسِهِمْ لَا تَقْنَطُوا مِن رَّحْمَةِ اللَّهِ',
    transliteration: "Qul yaa 'ibaadiyalladhiina asrafuu 'alaaa anfusihim laa taqnatuu mir-rahmatillaah",
    english: 'Say: O My servants who have transgressed against themselves, do not despair of the mercy of Allah.',
    reference: 'Quran 39:53',
  ),
  AyahModel(
    arabic: 'وَإِذَا سَأَلَكَ عِبَادِي عَنِّي فَإِنِّي قَرِيبٌ',
    transliteration: "Wa idhaa sa-alaka 'ibaadii 'anni fa-innii qareeb",
    english: 'And when My servants ask you concerning Me — indeed I am near.',
    reference: 'Quran 2:186',
  ),
  AyahModel(
    arabic: 'حَسْبُنَا اللَّهُ وَنِعْمَ الْوَكِيلُ',
    transliteration: "Hasbunallaahu wa ni'mal-wakeel",
    english: 'Allah is sufficient for us, and He is the best Disposer of affairs.',
    reference: 'Quran 3:173',
  ),
];

const List<DuaModel> _duas = [
  DuaModel(
    title: 'Against Shaytan',
    category: 'urge_protection',
    arabic: 'أَعُوذُ بِاللَّهِ مِنَ الشَّيْطَانِ الرَّجِيمِ',
    transliteration: "A'udhu billahi minash-shaytanir-rajeem",
    english: 'I seek refuge in Allah from the accursed devil.',
  ),
  DuaModel(
    title: 'Seeking Forgiveness',
    category: 'repentance',
    arabic: 'رَبَّنَا ظَلَمْنَا أَنفُسَنَا وَإِن لَّمْ تَغْفِرْ لَنَا وَتَرْحَمْنَا لَنَكُونَنَّ مِنَ الْخَاسِرِينَ',
    transliteration: "Rabbanaa zalamnaaa anfusanaa wa illam taghfir lanaa wa tarhamnaa lanakuunanna minal-khaasireen",
    english: 'Our Lord, we have wronged ourselves, and if You do not forgive us and have mercy upon us, we will surely be among the losers.',
  ),
  DuaModel(
    title: 'For Strength',
    category: 'strength',
    arabic: 'رَبَّنَا أَفْرِغْ عَلَيْنَا صَبْرًا وَثَبِّتْ أَقْدَامَنَا',
    transliteration: "Rabbanaaa afrigh 'alaynaa sabraw wa thabbit aqdaamanaa",
    english: 'Our Lord, pour upon us patience and plant firmly our feet.',
  ),
  DuaModel(
    title: 'Purify the Heart',
    category: 'purification',
    arabic: 'اللَّهُمَّ طَهِّرْ قَلْبِي مِنَ النِّفَاقِ وَعَمَلِي مِنَ الرِّيَاءِ',
    transliteration: "Allahumma tahhir qalbi minan-nifaaq wa 'amali minar-riyaa'",
    english: 'O Allah, purify my heart from hypocrisy and my deeds from showing off.',
  ),
  DuaModel(
    title: 'Complete Tawbah',
    category: 'repentance',
    arabic: 'اللَّهُمَّ إِنِّي أَتُوبُ إِلَيْكَ مِنْ كُلِّ ذَنْبٍ',
    transliteration: "Allahumma innii atoobu ilayka min kulli dhanb",
    english: 'O Allah, I turn to You in repentance from every sin.',
  ),
];

// ─── Dhikr Counter Repository (Hive-backed) ─────────────────────────────────

class DhikrRepository extends StateNotifier<int> {
  final Box _box;
  final String _todayKey;

  DhikrRepository(this._box)
      : _todayKey = _buildTodayKey(),
        super(0) {
    _load();
  }

  static String _buildTodayKey() {
    final now = DateTime.now();
    return 'dhikr_${now.year}_${now.month}_${now.day}';
  }

  void _load() {
    state = _box.get(_todayKey, defaultValue: 0) as int;
  }

  Future<void> increment() async {
    final next = state + 1;
    state = next;
    await _box.put(_todayKey, next);
  }

  Future<void> resetToday() async {
    state = 0;
    await _box.put(_todayKey, 0);
  }
}

// ─── Providers ──────────────────────────────────────────────────────────────

final dhikrBoxProvider = Provider<Box>((ref) => Hive.box('preferences'));

final dhikrRepositoryProvider =
    StateNotifierProvider<DhikrRepository, int>((ref) {
  final box = ref.watch(dhikrBoxProvider);
  return DhikrRepository(box);
});

final duaListProvider = Provider<List<DuaModel>>((ref) => _duas);

AyahModel getDailyAyah() {
  final dayOfYear = DateTime.now().difference(DateTime(DateTime.now().year, 1, 1)).inDays;
  return _ayat[dayOfYear % _ayat.length];
}
