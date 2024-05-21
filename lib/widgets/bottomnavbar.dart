// import 'package:flutter/material.dart';

// class BottomNavBar extends StatelessWidget {
//   final Function(int) onTabSelected;
//   final int currentIndex;

//   const BottomNavBar({
//     Key? key,
//     required this.onTabSelected,
//     required this.currentIndex,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return BottomNavigationBar(
//       selectedItemColor: Colors.black, // Set selected item color to black
//       unselectedItemColor: Colors.black, // Set unselected item color to black
//       // currentIndex: currentIndex,
//       onTap: onTabSelected,
//       selectedFontSize: 10,
//       items: const <BottomNavigationBarItem>[
//         BottomNavigationBarItem(
//           icon: Icon(Icons.home),
//           label: '',
//         ),
//         BottomNavigationBarItem(
//           icon: Icon(Icons.search),
//           label: '',
//         ),
//         BottomNavigationBarItem(
//           icon: Icon(Icons.add_box),
//           label: '',
//         ),
//         BottomNavigationBarItem(
//           icon: Icon(Icons.favorite_border),
//           label: '',
//         ),
//         BottomNavigationBarItem(
//           icon: Icon(Icons.account_circle),
//           label: '',
//         ),
//       ],
//     );
//   }
// }

import 'package:flutter/material.dart';

class BottomNavBar extends StatelessWidget {
  final Function(int) onTabSelected;
  final int currentIndex;

  const BottomNavBar({
    Key? key,
    required this.onTabSelected,
    required this.currentIndex,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey.shade800,
      height: 60,
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            IconButton(
              icon: const Icon(Icons.home),
              color: currentIndex == 0 ? Colors.black : Colors.white,
              onPressed: () => onTabSelected(0),
            ),
            IconButton(
              icon: const Icon(Icons.search),
              color: currentIndex == 1 ? Colors.black : Colors.white,
              onPressed: () => onTabSelected(1),
            ),
            IconButton(
              icon: const Icon(Icons.add_box),
              color: currentIndex == 2 ? Colors.black : Colors.white,
              onPressed: () => onTabSelected(2),
            ),
            IconButton(
              icon: const Icon(Icons.favorite_border),
              color: currentIndex == 3 ? Colors.black : Colors.white,
              onPressed: () => onTabSelected(3),
            ),
            IconButton(
              icon: const Icon(Icons.account_circle),
              color: currentIndex == 4 ? Colors.black : Colors.white,
              onPressed: () => onTabSelected(4),
            ),
          ],
        ),
      ),
    );
  }
}
