import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bloood_donation_app/core/providers/auth_provider.dart';
import 'package:bloood_donation_app/core/providers/receiver_provider.dart';
import 'package:bloood_donation_app/core/models/receiver_model.dart';
import 'package:bloood_donation_app/features/receiver/screens/reciever_homescreen.dart';

class ReceiverEditProfileScreen extends StatefulWidget {
  const ReceiverEditProfileScreen({super.key});

  @override
  State<ReceiverEditProfileScreen> createState() => _ReceiverEditProfileScreenState();
}

class _ReceiverEditProfileScreenState extends State<ReceiverEditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _hospitalNameController = TextEditingController();
  final _addressController = TextEditingController();
  final _contactPersonController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadReceiverData();
  }

  @override
  void dispose() {
    _hospitalNameController.dispose();
    _addressController.dispose();
    _contactPersonController.dispose();
    super.dispose();
  }

  Future<void> _loadReceiverData() async {
    final receiverProvider = Provider.of<ReceiverProvider>(context, listen: false);
    if (receiverProvider.receiver != null) {
      setState(() {
        _hospitalNameController.text = receiverProvider.receiver!.hospitalName;
        _addressController.text = receiverProvider.receiver!.address;
        _contactPersonController.text = receiverProvider.receiver!.contactPerson;
      });
    }
  }

  Future<void> _saveReceiverProfile() async {
    if (_formKey.currentState!.validate()) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final receiverProvider = Provider.of<ReceiverProvider>(context, listen: false);
      
      final receiver = ReceiverModel(
        id: receiverProvider.receiver?.id ?? '',
        userId: authProvider.user!.id,
        hospitalName: _hospitalNameController.text.trim(),
        address: _addressController.text.trim(),
        contactPerson: _contactPersonController.text.trim(),
      );
      
      final success = await receiverProvider.createOrUpdateReceiverProfile(receiver);
      
      if (success && mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const ReceiverHomeScreen()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final receiverProvider = Provider.of<ReceiverProvider>(context);
    final isEditing = receiverProvider.receiver != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Profile' : 'Create Profile'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
                'Contact Person',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _contactPersonController,
                decoration: const InputDecoration(
                  hintText: 'Enter contact person name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter contact person';
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
                onPressed: receiverProvider.isLoading ? null : _saveReceiverProfile,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                ),
                child: receiverProvider.isLoading
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

