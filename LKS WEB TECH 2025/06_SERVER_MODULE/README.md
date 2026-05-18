# Module: 06_SERVER_MODULE (Full-Stack Web Application)

## 1. Penjelasan Detail Project Keseluruhan
Project ini adalah platform layanan masyarakat yang mengintegrasikan dua sistem utama: **Sistem Validasi Data Sosial** dan **Sistem Pengajuan Cicilan (Installment)**. Sistem ini memungkinkan warga (Society) untuk mendaftar, login, mengajukan validasi pekerjaan/pendapatan, serta melihat dan mengajukan cicilan kendaraan.

Project ini menggunakan arsitektur **Decoupled (Separated Frontend & Backend)**:
- **Backend**: Bertugas sebagai RESTful API Server yang menyediakan data dan memproses logika bisnis.
- **Frontend**: Bertugas sebagai Consumer API yang menyediakan antarmuka pengguna interaktif (SPA).

---

## 2. Backend (Laravel API)
Backend dibangun menggunakan framework **Laravel 11** dengan fokus pada penyediaan endpoint API yang aman dan efisien.

### Teknologi & Fitur:
- **Laravel 11 & PHP 8.2**: Versi terbaru dengan performa optimal.
- **Laravel Sanctum**: Digunakan untuk autentikasi berbasis token (Token-based Auth).
- **Eloquent ORM**: Pemodelan database yang kompleks menghubungkan `Societies`, `Validations`, `Installments`, dan `Regionals`.
- **API Versioning**: Menggunakan prefix `v1/` pada rute untuk manajemen versi API.
- **Database**: MySQL/MariaDB dengan relasi antar tabel yang ketat (Foreign Keys & Constraints).

### Konsep Penting Backend:
- **Custom Auth**: Login menggunakan `id_card_number` alih-alih email.
- **Middleware**: Melindungi endpoint sensitif (misal: pengajuan validasi) agar hanya bisa diakses oleh user yang sudah login.
- **Validation**: Menggunakan Request Validation untuk memastikan data yang masuk sesuai format.
- **Resources/JSON Response**: Memberikan format response yang konsisten untuk dikonsumsi frontend.

---

## 3. Frontend (Vue.js SPA)
Frontend dibangun menggunakan **Vue 3** dengan **Vite** sebagai build tool, memberikan pengalaman pengguna yang sangat cepat tanpa reload halaman.

### Teknologi & Fitur:
- **Vue 3 (Composition API)**: Standard modern pengembangan komponen Vue.
- **Vue Router**: Manajemen navigasi halaman (Dashboard, Login, Create Validation, List Cars).
- **Axios**: Library untuk melakukan HTTP Request ke Laravel API.
- **Bootstrap 5**: Framework CSS untuk styling UI yang responsif dan konsisten.

### Konsep Penting Frontend:
- **Reactive State**: Penggunaan `ref` dan `reactive` untuk sinkronisasi data UI.
- **Lifecycle Hooks**: `onMounted` untuk fetch data saat halaman dimuat.
- **Navigation Guards**: Melindungi route agar user yang belum login tidak bisa masuk ke Dashboard.
- **Component Reusability**: Membagi UI menjadi bagian-bagian kecil (Header, Sidebar, Form Components).

---

## Persiapan & Materi Belajar
1. **RESTful API**: Pahami metode GET, POST, PUT, DELETE dan HTTP Status Codes (200, 201, 401, 422).
2. **Laravel Eloquent**: Pelajari relasi `belongsTo`, `hasMany`, dan `belongsToMany`.
3. **Vue Router**: Cara kerja `router-link`, `router-view`, dan redirecting.
4. **Token Management**: Cara menyimpan token di `localStorage` atau `sessionStorage` dan mengirimkannya melalui Header Authorization (Bearer Token) pada setiap request Axios.
5. **Database Migration & Seeding**: Penting untuk menyiapkan environment development dengan cepat.
