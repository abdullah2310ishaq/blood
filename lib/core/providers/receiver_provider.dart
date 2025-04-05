import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:bloood_donation_app/core/models/receiver_model.dart';
import 'package:bloood_donation_app/core/models/donation_request_model.dart';

class ReceiverProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  ReceiverModel? _receiver;
  List<DonationRequestModel> _myRequests = [];
  bool _isLoading = false;
  String? _error;

  ReceiverModel? get receiver => _receiver;
  List<DonationRequestModel> get myRequests => _myRequests;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Initialize receiver data
  Future<void> initReceiver(String userId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final receiverSnapshot = await _firestore
          .collection('receivers')
          .where('userId', isEqualTo: userId)
          .limit(1)
          .get();

      if (receiverSnapshot.docs.isNotEmpty) {
        _receiver = ReceiverModel.fromJson(
            receiverSnapshot.docs.first.data() as Map<String, dynamic>);
      }
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Create or update receiver profile
  Future<bool> createOrUpdateReceiverProfile(ReceiverModel receiver) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      if (receiver.id.isEmpty) {
        // Create new receiver
        final docRef = _firestore.collection('receivers').doc();
        final newReceiver = ReceiverModel(
          id: docRef.id,
          userId: receiver.userId,
          hospitalName: receiver.hospitalName,
          address: receiver.address,
          contactPerson: receiver.contactPerson,
        );
        
        await docRef.set(newReceiver.toJson());
        _receiver = newReceiver;
      } else {
        // Update existing receiver
        await _firestore
            .collection('receivers')
            .doc(receiver.id)
            .update(receiver.toJson());
        _receiver = receiver;
      }
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Create donation request
  Future<bool> createDonationRequest(DonationRequestModel request) async {
    if (_receiver == null) return false;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final docRef = _firestore.collection('donation_requests').doc();
      final newRequest = DonationRequestModel(
        id: docRef.id,
        receiverId: _receiver!.id,
        bloodType: request.bloodType,
        urgency: request.urgency,
        status: 'pending',
        hospitalName: request.hospitalName,
        address: request.address,
        patientName: request.patientName,
        contactNumber: request.contactNumber,
        createdAt: DateTime.now(),
      );
      
      await docRef.set(newRequest.toJson());
      
      // Add to local list
      _myRequests.insert(0, newRequest);
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Fetch my donation requests
  Future<void> fetchMyRequests() async {
    if (_receiver == null) return;

    _isLoading = true;
    notifyListeners();

    try {
      final requestsSnapshot = await _firestore
          .collection('donation_requests')
          .where('receiverId', isEqualTo: _receiver!.id)
          .orderBy('createdAt', descending: true)
          .get();

      _myRequests = requestsSnapshot.docs
          .map((doc) => DonationRequestModel.fromJson(
              doc.data() as Map<String, dynamic>))
          .toList();

      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Cancel donation request
  Future<bool> cancelDonationRequest(String requestId) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _firestore.collection('donation_requests').doc(requestId).update({
        'status': 'cancelled',
      });

      // Update local list
      _myRequests = _myRequests.map((request) {
        if (request.id == requestId) {
          return DonationRequestModel(
            id: request.id,
            receiverId: request.receiverId,
            bloodType: request.bloodType,
            urgency: request.urgency,
            status: 'cancelled',
            hospitalName: request.hospitalName,
            address: request.address,
            patientName: request.patientName,
            contactNumber: request.contactNumber,
            donorId: request.donorId,
            createdAt: request.createdAt,
            completedAt: request.completedAt,
          );
        }
        return request;
      }).toList();

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Mark donation request as completed
  Future<bool> completeDonationRequest(String requestId) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _firestore.collection('donation_requests').doc(requestId).update({
        'status': 'completed',
        'completedAt': DateTime.now().toIso8601String(),
      });

      // Update local list
      _myRequests = _myRequests.map((request) {
        if (request.id == requestId) {
          return DonationRequestModel(
            id: request.id,
            receiverId: request.receiverId,
            bloodType: request.bloodType,
            urgency: request.urgency,
            status: 'completed',
            hospitalName: request.hospitalName,
            address: request.address,
            patientName: request.patientName,
            contactNumber: request.contactNumber,
            donorId: request.donorId,
            createdAt: request.createdAt,
            completedAt: DateTime.now(),
          );
        }
        return request;
      }).toList();

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Reset error
  void resetError() {
    _error = null;
    notifyListeners();
  }
}

