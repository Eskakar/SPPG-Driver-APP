# 📱 SPPG Driver App

![Flutter](https://img.shields.io/badge/Flutter-3.x-blue)
![Dart](https://img.shields.io/badge/Dart-Language-blue)
![Platform](https://img.shields.io/badge/Platform-Android-green)
![Status](https://img.shields.io/badge/Status-Active-success)

Aplikasi mobile berbasis Flutter untuk sistem **SPPG Driver**, digunakan untuk membantu proses distribusi MBG (Makanan Bergizi Gratis) secara digital, terstruktur, dan terintegrasi dengan backend.

---

# ✨ Features

## 🔐 Autentikasi

* Login berbasis session
* Penyimpanan cookie menggunakan `cookie_jar`
* Auto login menggunakan validasi session

## 🚚 Tugas Pengantaran

* Menampilkan tugas harian driver
* Progress distribusi ke sekolah
* Detail tugas secara lengkap

## 📦 Scan QR

* Scan QR saat pickup di SPPG
* Scan QR saat delivery ke sekolah
* Validasi lokasi berbasis GPS

## 🗺️ Peta & Navigasi

* Menampilkan lokasi driver dan sekolah
* Menampilkan rute perjalanan
* Perhitungan jarak pengantaran

## 🔔 Notifikasi

* Notifikasi tugas baru
* Sinkronisasi dengan backend

## 🎰 Roulette Reward

* Mendapatkan spin setelah menyelesaikan tugas
* Animasi roulette
* Hasil dikontrol backend (anti cheat)

## 🤖 Chatbot AI

* Asisten virtual berbasis LLM
* Menjawab pertanyaan pengguna
* Menggunakan model openai/gpt-oss-120b:free

---

# 🧠 App Architecture

```
Flutter UI
   ↓
Service Layer (Dio + API Service)
   ↓
Backend API (Express.js)
   ↓
Database (MySQL)
```

---

# 📂 Project Structure

```
lib/
├── screens/        # Halaman UI
├── services/       # API dan logic komunikasi backend
├── widgets/        # Komponen UI reusable
├── models/         # Model data
└── main.dart       # Entry point aplikasi
```

---

# ⚙️ Installation

## 1️⃣ Clone Repository

```bash
git clone https://github.com/Eskakar/SPPG-Driver-APP.git
cd SPPG-Driver-APP
```

---

## 2️⃣ Install Dependencies

```bash
flutter pub get
```

---

## 3️⃣ Run Application

```bash
flutter run
```

---

# 🔧 Configuration

Pastikan backend sudah berjalan, lalu sesuaikan base URL di:

```
ApiService.dart
```

Contoh:

```dart
baseUrl = "http://localhost:3000";
```

---

# 🌐 API Integration

Aplikasi terhubung dengan backend API untuk:

* Autentikasi pengguna
* Data tugas dan distribusi
* Scan QR dan validasi lokasi
* Sistem roulette
* Chatbot AI

---

# 🔄 App Flow

```
Login
↓
Cek Session
↓
Tugas Hari Ini
↓
Scan QR (Pickup)
↓
Perjalanan
↓
Scan QR (Delivery)
↓
Tugas Selesai
↓
Reward Roulette 🎰
```

---

# 🧠 Tech Stack

* Flutter
* Dart
* Dio (HTTP Client)
* cookie_jar
* Mobile Scanner (QR)
* Flutter Map (OpenStreetMap)
* LLM API (OpenRouter)

---

# ⚠️ Important Notes

* Session menggunakan cookie (bukan JWT)
* Semua logic penting ada di backend
* Gunakan HTTPS untuk production
* OpenStreetMap memiliki rate limit (gunakan dengan bijak)

---

# 💬 Key Concept

> Aplikasi ini dirancang untuk meningkatkan efisiensi distribusi dengan menggabungkan teknologi mobile, validasi lokasi, dan sistem reward berbasis gamification.

---

# 🚀 Future Improvements

* Push Notification (FCM)
* Offline Mode
* Tracking real-time
* Dashboard analytics

---

# 👨‍💻 Author

Developed for **SPPG Driver System**
* Nabil Aqila Putra 123230085
* Adib Fathani Awwab 123230104

