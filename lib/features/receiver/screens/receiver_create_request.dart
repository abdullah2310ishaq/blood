import 'package:bloood_donation_app/core/widgets/customappbar.dart';
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

  String bloodGroup = "A+";
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
        SnackBar(
          content: const Text("Blood Request Created Successfully!"),
          backgroundColor: primaryColor,
        ),
      );

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor, // ✅ Soft Creamy White Background
      appBar: CustomAppBar(),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ✅ Title
                    const Center(
                      child: Text(
                        "Fill in the details to request blood",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // ✅ Blood Group Dropdown
                    _buildDropdownField(
                      label: "Select Blood Group",
                      value: bloodGroup,
                      items: ["A+", "A-", "B+", "B-", "O+", "O-", "AB+", "AB-"],
                      onChanged: (value) => setState(() => bloodGroup = value!),
                    ),
                    const SizedBox(height: 20),

                    // ✅ Number of Units Input
                    _buildTextField(
                      label: "Number of Units",
                      hintText: "Enter required units",
                      keyboardType: TextInputType.number,
                      onChanged: (val) => units = int.tryParse(val) ?? 1,
                      validator: (val) =>
                          val!.isEmpty || int.tryParse(val)! <= 0
                              ? "Enter valid units"
                              : null,
                    ),
                    const SizedBox(height: 20),

                    // ✅ Location Input
                    _buildTextField(
                      label: "Location",
                      hintText: "Enter Hospital or City",
                      onChanged: (val) => location = val,
                      validator: (val) =>
                          val!.isEmpty ? "Enter a location" : null,
                    ),
                    const SizedBox(height: 30),

                    // ✅ Submit Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 3,
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

  // ✅ Reusable Dropdown Field
  Widget _buildDropdownField({
    required String label,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.black, width: 1.5),
            borderRadius: BorderRadius.circular(10),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: DropdownButtonFormField<String>(
            value: value,
            decoration: const InputDecoration(border: InputBorder.none),
            items: items
                .map((group) => DropdownMenuItem(
                      value: group,
                      child: Text(group),
                    ))
                .toList(),
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }

  // ✅ Reusable Text Field
  Widget _buildTextField({
    required String label,
    required String hintText,
    required ValueChanged<String> onChanged,
    required String? Function(String?) validator,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 6),
        TextFormField(
          decoration: InputDecoration(
            hintText: hintText,
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Colors.black, width: 1.5),
            ),
          ),
          keyboardType: keyboardType,
          onChanged: onChanged,
          validator: validator,
        ),
      ],
    );
  }
}
