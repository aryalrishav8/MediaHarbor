import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mediaharbor/helper/audio_play.dart';


class EditPostScreen extends StatefulWidget {
  final String postId;
  final String imageUrl; // Replace with actual image/audio URL
  final String caption;
  final String postType;

  const EditPostScreen({
    Key? key,
    required this.postId,
    required this.imageUrl,
    required this.caption,
    required this.postType,
  }) : super(key: key);

  @override
  _EditPostScreenState createState() => _EditPostScreenState();
}

class _EditPostScreenState extends State<EditPostScreen> {
  late TextEditingController _captionController;

  @override
  void initState() {
    super.initState();
    _captionController = TextEditingController(text: widget.caption);
  }

  @override
  void dispose() {
    _captionController.dispose();
    super.dispose();
  }

  Future<void> _updateCaption(String newCaption) async {
    try {
      await FirebaseFirestore.instance
          .collection('posts')
          .doc(widget.postId)
          .update({'caption': newCaption});
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Caption Updated Successfully'),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating caption: $e'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Post'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.postType == 'Audio')
              AudioPlayerWidget(audioUrl: widget.imageUrl),
            if (widget.postType != 'Audio')
              Image.network(
                widget.imageUrl,
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            const SizedBox(height: 16),
            TextField(
              controller: _captionController,
              decoration: InputDecoration(
                labelText: 'Caption',
                border: OutlineInputBorder(),
              ),
              maxLines: null, // Allow multiple lines for longer captions
              keyboardType: TextInputType.multiline,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // Save the updated caption
                String updatedCaption = _captionController.text;
                _updateCaption(updatedCaption);
              },
              child: Text('Save Caption'),
            ),
          ],
        ),
      ),
    );
  }
}
