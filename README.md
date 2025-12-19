# Goalytics Mobile

Platform mobile interaktif untuk penggemar sepak bola yang ingin mengakses statistik pemain, membuat prediksi pertandingan, berdiskusi, dan mengelola informasi favorit mereka dalam satu aplikasi modern dan mudah digunakan.

Aplikasi ini hadir untuk menjawab kebutuhan pengguna yang selama ini harus mencari data pemain, forum diskusi, dan insight pertandingan dari sumber yang tersebar. Goalytics Mobile menyatukan semuanya dalam satu ekosistem lengkap — cepat, ringkas, dan mobile-friendly.

## Install
![Build Status](https://app.bitrise.io/app/413c8e52-48e3-41e6-a98a-5bb163d0d127/status.svg?token=hPfG1Ehpdx2MLieN_gPyYg&branch=main)

https://app.bitrise.io/app/413c8e52-48e3-41e6-a98a-5bb163d0d127/installable-artifacts/e6328d63220739e1/public-install-page/4f65bcb9feaf091763c753cf5f3117a3




## 👥 Anggota Tim

| Nama                         | NPM        |
|------------------------------|-----------|
| Jefferson Tirza Liman        | 2406435963 |
| Haikal Muzaki                | 2406407360 |
| Malik Alifan Kareem          | 2406348710 |
| Muhammad Haikal              | 2406424190 |
| Zakiy Nashrudin Wahid        | 2406496044 |
| Rayyan Emir Muhammad         | 2406345375 |

---

## Fitur Utama

- Akses cepat statistik pemain berbasis mobile  
- CRUD modul favorit, prediksi, dan forum  
- Tampilan responsif dan intuitif  
- Personalisasi berdasarkan preferensi pengguna (liga, klub, mode tampilan)  
- Database pemain yang dapat diperbarui oleh admin  

---

## 🧩 Module Overview
| Modul                         | Purpose                         | Fungsi Utama                                                                 |
|------------------------------|---------------------------------|------------------------------------------------------------------------------|
| **Favorite Player List**     | Manajemen pemain favorit        | Tambah, lihat, edit, hapus daftar pemain favorit                            |
| **Match Prediction**         | Prediksi pertandingan           | CRUD prediksi dan hasil prediksi                                            |
| **Football Discussion**      | Forum diskusi sepak bola        | Post & komentar antar pengguna (forum-based)                                |
| **Comparison**               | Perbandingan statistik pemain   | Bandingkan performa beberapa pemain secara visual dan interaktif            |
| **View/Edit Profile**        | Manajemen profil pengguna       | Edit akun, preferensi klub & liga, serta pengaturan tampilan                |
| **Football Transfer Rumour** | Modul berita transfer pemain    | Analyst dapat membuat, mengedit dan men-delete berita yang dibuatnya        |
| **Login, Authentification, and Database** | Dashboard dan player management    | Landing page dan untuk menambahkan pemain dan klub        |

---

## 📌 Deskripsi Singkat Modul

- Modul Dream Squad (Zaky)
Pengguna dapat menambah, melihat, mengedit, dan menghapus daftar squad impian secara mobile untuk memantau squad terbaik mereka.

- Modul Match Prediction (Haikal Muzaki)
Pengguna dapat membuat, membaca, memperbarui, dan menghapus prediksi pertandingan secara mandiri.

- Modul Football Discussion (Muhammad Haikal)
Forum diskusi sepak bola tempat pengguna berbagi opini, analisis, dan berita. Setiap postingan dan komentar dapat dikelola oleh pemiliknya (CRUD).

- Modul Comparison (Rayyan Emir)
Pengguna dapat membandingkan dua atau lebih pemain berdasarkan statistik utama secara visual dan interaktif, serta menyimpan hasil perbandingan.

- Modul View/Edit Profile (Malik Kareem)
Pengguna dapat mengelola profil pribadi, termasuk preferensi liga, klub favorit, dan pengaturan tampilan aplikasi.

- Modul Transfer Rumour (Malik Kareem)
Modul dimana pengguna dapat membaca berita terbaru mengenai rumor rumor transfer. Pengguna dengan role analyst dapat membuat dan mendelete berita yang dibuat oleh mereka sendiri.

- Modul Login, Authentification, and Database (Jefferson Tirza)
Modul dimana pengguna dapat melakukan autentikasi berupa register dan login. Selain itu akan ada 3 role berupa basic-user sebagai user biasa, admin yang dapat mengedit, menambahkan, menghapus database dan analyst yang dapat menambahkan prediksi sebuah pertandingan


---

## 🧑‍💼 Role Pengguna
| Role                | Deskripsi        |
|------------------------------|-----------|
| Admin        | Pengguna dengan hak akses tertinggi yang mengelola seluruh data pemain dan memvalidasi konten pengguna. |
| Analyst                | Pengguna dengan sebagian akses CRUD terhadap pembaruan statistik pemain dan pembuatan berita. Role ini hanya dapat diberikan oleh Admin. |
| Basic User    | Pengguna terdaftar yang dapat menjelajahi data, melakukan follow, membandingkan statistik, membuat konten diskusi, serta edit/view profil. |

---
## 🔗 Integrasi Data Goalytics Mobile dengan PWS (Web Service)
![image](https://hackmd.io/_uploads/rk_I95Z-Zl.png)
Goalytics Mobile terintegrasi dengan aplikasi web (PWS) yang dikembangkan pada Proyek Tengah Semester. PWS berfungsi sebagai backend dan penyedia web service, sementara aplikasi mobile menjadi client yang mengakses dan mengelola data melalui endpoint berbasis JSON.

### 1. PWS sebagai Backend
PWS Django menyediakan endpoint yang:
- Mengirim data dalam format JSON (GET)
- Menerima data melalui POST
- Melakukan CRUD menggunakan model Django yang sama


### 2. Mobile Mengambil Data (GET)
- Flutter memanggil endpoint JSON menggunakan http.get atau CookieRequest.get
- JSON diparsing menjadi model Dart (fromJson)
- Data ditampilkan pada UI
- Data pada mobile selalu sinkron dengan database PWS

### 3. Mobile Mengirim Data (POST)
- Input user dikirim melalui http.post atau CookieRequest.post
- Django memvalidasi dan menyimpan perubahan ke database
- Respons JSON menentukan pembaruan tampilan di mobile

### 4. Integrasi Autentikasi (Session)

Jika menggunakan CookieRequest:
- Login mobile mengirim credential ke endpoint Django
- Django membuat session & cookie disimpan pada client
- Semua request selanjutnya otomatis terautentikasi

### 5. Single Source of Truth

Semua data hanya disimpan pada database Django PWS, sehingga:
- Tidak ada database terpisah di mobile
- Data lebih konsisten dan terpusat
- Logic dan validasi tetap di backend


---

## 🎨 Desain Figma
https://www.figma.com/design/X70RYm1pFUEeaesudaxkZY/Untitled?t=1ThCUwVMVF4BBgrC-1

