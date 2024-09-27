import 'package:flutter/material.dart';

import '../models/manager.dart';
import '../services/manager_firebase_service.dart';

class UpdateManagerScreen extends StatefulWidget {
  final Manager manager;

  const UpdateManagerScreen({Key? key, required this.manager})
      : super(key: key);

  @override
  UpdateManagerScreenState createState() => UpdateManagerScreenState();
}

class UpdateManagerScreenState extends State<UpdateManagerScreen> {
  final TextEditingController _nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.manager.name;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Update Manager'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            ElevatedButton(
              child: const Text('Update'),
              onPressed: () {
                String newName = _nameController.text;

                Manager updatedManager = Manager(
                  id: widget.manager.id,
                  name: newName,
                );

                ManagerFirebaseService.updateManager(updatedManager)
                    .then((_) {
                  // Update the manager data
                  widget.manager.name = newName;
                  Navigator.pop(context);
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}
