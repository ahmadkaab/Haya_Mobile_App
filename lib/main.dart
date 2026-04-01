import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Load Environment Variables securely
  await dotenv.load(fileName: ".env");

  // 2. Initialize Supabase
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );

  // 3. Initialize Hive with AES Encryption for local data security
  await Hive.initFlutter();
  const secureStorage = FlutterSecureStorage();
  
  // Try to find an existing Hive encryption key, or generate a new one
  String? encryptionKeyStr = await secureStorage.read(key: 'haya_hive_encryption_key');
  if (encryptionKeyStr == null) {
    final key = Hive.generateSecureKey();
    // Save to device hardware keystore
    await secureStorage.write(
      key: 'haya_hive_encryption_key',
      value: base64UrlEncode(key),
    );
    encryptionKeyStr = base64UrlEncode(key);
  }
  
  final encryptionKey = base64Url.decode(encryptionKeyStr);
  final cipher = HiveAesCipher(encryptionKey);

  // **Security Phase Wipe**: Delete old plaintext dev boxes
  await Hive.deleteBoxFromDisk('journal');
  await Hive.deleteBoxFromDisk('preferences');

  // Open boxes with AES Cipher to protect sensitive recovery data
  await Hive.openBox('journal', encryptionCipher: cipher);
  await Hive.openBox('preferences', encryptionCipher: cipher);

  runApp(
    // Wrap entire app in ProviderScope for Riverpod state management
    const ProviderScope(
      child: HayaApp(),
    ),
  );
}
