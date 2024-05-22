// ignore_for_file: unused_import

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_music/controllers/player_controller.dart';
import 'package:my_music/views/player.dart'; // Import layar Player
import 'package:on_audio_query/on_audio_query.dart';

class SearchScreen extends StatelessWidget {
  final TextEditingController _searchController = TextEditingController();
  final PlayerController controller = Get.find<PlayerController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey,
        iconTheme: IconThemeData(color: Colors.white),
        title: TextField(
          controller: _searchController,
          cursorColor: Colors.white,
          style: TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'Search for songs...',
            hintStyle: TextStyle(color: Colors.white),
            border: InputBorder.none,
            suffixIcon: IconButton(
              icon: Icon(
                Icons.delete,
                color: Colors.white,
              ),
              onPressed: () {
                _searchController.clear();
                controller.filterSongsByTitle('');
              },
            ),
          ),
          onChanged: (query) {
            controller.filterSongsByTitle(query);
          },
        ),
      ),
      body: Container(
        color: Colors.black,
        child: Obx(
          () {
            // Ambil daftar judul lagu yang sesuai dengan hasil pencarian
            List<String> songTitles = controller.filteredSongs
                .where((song) =>
                    song.duration! >
                        105000 && // Filter berdasarkan durasi > 1 menit 45 detik
                    song.displayName.toLowerCase().contains(_searchController
                        .text
                        .toLowerCase())) // Filter berdasarkan judul lagu
                .map((song) => song.displayName)
                .toList();

            // Tampilkan pesan "Song not found" jika tidak ada hasil pencarian
            if (_searchController.text.isNotEmpty && songTitles.isEmpty) {
              return Center(
                child: Text(
                  'Song not found',
                  style: TextStyle(color: Colors.white),
                ),
              );
            }

            // Tampilkan pesan "Type to search" jika search bar kosong
            if (_searchController.text.isEmpty) {
              return Center(
                child: Text(
                  'Type to search',
                  style: TextStyle(color: Colors.white),
                ),
              );
            }

            // Tampilkan daftar judul lagu dalam ListView
            return ListView.builder(
              itemCount: songTitles.length,
              itemBuilder: (context, index) {
                return InkWell(
                  onTap: () {
                    // Saat lagu diklik, navigasikan ke layar Player dan putar lagu yang diklik
                    Get.to(Player(data: controller.filteredSongs));
                    controller.playFilteredSong(index);
                  },
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 3.0),
                    child: Container(
                      height: 50, // Tetapkan tinggi kotak
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(10.0),
                        border: Border.all(color: Colors.grey),
                      ),
                      child: Padding(
                        padding:
                            EdgeInsets.only(left: 16.0), // Atur jarak kiri teks
                        child: Align(
                          alignment:
                              Alignment.centerLeft, // Posisikan teks ke kiri
                          child: Text(
                            songTitles[index],
                            style: TextStyle(color: Colors.black),
                            overflow: TextOverflow
                                .ellipsis, // Gunakan ellipsis untuk teks yang terlalu panjang
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
