import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Dock(
            items: const [
              Icons.person,
              Icons.message,
              Icons.call,
              Icons.camera,
              Icons.photo,
            ],
            builder: (e) {
              return Container(
                constraints: const BoxConstraints(minWidth: 48),
                height: 48,
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.primaries[e.hashCode % Colors.primaries.length],
                ),
                child: Center(child: Icon(e, color: Colors.white)),
              );
            },
          ),
        ),
      ),
    );
  }
}

class Dock<T> extends StatefulWidget {
  const Dock({
    super.key,
    required this.items,
    required this.builder,
  });

  final List<T> items;
  final Widget Function(T) builder;

  @override
  State<Dock<T>> createState() => _DockState<T>();
}

class _DockState<T> extends State<Dock<T>> with SingleTickerProviderStateMixin {
  late final List<T> _items;
  int? _draggingIndex;
  int? _hoveredIndex;
  bool _isDragging = false;

  @override
  void initState() {
    super.initState();
    _items = widget.items.toList();
  }

  void _resetDragState() {
    setState(() {
      _draggingIndex = null;
      _hoveredIndex = null;
      _isDragging = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Colors.black12,
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(_items.length, (index) {
          final item = _items[index];
          final isBeingDragged = _draggingIndex == index;

          return LongPressDraggable<int>(
            data: index,
            delay: const Duration(milliseconds: 50),
            onDragStarted: () {
              setState(() {
                _draggingIndex = index;
                _isDragging = true;
              });
            },
            onDragCompleted: _resetDragState,
            onDraggableCanceled: (_, __) => _resetDragState(),
            feedback: Material(
              color: Colors.transparent,
              child: Transform.scale(
                scale: 1.2,
                child: Opacity(
                  opacity: 0.95,
                  child: widget.builder(item),
                ),
              ),
            ),
            childWhenDragging: const SizedBox(
                width: 48), // Changed this line to just show an empty SizedBox
            child: DragTarget<int>(
              onAccept: (oldIndex) {
                setState(() {
                  if (oldIndex < _items.length) {
                    final movedItem = _items.removeAt(oldIndex);
                    _items.insert(index, movedItem);
                  }
                  _resetDragState();
                });
              },
              onWillAccept: (oldIndex) {
                if (oldIndex == null || oldIndex == index) return false;
                setState(() {
                  _hoveredIndex = index;
                });
                return true;
              },
              onLeave: (_) {
                setState(() {
                  _hoveredIndex = null;
                });
              },
              builder: (context, candidateData, rejectedData) {
                double offset = 0.0;
                if (_isDragging &&
                    _hoveredIndex != null &&
                    _draggingIndex != null) {
                  if (_draggingIndex! < index && index <= _hoveredIndex!) {
                    offset = -48.0;
                  } else if (_draggingIndex! > index &&
                      index >= _hoveredIndex!) {
                    offset = 48.0;
                  }
                }

                return AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  transform: Matrix4.translationValues(offset, 0, 0),
                  curve: Curves.easeOutCubic,
                  child: AnimatedScale(
                    duration: const Duration(milliseconds: 200),
                    scale: isBeingDragged ? 0.9 : 1.0,
                    child: AnimatedRotation(
                      turns: isBeingDragged ? 0.05 : 0.0,
                      duration: const Duration(milliseconds: 200),
                      child: widget.builder(item),
                    ),
                  ),
                );
              },
            ),
          );
        }),
      ),
    );
  }

  @override
  void dispose() {
    _items.clear();
    super.dispose();
  }
}
