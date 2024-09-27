import 'package:flutter/material.dart';

import '../models/manager.dart';
import '../services/manager_firebase_service.dart';

class ManagerSelection extends StatefulWidget {
  final Function(Manager?) onSelectedManager;

  const ManagerSelection({super.key, required this.onSelectedManager});

  @override
  ManagerSelectionState createState() => ManagerSelectionState();
}

class ManagerSelectionState extends State<ManagerSelection> {
  final TextEditingController _searchController = TextEditingController();
  List<Manager> _managers = [];
  Manager? _selectedManager;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _searchManagersByName() async {
    String name = _searchController.text;
    List<Manager> managers =
        await ManagerFirebaseService.searchManagersByName(name);
    setState(() {
      _managers = managers;
    });
  }

  void _selectManager(Manager manager) {
    setState(() {
      _selectedManager = manager;
      widget.onSelectedManager(_selectedManager); // Notify the parent widget
    });
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: _searchController,
          onChanged: (_) => _searchManagersByName(),
          decoration: const InputDecoration(labelText: 'Reports to:'),
        ),
        Flexible(
          child: ListView.builder(
            itemCount: _managers.length,
            itemBuilder: (context, index) {
              final Manager manager = _managers[index];
              return ListTile(
                title: Text(manager.name),
                trailing: ElevatedButton(
                  child: const Text('Select'),
                  onPressed: () => _selectManager(manager),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}