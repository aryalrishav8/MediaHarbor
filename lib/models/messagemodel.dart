

class Message {
  final String sender;
  final String time;
  final String text;
  final String image;
  final String receiver;

  Message(
      {required this.sender,
      required this.time,
      required this.text,
      required this.image,
      required this.receiver
      });
}

/*List<Message> messages = [
  Message(
    sender: 'ram',
    time: '5:30 PM',
    text: 'Hey there! How are you?',
    image: 'assets/images/ram.png',
  ),
  Message(
    sender: 'shyam',
    time: '4:30 PM',
    text: 'We could surely handle this much easily if you were here.',
    image: 'assets/images/shyam.jpeg',
  ),
];*/