<div align="center">

# 🌙 Haya (حياء)
**A Private, Secure Sanctuary for Personal Growth and Addiction Recovery**

![Flutter](https://img.shields.io/badge/Flutter-%2302569B.svg?style=for-the-badge&logo=Flutter&logoColor=white)
![Dart](https://img.shields.io/badge/dart-%230175C2.svg?style=for-the-badge&logo=dart&logoColor=white)
![Supabase](https://img.shields.io/badge/Supabase-3ECF8E?style=for-the-badge&logo=supabase&logoColor=white)
![Hive](https://img.shields.io/badge/Hive-Database-orange?style=for-the-badge)

</div>

## 📖 Overview
**Haya** is an interactive, natively compiled mobile application built with Flutter, designed to help users combat bad habits, regulate their daily routines, and establish powerful positive momentum.

Built strictly with user privacy as its core tenant, Haya features military-grade on-device encryption, strict cloud-level Row Level Security, and mandatory Biometric authentication locks so your private journals remain exclusively yours.

## ✨ Key Features
* 🛡️ **Zero-Trust App Lock**: Automatically freezes the app when sent to the background, requiring system-level Biometric Authentication (FaceID/TouchID/PIN) to unlock.
* 🔐 **Encrypted Local Storage**: Journals and preference tracking are completely encrypted locally on-device using hardware-backed keystores via `HiveAesCipher`.
* ☁️ **Cloud Defense**: Powered by a Supabase Backend, rigorously secured via PostgreSQL **Row Level Security (RLS)** to mathematically prevent cross-user data exposure.
* 📈 **Streak Tracking**: Maintain a persistent streak counter. Haya gamifies your recovery journey with motivational feedback loops.
* 📓 **Private Journaling**: Safely record your emotional state, log urges, and document your personal victories knowing that nobody else can access your data.
* 🏅 **Dynamic Badges**: Earn beautiful, unlockable community achievements as you cross recovery milestones (`Sabr_7`, `Ramadan_30`, `Prophetic_365`).

## 🛠️ Tech Stack
* **Frontend**: [Flutter](https://flutter.dev/) & Dart 3
* **State Management**: [Riverpod](https://riverpod.dev/) (`flutter_riverpod`)
* **Routing**: `go_router` (StatefulShellRoutes for persistent navigation)
* **Local Database**: `hive` & `hive_flutter` (AES-256 encrypted boxes)
* **Backend Database**: [Supabase](https://supabase.com/)
* **Security & Auth**: `local_auth`, `flutter_secure_storage`, `flutter_dotenv`

---

## 🚀 Getting Started

To run this project on your local machine, ensure you have the Flutter SDK installed on your system path.

### 1. Clone the Repository
```bash
git clone https://github.com/ahmadkaab/Haya_Mobile_App.git
cd Haya_Mobile_App/haya
```

### 2. Setup Environment Variables
Create a file named `.env` in the root of the `haya/` directory and include your API keys:
```env
SUPABASE_URL=your_supabase_project_url
SUPABASE_ANON_KEY=your_supabase_anon_key
```

### 3. Fetch Dependencies
```bash
flutter pub get
```

### 4. Run the App!
Launch to your connected physical device (iPhone or Android):
```bash
flutter run
```

---

<div align="center">
<i>"Indeed, modesty (Haya) does not bring anything except good."</i> <br>
— Al-Bukhari & Muslim
</div>
