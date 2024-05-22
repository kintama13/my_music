import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_music/controllers/player_controller.dart';
import 'package:my_music/conts/colors.dart';
import 'package:my_music/conts/text_style.dart';
import 'package:on_audio_query/on_audio_query.dart';

class Player extends StatelessWidget {
  final List<SongModel> data;
  const Player({Key? key, required this.data}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var controller = Get.find<PlayerController>();

    return Scaffold(
      backgroundColor: bgColor,
      body: Padding(
        padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
        child: Column(
          children: [
            Obx(
              () => Expanded(
                child: Container(
                  clipBehavior: Clip.antiAliasWithSaveLayer,
                  height: 300,
                  width: 300,
                  decoration: BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: QueryArtworkWidget(
                    id: data[controller.playIndex.value].id,
                    type: ArtworkType.AUDIO,
                    artworkHeight: double.infinity,
                    artworkWidth: double.infinity,
                    nullArtworkWidget: Icon(
                      Icons.music_note,
                      size: 48,
                      color: whiteColor,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 12),
            Expanded(
              child: Container(
                padding: EdgeInsets.all(8),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: whiteColor,
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                ),
                child: Obx(
                  () => Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        data[controller.playIndex.value].displayNameWOExt,
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                        style: ourStyle(
                            color: bgDarkColor, family: bold, size: 24),
                      ),
                      SizedBox(height: 12),
                      Text(
                        data[controller.playIndex.value].artist ??
                            'Unknown Artist',
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                        style: ourStyle(
                            color: bgDarkColor, family: regular, size: 20),
                      ),
                      SizedBox(height: 12),
                      Obx(
                        () => Row(
                          children: [
                            Text(
                              controller.position.value,
                              style: ourStyle(color: bgDarkColor),
                            ),
                            Expanded(
                              child: Slider(
                                thumbColor: slideColor,
                                inactiveColor: bgColor,
                                activeColor: slideColor,
                                min: 0,
                                max: controller.max.value,
                                value: controller.value.value,
                                onChanged: (newValue) {
                                  controller.changeDurationToSeconds(
                                      newValue.toInt());
                                },
                              ),
                            ),
                            Text(
                              controller.duration.value,
                              style: ourStyle(color: bgDarkColor),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          IconButton(
                            onPressed: () {
                              controller.playPrevious();
                            },
                            icon: Icon(
                              Icons.skip_previous_rounded,
                              size: 40,
                              color: bgDarkColor,
                            ),
                          ),
                          Obx(
                            () => CircleAvatar(
                              radius: 35,
                              backgroundColor: bgDarkColor,
                              child: IconButton(
                                onPressed: () {
                                  if (controller.isPlaying.value) {
                                    controller.pause();
                                  } else {
                                    controller.play();
                                  }
                                },
                                icon: Icon(
                                  controller.isPlaying.value
                                      ? Icons.pause
                                      : Icons.play_arrow,
                                  size: 40,
                                  color: whiteColor,
                                ),
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              controller.playNext();
                            },
                            icon: Icon(
                              Icons.skip_next_rounded,
                              size: 40,
                              color: bgDarkColor,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 12),
                      Expanded(
                        child: SingleChildScrollView(
                          child: Obx(
                            () => Text(
                              controller.lyrics.value,
                              style: ourStyle(
                                  color: bgDarkColor,
                                  size: 16,
                                  family: regular),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
