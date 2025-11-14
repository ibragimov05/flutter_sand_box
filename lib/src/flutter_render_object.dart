/*
 * How to build a RenderObject - Flutter Build Show
 * https://www.youtube.com/watch?v=cq34RWXegM8
 */

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/widget_previews.dart';

/// {@template flutter_render_object}
/// Flutter render object widget.
/// {@endtemplate}
class FlutterRenderObject extends StatefulWidget {
  /// {@macro flutter_render_object}
  const FlutterRenderObject({super.key});

  @override
  State<FlutterRenderObject> createState() => _FlutterRenderObjectState();
}

@Preview()
WidgetBuilder preview() =>
    (context) => Container(width: 100, height: 100, color: Colors.yellow, child: const FlutterLogo(size: 100));

@Preview()
WidgetBuilder preview2() =>
    (context) => Container(width: 100, height: 100, color: Colors.purple, child: const FlutterLogo(size: 100));

class _FlutterRenderObjectState extends State<FlutterRenderObject> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController()..text = 'Hello, how are you?';
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Flutter Render Object')),
    body: Center(
      child: SizedBox(
        width: 220,
        child: Column(
          mainAxisAlignment: .end,
          children: [
            Align(
              alignment: .centerRight,
              child: Container(
                color: Colors.blue[100]!,
                padding: const EdgeInsets.all(16),
                child: ListenableBuilder(
                  listenable: _controller,
                  builder: (context, child) => TimeStampedChatMessage(
                    text: _controller.text,
                    sentAt: '2 minutes ago',
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              ),
            ),

            Padding(
              padding: const .symmetric(vertical: 24),
              child: TextField(controller: _controller),
            ),
          ],
        ),
      ),
    ),
  );
}

class TimeStampedChatMessage extends LeafRenderObjectWidget {
  const TimeStampedChatMessage({required this.text, required this.sentAt, required this.style, super.key});

  final String text;
  final String sentAt;
  final TextStyle style;

  @override
  RenderObject createRenderObject(BuildContext context) => TimeStampedChatMessageRenderObject(
    text: text,
    sentAt: sentAt,
    style: style,
    textDirection: Directionality.of(context),
  );

  @override
  void updateRenderObject(BuildContext context, covariant TimeStampedChatMessageRenderObject renderObject) {
    renderObject
      ..text = text
      ..sentAt = sentAt
      ..style = style
      ..textDirection = Directionality.of(context);
  }
}

class TimeStampedChatMessageRenderObject extends RenderBox {
  TimeStampedChatMessageRenderObject({
    required String text,
    required String sentAt,
    required TextStyle style,
    required TextDirection textDirection,
  }) : _text = text,
       _sentAt = sentAt,
       _style = style,
       _textDirection = textDirection {
    _textPainter = TextPainter(text: textTextSpan, textDirection: _textDirection);

    _sentAtPainter = TextPainter(text: sentAtTextSpan, textDirection: _textDirection);
  }

  String _text;
  String _sentAt;
  TextStyle _style;
  TextDirection _textDirection;

  late TextPainter _textPainter;
  late TextPainter _sentAtPainter;

  late bool _sentAtFitsOnLastLine;
  late double _lineHeight;
  late double _lastMessageLineWidth;
  late double _longestLineWidth;
  late double _sentAtLineWidth;
  late int _numMessageLines;

  void setState() {
    markNeedsLayout();
    markNeedsSemanticsUpdate();
  }

  String get text => _text;
  set text(String value) {
    if (_text == value) return;
    _text = value;
    _textPainter.text = textTextSpan;

    setState();
  }

  String get sentAt => _sentAt;
  set sentAt(String value) {
    if (_sentAt == value) return;
    _sentAt = value;
    _sentAtPainter.text = sentAtTextSpan;

    setState();
  }

  TextStyle get style => _style;
  set style(TextStyle value) {
    if (_style == value) return;
    _style = value;
    _textPainter.text = textTextSpan;
    _sentAtPainter.text = sentAtTextSpan;

    setState();
  }

  TextDirection get textDirection => _textDirection;
  set textDirection(TextDirection value) {
    if (_textDirection == value) return;
    _textDirection = value;
    _textPainter.textDirection = value;
    _sentAtPainter.textDirection = value;

    setState();
  }

  TextSpan get textTextSpan => TextSpan(text: _text, style: _style);
  TextSpan get sentAtTextSpan => TextSpan(
    text: _sentAt,
    style: _style.copyWith(color: Colors.grey),
  );

  @override
  void performLayout() {
    _textPainter.layout(maxWidth: constraints.maxWidth);
    final textLines = _textPainter.computeLineMetrics();

    _sentAtPainter.layout(maxWidth: constraints.maxWidth);
    _sentAtLineWidth = _sentAtPainter.computeLineMetrics().first.width;

    _longestLineWidth = 0;

    for (final line in textLines) {
      _longestLineWidth = max(_longestLineWidth, line.width);
    }

    _lastMessageLineWidth = textLines.last.width;
    _lineHeight = textLines.last.height;
    _numMessageLines = textLines.length;

    final sizeOfMessage = Size(_longestLineWidth, _textPainter.height);

    final lastLineWithDate = _lastMessageLineWidth + (_sentAtLineWidth * 1.1);
    if (textLines.length == 1) {
      _sentAtFitsOnLastLine = lastLineWithDate < constraints.maxWidth;
    } else {
      _sentAtFitsOnLastLine = lastLineWithDate < min(_longestLineWidth, constraints.maxWidth);
    }

    late Size computedSize;
    if (!_sentAtFitsOnLastLine) {
      computedSize = Size(sizeOfMessage.width, sizeOfMessage.height + _sentAtPainter.height);
    } else {
      if (textLines.length == 1) {
        computedSize = Size(lastLineWithDate, sizeOfMessage.height);
      } else {
        computedSize = Size(_longestLineWidth, sizeOfMessage.height);
      }
    }

    size = constraints.constrain(computedSize);
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    _textPainter.paint(context.canvas, offset);

    late Offset sentAtOffset;
    if (_sentAtFitsOnLastLine) {
      sentAtOffset = Offset(
        offset.dx + (size.width - _sentAtLineWidth),
        offset.dy + (_lineHeight * (_numMessageLines - 1)),
      );
    } else {
      sentAtOffset = Offset(offset.dx + (size.width - _sentAtLineWidth), offset.dy + (_lineHeight * _numMessageLines));
    }

    _sentAtPainter.paint(context.canvas, sentAtOffset);
  }

  @override
  void describeSemanticsConfiguration(SemanticsConfiguration config) {
    super.describeSemanticsConfiguration(config);

    config
      ..isSemanticBoundary = true
      ..label = '$_text, sent at $_sentAt'
      ..textDirection = _textDirection;
  }
}
