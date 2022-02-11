import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_downloader/image_downloader.dart';
import 'package:image_editor_dove/image_editor.dart';
import 'package:image_picker/image_picker.dart';

class UserChat extends StatefulWidget {
  final String chatId;
  const UserChat({Key? key, required this.chatId}) : super(key: key);

  @override
  _UserChatState createState() => _UserChatState();
}

class _UserChatState extends State<UserChat> {
  final databaseReference = FirebaseDatabase.instance.ref().child("user_chat");

  bool isProcessing = false;
  String user = "";
  String loggedInUser = "";

  String chatRef = "";
  final picker = ImagePicker();

  final TextEditingController _messageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    isProcessing = true;
    if (mounted) {
      setState(() {});
    }

    chatRef = widget.chatId;
    var users = chatRef.split("_");
    user = users[1];
    loggedInUser = users[0];

    databaseReference.child(widget.chatId).once().then((DatabaseEvent event) {
      if (!event.snapshot.exists) {
        print("does not exits");
        chatRef = user + "_" + loggedInUser;
      } else {
        print("exits");
      }
      isProcessing = false;
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    print(chatRef);
    return Scaffold(
      backgroundColor: Colors.blue.shade50,
      appBar: AppBar(
        title: const Text("I-Spy"),
      ),
      body: Container(
        // padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        child: isProcessing
            ? const Center(
                child: Text("Please Wait..."),
              )
            : Column(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Column(
                        children: [
                          const SizedBox(
                            height: 10,
                          ),
                          Text(user,
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w600,
                              )),
                          Flexible(
                            flex: 1,
                            child: FirebaseAnimatedList(
                              // key: ValueKey<bool>(_anchorToBottom),
                              query: databaseReference.child(chatRef),
                              // reverse: _anchorToBottom,
                              itemBuilder:
                                  (context2, snapshot, animation, index) {
                                var message = snapshot.child("msg").value;
                                var image = snapshot.child("image").value;
                                var from = snapshot.child("from").value;
                                return SizeTransition(
                                  sizeFactor: animation,
                                  child: image != null
                                      ? Container(
                                          alignment: user == from.toString()
                                              ? Alignment.centerRight
                                              : Alignment.centerLeft,
                                          padding: const EdgeInsets.all(8.0),
                                          child: Card(
                                            clipBehavior: Clip.antiAlias,
                                            child: Stack(children: [
                                              CachedNetworkImage(
                                                height: 250,
                                                fit: BoxFit.cover,
                                                imageUrl: image.toString(),
                                                placeholder: (context, url) =>
                                                    Container(
                                                  height: 80,
                                                  width: 80,
                                                  child: const Center(
                                                      child:
                                                          CircularProgressIndicator()),
                                                ),
                                                errorWidget:
                                                    (context, url, error) =>
                                                        const Icon(Icons.error),
                                              ),
                                              Positioned(
                                                  right: 0,
                                                  top: 0,
                                                  child: PopupMenuButton(
                                                      icon: const Icon(
                                                          Icons.more_vert),
                                                      itemBuilder: (context1) =>
                                                          [
                                                            PopupMenuItem(
                                                              child: const Text(
                                                                  "Replay"),
                                                              value: 1,
                                                              onTap: () {
                                                                toImageEditor(
                                                                    context,
                                                                    image
                                                                        .toString());
                                                              },
                                                            ),
                                                            // PopupMenuItem(
                                                            //   child:
                                                            //       const Text("Delete"),
                                                            //   value: 2,
                                                            //   onTap: () {
                                                            //     // snapshot.ref.remove();
                                                            //   },
                                                            // )
                                                          ]))
                                            ]),
                                          ),
                                        )
                                      : Container(
                                          alignment: user == from.toString()
                                              ? Alignment.centerRight
                                              : Alignment.centerLeft,
                                          child: Card(
                                            clipBehavior: Clip.antiAlias,
                                            child: Container(
                                                color: Colors.green.shade50,
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: Text("$message")),
                                          ),
                                        ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    color: Colors.white,
                    padding: const EdgeInsets.all(8),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _messageController,
                            decoration: InputDecoration(
                              hintText: "Enter message",
                              isDense: true,
                              border: const OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Colors.grey,
                                  width: 0.1,
                                ),
                              ),
                              suffixIcon: IconButton(
                                onPressed: () async {
                                  final pickedFile = await picker.pickImage(
                                      source: ImageSource.camera,
                                      imageQuality: 70,
                                      maxHeight: 1500,
                                      maxWidth: 1000);
                                  isProcessing = true;
                                  if (mounted) {
                                    setState(() {});
                                  }
                                  uploadImageToFirebase(
                                          context, File(pickedFile!.path))
                                      .whenComplete(() {
                                    isProcessing = false;
                                    if (mounted) {
                                      setState(() {});
                                    }
                                  });
                                },
                                icon: const Icon(Icons.camera),
                              ),
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            if (_messageController.text.isNotEmpty) {
                              databaseReference
                                  .child(chatRef)
                                  .child(
                                      "${DateTime.now().microsecondsSinceEpoch}")
                                  .set({
                                'msg': _messageController.text,
                                'from': user
                              });
                              _messageController.clear();
                            }
                          },
                          icon: const Icon(Icons.send),
                        ),
                      ],
                    ),
                  )
                ],
              ),
      ),
    );
  }

  Future<void> toImageEditor(BuildContext context, String origin) async {
    isProcessing = true;
    if (mounted) {
      setState(() {});
    }
    print("toImageEditor : $origin");
    var imageId = await ImageDownloader.downloadImage(origin);
    if (imageId == null) {
      print("imageId : null");
      return;
    }

    print("imageId : $imageId");
    // Below is a method of obtaining saved image information.
    var fileName = await ImageDownloader.findName(imageId);
    var path = await ImageDownloader.findPath(imageId);
    return Navigator.push(context, MaterialPageRoute(builder: (context) {
      return ImageEditor(
        originImage: File(path!),
      );
    })).then((result) {
      if (result is EditorImageResult) {
        // setState(() {
        uploadImageToFirebase(context, result.newFile);
        // });
      }
    }).catchError((er) {
      debugPrint(er);
    }).whenComplete(() {
      isProcessing = false;
      if (mounted) {
        setState(() {});
      }
    });
  }

  Future uploadImageToFirebase(BuildContext context, File file) async {
    String fileName = file.path;
    Reference firebaseStorageRef =
        FirebaseStorage.instance.ref().child('uploads/$fileName');
    UploadTask uploadTask =
        firebaseStorageRef.putData(await file.readAsBytes());
    TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() {});
    taskSnapshot.ref.getDownloadURL().then((value) {
      if (kDebugMode) {
        print("Done: $value");
      }
      databaseReference
          .child(chatRef)
          .child("${DateTime.now().microsecondsSinceEpoch}")
          .set({"image": value, 'from': loggedInUser});
    });
  }
}
