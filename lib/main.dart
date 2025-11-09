import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:logbook/logbook.dart';

import 'src/flutter_render_object.dart';

@pragma('vm:entry-point')
void main([List<String>? args]) => runZonedGuarded<void>(() => runApp(const MainApp()), l.s);

/// {@template main_app}
/// App widget.
/// {@endtemplate}
class MainApp extends StatelessWidget {
  /// {@macro main_app}
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) => const MaterialApp(home: Home());
}

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Codes from the Flutter tutorials')),
    body: ListView(
      children: [
        ListTile(
          leading: const Icon(Icons.flutter_dash),
          title: const Text('Flutter Render Object'),
          onTap: () => Navigator.push<void>(
            context,
            CupertinoPageRoute<void>(builder: (context) => const FlutterRenderObject()),
          ),
        ),
      ],
    ),
  );
}
