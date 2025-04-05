import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:bloood_donation_app/core/models/donor_model.dart';
import 'package:bloood_donation_app/core/services/location_service.dart';

class LocationProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final LocationService _locationService = LocationService();
  
  Position? _currentPosition;
  List<DonorModel> _nearbyDonors = [];
  double _searchRadius = 10.0; // Default 10 km radius
  bool _isLoading = false;
  String? _error;

  Position? get currentPosition => _currentPosition;
  List<DonorModel> get nearbyDonors => _nearbyDonors;
  double get searchRadius => _searchRadius;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Initialize location
  Future<void> initLocation() async {
    _isLoading = true;
    notifyListeners();

    try {
      _currentPosition = await _locationService.getCurrentPosition();
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Update search radius
  void updateSearchRadius(double radius) {
    _searchRadius = radius;
    notifyListeners();
  }

  // Find nearby donors
  Future<void> findNearbyDonors({String? bloodType}) async {
    if (_currentPosition == null) {
      await initLocation();
      if (_currentPosition == null) return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      // Get all donors who share their location and are available
      Query query = _firestore
          .collection('donors')
          .where('shareLocation', isEqualTo: true)
          .where('isAvailable', isEqualTo: true);
      
      // Add blood type filter if specified
      if (bloodType != null && bloodType.isNotEmpty) {
        query = query.where('bloodType', isEqualTo: bloodType);
      }
      
      final donorsSnapshot = await query.get();
      
      // Filter donors by distance
      List<DonorModel> allDonors = donorsSnapshot.docs
          .map((doc) => DonorModel.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
      
      _nearbyDonors = allDonors.where((donor) {
        if (donor.latitude == null || donor.longitude == null) return false;
        
        double distance = _locationService.calculateDistance(
          _currentPosition!.latitude,
          _currentPosition!.longitude,
          donor.latitude!,
          donor.longitude!
        );
        
        return distance <= _searchRadius;
      }).toList();

      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Get distance between current position and donor
  double getDistanceToDonor(DonorModel donor) {
    if (_currentPosition == null || donor.latitude == null || donor.longitude == null) {
      return -1; // Invalid distance
    }
    
    return _locationService.calculateDistance(
      _currentPosition!.latitude,
      _currentPosition!.longitude,
      donor.latitude!,
      donor.longitude!
    );
  }

  // Reset error
  void resetError() {
    _error = null;
    notifyListeners();
  }
}

