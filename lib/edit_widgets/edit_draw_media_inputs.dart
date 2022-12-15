import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';

class DrawMediaInputs extends StatefulWidget {
  const DrawMediaInputs({
    Key? key,
    required this.imageURL,
    required this.updateImage,
    required this.deleteImage,
  }) : super(key: key);

  final String imageURL;

  final Function updateImage;
  final Function deleteImage;

  @override
  State<DrawMediaInputs> createState() => _DrawMediaInputsState();
}

class _DrawMediaInputsState extends State<DrawMediaInputs> {
  FirebaseStorage storage = FirebaseStorage.instance;
  final ImagePicker _imagePicker = ImagePicker();

  bool isUploadingImg = false;

  Future fromGallery(String path) async {
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

  Future deleteImage() async {
    print("Deleteing " + widget.imageURL);
    Reference _reference = storage.ref().child(widget.imageURL);
    setState(() {
      isUploadingImg = true;
    });
    await _reference.delete();
    setState(() {
      isUploadingImg = false;
      widget.deleteImage();
    });
  }

  Future<String> getLink() async {
    return await storage.ref().child(widget.imageURL).getDownloadURL();
  }

  @override
  void initState() {
    super.initState();
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
                    Text("Loading"),
                  ],
                ),
              )
            : widget.imageURL.isNotEmpty
                ? AspectRatio(
                    aspectRatio: 3 / 2,
                    child: Image.network(widget.imageURL),
                  )
                : Container(
                    width: double.infinity,
                    height: double.infinity,
                    color: Colors.grey.shade200,
                  ));
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Container(
        width: Get.height * 0.4,
        height: Get.height * 0.3,
        padding: const EdgeInsets.all(8.0),
        child: Stack(children: [
          imageInput(),
          if (widget.imageURL.isNotEmpty)
            Positioned(
                top: 5,
                right: 5,
                child: IconButton(
                    onPressed: () => deleteImage(),
                    icon: const Icon(
                      Icons.delete,
                      color: Colors.red,
                    ))),
          if (widget.imageURL.isEmpty)
            Align(
              alignment: Alignment.center,
              child: ElevatedButton.icon(
                onPressed: () => fromGallery("PromotionalDrawImages"),
                icon: const Icon(Icons.add_a_photo),
                label: const Text("Upload Image"),
              ),
            ),
        ]),
      ),
    );
  }
}
