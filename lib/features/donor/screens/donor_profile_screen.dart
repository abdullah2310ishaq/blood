import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bloood_donation_app/core/providers/auth_provider.dart';
import 'package:bloood_donation_app/core/providers/donor_provider.dart';
import 'package:bloood_donation_app/core/models/donor_model.dart';
import 'package:bloood_donation_app/features/donor/screens/donor_homescreen.dart';

class DonorProfileScreen extends StatefulWidget {
  const DonorProfileScreen({super.key});

  @override
  State<DonorProfileScreen> createState() => _DonorProfileScreenState();
}

class _DonorProfileScreenState extends State<DonorProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  String _bloodType = 'A+';
  final _addressController = TextEditingController();
  DateTime _lastDonationDate = DateTime.now();
  final List<String> _medicalConditions = [];
  bool _isAvailable = true;
  bool _shareLocation = false;

  final List<String> _bloodTypes = [
    'A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'
  ];

  @override
  void initState() {
    super.initState();
    _loadDonorData();
  }

  @override
  void dispose() {
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _loadDonorData() async {
    final donorProvider = Provider.of<DonorProvider>(context, listen: false);
    if (donorProvider.donor != null) {
      setState(() {
        _bloodType = donorProvider.donor!.bloodType;
        _addressController.text = donorProvider.donor!.address;
        _lastDonationDate = donorProvider.donor!.lastDonationDate;
        _medicalConditions.clear();
        _medicalConditions.addAll(donorProvider.donor!.medicalConditions);
        _isAvailable = donorProvider.donor!.isAvailable;
        _shareLocation = donorProvider.donor!.shareLocation;
      });
    }
  }

  Future<void> _saveDonorProfile() async {
    if (_formKey.currentState!.validate()) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final donorProvider = Provider.of<DonorProvider>(context, listen: false);
      
      final donor = DonorModel(
        id: donorProvider.donor?.id ?? '',
        userId: authProvider.user!.id,
        bloodType: _bloodType,
        address: _addressController.text.trim(),
        isAvailable: _isAvailable,
        lastDonationDate: _lastDonationDate,
        medicalConditions: _medicalConditions,
        shareLocation: _shareLocation,
        latitude: donorProvider.donor?.latitude,
        longitude: donorProvider.donor?.longitude,
      );
      
      final success = await donorProvider.createOrUpdateDonorProfile(donor);
      
      if (success && mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const DonorHomeScreen()),
        );
      }
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _lastDonationDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _lastDonationDate) {
      setState(() {
        _lastDonationDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final donorProvider = Provider.of<DonorProvider>(context);
    final isEditing = donorProvider.donor != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Donor Profile' : 'Create Donor Profile'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Blood Type',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _bloodType,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                ),
                items: _bloodTypes.map((String type) {
                  return DropdownMenuItem<String>(
                    value: type,
                    child: Text(type),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    setState(() {
                      _bloodType = newValue;
                    });
                  }
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select your blood type';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              const Text(
                'Address',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(
                  hintText: 'Enter your address',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your address';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              const Text(
                'Last Donation Date',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              InkWell(
                onTap: () => _selectDate(context),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade400),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${_lastDonationDate.day}/${_lastDonationDate.month}/${_lastDonationDate.year}',
                        style: const TextStyle(fontSize: 16),
                      ),
                      const Icon(Icons.calendar_today),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Text(
                    'Available for donation:',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  Switch(
                    value: _isAvailable,
                    activeColor: Colors.red,
                    onChanged: (value) {
                      setState(() {
                        _isAvailable = value;
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Text(
                    'Share my location:',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  Switch(
                    value: _shareLocation,
                    activeColor: Colors.red,
                    onChanged: (value) {
                      setState(() {
                        _shareLocation = value;
                      });
                    },
                  ),
                ],
              ),
              if (_shareLocation)
                Container(
                  margin: const EdgeInsets.only(top: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.yellow.shade100,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.yellow.shade700),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.orange),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Your location will be shared with receivers to help them find nearby donors in emergencies.',
                          style: TextStyle(fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 24),
              if (donorProvider.error != null)
                Container(
                  padding: const EdgeInsets.all(8),
                  color: Colors.red.shade100,
                  child: Text(
                    donorProvider.error!,
                    style: TextStyle(color: Colors.red.shade800),
                  ),
                ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: donorProvider.isLoading ? null : _saveDonorProfile,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                ),
                child: donorProvider.isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Save Profile'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

