import 'dart:async';
import 'dart:collection';
import 'dart:io';

// ANSI escape codes
const String clearScreen = "\x1B[2J\x1B[H";
const String hideCursor = "\x1B[?25l";
const String showCursor = "\x1B[?25h";
const String resetCursor = "\x1B[H"; // Menaruh kursor di posisi (0,0)
const String resetColor = "\x1B[0m"; // Reset ke warna default

// ANSI escape codes untuk warna
const List<String> colors = [
  "\x1B[34m", // Biru
  "\x1B[35m", // Ungu
  "\x1B[38;5;172m", // orange
];

final class Huruf extends LinkedListEntry<Huruf> {
  String isi, color; // Menyimpan warna
  Huruf(this.isi, {this.color = resetColor});
}

void main() {
  stdout.write("Masukkan namamu: ");
  String? nama = stdin.readLineSync() ?? '';

  // Ambil ukuran terminal
  final width = stdout.terminalColumns;
  final height = stdout.terminalLines;
  final totalChars = width * height;
  final String chars = nama.isNotEmpty ? nama : "USER";

  // Membuat grid LinkedList dari Huruf
  final List<LinkedList<Huruf>> grid = List.generate(height, (_) {
    final row = LinkedList<Huruf>();
    for (int i = 0; i < width; i++) {
      row.add(Huruf(' ')); // Isi baris dengan spasi kosong
    }
    return row;
  });

  int index = 0; // Indeks untuk karakter yang akan dicetak
  bool namaSelesai = false; // Menandai apakah pencetakan nama selesai
  int colorIndex = 0; // Indeks warna untuk mengubah warna teks

  // Fungsi untuk mencetak grid
  void printGrid() {
    stdout.write(resetCursor); // Pindah kursor ke (0, 0)
    for (var row in grid) {
      for (var huruf in row) {
        stdout.write("${huruf.color}${huruf.isi}"); // Cetak isi huruf dengan warna
      }
    }
    stdout.write(resetColor); // Reset warna setelah mencetak grid
  }

  // Fungsi animasi
  Future<void> animate() async {
    // Fase 1: Mencetak nama
    while (index < totalChars && !namaSelesai) {
      // Hitung posisi baris dan kolom
      int row = (index ~/ width) % height; // Baris
      int col = (index % width); // Kolom

      // Dapatkan linked list baris saat ini
      var currentRow = grid[row];
      var currentNode = currentRow.first;

      // Akses node tertentu di linked list (berdasarkan kolom)
      for (int i = 0; i < col; i++) {
        currentNode = currentNode.next!;
      }

      // Tentukan arah pergerakan
      if ((row % 2) == 0) {
        // Baris genap: kiri ke kanan
        currentNode.isi = chars[index % chars.length];
      } else {
        // Baris ganjil: kanan ke kiri
        int reverseCol = width - 1 - col; // Hitung kolom terbalik
        currentNode = currentRow.first;
        for (int i = 0; i < reverseCol; i++) {
          currentNode = currentNode.next!;
        }
        currentNode.isi = chars[index % chars.length];
      }

      stdout.write("${hideCursor}"); // Sembunyikan kursor
      printGrid();
      index++;

      await Future.delayed(Duration(milliseconds: 50)); // Delay sebelum langkah berikutnya

      // Cek apakah nama sudah selesai dicetak
      if (index >= totalChars) {
        namaSelesai = true;
        index = 0; // Reset indeks untuk perubahan warna
      }
    }

    // Fase 2: Mengubah warna teks setelah pencetakan selesai
    while (namaSelesai && index < totalChars && colorIndex < colors.length) {
      // Hitung posisi baris dan kolom
      int row = (index ~/ width) % height; // Baris
      int col = (index % width); // Kolom

      // Dapatkan linked list baris saat ini
      var currentRow = grid[row];
      var currentNode = currentRow.first;

      // Akses node tertentu di linked list (berdasarkan kolom)
      for (int i = 0; i < col; i++) {
        currentNode = currentNode.next!;
      }

      // Tentukan arah pergerakan
      if ((row % 2) == 0) {
        // Baris genap: kiri ke kanan
        currentNode.color = colors[colorIndex % colors.length]; // Ubah warna huruf
      } else {
        // Baris ganjil: kanan ke kiri
        int reverseCol = width - 1 - col; // Hitung kolom terbalik
        currentNode = currentRow.first;
        for (int i = 0; i < reverseCol; i++) {
          currentNode = currentNode.next!;
        }
        currentNode.color = colors[colorIndex % colors.length]; // Ubah warna huruf
      }

      stdout.write("${hideCursor}"); // Sembunyikan kursor
      printGrid();
      index++;

      await Future.delayed(Duration(milliseconds: 50)); // Delay sebelum langkah berikutnya

      // Ubah warna secara berulang
      if (index >= totalChars) {
        colorIndex++; // Ubah ke warna berikutnya
        index = 0; // Reset indeks untuk siklus berikutnya
      }
    }

    stdout.write(showCursor); // Tampilkan kursor kembali setelah animasi selesai
  }

  // Jalankan animasi
  animate();
}
