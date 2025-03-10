import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RequestProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  List<Map<String, dynamic>> _requests = [];
  List<Map<String, dynamic>> get requests => _requests;

  List<Map<String, dynamic>> _donors = []; // ✅ Fixed: Added _donors list
  List<Map<String, dynamic>> get donors => _donors;

  // ✅ Create a New Blood Request
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
      "status": "Pending", // ✅ FIX: Ensure status is always set
      "timestamp": FieldValue.serverTimestamp(),
    };

    await _firestore.collection("blood_requests").add(requestData);
    _requests.add(requestData);
    notifyListeners();
  }

  // ✅ Find Available Donors Based on Blood Group & City
  Future<void> findDonors(String bloodGroup, String city) async {
    QuerySnapshot snapshot = await _firestore
        .collection("users")
        .where("role", isEqualTo: "donor")
        .where("bloodGroup", isEqualTo: bloodGroup)
        .where("city", isEqualTo: city)
        .where("isAvailable", isEqualTo: true)
        .get();

    _donors = snapshot.docs.map((doc) {
      return {
        "id": doc.id,
        "name": doc["name"],
        "contact": doc["contact"],
        "bloodGroup": doc["bloodGroup"],
        "city": doc["city"],
        "profilePic": doc["profilePic"],
      };
    }).toList();

    notifyListeners();
  }

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
        return {
          "id": doc.id,
          "bloodGroup": doc["bloodGroup"],
          "units": doc["units"],
          "location": doc["location"],
          "status": doc["status"],
        };
      }).toList();

      debugPrint("✅ Fetching my requests: ${_requests.length} found.");
      notifyListeners();
    } catch (e) {
      debugPrint("❌ Error fetching requests: $e");
    }
  }

  // ✅ Fetch All Active Requests for Donors
// ✅ Fetch Active Requests for Donors
// ✅ Fetch Active Requests for Donors
  Future<void> fetchActiveRequests() async {
    QuerySnapshot snapshot = await _firestore
        .collection("blood_requests")
        .where("status",
            isEqualTo: "Pending") // ✅ FIX: Ensure query filters for "Pending"
        .orderBy("timestamp", descending: true)
        .get();

    _requests = snapshot.docs.map((doc) {
      return {
        "id": doc.id,
        "receiverId": doc["receiverId"],
        "bloodGroup": doc["bloodGroup"],
        "units": doc["units"],
        "location": doc["location"],
        "status": doc["status"],
      };
    }).toList();

    notifyListeners();
  }

  Future<void> acceptRequest(String requestId) async {
    User? user = _auth.currentUser;
    if (user == null) return;

    await _firestore.collection("blood_requests").doc(requestId).update({
      "donorId": user.uid,
      "status": "Accepted",
    });

    _requests.removeWhere((request) => request["id"] == requestId);
    notifyListeners();
  }

Future<void> deleteRequest(String requestId) async {
  try {
    await _firestore.collection("blood_requests").doc(requestId).delete();

    // ✅ Remove the request from the list locally
    _requests.removeWhere((req) => req["id"] == requestId);
    
    debugPrint("✅ Deleted request with ID: $requestId");
    
    notifyListeners();
  } catch (e) {
    debugPrint("❌ Error deleting request: $e");
  }
}



}
