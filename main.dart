import 'dart:ui';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const DrawingBoard(),
    );
  }
}

class DrawingBoard extends StatefulWidget {
  const DrawingBoard({super.key});

  @override
  State<DrawingBoard> createState() => _DrawingBoardState();
}

class _DrawingBoardState extends State<DrawingBoard> {
  Color selectedColor = Colors.black;
  double strokeWidth = 5;
  List<DrawingPoint?> drawingPoints = [];
  List<DrawingPoint?> undonePoints = [];
  List<Color> colors = [
    Colors.black,
    Colors.red,
    Colors.teal,
    Colors.brown,
    Colors.yellow,
    Colors.blue,
    Colors.lime,
    Colors.purple,
    Colors.deepOrange,
    Colors.green,
    Colors.white,
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey,
        title: Row(
          children: [
            const Text(
              "Width:",
              style: TextStyle(fontSize: 18, color: Colors.black),
            ),
            Expanded(
              child: Slider(
                value: strokeWidth,
                min: 1.0,
                max: 20.0,
                onChanged: (val) => setState(() => strokeWidth = val),
                activeColor: Colors.white,
                inactiveColor: Colors.grey,
              ),
            ),
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.undo),
                  onPressed: undo,
                  tooltip: 'Undo',
                ),
                const SizedBox(width: 10),
                IconButton(
                  icon: const Icon(Icons.redo),
                  onPressed: redo,
                  tooltip: 'Redo',
                ),
                const SizedBox(width: 10),
                IconButton(
                  icon: const Icon(Icons.brush),
                  onPressed: () => setState(() => selectedColor = Colors.white),
                  tooltip: 'Eraser',
                ),
                const SizedBox(width: 10), // Space between buttons
                IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () => setState(() {
                    drawingPoints.clear();
                    undonePoints.clear();
                  }),
                  tooltip: 'Clear Canvas',
                  iconSize: 24, // Smaller size for the Clear Canvas button
                ),
              ],
            ),
          ],
        ),
      ),
      body: GestureDetector(
        onPanStart: (details) {
          setState(() {
            undonePoints.clear(); // Clear undone points when a new stroke starts
            drawingPoints.add(
              DrawingPoint(
                details.localPosition,
                Paint()
                  ..color = selectedColor
                  ..isAntiAlias = true
                  ..strokeWidth = strokeWidth
                  ..strokeCap = StrokeCap.round,
              ),
            );
          });
        },
        onPanUpdate: (details) {
          setState(() {
            drawingPoints.add(
              DrawingPoint(
                details.localPosition,
                Paint()
                  ..color = selectedColor
                  ..isAntiAlias = true
                  ..strokeWidth = strokeWidth
                  ..strokeCap = StrokeCap.round,
              ),
            );
          });
        },
        onPanEnd: (details) {
          setState(() {
            drawingPoints.add(null);
          });
        },
        child: CustomPaint(
          painter: _DrawingPainter(drawingPoints),
          child: Container(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
          ),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        child: Container(
          color: Colors.grey[350],
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(
                colors.length,
                    (index) => _buildColorChose(colors[index]),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void undo() {
    setState(() {
      if (drawingPoints.isNotEmpty) {
        DrawingPoint? lastPoint = drawingPoints.removeLast();
        while (lastPoint != null && drawingPoints.isNotEmpty) {
          undonePoints.add(lastPoint);
          lastPoint = drawingPoints.removeLast();
        }
        undonePoints.add(null); // Mark the end of the removed stroke
      }
    });
  }

  void redo() {
    setState(() {
      if (undonePoints.isNotEmpty) {
        DrawingPoint? lastUndonePoint = undonePoints.removeLast();
        while (lastUndonePoint != null && undonePoints.isNotEmpty) {
          drawingPoints.add(lastUndonePoint);
          lastUndonePoint = undonePoints.removeLast();
        }
        drawingPoints.add(null); // Mark the end of the restored stroke
      }
    });
  }

  Widget _buildColorChose(Color color) {
    bool isSelected = selectedColor == color;
    return GestureDetector(
      onTap: () => setState(() => selectedColor = color),
      child: Container(
        height: isSelected ? 46 : 35,
        width: isSelected ? 46 : 35,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: isSelected
              ? Border.all(
            color: Colors.white,
            width: 3,
          )
              : null,
        ),
      ),
    );
  }
}

class _DrawingPainter extends CustomPainter {
  final List<DrawingPoint?> drawingPoints;

  _DrawingPainter(this.drawingPoints);

  List<Offset> offsetsList = [];

  @override
  void paint(Canvas canvas, Size size) {
    for (int i = 0; i < drawingPoints.length - 1; i++) {
      if (drawingPoints[i] != null && drawingPoints[i + 1] != null) {
        canvas.drawLine(
          drawingPoints[i]!.offset,
          drawingPoints[i + 1]!.offset,
          drawingPoints[i]!.paint,
        );
      } else if (drawingPoints[i] != null && drawingPoints[i + 1] == null) {
        offsetsList.clear();
        offsetsList.add(drawingPoints[i]!.offset);

        canvas.drawPoints(
          PointMode.points,
          offsetsList,
          drawingPoints[i]!.paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class DrawingPoint {
  Offset offset;
  Paint paint;

  DrawingPoint(this.offset, this.paint);
}
