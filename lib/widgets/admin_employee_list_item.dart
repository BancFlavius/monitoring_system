import 'package:ARRK/constants/constants.dart';
import 'package:flutter/material.dart';

import '../models/employee.dart';

class AdminEmployeeListItem extends StatelessWidget {
  final Employee employee;
  final VoidCallback onDelete;
  final VoidCallback onEdit;

  const AdminEmployeeListItem({
    Key? key,
    required this.employee,
    required this.onDelete,
    required this.onEdit,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(employee.name),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.offline_pin_rounded,
            color: employee.isInOffice
                ? AppColors.kBlueColor
                : Colors.grey.shade600,
          ),
          const SizedBox(
            width: 10,
          ),
          Text(
            employee.code,
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
