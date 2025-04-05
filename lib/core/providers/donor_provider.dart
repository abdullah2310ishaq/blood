import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:bloood_donation_app/core/models/donor_model.dart';
import 'package:bloood_donation_app/core/models/donation_request_model.dart';
import 'package:bloood_donation_app/core/services/location_service.dart';

class DonorProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final LocationService _locationService = LocationService();
  
  DonorModel? _donor;
  List<DonationRequestModel> _availableRequests = [];
  List<DonationRequestModel> _myDonations = [];
  bool _isLoading = false;
  String? _error;
  Position? _currentPosition;

  DonorModel? get donor => _donor;
  List<DonationRequestModel> get availableRequests => _availableRequests;
  List<DonationRequestModel> get myDonations => _myDonations;
  bool get isLoading => _isLoading;
  String? get error => _error;
  Position? get currentPosition => _currentPosition;

  // Initialize donor data
  Future<void> initDonor(String userId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final donorSnapshot = await _firestore
          .collection('donors')
          .where('userId', isEqualTo: userId)
          .limit(1)
          .get();

      if (donorSnapshot.docs.isNotEmpty) {
        _donor = DonorModel.fromJson(
            donorSnapshot.docs.first.data() as Map<String, dynamic>);
        
        // If donor shares location, update it
        if (_donor!.shareLocation) {
          await updateDonorLocation();
        }
      }
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Create or update donor profile
  Future<bool> createOrUpdateDonorProfile(DonorModel donor) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // If donor wants to share location, get current position
      DonorModel donorToSave = donor;
      if (donor.shareLocation) {
        try {
          final position = await _locationService.getCurrentPosition();
          donorToSave = donor.copyWith(
            latitude: position.latitude,
            longitude: position.longitude,
          );
          _currentPosition = position;
        } catch (e) {
          // Handle location error but continue with profile update
          _error = "Couldn't get location: ${e.toString()}";
        }
      }

      if (donor.id.isEmpty) {
        // Create new donor
        final docRef = _firestore.collection('donors').doc();
        final newDonor = DonorModel(
          id: docRef.id,
          userId: donorToSave.userId,
          bloodType: donorToSave.bloodType,
          address: donorToSave.address,
          isAvailable: donorToSave.isAvailable,
          lastDonationDate: donorToSave.lastDonationDate,
          medicalConditions: donorToSave.medicalConditions,
          latitude: donorToSave.latitude,
          longitude: donorToSave.longitude,
          shareLocation: donorToSave.shareLocation,
        );
        
        await docRef.set(newDonor.toJson());
        _donor = newDonor;
      } else {
        // Update existing donor
        await _firestore
            .collection('donors')
            .doc(donorToSave.id)
            .update(donorToSave.toJson());
        _donor = donorToSave;
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

  // Update donor location
  Future<bool> updateDonorLocation() async {
    if (_donor == null || !_donor!.shareLocation) return false;

    try {
      final position = await _locationService.getCurrentPosition();
      _currentPosition = position;
      
      final updatedDonor = _donor!.copyWith(
        latitude: position.latitude,
        longitude: position.longitude,
      );

      await _firestore
          .collection('donors')
          .doc(_donor!.id)
          .update({
            'latitude': position.latitude,
            'longitude': position.longitude,
          });

      _donor = updatedDonor;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    }
  }

  // Toggle availability status
  Future<bool> toggleAvailability() async {
    if (_donor == null) return false;

    _isLoading = true;
    notifyListeners();

    try {
      final updatedDonor = _donor!.copyWith(
        isAvailable: !_donor!.isAvailable,
      );

      await _firestore
          .collection('donors')
          .doc(_donor!.id)
          .update({'isAvailable': updatedDonor.isAvailable});

      _donor = updatedDonor;
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

  // Toggle location sharing
  Future<bool> toggleLocationSharing() async {
    if (_donor == null) return false;

    _isLoading = true;
    notifyListeners();

    try {
      final newShareLocationValue = !_donor!.shareLocation;
      
      // If turning on location sharing, get current position
      double? latitude = _donor!.latitude;
      double? longitude = _donor!.longitude;
      
      if (newShareLocationValue) {
        try {
          final position = await _locationService.getCurrentPosition();
          latitude = position.latitude;
          longitude = position.longitude;
          _currentPosition = position;
        } catch (e) {
          _error = "Couldn't get location: ${e.toString()}";
          _isLoading = false;
          notifyListeners();
          return false;
        }
      }

      final updatedDonor = _donor!.copyWith(
        shareLocation: newShareLocationValue,
        latitude: latitude,
        longitude: longitude,
      );

      await _firestore
          .collection('donors')
          .doc(_donor!.id)
          .update({
            'shareLocation': newShareLocationValue,
            'latitude': latitude,
            'longitude': longitude,
          });

      _donor = updatedDonor;
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

  // Fetch available donation requests
  Future<void> fetchAvailableRequests() async {
    if (_donor == null) return;

    _isLoading = true;
    notifyListeners();

    try {
      final requestsSnapshot = await _firestore
          .collection('donation_requests')
          .where('status', isEqualTo: 'pending')
          .where('bloodType', isEqualTo: _donor!.bloodType)
          .orderBy('createdAt', descending: true)
          .get();

      _availableRequests = requestsSnapshot.docs
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

  // Fetch my donations
  Future<void> fetchMyDonations() async {
    if (_donor == null) return;

    _isLoading = true;
    notifyListeners();

    try {
      final donationsSnapshot = await _firestore
          .collection('donation_requests')
          .where('donorId', isEqualTo: _donor!.id)
          .orderBy('createdAt', descending: true)
          .get();

      _myDonations = donationsSnapshot.docs
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

  // Accept donation request
  Future<bool> acceptDonationRequest(String requestId) async {
    if (_donor == null) return false;

    _isLoading = true;
    notifyListeners();

    try {
      await _firestore.collection('donation_requests').doc(requestId).update({
        'status': 'accepted',
        'donorId': _donor!.id,
      });

      // Update local list
      _availableRequests = _availableRequests
          .where((request) => request.id != requestId)
          .toList();

      // Fetch my donations to update the list
      await fetchMyDonations();

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

