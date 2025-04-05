import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bloood_donation_app/core/providers/receiver_provider.dart';
import 'package:bloood_donation_app/core/models/donation_request_model.dart';

class ReceiverCreateRequestScreen extends StatefulWidget {
  const ReceiverCreateRequestScreen({super.key});

  @override
  State<ReceiverCreateRequestScreen> createState() => _ReceiverCreateRequestScreenState();
}

class _ReceiverCreateRequestScreenState extends State<ReceiverCreateRequestScreen> {
  final _formKey = GlobalKey<FormState>();
  String _bloodType = 'A+';
  String _urgency = 'medium';
  final _hospitalNameController = TextEditingController();
  final _addressController = TextEditingController();
  final _patientNameController = TextEditingController();
  final _contactNumberController = TextEditingController();

  final List<String> _bloodTypes = [
    'A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'
  ];

  final Map<String, String> _urgencyLevels = {
    'low': 'Low',
    'medium': 'Medium',
    'high': 'High',
  };

  @override
  void initState() {
    super.initState();
    _loadReceiverData();
  }

  @override
  void dispose() {
    _hospitalNameController.dispose();
    _addressController.dispose();
    _patientNameController.dispose();
    _contactNumberController.dispose();
    super.dispose();
  }

  Future<void> _loadReceiverData() async {
    final receiverProvider = Provider.of<ReceiverProvider>(context, listen: false);
    if (receiverProvider.receiver != null) {
      setState(() {
        _hospitalNameController.text = receiverProvider.receiver!.hospitalName;
        _addressController.text = receiverProvider.receiver!.address;
      });
    }
  }

  Future<void> _createRequest() async {
    if (_formKey.currentState!.validate()) {
      final receiverProvider = Provider.of<ReceiverProvider>(context, listen: false);
      
      final request = DonationRequestModel(
        id: '',
        receiverId: '',
        bloodType: _bloodType,
        urgency: _urgency,
        status: 'pending',
        hospitalName: _hospitalNameController.text.trim(),
        address: _addressController.text.trim(),
        patientName: _patientNameController.text.trim(),
        contactNumber: _contactNumberController.text.trim(),
        createdAt: DateTime.now(),
      );
      
      final success = await receiverProvider.createDonationRequest(request);
      
      if (success && mounted) {
        _patientNameController.clear();
        _contactNumberController.clear();
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Donation request created successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final receiverProvider = Provider.of<ReceiverProvider>(context);

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Create Donation Request',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Blood Type Needed',
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
                    return 'Please select blood type';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              const Text(
                'Urgency Level',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _urgency,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                ),
                items: _urgencyLevels.entries.map((entry) {
                  return DropdownMenuItem<String>(
                    value: entry.key,
                    child: Text(entry.value),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    setState(() {
                      _urgency = newValue;
                    });
                  }
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select urgency level';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              const Text(
                'Hospital/Organization Name',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _hospitalNameController,
                decoration: const InputDecoration(
                  hintText: 'Enter hospital or organization name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter hospital name';
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
                  hintText: 'Enter address',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter address';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              const Text(
                'Patient Name',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _patientNameController,
                decoration: const InputDecoration(
                  hintText: 'Enter patient name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter patient name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              const Text(
                'Contact Number',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _contactNumberController,
                decoration: const InputDecoration(
                  hintText: 'Enter contact number',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter contact number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              if (receiverProvider.error != null)
                Container(
                  padding: const EdgeInsets.all(8),
                  color: Colors.red.shade100,
                  child: Text(
                    receiverProvider.error!,
                    style: TextStyle(color: Colors.red.shade800),
                  ),
                ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: receiverProvider.isLoading ? null : _createRequest,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                ),
                child: receiverProvider.isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Create Request'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

