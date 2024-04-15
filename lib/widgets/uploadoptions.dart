import 'package:flutter/material.dart';
import 'package:mediaharbor/ui/audio_record.dart';
import 'package:mediaharbor/ui/post_upload.dart';

Future<void> showUploadOptions(BuildContext context) async {
  return showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Upload Options'),
        content: SingleChildScrollView(
          child: ListBody(
            children: <Widget>[
              GestureDetector(
                child: const Text('Record Audio'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => RecordScreen()),
                  );
                  // Navigate to audio recording page here(later)
                },
              ),
              const SizedBox(height: 20),
              GestureDetector(
                child: const Text('Upload Image'),
                onTap: () {
                  Navigator.pop(context);
                  // Navigate to image upload page or handle image upload logic
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => PostUploadPage()),
                  );
                },
              ),
            ],
          ),
        ),
      );
    },
  );
}
