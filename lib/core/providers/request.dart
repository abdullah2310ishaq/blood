import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RequestProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // =========================================
  // List of requests (kept as List<Map<String,dynamic>>)
  // =========================================
  List<Map<String, dynamic>> _requests = [];
  List<Map<String, dynamic>> get requests => _requests;

  // =========================================
  // List of donors for 'findDonors' logic
  // =========================================
  List<Map<String, dynamic>> _donors = [];
  List<Map<String, dynamic>> get donors => _donors;

  // =========================================
  // Fetch Single Donor Details
  // =========================================
  Future<Map<String, dynamic>?> fetchDonorDetails(String donorId) async {
    try {
      DocumentSnapshot doc =
          await _firestore.collection("users").doc(donorId).get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        return {
          "id": doc.id,
          "name": data["name"] ?? "Unknown",
          "age": data["age"]?.toString() ?? "N/A",
          "bloodGroup": data["bloodGroup"] ?? "N/A",
          "city": data["city"] ?? "N/A",
          "contact": data["contact"] ?? "N/A",
          "profilePic": data["profilePic"] ?? "",
          "lastDonationDate": data["lastDonationDate"] ?? "Not Available",
          "isAvailable": data["isAvailable"] ?? false,
          "gender": data["gender"] ?? "N/A",
          "additionalNotes": data["additionalNotes"] ?? "",
        };
      }
    } catch (e) {
      debugPrint("❌ Error fetching donor details: $e");
    }
    return null;
  }

  // =========================================
  // Create a New Blood Request (Receiver side)
  // =========================================
  Future<void> createRequest({
    required String bloodGroup,
    required int units,
    required String location,
  }) async {
    User? user = _auth.currentUser;
    if (user == null) return;

    final requestData = {
      "receiverId": user.uid,
      "bloodGroup": bloodGroup,
      "units": units,
      "location": location,
      "status": "Pending",
      "timestamp": FieldValue.serverTimestamp(),
    };

    // Add to Firestore
    DocumentReference docRef =
        await _firestore.collection("blood_requests").add(requestData);

    // Insert locally with the assigned doc ID
    final newRequest = {
      "id": docRef.id,
      "receiverId": user.uid,
      "bloodGroup": bloodGroup,
      "units": units,
      "location": location,
      "status": "Pending",
      // We won't store timestamp locally (or we can store a placeholder)
    };

    _requests.add(newRequest);
    notifyListeners();
  }

  // =========================================
  // Find Available Donors (Receiver side)
  // =========================================
  Future<void> findDonors(String bloodGroup, String city) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection("users")
          .where("role", isEqualTo: "donor")
          .where("bloodGroup", isEqualTo: bloodGroup)
          .where("city", isEqualTo: city)
          .where("isAvailable", isEqualTo: true)
          .get();

      _donors = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return {
          "id": doc.id,
          "name": data["name"] ?? "Unknown",
          "age": data["age"]?.toString() ?? "N/A",
          "bloodGroup": data["bloodGroup"] ?? "N/A",
          "city": data["city"] ?? "N/A",
          "contact": data["contact"] ?? "N/A",
          "profilePic": data["profilePic"] ?? "",
          "lastDonationDate": data["lastDonationDate"] ?? "Not Available",
          "isAvailable": data["isAvailable"] ?? false,
        };
      }).toList();

      debugPrint("✅ Total donors found: ${_donors.length}");
      notifyListeners();
    } catch (e) {
      debugPrint("❌ Error fetching donors: $e");
    }
  }

  // =========================================
  // Fetch Requests for Current Receiver
  // =========================================
  Future<void> fetchMyRequests() async {
    User? user = _auth.currentUser;
    if (user == null) return;

    try {
      QuerySnapshot snapshot = await _firestore
          .collection("blood_requests")
          .where("receiverId", isEqualTo: user.uid)
          .orderBy("timestamp", descending: true)
          .get();

      _requests = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return {
          "id": doc.id,
          "bloodGroup": data["bloodGroup"],
          "units": data["units"],
          "location": data["location"],
          "status": data["status"],
        };
      }).toList();

      debugPrint("✅ Fetching my requests: ${_requests.length} found.");
      notifyListeners();
    } catch (e) {
      debugPrint("❌ Error fetching requests: $e");
    }
  }

  // =========================================
  // Fetch All Pending Requests for Donors
  // =========================================
  Future<void> fetchActiveRequests() async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection("blood_requests")
          .where("status", isEqualTo: "Pending")
          .orderBy("timestamp", descending: true)
          .get();

      _requests = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return {
          "id": doc.id,
          "receiverId": data["receiverId"],
          "bloodGroup": data["bloodGroup"],
          "units": data["units"],
          "location": data["location"],
          "status": data["status"],
        };
      }).toList();

      notifyListeners();
    } catch (e) {
      debugPrint("❌ Error fetching active requests: $e");
    }
  }

  // =========================================
  // Donor Accepts a Request
  // =========================================
Future<void> acceptRequest(String requestId) async {
  User? user = _auth.currentUser;
  if (user == null) return;

  await _firestore.collection("blood_requests").doc(requestId).update({
    "donorId": user.uid,
    "status": "Accepted",
  });

  // 1. Get the request doc to find the receiver's ID
  final doc = await _firestore.collection("blood_requests").doc(requestId).get();
  final data = doc.data() as Map<String, dynamic>;
  final receiverId = data["receiverId"];
  final bloodGroup = data["bloodGroup"];

  // 2. Create a new notification for the receiver
  final notifData = {
    "userId": receiverId,
    "title": "Request Accepted",
    "message": "Your request for $bloodGroup was accepted!",
    "timestamp": FieldValue.serverTimestamp(),
    "isRead": false,
    "extraData": {
      "requestId": requestId,
    },
  };
  await _firestore.collection("notifications").add(notifData);

  // 3. Remove from local list or update status, whichever you do
  _requests.removeWhere((r) => r["id"] == requestId);
  notifyListeners();
}

  // =========================================
  // Donor Rejects a Request
  // =========================================
  Future<void> rejectRequest(String requestId) async {
    User? user = _auth.currentUser;
    if (user == null) return;

    // Update Firestore
    await _firestore.collection("blood_requests").doc(requestId).update({
      "donorId": user.uid,
      "status": "Rejected",
    });

    // Remove it from local list
    _requests.removeWhere((req) => req["id"] == requestId);

    notifyListeners();
  }

  // =========================================
  // Receiver Deletes Their Own Request
  // =========================================
  Future<void> deleteRequest(String requestId) async {
    try {
      await _firestore.collection("blood_requests").doc(requestId).delete();

      _requests.removeWhere((req) => req["id"] == requestId);
      debugPrint("✅ Deleted request with ID: $requestId");

      notifyListeners();
    } catch (e) {
      debugPrint("❌ Error deleting request: $e");
    }
  }

Future<Map<String, dynamic>?> fetchUserDetails(String userId) async {
  try {
    DocumentSnapshot doc = await _firestore.collection("users").doc(userId).get();
    if (doc.exists) {
      final data = doc.data() as Map<String, dynamic>;
      return {
        "id": doc.id,
        "name": data["name"] ?? "Unknown",
        "contact": data["contact"] ?? "N/A",
        "city": data["city"] ?? "N/A",
        "profilePic": data["profilePic"] ?? "",
        "bloodGroup": data["bloodGroup"] ?? "",
        // etc. any fields you want
      };
    }
  } catch (e) {
    debugPrint("❌ Error fetching user details: $e");
  }
  return null;
}


}
