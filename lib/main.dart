import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

/// The root widget of the application.
class MyApp extends StatelessWidget {
  /// Creates a [MyApp] widget.
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

/// A customizable dock widget that displays a row of draggable items.
///
/// The [Dock] widget creates an interactive dock/toolbar where items can be
/// reordered through drag and drop interactions. Each item is rendered using
/// the provided [builder] function.
///
/// Type parameter [T] defines the type of items to be displayed in the dock.
class Dock<T> extends StatefulWidget {
  /// Creates a dock widget.
  ///
  /// The [items] parameter specifies the list of items to display.
  /// The [builder] parameter defines how each item should be rendered.
  const Dock({
    super.key,
    required this.items,
    required this.builder,
  });

  /// The list of items to display in the dock.
  final List<T> items;

  /// A builder function that defines how each item should be rendered.
  ///
  /// This function takes an item of type [T] and returns a [Widget].
  final Widget Function(T) builder;

  @override
  State<Dock<T>> createState() => _DockState<T>();
}

class _DockState<T> extends State<Dock<T>> with SingleTickerProviderStateMixin {
  /// Internal list of items that can be reordered.
  late final List<T> _items;

  /// Index of the item currently being dragged, null if no drag is in progress.
  int? _draggingIndex;

  /// Index of the position where a dragged item is hovering, null if not hovering.
  int? _hoveredIndex;

  /// Whether an item is currently being dragged.
  bool _isDragging = false;

  @override
  void initState() {
    super.initState();
    _items = widget.items.toList();
  }

  /// Resets all drag-related state variables.
  void _resetDragState() {
    setState(() {
      _draggingIndex = null;
      _hoveredIndex = null;
      _isDragging = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Colors.black12,
      ),
      padding: const EdgeInsets.all(4),
      transform: Matrix4.identity()..scale(_isDragging ? 0.95 : 1.0),
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
            feedback: _buildDragFeedback(item),
            childWhenDragging: const SizedBox(width: 48),
            child: _buildDragTarget(index, item, isBeingDragged),
          );
        }),
      ),
    );
  }

  /// Builds the visual feedback shown while dragging an item.
  Widget _buildDragFeedback(T item) {
    return Material(
      color: Colors.transparent,
      child: Transform.scale(
        scale: 1.2,
        child: Opacity(
          opacity: 0.95,
          child: widget.builder(item),
        ),
      ),
    );
  }

  /// Builds a drag target for an item at the specified index.
  ///
  /// Handles the drag and drop logic and animations for each item.
  Widget _buildDragTarget(int index, T item, bool isBeingDragged) {
    return DragTarget<int>(
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
        final offset = _calculateOffset(index);

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
    );
  }

  /// Calculates the horizontal offset for an item during drag operations.
  double _calculateOffset(int index) {
    if (_isDragging && _hoveredIndex != null && _draggingIndex != null) {
      if (_draggingIndex! < index && index <= _hoveredIndex!) {
        return -48.0;
      } else if (_draggingIndex! > index && index >= _hoveredIndex!) {
        return 48.0;
      }
    }
    return 0.0;
  }

  @override
  void dispose() {
    _items.clear();
    super.dispose();
  }
}
