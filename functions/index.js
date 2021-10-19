const functions = require("firebase-functions");

// // Create and Deploy Your First Cloud Functions
// // https://firebase.google.com/docs/functions/write-firebase-functions
//
// exports.helloWorld = functions.https.onRequest((request, response) => {
//   functions.logger.info("Hello logs!", {structuredData: true});
//   response.send("Hello from Firebase!");
// });
exports.onDeleteCircle = functions.firestore
    .document('/circles/{circleId}')
    .onDelete((snapshot, context) => {
    const circle
    const circleId = context.params.userId;

    const ref admin.firestore().collection('')
    });