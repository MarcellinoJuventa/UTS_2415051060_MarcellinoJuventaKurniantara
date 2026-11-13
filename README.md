# North — Specialty Coffee Bar Catalog & Brew Log

**North** adalah aplikasi mobile Flutter bertema *Nordic Specialty Coffee Bar* yang dikembangkan untuk memenuhi tugas **Project Ujian Tengah Semester (UTS) Pemrograman Mobile**. Aplikasi ini mengintegrasikan katalog minuman kopi bar publik melalui **REST API (`GET`)** dengan pencatatan jurnal racikan pribadi (*Brew Log / Tasting Notes*) pada database cloud **Supabase PostgreSQL (`CRUD`)**.

---

## Identitas Mahasiswa

| Atribut | Keterangan |
| :--- | :--- |
| **Nama Lengkap** | Marcellino Juventa Kurniantara |
| **NIM** | 2415051060 |
| **Kelas** | PTI-5IKI |
| **Nama Aplikasi** | North (`north_coffee_bar`) |
| **Tema Project** | Kuliner Minuman Coffee Bar & Jurnal Racikan Kopi |
| **Dosen Pengampu** | Dr. Ir. I Ketut Resika Arthana, S.T., M.Kom |
| **Teaching Assistant** | Made Yuda Sadewa, S.Pd. |
| **Repository URL** | [https://github.com/MarcellinoJuventa/UTS_2415051060_MarcellinoJuventaKurniantara](https://github.com/MarcellinoJuventa/UTS_2415051060_MarcellinoJuventaKurniantara) |

---

## Daftar Fitur Utama

1. **Dashboard Coffee Bar (`HomeScreen`):**
   - Ringkasan metrik jumlah menu katalog API, jumlah catatan tersimpan di Supabase, dan rata-rata rating kopi.
   - Pintasan filter cepat (*All Menu*, *Hot Espresso & Milk*, *Iced & Cold Brew*).
   - Carousel horizontal *Favorit Bar Anda* (*shared state*) dan rekomendasi *Barista's Pick*.
2. **Katalog Menu Bar dari REST API (`CatalogScreen`):**
   - Mengambil daftar minuman *Hot Coffee* dan *Iced Coffee* secara *real-time* melalui HTTP `GET`.
   - Fitur pencarian (*Search*) berdasarkan nama minuman, deskripsi rasa, maupun komposisi bahan (*ingredients*).
   - Filter kategori menggunakan `ChoiceChip` (*Semua*, *Hot*, *Iced*).
3. **Detail Minuman & Komposisi Bar (`DetailScreen`):**
   - Menampilkan foto minuman, kategori penyajian, deskripsi karakter rasa, dan daftar *Ingredients* melalui *passing data* antar-screen.
   - Tombol *Toggle Favorite* (*shared state*) dan tombol pintas *Simpan Racikan ke Brew Log*.
4. **Tambah Catatan Racikan ke Database (`AddLogScreen` — `CREATE`):**
   - Form interaktif dengan validasi (`TextFormField`, `SegmentedButton`, `DropdownButtonFormField`, pemilih bintang 1–5, dan `SwitchListTile`).
   - Menyimpan data racikan kopi baru ke tabel `public.coffee_logs` di Supabase.
5. **Jurnal Racikan Kopi (`SavedLogsScreen` — `READ` & `DELETE`):**
   - Menampilkan seluruh data racikan kopi yang tersimpan di Supabase PostgreSQL.
   - Filter berdasarkan status (*Semua*, *Sudah Dicoba*, *Wishlist*).
   - Fitur hapus catatan dengan **`AlertDialog` konfirmasi** sebelum mengeksekusi `DELETE` ke Supabase.
6. **Edit Catatan Racikan (`EditLogScreen` — `UPDATE`):**
   - Mengubah nama racikan, kategori, tingkat kemanisan (*sweetness level*), rating bintang, status sudah dicoba, dan catatan barista.
7. **Responsive Layout (Compact vs Wide/Expanded):**
   - Layar **Compact (`< 600px`)**: Menggunakan `NavigationBar` bawah dan `ListView`.
   - Layar **Wide/Expanded (`>= 600px`)**: Menggunakan `NavigationRail` samping dan otomatis mengubah daftar menjadi `GridView` multi-kolom menggunakan `LayoutBuilder` & `MediaQuery`.
8. **State & Feedback Lengkap:**
   - Penanganan *Loading State*, *Error State* (dengan tombol *Retry*), dan *Empty State*.
   - Feedback pengguna menggunakan `SnackBar` dan `AlertDialog`.

---

## Tech Stack

- **Framework & Bahasa:** Flutter SDK & Dart (Null Safety, Async/Await, Future, Exception Handling)
- **State Management:** `provider` (`ChangeNotifier` & `MultiProvider`)
- **HTTP & Networking:** `http` package
- **Formatting:** `intl` package
- **Backend Database:** Supabase (PostgreSQL REST API `/rest/v1/coffee_logs`)
- **Public REST API:** SampleAPIs Coffee API

---

## REST API yang Digunakan

Aplikasi menggunakan **SampleAPIs Coffee Public REST API** (Operasi `GET`):
- **Hot Coffee Endpoint:** `https://api.sampleapis.com/coffee/hot`
- **Iced Coffee Endpoint:** `https://api.sampleapis.com/coffee/iced`
- **Konversi Model:** Response JSON dikonversi menjadi Dart Model `CoffeeItem` (`id`, `title`, `description`, `ingredients`, `image`, `category`).

---

## Backend & Database yang Digunakan

Aplikasi menggunakan **Supabase (PostgreSQL)** untuk menyimpan data personal pengguna pada tabel `public.coffee_logs`:
- **Base REST URL:** `https://ekzkpfwyfnprafgkbjro.supabase.co/rest/v1/coffee_logs`
- **Keamanan:** Hanya menggunakan `anon / publishable key` dengan kebijakan RLS (*Row Level Security*). Tidak ada `service_role` key atau kredensial rahasia di dalam repositori.
- **Skema Tabel `public.coffee_logs`:**
  - `id` (`BIGINT` — Primary Key)
  - `coffee_id` (`INT` — ID referensi katalog)
  - `coffee_title` (`TEXT` — Nama minuman kopi)
  - `coffee_image` (`TEXT` — URL gambar minuman)
  - `category` (`TEXT` — `'Hot'` / `'Iced'`)
  - `sweetness_level` (`TEXT` — Tingkat kemanisan)
  - `custom_note` (`TEXT` — Catatan racikan barista / review rasa)
  - `rating` (`INT` — Rating 1 s/d 5)
  - `is_tried` (`BOOLEAN` — Status *Sudah Dicoba* atau *Wishlist*)
  - `created_at` (`TIMESTAMPTZ` — Waktu pencatatan)

---

## Struktur Arsitektur Aplikasi

Project menerapkan pemisahan layer **UI → Provider → Repository → Service → REST API / Database**:

```text
lib/
├── config/
│   ├── app_config.dart             # Konstanta endpoint API, Supabase, & identitas mahasiswa
│   └── app_theme.dart              # Tema warna & tipografi North Specialty Coffee Bar
├── models/
│   ├── coffee_item.dart            # Model 1: Konversi JSON dari REST API Katalog Kopi
│   ├── coffee_log.dart             # Model 2: Konversi data tabel Supabase coffee_logs
│   └── models.dart
├── services/
│   ├── coffee_api_service.dart     # HTTP GET ke SampleAPIs Coffee (/hot & /iced)
│   ├── supabase_service.dart       # Operasi CRUD HTTP ke Supabase REST API
│   └── services.dart
├── repositories/
│   ├── coffee_repository.dart      # Abstraksi sumber data katalog REST API
│   ├── log_repository.dart         # Abstraksi sumber data CRUD Supabase
│   └── repositories.dart
├── providers/
│   ├── coffee_provider.dart        # State katalog, pencarian, filter Hot/Iced, & favorit
│   ├── log_provider.dart           # State CRUD database Supabase & filter status
│   └── providers.dart
├── screens/
│   ├── main_navigation_screen.dart # Shell navigasi responsif (NavigationBar & NavigationRail)
│   ├── home_screen.dart            # Screen 1: Dashboard & Barista's Pick
│   ├── catalog_screen.dart         # Screen 2: Katalog Kopi REST API (List/Grid responsif)
│   ├── detail_screen.dart          # Screen 3: Detail Kopi & Komposisi Bar (Passing Data)
│   ├── add_log_screen.dart         # Screen 4: Form Tambah Catatan Racikan (CREATE)
│   ├── edit_log_screen.dart        # Screen 5: Form Edit Catatan Racikan (UPDATE)
│   ├── saved_logs_screen.dart      # Screen 6: Daftar Brew Log & Konfirmasi Hapus (READ/DELETE)
│   ├── profile_screen.dart         # Screen 7: Profil Mahasiswa & Informasi Arsitektur
│   └── screens.dart
├── widgets/
│   ├── responsive_layout.dart      # Reusable Widget 1: LayoutBuilder Compact vs Wide
│   ├── log_card.dart               # Reusable Widget 2: Kartu catatan database Supabase
│   ├── ingredient_chip.dart        # Reusable Widget 3: Chip komposisi & kategori kopi
│   ├── coffee_card.dart            # Reusable Widget 4: Kartu item katalog kopi
│   ├── state_view_widget.dart      # Reusable Widget 5: Loading, Error, & Empty State
│   └── widgets.dart
└── main.dart                       # Entry point aplikasi & konfigurasi MultiProvider
```

---

## Screenshot Aplikasi

> Letakkan file screenshot aplikasi pada folder `screenshots/` untuk dokumentasi:
- **Home / Dashboard Screen** (`screenshots/01_home.png`)
- **Bar Menu Catalog — Compact List & Wide Grid** (`screenshots/02_catalog_responsive.png`)
- **Coffee Detail Screen** (`screenshots/03_detail.png`)
- **Create / Add Brew Log Form** (`screenshots/04_create_log.png`)
- **Saved Brew Logs (Supabase Database)** (`screenshots/05_saved_logs.png`)
- **Edit Brew Log & Delete Confirmation Dialog** (`screenshots/06_edit_delete.png`)
- **Profile & Architecture Info Screen** (`screenshots/07_profile.png`)

---

## Cara Menjalankan Project

1. **Clone repository ini:**
   ```bash
   git clone https://github.com/MarcellinoJuventa/UTS_2415051060_MarcellinoJuventaKurniantara.git
   cd UTS_2415051060_MarcellinoJuventaKurniantara
   ```
2. **Unduh dependencies Flutter:**
   ```bash
   flutter pub get
   ```
3. **Jalankan aplikasi (Android / Windows / Chrome / Emulator):**
   ```bash
   flutter run
   ```
4. **Build APK Release (untuk pengumpulan deliverables UTS):**
   ```bash
   flutter build apk --release
   ```
