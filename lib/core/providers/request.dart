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

    await _firestore.collection("blood_requests").add(requestData);
    _requests.add(requestData);
    notifyListeners();
  }

  // ✅ Find Available Donors Based on Blood Group & City
  Future<void> findDonors(String bloodGroup, String city) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection("users")
          .where("role", isEqualTo: "donor")
          .where("bloodGroup", isEqualTo: bloodGroup)
          .where("city", isEqualTo: city)
          .where("isAvailable",
              isEqualTo: true) // Ensures only available donors are fetched
          .get();

      _donors = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;

        debugPrint(
            "Fetched Donor: ${data["name"]}, Available: ${data["isAvailable"]}");

        return {
          "id": doc.id,
          "name": data["name"] ?? "Unknown",
          "age": data["age"]?.toString() ?? "N/A",
          "bloodGroup": data["bloodGroup"] ?? "N/A",
          "city": data["city"] ?? "N/A",
          "contact": data["contact"] ?? "N/A",
          "profilePic": data["profilePic"] ?? "",
          "lastDonationDate": data["lastDonationDate"] ?? "Not Available",
          "isAvailable": data["isAvailable"] ?? false, // ✅ Fixing availability
        };
      }).toList();

      debugPrint("✅ Total donors found: ${_donors.length}");

      notifyListeners();
    } catch (e) {
      debugPrint("❌ Error fetching donors: $e");
    }
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
    try {
      QuerySnapshot snapshot = await _firestore
          .collection("blood_requests")
          .where("status", isEqualTo: "Pending") // Only show pending requests
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
    } catch (e) {
      debugPrint("Error fetching active requests: $e");
    }
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
