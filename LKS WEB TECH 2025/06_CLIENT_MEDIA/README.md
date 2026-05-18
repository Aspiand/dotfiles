# Module: 06_CLIENT_MEDIA (Game Development)

## Deskripsi Project
Module ini adalah proyek pengembangan game berbasis web menggunakan teknologi **Vanilla JavaScript (ES6+)**. Game ini melibatkan pemain yang menavigasi karakter dalam sebuah arena (board) yang berisi rintangan seperti bom (TNT), dinding (Wall), dan es (Ice). Tujuannya adalah mencapai skor tertentu atau bertahan dalam waktu yang ditentukan.

## Teknologi yang Digunakan
- **HTML5**: Struktur halaman game dan elemen UI (Welcome screen, Instruction, Game board, Leaderboards).
- **CSS3**: Styling visual game, animasi, dan layouting (menggunakan class-based hidden/show logic).
- **Vanilla JavaScript**: Logika inti game, manipulasi DOM, manajemen state, dan penyimpanan data lokal.
- **LocalStorage API**: Digunakan untuk menyimpan nama pemain dan data skor untuk fitur Leaderboards secara persisten di browser.

## Struktur File Penting
- `index.html`: Entry point utama aplikasi.
- `style.css`: Berisi desain layout game, dari layar awal hingga layar game over.
- `vanilla.js`: Berisi logika JavaScript. Terdapat class `Game` untuk manajemen siklus hidup game.
- `Images/`: Aset grafis game (karakter, rintangan, latar belakang).

## Hal-Hal yang Harus Dipelajari (Persiapan)
1. **Game Loop**: Memahami cara kerja loop game menggunakan `requestAnimationFrame` atau `setInterval`.
2. **DOM Manipulation**: Cara menggerakkan elemen di layar dengan mengubah koordinat CSS (top/left) atau menggunakan Grid System.
3. **Event Listeners**: Menangani input keyboard (WASD atau Arrow Keys) untuk pergerakan karakter.
4. **Collision Detection**: Logika untuk mendeteksi ketika karakter menyentuh dinding atau item rintangan.
5. **State Management**: Mengelola status game (Countdown, Running, Paused, GameOver).
6. **Local Storage**: Cara menyimpan, mengambil, dan mengurutkan data (sorting) untuk leaderboard.

## Kisi-Kisi Konsep
- Implementasi sistem nyawa (Heart logic).
- Perhitungan waktu (Timer) dan skor berdasarkan item yang dihancurkan/dikumpulkan.
- Validasi form input nama sebelum memulai game.
- Transisi antar layar (Start -> Instruction -> Play -> Game Over -> Leaderboard).
