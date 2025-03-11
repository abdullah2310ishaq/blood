import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/constants/colors.dart';
import '../../../core/services/auth_service.dart';

class DonorFormScreen extends StatefulWidget {
  const DonorFormScreen({super.key});

  @override
  _DonorFormScreenState createState() => _DonorFormScreenState();
}

class _DonorFormScreenState extends State<DonorFormScreen> {
  final _formKey = GlobalKey<FormState>();

  String bloodGroup = "A+";
  String gender = "Male";
  String city = "";
  int age = 18;
  DateTime? lastDonationDate;
  bool isAvailable = true;
  String additionalNotes = "";

  final AuthService _authService = AuthService();

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      String uid = _authService.getCurrentUser()?.uid ?? "";
      if (uid.isEmpty) return;

      try {
        await FirebaseFirestore.instance.collection('donors').doc(uid).set({
          "bloodGroup": bloodGroup,
          "age": age,
          "gender": gender,
          "city": city,
          "lastDonationDate": lastDonationDate != null
              ? lastDonationDate!.toIso8601String()
              : "",
          "isAvailable": isAvailable,
          "additionalNotes": additionalNotes,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text("Donation details saved successfully!"),
            backgroundColor: primaryColor,
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error: ${e.toString()}"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor, // ✅ Soft creamy white background

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ✅ Blood Group Dropdown
              const Text("Blood Group",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              DropdownButtonFormField<String>(
                value: bloodGroup,
                items: ["A+", "A-", "B+", "B-", "O+", "O-", "AB+", "AB-"]
                    .map((group) => DropdownMenuItem(
                          value: group,
                          child: Text(group),
                        ))
                    .toList(),
                onChanged: (value) => setState(() => bloodGroup = value!),
                decoration: _inputDecoration(),
              ),
              const SizedBox(height: 16),

              // ✅ Age Input
              const Text("Age",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              TextFormField(
                keyboardType: TextInputType.number,
                decoration: _inputDecoration(hintText: "Enter your age"),
                onChanged: (val) => age = int.tryParse(val) ?? 18,
                validator: (val) => (val!.isEmpty ||
                        int.tryParse(val) == null ||
                        int.parse(val) < 18)
                    ? "Enter a valid age (18+)"
                    : null,
              ),
              const SizedBox(height: 16),

              // ✅ Gender Selection
              const Text("Gender",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              Row(
                children: [
                  Radio(
                    value: "Male",
                    groupValue: gender,
                    onChanged: (value) => setState(() => gender = value!),
                  ),
                  const Text("Male"),
                  Radio(
                    value: "Female",
                    groupValue: gender,
                    onChanged: (value) => setState(() => gender = value!),
                  ),
                  const Text("Female"),
                ],
              ),
              const SizedBox(height: 16),

              // ✅ City Input
              const Text("City",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              TextFormField(
                decoration: _inputDecoration(hintText: "Enter your city"),
                onChanged: (val) => city = val,
                validator: (val) =>
                    val!.isEmpty ? "Please enter your city" : null,
              ),
              const SizedBox(height: 16),

              // ✅ Last Donation Date Picker
              const Text("Last Donation Date",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              GestureDetector(
                onTap: () async {
                  DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime.now(),
                  );
                  if (pickedDate != null) {
                    setState(() => lastDonationDate = pickedDate);
                  }
                },
                child: Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Text(
                    lastDonationDate == null
                        ? "Select Date"
                        : "${lastDonationDate!.day}/${lastDonationDate!.month}/${lastDonationDate!.year}",
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // ✅ Availability Toggle
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Available to Donate?",
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  Switch(
                    value: isAvailable,
                    activeColor: primaryColor,
                    onChanged: (value) => setState(() => isAvailable = value),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // ✅ Additional Notes
              const Text("Additional Notes (Optional)",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              TextFormField(
                maxLines: 3,
                decoration:
                    _inputDecoration(hintText: "Enter any extra details..."),
                onChanged: (val) => additionalNotes = val,
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
                  onPressed: _submitForm,
                  child: const Text(
                    "Submit",
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

  // ✅ Input Field Decoration
  InputDecoration _inputDecoration({String? hintText}) {
    return InputDecoration(
      hintText: hintText,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey.shade400),
      ),
    );
  }
}
