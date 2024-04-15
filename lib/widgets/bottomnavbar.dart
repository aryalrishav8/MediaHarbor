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
    return BottomNavigationBar(
      selectedItemColor: Colors.black, // Set selected item color to black
      unselectedItemColor: Colors.black, // Set unselected item color to black
      currentIndex: currentIndex,
      onTap: onTabSelected,
      selectedFontSize: 10,
      items: const <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.search),
          label: 'Search',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.add_box),
          label: 'Upload',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.favorite_border),
          label: 'Favorites',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.account_circle),
          label: 'Profile',
        ),
      ],
    );
  }
}
