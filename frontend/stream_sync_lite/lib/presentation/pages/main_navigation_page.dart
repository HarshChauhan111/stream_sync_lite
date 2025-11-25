import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/notification/notification_bloc.dart';
import '../bloc/notification/notification_state.dart';
import '../bloc/video/video_bloc.dart';
import '../bloc/video/video_event.dart';
import 'home_page.dart';
import 'notifications_page.dart';
import 'favorites_page.dart';
import 'profile_page.dart';

class MainNavigationPage extends StatefulWidget {
  const MainNavigationPage({super.key});

  @override
  State<MainNavigationPage> createState() => _MainNavigationPageState();
}

class _MainNavigationPageState extends State<MainNavigationPage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const HomePage(),
    const NotificationsPage(),
    const FavoritesPage(),
    const ProfilePage(),
  ];

  final List<String> _titles = [
    'StreamSync Lite',
    'Notifications',
    'Favorites',
    'Profile',
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_selectedIndex]),
        elevation: 0,
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: BlocBuilder<NotificationBloc, NotificationState>(
        builder: (context, state) {
          final unreadCount = state is NotificationLoaded ? state.unreadCount : 0;
          
          return BottomNavigationBar(
            currentIndex: _selectedIndex,
            onTap: _onItemTapped,
            type: BottomNavigationBarType.fixed,
            selectedItemColor: Theme.of(context).colorScheme.primary,
            unselectedItemColor: Colors.grey,
            items: [
              const BottomNavigationBarItem(
                icon: Icon(Icons.home),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: unreadCount > 0
                    ? Badge(
                        label: Text('$unreadCount'),
                        child: const Icon(Icons.notifications),
                      )
                    : const Icon(Icons.notifications),
                label: 'Notifications',
              ),
              const BottomNavigationBarItem(
                icon: Icon(Icons.favorite),
                label: 'Favorites',
              ),
              const BottomNavigationBarItem(
                icon: Icon(Icons.person),
                label: 'Profile',
              ),
            ],
          );
        },
      ),
    );
  }
}
