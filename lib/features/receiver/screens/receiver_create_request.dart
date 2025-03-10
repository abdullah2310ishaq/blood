import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/request.dart';
import '../../../core/constants/colors.dart';

class ReceiverCreateRequestScreen extends StatefulWidget {
  const ReceiverCreateRequestScreen({super.key});

  @override
  _ReceiverCreateRequestScreenState createState() =>
      _ReceiverCreateRequestScreenState();
}

class _ReceiverCreateRequestScreenState
    extends State<ReceiverCreateRequestScreen> {
  final _formKey = GlobalKey<FormState>();

  String bloodGroup = "A+"; // Default selection
  int units = 1;
  String location = "";
  bool isLoading = false;

  void _submitRequest() async {
    if (_formKey.currentState!.validate()) {
      setState(() => isLoading = true);

      await Provider.of<RequestProvider>(context, listen: false).createRequest(
        bloodGroup: bloodGroup,
        units: units,
        location: location,
      );

      setState(() => isLoading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Blood Request Created Successfully!")),
      );

      Navigator.pop(context); // Return to previous screen
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Create Blood Request"),
        backgroundColor: primaryColor,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    // ✅ Blood Group Dropdown
                    const Text("Select Blood Group"),
                    DropdownButtonFormField<String>(
                      value: bloodGroup,
                      items: ["A+", "A-", "B+", "B-", "O+", "O-", "AB+", "AB-"]
                          .map((group) => DropdownMenuItem(
                                value: group,
                                child: Text(group),
                              ))
                          .toList(),
                      onChanged: (value) => setState(() => bloodGroup = value!),
                    ),
                    const SizedBox(height: 16),

                    // ✅ Number of Units Input
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: "Number of Units",
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (val) => units = int.tryParse(val) ?? 1,
                      validator: (val) =>
                          val!.isEmpty || int.tryParse(val)! <= 0
                              ? "Enter valid units"
                              : null,
                    ),
                    const SizedBox(height: 16),

                    // ✅ Location Input
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: "Location (Hospital/City)",
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (val) => location = val,
                      validator: (val) =>
                          val!.isEmpty ? "Enter a location" : null,
                    ),
                    const SizedBox(height: 24),

                    // ✅ Submit Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: _submitRequest,
                        child: const Text(
                          "Create Request",
                          style: TextStyle(fontSize: 18, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
