import 'package:flutter/material.dart';

import '../models/manager.dart';

class AdminManagerListItem extends StatelessWidget {
  final Manager manager;
  final VoidCallback onDelete;
  final VoidCallback onEdit;

  const AdminManagerListItem({
    Key? key,
    required this.manager,
    required this.onDelete,
    required this.onEdit,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(manager.name),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            manager.nrOfEmployees.toString(),
            style: const TextStyle(color: Colors.blueAccent),
          ),
          const SizedBox(
            width: 10,
          ),
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: onEdit,
            color: Colors.amber,
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: onDelete,
            color: Colors.red,
          ),
        ],
      ),
    );
  }
}
