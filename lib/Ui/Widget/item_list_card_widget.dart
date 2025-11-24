import 'package:flutter/material.dart';

class ItemListCard<T> extends StatelessWidget {
  final List<T> items;
  final Widget Function(T item) leading;
  final Widget Function(T item) title;
  final Widget? Function(T item)? subtitle;
  final void Function(T item, int index)? onEdit;
  final void Function(T item, int index)? onDelete;

  const ItemListCard({
    Key? key,
    required this.items,
    required this.leading,
    required this.title,
    this.subtitle,
    this.onEdit,
    this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const Center(child: Text("No items for this date"));
    }

    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 6),
          elevation: 3,
          child: ListTile(
            leading: leading(item),
            title: title(item),
            subtitle: subtitle != null ? subtitle!(item) : null,
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (onEdit != null)
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.blue),
                    onPressed: () => onEdit!(item, index),
                  ),
                if (onDelete != null)
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => onDelete!(item, index),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
