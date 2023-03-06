import 'dart:math';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

const double _maxBarHeight = 255;

/// Docs
class AudioWaveSlider extends StatefulWidget {
  /// Docs
  const AudioWaveSlider({
    super.key,
    required this.bars,
    required this.progressStream,
    this.barsRatio = 1,
  });

  /// Docs
  final List<int> bars;

  /// Docs
  final Stream<double> progressStream;

  ///Docs
  final double barsRatio;

  @override
  _AudioWaveSliderState createState() => _AudioWaveSliderState();
}

class _AudioWaveSliderState extends State<AudioWaveSlider> {
  var _dragging = false;
  final _initialSize = 15.0;
  final _finalSize = 22.0;

  double _currentSize() {
    return _dragging ? _finalSize : _initialSize;
  }

  double _progressToWidth(BoxConstraints constraints, double progress) {
    return constraints.maxWidth * progress;
  }

  @override
  Widget build(BuildContext context) {
    final gestureDetector = GestureDetector(
      onHorizontalDragStart: (details) {
        setState(() {
          _dragging = true;
        });
      },
      onHorizontalDragEnd: (details) {
        setState(() {
          _dragging = false;
        });
      },
      onHorizontalDragUpdate: (details) {},
    );

    return StreamBuilder<double>(
      initialData: 0,
      stream: widget.progressStream,
      builder: (context, snapshot) {
        final progress = snapshot.data ?? 0;

        return LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            return Stack(
              alignment: Alignment.center,
              children: [
                CustomPaint(
                  size: Size(constraints.maxWidth, constraints.maxHeight),
                  painter: _AudioBarsPainter(
                    bars: widget.bars,
                    colorLeft: Colors.lightBlueAccent,
                    colorRight: Colors.blueAccent,
                    progress: _progressToWidth(constraints, progress),
                    barRatio: 0.6,
                  ),
                ),
                AnimatedPositioned(
                  duration: Duration.zero,
                  left: _progressToWidth(constraints, progress),
                  key: const ValueKey('item 1'),
                  child: Container(
                    width: _currentSize(),
                    height: _currentSize(),
                    // color: Colors.red,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.green,
                    ),
                  ),
                ),
                gestureDetector,
              ],
            );
          },
        );
      },
    );
  }
}

class _AudioBarsPainter extends CustomPainter {
  _AudioBarsPainter({
    required this.bars,
    required this.colorLeft,
    required this.colorRight,
    required this.progress,
    required this.barRatio,
  });

  final List<int> bars;
  final Color colorRight;
  final Color colorLeft;
  final double progress;
  final spacingRatio = 0.005;
  final double barRatio;

  /// barWidth should include spacing, not only the width of the bar.
  Color _barColor(double barCenter, double progress) {
    return (progress > barCenter) ? colorRight : colorLeft;
  }

  double _barHeight(int barValue, totalHeight) {
    return max((barValue / _maxBarHeight) * totalHeight * barRatio, 4);
  }

  @override
  void paint(Canvas canvas, Size size) {
    final spacingWidth = size.width * spacingRatio;
    final totalBarWidth = size.width - spacingWidth * (bars.length - 1);
    final barWidth = totalBarWidth / bars.length;
    final barY = size.height / 2;

    bars.forEachIndexed((i, barValue) {
      final barHeight = _barHeight(barValue, size.height);
      final barX = i * (barWidth + spacingWidth) + barWidth / 2;

      final rect = RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(barX, barY),
          width: barWidth,
          height: barHeight,
        ),
        const Radius.circular(50),
      );

      final paint = Paint()..color = _barColor(barX + barWidth / 2, progress);
      canvas.drawRRect(rect, paint);
    });
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
