import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

@Preview()
WidgetBuilder preview() =>
    (context) => Container(width: 100, height: 100, color: Colors.red, child: const FlutterLogo(size: 100));
