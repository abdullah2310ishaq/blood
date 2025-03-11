import 'package:bloood_donation_app/core/widgets/customappbar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/colors.dart';
import '../../../core/providers/request.dart';
import '../widgets/request_card.dart';
import 'detailed_donor.dart';

class ReceiverFindDonorsScreen extends StatefulWidget {
  const ReceiverFindDonorsScreen({super.key});

  @override
  _ReceiverFindDonorsScreenState createState() =>
      _ReceiverFindDonorsScreenState();
}

class _ReceiverFindDonorsScreenState extends State<ReceiverFindDonorsScreen> {
  final _formKey = GlobalKey<FormState>();
  String selectedBloodGroup = "A+";
  String selectedCity = "";
  bool isSearching = false;

  void _searchDonors() async {
    if (_formKey.currentState!.validate()) {
      setState(() => isSearching = true);
      try {
        await Provider.of<RequestProvider>(context, listen: false)
            .findDonors(selectedBloodGroup, selectedCity);
      } catch (e) {
        debugPrint("Error finding donors: $e");
      } finally {
        setState(() => isSearching = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final requestProvider = Provider.of<RequestProvider>(context);
    final donors = requestProvider.donors;

    return Scaffold(
      backgroundColor: backgroundColor, // ✅ Soft Creamy White
      appBar: CustomAppBar(),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // ✅ Search Form
            Form(
              key: _formKey,
              child: Column(
                children: [
                  // Blood Group Selection
                  _buildDropdownField(
                    label: "Select Blood Group",
                    value: selectedBloodGroup,
                    items: ["A+", "A-", "B+", "B-", "O+", "O-", "AB+", "AB-"],
                    onChanged: (value) =>
                        setState(() => selectedBloodGroup = value!),
                  ),
                  const SizedBox(height: 16),

                  // City Input
                  _buildTextField(
                    label: "Enter City",
                    hintText: "City name",
                    onChanged: (val) => selectedCity = val,
                    validator: (val) =>
                        val!.isEmpty ? "Enter a city to search" : null,
                  ),
                  const SizedBox(height: 20),

                  // Search Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 4,
                      ),
                      onPressed: _searchDonors,
                      child: const Text(
                        "Search Donors",
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // ✅ Loading Indicator
            if (isSearching) const Center(child: CircularProgressIndicator()),

            // ✅ No donors found
            if (donors.isEmpty && !isSearching)
              const Center(
                child: Padding(
                  padding: EdgeInsets.only(top: 20),
                  child: Text(
                    "No donors found.",
                    style: TextStyle(color: Colors.black87, fontSize: 18),
                  ),
                ),
              ),

            // ✅ Show Donor Cards
            if (donors.isNotEmpty)
              Expanded(
                child: ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  itemCount: donors.length,
                  itemBuilder: (context, index) {
                    final donor = donors[index];
                    final name = donor["name"] ?? "N/A";
                    final bloodGroup = donor["bloodGroup"] ?? "N/A";
                    final contact = donor["contact"] ?? "N/A";
                    final isAvailable = donor["isAvailable"] ?? false;
                    final lastDonation = donor["lastDonationDate"] ?? "N/A";

                    return DonorCard(
                      name: name,
                      bloodGroup: bloodGroup,
                      isAvailable: isAvailable,
                      contact: contact,
                      profilePic: donor["profilePic"] ?? "",
                      onViewDetails: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => DetailedDonorPage(
                              name: name,
                              age: (donor["age"]?.toString()) ?? "N/A",
                              bloodGroup: bloodGroup,
                              location: donor["city"] ?? "N/A",
                              contact: contact,
                              profilePic: donor["profilePic"],
                              isAvailable: isAvailable,
                              lastDonationDate: lastDonation,
                              notes: donor["additionalNotes"] ?? "",
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
          ],
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
