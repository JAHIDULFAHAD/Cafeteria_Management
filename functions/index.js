// functions/index.js
const functions = require("firebase-functions");
const admin = require("firebase-admin");
admin.initializeApp();

exports.deleteUser = functions.https.onCall(async (data, context) => {
  console.log("Received data:", data);

 // Check if the user is authenticated
  const uid = data?.uid || data?.data?.uid;

  if (!uid || typeof uid !== "string" || uid.trim() === "") {
    console.error("❌ UID is empty or invalid!");
    return { success: false, message: "UID is empty or invalid!" };
  }

  console.log("Deleting UID:", uid);

  try {
    // Firestore document delete
    const docRef = admin.firestore().collection("users").doc(uid);
    const docSnap = await docRef.get();
    if (docSnap.exists) await docRef.delete();

    // Firebase Auth user delete
    await admin.auth().deleteUser(uid);

    console.log("✅ Firestore + Auth deleted");
    return { success: true };
  } catch (error) {
    console.error("🔥 Error deleting user:", error);
    return { success: false, message: error.message };
  }
});

