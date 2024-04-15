import "package:flutter/material.dart";
import "package:record/record.dart";
import 'package:audioplayers/audioplayers.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:cloud_firestore/cloud_firestore.dart' hide Source;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:path_provider/path_provider.dart';

class RecordScreen extends StatefulWidget {
  const RecordScreen({super.key});

  @override
  State<RecordScreen> createState() => _RecordScreenState();
}

class _RecordScreenState extends State<RecordScreen> {
  late AudioRecorder audioRecord;
  late AudioPlayer audioPlayer;
  bool isRecording = false;
  String audioPath = "";
  late String postAudioUrl;
  bool recording_now = true;
  bool uploaded = false;
  TextEditingController captionController = TextEditingController();
  late String caption;

  @override
  void initState() {
    super.initState();
    audioPlayer = AudioPlayer();
    audioRecord = AudioRecorder();
  }

  bool playing = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Voice Recorder'),
        ),
        body: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            recording_now
                ? IconButton(
                    icon: !isRecording
                        ? const Icon(
                            Icons.mic_none,
                            color: Colors.red,
                            size: 50,
                          )
                        : const Icon(Icons.fiber_manual_record,
                            color: Colors.red, size: 50),
                    onPressed: isRecording ? stopRecording : startRecording,
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: !playing
                            ? const Icon(Icons.play_circle,
                                color: Colors.green, size: 50)
                            : const Icon(Icons.pause_circle,
                                color: Colors.green, size: 50),
                        onPressed: !playing ? playRecording : pauseRecording,
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete,
                            color: Colors.red, size: 50),
                        onPressed: deleteRecording,
                      ),
                      IconButton(
                        icon: const Icon(Icons.trending_up,
                            color: Colors.green, size: 50),
                        onPressed: uploadAndDeleteRecording,
                      ),
                    ],
                  ),
          ],
        ));
  }

  // Future<void> recordAudio() async {
  //   try {
  //     if (await audioRecord.hasPermission()) {
  //       await audioRecord.start(RecordConfig(), path: "try.m4a");
  //       setState(() {
  //         isRecording = true;
  //       });
  //     }
  //   } catch (e) {
  //     print("Recording error==========================${e}");
  //   }
  // }

  Future<void> stopRecording() async {
    try {
      String? path = await audioRecord.stop();
      setState(() {
        isRecording = false;
        audioPath = path!;
        recording_now = false;
      });
      setState(() {});
      print("Stop Recording=============================");
    } catch (e) {
      print("Stop Recording=============================${e}");
    }
  }

  Future<void> playRecording() async {
    try {
      playing = true;
      setState(() {});
      Source urlSource = UrlSource(audioPath);
      await audioPlayer.play(urlSource);
      audioPlayer.onPlayerStateChanged.listen((PlayerState state) {
        if (state == PlayerState.completed) {
          playing = false;
          setState(() {});
        }
      });
    } catch (e) {
      print("Audio playing error+++++++++++++++++${e}");
    }
  }

  Future<void> pauseRecording() async {
    try {
      playing = false;
      await audioPlayer.pause();
      setState(() {});
    } catch (e) {
      print("Audio pause+++++++++++++++++++${e}");
    }
  }

  Future<void> uploadAndDeleteRecording() async {
    try {
      final audioFile = File(audioPath);
      firebase_storage.FirebaseStorage storage =
          firebase_storage.FirebaseStorage.instance;
      firebase_storage.Reference ref =
          storage.ref().child("audios/${DateTime.now()}.mp3");
      firebase_storage.UploadTask uploadTask = ref.putFile(audioFile);
      firebase_storage.TaskSnapshot taskSnapshot = await uploadTask;
      String audioUrl = await taskSnapshot.ref.getDownloadURL();
      setState(() {
        postAudioUrl = audioUrl.toString();
      });
      await uploadPostToFirestore(postAudioUrl);
      final snackBar = SnackBar(content: Text('Audio uploaded successfully'));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    } catch (e) {
      final snackBar = SnackBar(content: Text('Error uploading audio: $e'));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  Future<void> deleteRecording() async {
    if (audioPath.isNotEmpty) {
      try {
        recording_now = true;
        File file = File(audioPath);
        if (file.existsSync()) {
          file.deleteSync();
          final snackBar = SnackBar(content: Text('Recording deleted'));
          ScaffoldMessenger.of(context).showSnackBar(snackBar);
          print(
              "FILE DELETED+++++++++++++++++++++++++++++++++++++++++++++++++");
        }
      } catch (e) {
        print(
            "FILE NOT DELETED++++++++++++++++${e}+++++++++++++++++++++++++++++++++");
      }

      setState(() {
        audioPath = "";
      });
    }
  }

  Future<void> startRecording() async {
    try {
      print("START RECODING+++++++++++++++++++++++++++++++++++++++++++++++++");
      if (await audioRecord.hasPermission()) {
        Directory appDocumentsDirectory =
            await getApplicationDocumentsDirectory();
        String filePath = '${appDocumentsDirectory.path}/recording.m4a';
        await audioRecord.start(RecordConfig(), path: filePath);
        setState(() {
          isRecording = true;
        });
        print(
            "Start recording=+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++");
      }
    } catch (e, stackTrace) {
      print(
          "START RECODING+++++++++++++++++++++$e++++++++++$stackTrace+++++++++++++++++");
    }
  }

  Future<void> uploadPostToFirestore(String audioDownloadUrl) async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        // Retrieve user data from Firestore to get profile picture URL
        DocumentSnapshot userDataSnapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (userDataSnapshot.exists) {
          String profilePicUrl = userDataSnapshot['profilePictureUrl'] ?? '';

          // Create a reference to the Firestore collection "posts"
          CollectionReference posts =
              FirebaseFirestore.instance.collection('posts');

          await showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text("Upload caption"),
              content: TextField(
                controller: captionController,
                decoration: InputDecoration(hintText: "Enter Caption..."),
              ),
              actions: [
                ElevatedButton(
                    onPressed: () {
                      setState(() {
                        caption = captionController.text;
                      });
                      Navigator.pop(context);
                    },
                    child: Text("Save"))
              ],
            ),
          );

          // Add a new document with auto-generated ID
          await posts.add({
            'senderId': user.uid,
            'path': audioDownloadUrl,
            'likes': [],
            'comments': [],
            'profilePic':
                profilePicUrl, // Use profile picture URL from user data
            'date': DateTime.now(),
            'type': 'Audio',
            'caption': caption
          });

          print('Post added to Firestore successfully!');
        } else {
          print('User data not found.');
        }
      } else {
        print('User not authenticated.');
      }
    } catch (e) {
      print('Error uploading post to Firestore: $e');
    }
  }
}
