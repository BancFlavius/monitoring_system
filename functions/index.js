const functions = require("firebase-functions");
const admin = require("firebase-admin");
// const logger = require("firebase-functions/lib/logger");

admin.initializeApp(functions.config().firebase);

// Update checkInEnabled value in Firestore
const updateCheckInEnabled = async (value) => {
  const settingsRef = admin.firestore().collection("globals").doc("settings");
  await settingsRef.update({ checkInEnabled: value });
};

exports.autoCheckout = functions.pubsub
    .schedule("30 20 * * 1-5")
    .timeZone("Europe/Bucharest")
    .onRun(async (context) => {
      await updateCheckInEnabled(false);
      const snapshot = await admin.firestore().collection("employee").get();
      const updatePromises = snapshot.docs.map(async (doc) => {
        try {
          await doc.ref.update({isInOffice: false});
        } catch (error) {
          console.error("Failed to update document:", doc.id);
        }
      });
      await Promise.all(updatePromises);
      console.log("Scheduled function autoCheckout executed successfully.");
      return null;
    });

exports.enableCheckIn = functions.pubsub
  .schedule("0 7 * * 1-5")
  .timeZone("Europe/Bucharest")
  .onRun(async (context) => {
      await updateCheckInEnabled(true);
      return null;
  });

exports.deleteOldStepReservations = functions.pubsub
    .schedule("0 7 * * 1-5") // Schedule at 7 am every day from Monday to Friday
    .timeZone("Europe/Bucharest")
    .onRun(async (context) => {
      // Get today's date in the format yyyy_mm_dd
      const currentDate = new Date();
      const currentDay = currentDate.getDate();
      const currentMonth = currentDate.getMonth() + 1;
      const currentYear = currentDate.getFullYear();
      const todayDate = `${currentYear}_${currentMonth.toString().padStart(2, '0')}_${currentDay.toString().padStart(2, '0')}`;


      // Get all reservations
      const reservationsRef = admin.firestore().collection("stepReservation");
      const querySnapshot = await reservationsRef.get();

      // Iterate through the documents and delete based on conditions
      querySnapshot.forEach((doc) => {
        const reservationDate = doc.id; // Assuming the document ID is the date

        // Check if the reservation date is before today's date
        if (reservationDate < todayDate) {
           reservationsRef.doc(reservationDate).delete() // Delete the document
             .then(() => {
                console.log('Document ${reservationDate} deleted successfully.');
              })
             .catch((error) => {
                console.error("Error deleting document: ", error);
              });
        }
    });

      // Return success or other meaningful information
      return null;
  });


//exports.deleteOldReservations = functions.pubsub
//  .schedule("0 7 * * 1-5") // Schedule at 7 am every day from Monday to Friday
//  .timeZone("Europe/Bucharest")
//  .onRun(async (context) => {
//    // Get today's date in the format dd_mm_yyyy
//    const currentDate = new Date();
//    const currentDay = currentDate.getDate();
//    const currentMonth = currentDate.getMonth() + 1;
//    const currentYear = currentDate.getFullYear();
//    const todayDate = `${currentDay}_${currentMonth}_${currentYear}`;
//
//    // Get all reservations
//    const reservationsRef = admin.firestore().collection("reservation");
//    const querySnapshot = await reservationsRef.get();
//
//    // Delete reservations with IDs from the past
//    const deletePromises = [];
//    querySnapshot.forEach((doc) => {
//      const idParts = doc.id.split("_");
//      const day = parseInt(idParts[0], 10);
//      const month = parseInt(idParts[1], 10);
//      const year = parseInt(idParts[2], 10);
//      const reservationDate = new Date(year, month -1, day); // month is 0-based in JavaScript Date object
//      if (reservationDate < currentDate) {
//        deletePromises.push(doc.ref.delete());
//      }
//    });
//
//    // Wait for all deletions to complete
//    await Promise.all(deletePromises);
//
//    return null;
//  });

//exports.modifyParkingSpotsStatus = functions.https.onCall(async (data, context) => {
//  const parkingSpotsSelected = data.selectedParkingSpots;
//  const scheduledDifference = data.scheduledDifference;
//  const statusData = data.status;
//  const regionData = data.region;
//
//  // Schedule the batch update at the scheduled time.
//  setTimeout(async () => {
//    const parkingSpotRef = admin.firestore().collection('parkingSpot').doc(regionData);
//
//    // Get the current document snapshot for the parkingSpot document.
//    const docSnapshot = await parkingSpotRef.get();
//    const spotNumbersData = docSnapshot.data().spotNumbers;
//
//    // Update the status for the specified parking spots in the spotNumbers map.
//    parkingSpotsSelected.forEach((parkingSpot) => {
//      if (spotNumbersData.hasOwnProperty(parkingSpot)) {
//        spotNumbersData[parkingSpot] = statusData;
//      }
//    });
//
//    // Update the "spotNumbers" field in the document with the modified map.
//    await parkingSpotRef.update({ spotNumbers: spotNumbersData });
//    console.log('Succes');
//  }, scheduledDifference);
//
//  // Return a success message to the client.
//  return { message: 'Parking spots will be blocked as scheduled.' };
//});
//
////firebase deploy --only functions:modifyParkingSpotsStatus





