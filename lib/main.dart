import 'package:flutter/material.dart';

/// The entry point of the application.
///
/// This function initializes the app by calling [runApp] with an instance of [MyApp].
void main() {
  runApp(const MyApp());
}

/// A [StatelessWidget] that builds the main [MaterialApp].
///
/// This widget serves as the root of the application and contains a [Dock]
/// widget that displays a list of draggable icons.
class MyApp extends StatelessWidget {
  /// Creates an instance of [MyApp].
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

/// A [StatefulWidget] that represents a dock of reorderable items.
///
/// The [Dock] allows users to drag and drop items to reorder them.
///
/// The type parameter [T] represents the type of items in the dock.
class Dock<T> extends StatefulWidget {
  /// Creates an instance of [Dock].
  ///
  /// The [items] parameter is a list of initial items to display in the dock.
  /// The [builder] parameter is a function that builds a widget for each item.
  const Dock({
    super.key,
    this.items = const [],
    required this.builder,
  });

  /// The initial list of [T] items to display in this [Dock].
  final List<T> items;

  /// A builder function that creates a widget for the provided [T] item.
  final Widget Function(T) builder;

  @override
  State<Dock<T>> createState() => _DockState<T>();
}

/// The state for the [Dock] widget.
///
/// This class manages the state of the dock, including the list of items
/// and the dragging behavior.
class _DockState<T> extends State<Dock<T>> {
  /// The list of [T] items being manipulated in the dock.
  late final List<T> _items = widget.items.toList();

  /// The index of the item currently being dragged, or null if no item is being dragged.
  int? _draggingIndex;

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
            onDragStarted: () {
              setState(() {
                _draggingIndex = index;
              });
            },
            onDragCompleted: () {
              setState(() {
                _draggingIndex = null;
              });
            },
            onDraggableCanceled: (velocity, offset) {
              setState(() {
                _draggingIndex = null;
              });
            },
            feedback: Material(
              color: Colors.transparent,
              child: Transform.scale(
                scale: 1.2,
                child: Opacity(
                  opacity: 0.8, // Add a slight opacity change
                  child: widget.builder(item),
                ),
              ),
            ),
            childWhenDragging: const SizedBox(width: 48),
            child: DragTarget<int>(
              onAccept: (oldIndex) {
                setState(() {
                  final movedItem = _items.removeAt(oldIndex);
                  _items.insert(index, movedItem);
                  _draggingIndex = null;
                });
              },
              onWillAccept: (oldIndex) => oldIndex != index,
              builder: (context, candidateData, rejectedData) {
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.bounceOut, // Use a bouncy curve
                  child: Transform.scale(
                    scale: isBeingDragged ? 1.1 : 1.0,
                    child: RotationTransition(
                      turns: isBeingDragged
                          ? const AlwaysStoppedAnimation(0.05)
                          : const AlwaysStoppedAnimation(0.0),
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
}
