import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_music/controllers/player_controller.dart';
import 'package:my_music/conts/colors.dart';
import 'package:my_music/conts/text_style.dart';
import 'package:my_music/views/SearchScreen.dart';
import 'package:my_music/views/player.dart';
import 'package:on_audio_query/on_audio_query.dart';

class Home extends StatelessWidget {
  const Home({Key? key});

  @override
  Widget build(BuildContext context) {
    var controller = Get.put(PlayerController());

    return Scaffold(
      backgroundColor: bgDarkColor,
      appBar: AppBar(
        backgroundColor: bgDarkColor,
        actions: [
          IconButton(
            onPressed: () {
              Get.to(() => SearchScreen());
            },
            icon: const Icon(
              Icons.search,
              color: whiteColor,
            ),
          )
        ],
        title: Text(
          "My Music",
          style: ourStyle(
            family: bold,
            size: 18,
          ),
        ),
      ),
      body: FutureBuilder<List<SongModel>>(
        future: controller.audioQuery.querySongs(
          ignoreCase: true,
          orderType: OrderType.ASC_OR_SMALLER,
          sortType: null,
          uriType: UriType.EXTERNAL,
        ),
        builder: (BuildContext context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasData) {
            final List<SongModel>? songs = snapshot.data;
            final List<SongModel> filteredSongs =
                songs!.where((song) => song.duration! > 105000).toList();

            if (filteredSongs.isEmpty) {
              return Center(
                child: Text(
                  "No Song Found",
                  style: ourStyle(),
                ),
              );
            } else {
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  itemCount: filteredSongs.length,
                  itemBuilder: (BuildContext context, int index) {
                    final SongModel song = filteredSongs[index];

                    return Container(
                      margin: const EdgeInsets.only(bottom: 5),
                      child: Obx(
                        () => ListTile(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          tileColor: bgColor,
                          title: Expanded(
                            child: Text(
                              song.displayNameWOExt.length > 20
                                  ? '${song.displayNameWOExt.substring(0, 20)}...'
                                  : song.displayNameWOExt,
                              style: ourStyle(family: bold, size: 15),
                            ),
                          ),
                          subtitle: Text(
                            "${song.artist}",
                            style: ourStyle(family: regular, size: 15),
                          ),
                          leading: QueryArtworkWidget(
                            id: song.id,
                            artworkBorder:
                                BorderRadius.all(Radius.circular(12)),
                            // artworkWidth: 96,
                            // artworkHeight: 32,
                            type: ArtworkType.AUDIO,
                            nullArtworkWidget: const Icon(
                              Icons.music_note,
                              color: whiteColor,
                              size: 50,
                            ),
                          ),
                          trailing: controller.playIndex.value == index &&
                                  controller.isPlaying.value
                              ? const Icon(Icons.play_arrow,
                                  color: whiteColor, size: 26)
                              : null,
                          onTap: () {
                            Get.to(() => Player(data: filteredSongs),
                                transition: Transition.downToUp);
                            controller.playSong(song.uri, index);
                          },
                        ),
                      ),
                    );
                  },
                ),
              );
            }
          }
          return Center(
            child: Text(
              "No Songs Found",
              style: ourStyle(),
            ),
          );
        },
      ),
    );
  }
}

void main() {
  runApp(GetMaterialApp(
    home: Home(),
  ));
}
