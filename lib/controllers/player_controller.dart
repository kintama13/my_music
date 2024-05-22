import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' show parse;
import 'dart:convert';

class PlayerController extends GetxController {
  final audioQuery = OnAudioQuery();
  final audioPlayer = AudioPlayer();

  var playIndex = 0.obs;
  var isPlaying = false.obs;

  var duration = ''.obs;
  var position = ''.obs;

  var max = 0.0.obs;
  var value = 0.0.obs;

  var songs = <SongModel>[].obs;
  var filteredSongs = <SongModel>[].obs;
  var lyrics = ''.obs;

  final String geniusAccessToken =
      'YOUR_GENIUS_ACCESS_TOKEN'; // Ganti dengan akses token Genius Anda

  @override
  void onInit() {
    super.onInit();
    checkPermission();
  }

  @override
  void onClose() {
    audioPlayer.dispose();
    super.onClose();
  }

  void updatePosition() {
    audioPlayer.durationStream.listen((d) {
      if (d != null) {
        duration.value = d.toString().split(".")[0];
        max.value = d.inSeconds.toDouble();
      }
    });
    audioPlayer.positionStream.listen((p) {
      position.value = p.toString().split(".")[0];
      value.value = p.inSeconds.toDouble();
    });
  }

  void changeDurationToSeconds(int seconds) {
    audioPlayer.seek(Duration(seconds: seconds));
  }

  Future<void> playSong(String? uri, int index) async {
    if (uri == null) return;
    playIndex.value = index;
    try {
      await audioPlayer.setAudioSource(AudioSource.uri(Uri.parse(uri)));
      await audioPlayer.play();
      isPlaying(true);
      updatePosition();
      fetchLyrics(index);
    } on Exception catch (e) {
      print(e.toString());
    }
  }

  Future<void> checkPermission() async {
    var permission = await Permission.storage.request();
    if (permission.isGranted) {
      loadSongs();
    } else {
      // Show an alert or handle the permission not granted case
    }
  }

  Future<void> loadSongs() async {
    var songList = await audioQuery.querySongs(
      ignoreCase: true,
      orderType: OrderType.ASC_OR_SMALLER,
      sortType: null,
      uriType: UriType.EXTERNAL,
    );
    songs.value = songList;
    filteredSongs.value = List.from(songList);
  }

  void filterSongsByTitle(String query) {
    if (query.isEmpty) {
      filteredSongs.value = List.from(songs);
    } else {
      filteredSongs.value = songs
          .where((song) =>
              song.displayName.toLowerCase().contains(query.toLowerCase()))
          .toList();
    }
  }

  void playFilteredSong(int index) {
    if (index >= 0 && index < filteredSongs.length) {
      var song = filteredSongs[index];
      playSong(song.uri, index);
    }
  }

  int getFilteredSongsCount() {
    return filteredSongs.length;
  }

  bool get isSongPlaying => isPlaying.value;

  Future<void> stopSong() async {
    await audioPlayer.stop();
    isPlaying(false);
  }

  Future<void> pause() async {
    await audioPlayer.pause();
    isPlaying(false);
  }

  Future<void> play() async {
    await audioPlayer.play();
    isPlaying(true);
  }

  void playPrevious() {
    if (playIndex.value > 0) {
      playSong(songs[playIndex.value - 1].uri, playIndex.value - 1);
    }
  }

  void playNext() {
    if (playIndex.value < songs.length - 1) {
      playSong(songs[playIndex.value + 1].uri, playIndex.value + 1);
    }
  }

  Future<void> fetchLyrics(int index) async {
    try {
      var song = songs[index];
      var artist = song.artist ?? 'Unknown Artist';
      var title = song.displayNameWOExt;

      var searchUrl = Uri.parse(
          'https://api.genius.com/search?q=${Uri.encodeComponent(title)} ${Uri.encodeComponent(artist)}&access_token=$geniusAccessToken');
      var searchResponse = await http.get(searchUrl);

      if (searchResponse.statusCode == 200) {
        var searchResult = json.decode(searchResponse.body);
        if (searchResult['response']['hits'].isNotEmpty) {
          var songId = searchResult['response']['hits'][0]['result']['id'];
          var songUrl = Uri.parse(
              'https://api.genius.com/songs/$songId?access_token=$geniusAccessToken');
          var songResponse = await http.get(songUrl);

          if (songResponse.statusCode == 200) {
            var songResult = json.decode(songResponse.body);
            var path = songResult['response']['song']['path'];

            var geniusUrl = 'https://genius.com$path';
            var lyricsResponse = await http.get(Uri.parse(geniusUrl));

            if (lyricsResponse.statusCode == 200) {
              var document =
                  parse(lyricsResponse.body); // Parse HTML dari Genius
              var lyricsDiv = document.querySelector('.lyrics') ??
                  document.querySelector('.Lyrics__Container-sc-1ynbvzw-6');
              if (lyricsDiv != null) {
                lyrics.value = lyricsDiv.text; // Mengambil teks lirik
              } else {
                lyrics.value = 'No lyrics found';
              }
            } else {
              lyrics.value = 'No lyrics found';
            }
          } else {
            lyrics.value = 'No lyrics found';
          }
        } else {
          lyrics.value = 'No lyrics found';
        }
      } else {
        lyrics.value = 'No lyrics found';
      }
    } catch (e) {
      lyrics.value = 'Failed to load lyrics';
      print(e.toString());
    }
  }
}
