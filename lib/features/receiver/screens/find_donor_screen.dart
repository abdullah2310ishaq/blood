import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:bloood_donation_app/core/providers/location_provider.dart';
import 'package:bloood_donation_app/core/models/donor_model.dart';
import 'package:url_launcher/url_launcher.dart';

class FindDonorScreen extends StatefulWidget {
  final String? bloodType;
  
  const FindDonorScreen({super.key, this.bloodType});

  @override
  State<FindDonorScreen> createState() => _FindDonorScreenState();
}

class _FindDonorScreenState extends State<FindDonorScreen> {
  GoogleMapController? _mapController;
  double _searchRadius = 10.0; // Default 10 km
  String? _selectedBloodType;
  
  @override
  void initState() {
    super.initState();
    _selectedBloodType = widget.bloodType;
    _initLocation();
  }

  Future<void> _initLocation() async {
    final locationProvider = Provider.of<LocationProvider>(context, listen: false);
    await locationProvider.initLocation();
    await locationProvider.findNearbyDonors(bloodType: _selectedBloodType);
  }

  @override
  Widget build(BuildContext context) {
    final locationProvider = Provider.of<LocationProvider>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Find Nearby Donors'),
      ),
      body: locationProvider.isLoading && locationProvider.currentPosition == null
          ? const Center(child: CircularProgressIndicator())
          : locationProvider.error != null && locationProvider.currentPosition == null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.location_off,
                        size: 64,
                        color: Colors.red,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Location error: ${locationProvider.error}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.red,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _initLocation,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : Column(
                  children: [
                    _buildFilterBar(),
                    Expanded(
                      child: Stack(
                        children: [
                          _buildMap(),
                          Positioned(
                            bottom: 16,
                            left: 0,
                            right: 0,
                            child: _buildDonorsList(),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
    );
  }

  Widget _buildFilterBar() {
    final locationProvider = Provider.of<LocationProvider>(context);
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _selectedBloodType,
                  decoration: const InputDecoration(
                    labelText: 'Blood Type',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  items: [
                    const DropdownMenuItem<String>(
                      value: null,
                      child: Text('All Blood Types'),
                    ),
                    ...['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'].map((String type) {
                      return DropdownMenuItem<String>(
                        value: type,
                        child: Text(type),
                      );
                    }).toList(),
                  ],
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedBloodType = newValue;
                    });
                    locationProvider.findNearbyDonors(bloodType: newValue);
                  },
                ),
              ),
              const SizedBox(width: 16),
              ElevatedButton(
                onPressed: () {
                  locationProvider.findNearbyDonors(bloodType: _selectedBloodType);
                },
                child: const Text('Search'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Text('Search Radius: '),
              Expanded(
                child: Slider(
                  value: _searchRadius,
                  min: 1.0,
                  max: 50.0,
                  divisions: 49,
                  label: '${_searchRadius.round()} km',
                  onChanged: (value) {
                    setState(() {
                      _searchRadius = value;
                    });
                  },
                  onChangeEnd: (value) {
                    locationProvider.updateSearchRadius(value);
                    locationProvider.findNearbyDonors(bloodType: _selectedBloodType);
                  },
                ),
              ),
              Text('${_searchRadius.round()} km'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMap() {
    final locationProvider = Provider.of<LocationProvider>(context);
    
    if (locationProvider.currentPosition == null) {
      return const Center(child: Text('Location not available'));
    }

    final currentPosition = LatLng(
      locationProvider.currentPosition!.latitude,
      locationProvider.currentPosition!.longitude,
    );

    // Create markers for all nearby donors
    final Set<Marker> markers = {
      Marker(
        markerId: const MarkerId('current_location'),
        position: currentPosition,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        infoWindow: const InfoWindow(title: 'Your Location'),
      ),
    };

    // Add markers for donors
    for (int i = 0; i < locationProvider.nearbyDonors.length; i++) {
      final donor = locationProvider.nearbyDonors[i];
      if (donor.latitude != null && donor.longitude != null) {
        markers.add(
          Marker(
            markerId: MarkerId('donor_${donor.id}'),
            position: LatLng(donor.latitude!, donor.longitude!),
            icon: BitmapDescriptor.defaultMarkerWithHue(
              donor.isAvailable ? BitmapDescriptor.hueGreen : BitmapDescriptor.hueRed,
            ),
            infoWindow: InfoWindow(
              title: 'Blood Type: ${donor.bloodType}',
              snippet: 'Distance: ${locationProvider.getDistanceToDonor(donor).toStringAsFixed(1)} km',
            ),
          ),
        );
      }
    }

    return GoogleMap(
      initialCameraPosition: CameraPosition(
        target: currentPosition,
        zoom: 12,
      ),
      markers: markers,
      circles: {
        Circle(
          circleId: const CircleId('search_radius'),
          center: currentPosition,
          radius: _searchRadius * 1000, // Convert km to meters
          fillColor: Colors.blue.withOpacity(0.1),
          strokeColor: Colors.blue,
          strokeWidth: 1,
        ),
      },
      myLocationEnabled: true,
      myLocationButtonEnabled: true,
      onMapCreated: (controller) {
        _mapController = controller;
      },
    );
  }

  Widget _buildDonorsList() {
    final locationProvider = Provider.of<LocationProvider>(context);
    
    return Container(
      height: 200,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
      ),
      child: locationProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : locationProvider.nearbyDonors.isEmpty
              ? const Center(
                  child: Text(
                    'No donors found in this area',
                    style: TextStyle(fontSize: 16),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: locationProvider.nearbyDonors.length,
                  itemBuilder: (context, index) {
                    final donor = locationProvider.nearbyDonors[index];
                    final distance = locationProvider.getDistanceToDonor(donor);
                    
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: donor.isAvailable ? Colors.green : Colors.red,
                          child: Text(
                            donor.bloodType,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        title: Text('Blood Type: ${donor.bloodType}'),
                        subtitle: Text(
                          'Distance: ${distance.toStringAsFixed(1)} km\n'
                          'Status: ${donor.isAvailable ? 'Available' : 'Not Available'}',
                        ),
                        isThreeLine: true,
                        trailing: IconButton(
                          icon: const Icon(Icons.phone),
                          onPressed: () => _showContactDialog(context, donor),
                        ),
                        onTap: () {
                          if (donor.latitude != null && donor.longitude != null) {
                            _mapController?.animateCamera(
                              CameraUpdate.newLatLngZoom(
                                LatLng(donor.latitude!, donor.longitude!),
                                15,
                              ),
                            );
                          }
                        },
                      ),
                    );
                  },
                ),
    );
  }

  void _showContactDialog(BuildContext context, DonorModel donor) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Contact Donor'),
        content: const Text(
          'Would you like to contact this donor? The app will redirect you to make a call.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              // In a real app, you would get the donor's phone number from their user profile
              // For now, we'll just show a message
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Contact feature will be available in the next update'),
                ),
              );
            },
            child: const Text('Contact'),
          ),
        ],
      ),
    );
  }
}

