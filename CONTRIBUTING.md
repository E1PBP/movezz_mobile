# Contributing to Movezz Mobile (Flutter)
---

## Cara Berkontribusi

1. **Fork & Clone repo ini**

   Klik tombol `Fork` lalu clone repo hasil fork kamu:

   ```bash
   git clone https://github.com/<username-kamu>/movezz_mobile.git
   cd movezz_mobile
    ```

2. **Buat branch baru**

   Gunakan nama branch yang deskriptif:

   ```bash
   git checkout -b feature/<fitur>
   # atau
   git checkout -b fix/<bug>
   ```

   **Format branch yang disarankan:**

   * `feature/<fitur>` → untuk fitur baru
     contoh: `feature/feeds-page`, `feature/profile-edit`
   * `fix/<bug>` → untuk perbaikan bug
     contoh: `fix/feeds-pagination`, `fix/login-validation`

3. **Setup environment**

   Pastikan sudah meng-install:

   * [Flutter SDK](https://docs.flutter.dev/get-started/install)
   * Dart (bundled dengan Flutter)
   * VS Code / Android Studio / IDE favoritmu
   * Backend Django Movezz berjalan (local / staging)

   Lalu:

   ```bash
   flutter pub get
   ```

   Salin `.env.example` menjadi `.env` (untuk referensi nilai):

   ```bash
   cp .env.example .env
   ```

   Sesuaikan `BACKEND_BASE_URL` dengan environment kamu (misalnya untuk emulator Android):

   ```env
   BACKEND_BASE_URL=http://10.0.2.2:8000
   ```

   > Catatan: Flutter tidak membaca `.env` secara langsung. Nilai ini digunakan sebagai referensi bersama tim. Saat menjalankan aplikasi, gunakan `--dart-define` (lihat bagian "Menjalankan Project").

4. **Jalankan project**

   Jalankan di emulator/device:

   ```bash
   flutter run \
     --dart-define=BACKEND_BASE_URL=http://10.0.2.2:8000
   ```

   Untuk web (Chrome):

   ```bash
   flutter run -d chrome \
     --dart-define=BACKEND_BASE_URL=http://localhost:8000
   ```

5. **Kerjakan perubahanmu**

   Beberapa guideline arsitektur:

   * Tambahkan kode ke dalam **feature yang tepat**:

     * `lib/features/auth/...`
     * `lib/features/feeds/...`
     * `lib/features/profile/...`
     * `lib/features/broadcast/...`
     * `lib/features/marketplace/...`
     * `lib/features/messages/...`
   * Ikuti pola:

     * `data/models` → model/DTO dari API
     * `data/datasources` → call ke backend (via `CookieRequest`)
     * `data/repositories` → abstraksi untuk UI
     * `presentation/controllers` → state management (`ChangeNotifier`, dll.)
     * `presentation/pages` → halaman/screen
     * `presentation/widgets` → komponen UI kecil

   Kalau mau membuat fitur baru dengan struktur standar, gunakan script:

   ```powershell
   # Windows / PowerShell
   .\generate_features.ps1
   ```

6. **Commit perubahan**

   Gunakan pesan commit yang jelas dan konsisten:

   ```bash
   git add .
   git commit -m "feat: add feeds list UI"
   ```

   **Prefix commit yang disarankan:**

   * `feat:` → fitur baru
     `feat: add login page UI`
   * `fix:` → perbaikan bug
     `fix: wrong error message on login`
   * `docs:` → update dokumentasi
     `docs: update README for setup`
   * `style:` → formatting/typo (tanpa mengubah logika)
     `style: reformat auth controller`
   * `refactor:` → refactor kode
     `refactor: extract widget for post card`
   * `test:` → menambah/memperbaiki testing
     `test: add widget test for feeds page`

7. **Push ke GitHub & buat Pull Request (PR)**

   ```bash
   git push origin feature/feeds-page
   ```

   Lalu buka GitHub dan buat PR ke branch utama (misalnya `main` atau `master` sesuai pengaturan repo ini).

---

## Testing

Sebelum submit PR, jalankan test Flutter untuk memastikan tidak ada yang rusak:

```bash
flutter test
```

Jika kamu menambahkan fitur penting, usahakan juga menambah:

* **Widget test** untuk halaman utama yang kamu sentuh, atau
* **Unit test** untuk fungsi util / validator.

Contoh:

```bash
flutter test test/widget_test.dart
```

---

## Konvensi Kode & Struktur

### 1. Struktur Feature-based

Setiap fitur utama (auth, feeds, profile, dll.) menggunakan struktur:

```text
lib/features/<feature>/
  data/
    models/
    datasources/
    repositories/
  presentation/
    controllers/
    pages/
    widgets/
```

Jika kamu menambah fitur baru, usahakan mengikuti pola yang sama agar proyek tetap rapi dan mudah dipahami.

### 2. State Management

Saat ini proyek menggunakan `ChangeNotifier` + `Provider` sebagai baseline.
Contoh:

* Controller: `lib/features/feeds/presentation/controllers/feeds_controller.dart`
* Di-`provide` melalui `ChangeNotifierProvider` di page terkait.

Jika ingin menambah state management lain (misalnya Riverpod, Bloc), diskusikan dulu via issue/PR agar konsisten di seluruh project.

### 3. Theming & Widgets

* Gunakan komponen dari:

  * `lib/core/theme/app_theme.dart`
  * `lib/core/widgets/app_button.dart`
  * `lib/core/widgets/app_text_field.dart`

  sebelum membuat style baru sendiri.

* Kalau ada komponen yang berpotensi reusable lintas fitur, pertimbangkan untuk memindahkannya ke:

  * `lib/core/widgets/`
  * atau `lib/shared/widgets/` (jika nanti dibuat)

### 4. Network & Backend

* Gunakan `CookieRequest` dari `lib/core/network/cookie_request.dart` untuk semua request ke backend Django yang memakai session.
* Gunakan helper `Env.api('/path')` dari `lib/core/config/env.dart` untuk menyusun URL backend.
* Jangan hardcode `http://...` dimana-mana — selalu pakai `Env.backendBaseUrl` / `Env.api()`.

---

## Hal yang Tidak Boleh dikommit

Mohon **jangan commit** hal-hal berikut:

* File `.env` berisi konfigurasi lokal / credential,
* Key API / secret dalam bentuk hardcoded di kode,
* File build/artifact, misalnya:

  * `build/`, `.dart_tool/`, `.idea/`, dll. (sudah ada di `.gitignore`,
    jangan diubah kecuali perlu),
* File yang di-generate otomatis Flutter (misalnya file di dalam `build`, dll).

Jika perlu menambahkan environment baru, gunakan `.env.example` sebagai template, jangan commit `.env` personal kamu.

---

## Tips Workflow untuk Tim

* Sebelum mulai kerja, **pull** dulu branch utama (`main`/`master`) dan rebase/merge ke branch kamu.
* Satu PR sebaiknya fokus ke **satu topik** (satu fitur / satu bug), supaya review lebih mudah.
* Kalau perubahanmu menyentuh kontrak API (route, payload), sinkronkan juga dengan tim backend dan update dokumentasi jika perlu.
* Untuk perubahan besar (misalnya ganti arsitektur state management), buat issue/discussion dulu.

---

## Sumber yang Membantu

* Dokumentasi Flutter: [https://docs.flutter.dev/](https://docs.flutter.dev/)
* Dokumentasi Dart: [https://dart.dev/guides](https://dart.dev/guides)
* Dokumentasi Provider: [https://pub.dev/packages/provider](https://pub.dev/packages/provider)
* Best practice struktur folder Flutter (feature-first architecture)

---

