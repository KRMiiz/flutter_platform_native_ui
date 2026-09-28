import 'package:flutter/material.dart';
import 'package:flutter_platform_native_ui/flutter_platform_native_ui.dart';

void main() => runApp(const ExampleApp());

class ExampleApp extends StatelessWidget {
  const ExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'NativeTabBar example',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const NativeTabBarExample(),
    );
  }
}

class NativeTabBarExample extends StatefulWidget {
  const NativeTabBarExample({super.key});

  @override
  State<NativeTabBarExample> createState() => _NativeTabBarExampleState();
}

class _NativeTabBarExampleState extends State<NativeTabBarExample> {
  int _currentIndex = 0;

  static const List<String> _titles = <String>[
    'Home',
    'Search',
    'Favorites',
    'Profile',
  ];

  static const List<NativeTabItem> _items = <NativeTabItem>[
    NativeTabItem(
      label: 'Home',
      icon: NativeTabIcon.sfSymbol('house'),
      selectedIcon: NativeTabIcon.sfSymbol('house.fill'),
    ),
    NativeTabItem(
      label: 'Search',
      icon: NativeTabIcon.sfSymbol('magnifyingglass'),
    ),
    NativeTabItem(
      label: 'Favorites',
      icon: NativeTabIcon.sfSymbol('heart'),
      selectedIcon: NativeTabIcon.sfSymbol('heart.fill'),
      badge: '3',
    ),
    NativeTabItem(
      label: 'Profile',
      icon: NativeTabIcon.sfSymbol('person'),
      selectedIcon: NativeTabIcon.sfSymbol('person.fill'),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('NativeTabBar')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              _titles[_currentIndex],
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text('Selected index: $_currentIndex'),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: NativeTabBar(
          currentIndex: _currentIndex,
          height: 64,
          items: _items,
          onTap: (int index) => setState(() => _currentIndex = index),
        ),
      ),
    );
  }
}
