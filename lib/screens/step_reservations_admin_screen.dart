import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class StepReservationsAdminScreen extends StatelessWidget {
  const StepReservationsAdminScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Step Reservations'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('stepReservation').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            final reservations = snapshot.data?.docs ?? [];

            return ListView.builder(
              itemCount: reservations.length,
              itemBuilder: (context, index) {
                final reservationData = reservations[index].data() as Map<String, dynamic>;
                // Display reservation details however you want
                return ListTile(
                  title: Text('Reservation ID: ${reservations[index].id}',style: TextStyle(color: Colors.blue,fontSize: 18),),
                  subtitle: Text('Details: ${reservationData.toString()}'),
                  // Add more details as needed
                );
              },
            );
          }
        },
      ),
    );
  }
}
