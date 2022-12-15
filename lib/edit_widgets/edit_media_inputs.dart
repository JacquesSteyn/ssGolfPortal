import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';
import 'package:video_player/video_player.dart';

class MediaInputs extends StatefulWidget {
  const MediaInputs(
      {Key? key,
      required this.imageURL,
      required this.videoURL,
      required this.updateImage,
      required this.updateVideo})
      : super(key: key);

  final String imageURL;
  final String videoURL;

  final Function updateImage;
  final Function updateVideo;

  @override
  State<MediaInputs> createState() => _MediaInputsState();
}

class _MediaInputsState extends State<MediaInputs> {
  FirebaseStorage storage = FirebaseStorage.instance;
  final ImagePicker _imagePicker = ImagePicker();
  late VideoPlayerController _vidController;
  bool isUploadingVid = false;
  bool isUploadingImg = false;

  Future fromGallery(String path) async {
    if (path == "Videos") {
      final pickedFile =
          await _imagePicker.pickVideo(source: ImageSource.gallery);
      Reference _reference =
          storage.ref().child('$path/${basename(pickedFile!.path)}');
      setState(() {
        isUploadingVid = true;
      });
      await _reference
          .putData(
        await pickedFile.readAsBytes(),
        SettableMetadata(contentType: pickedFile.mimeType),
      )
          .whenComplete(() async {
        await _reference.getDownloadURL().then((value) {
          setState(() {
            isUploadingVid = false;
            _vidController = VideoPlayerController.network(value)..initialize();
            widget.updateVideo(value);
          });
        });
      });
    } else {
      final pickedFile =
          await _imagePicker.pickImage(source: ImageSource.gallery);
      Reference _reference =
          storage.ref().child('$path/${basename(pickedFile!.path)}');
      setState(() {
        isUploadingImg = true;
      });
      await _reference
          .putData(
        await pickedFile.readAsBytes(),
        SettableMetadata(contentType: pickedFile.mimeType),
      )
          .whenComplete(() async {
        await _reference.getDownloadURL().then((value) {
          setState(() {
            isUploadingImg = false;
            widget.updateImage(value);
          });
        });
      });
    }
  }

  Future<String> getLink() async {
    return await storage.ref().child(widget.imageURL).getDownloadURL();
  }

  @override
  void initState() {
    super.initState();
    if (widget.videoURL.isNotEmpty) {
      _vidController = VideoPlayerController.network(widget.videoURL)
        ..initialize().then((_) {
          // Ensure the first frame is shown after the video is initialized, even before the play button has been pressed.
          setState(() {});
        });
    }
  }

  Widget imageInput() {
    return SizedBox(
        height: Get.height * 0.3,
        child: isUploadingImg
            ? Center(
                child: Column(
                  children: const [
                    SizedBox(
                      height: 10,
                      child: CircularProgressIndicator(),
                    ),
                    Text("Uploading"),
                  ],
                ),
              )
            : widget.imageURL.isNotEmpty
                ? AspectRatio(
                    aspectRatio: 3 / 2,
                    child: Image.network(widget.imageURL),
                  )
                : const AspectRatio(
                    aspectRatio: 3 / 2,
                    child: Placeholder(),
                  ));
  }

  Widget videoInput() {
    return SizedBox(
      height: Get.height * 0.3,
      child: isUploadingVid
          ? Center(
              child: Column(
                children: const [
                  SizedBox(
                    height: 10,
                    child: CircularProgressIndicator(),
                  ),
                  Text("Uploading"),
                ],
              ),
            )
          : AspectRatio(
              aspectRatio: 3 / 2,
              child: widget.videoURL.isNotEmpty
                  ? Stack(
                      children: [
                        VideoPlayer(_vidController),
                        Align(
                          alignment: Alignment.bottomCenter,
                          child: FloatingActionButton(
                            onPressed: () {
                              setState(() {
                                _vidController.value.isPlaying
                                    ? _vidController.pause()
                                    : _vidController.play();
                              });
                            },
                            child: Icon(
                              _vidController.value.isPlaying
                                  ? Icons.pause
                                  : Icons.play_arrow,
                            ),
                          ),
                        )
                      ],
                    )
                  : const Placeholder(),
            ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 20,
      runSpacing: 20,
      alignment: WrapAlignment.center,
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Challenge Thumbnail"),
                  const SizedBox(
                    width: 10,
                  ),
                  ElevatedButton.icon(
                    onPressed: () => fromGallery("Thumbnails"),
                    icon: const Icon(Icons.add_a_photo),
                    label: const Text("Upload Thumbnail"),
                  ),
                ],
              ),
              const SizedBox(
                height: 10,
              ),
              imageInput(),
            ]),
          ),
        ),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Challenge Video"),
                  const SizedBox(
                    width: 10,
                  ),
                  ElevatedButton.icon(
                    onPressed: () => fromGallery("Videos"),
                    icon: const Icon(Icons.add_a_photo),
                    label: const Text("Upload Video"),
                  ),
                ],
              ),
              const SizedBox(
                height: 10,
              ),
              videoInput()
            ]),
          ),
        )
      ],
    );
  }
}
