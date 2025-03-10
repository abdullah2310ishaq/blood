import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/colors.dart';
import '../../../core/providers/request.dart';
import '../widgets/request_card.dart';

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
      appBar: AppBar(
        title: const Text("Find Donors"),
        backgroundColor: primaryColor,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // ✅ Search Form
            Form(
              key: _formKey,
              child: Column(
                children: [
                  // ✅ Blood Group Dropdown
                  const Text("Select Blood Group"),
                  DropdownButtonFormField<String>(
                    value: selectedBloodGroup,
                    items: ["A+", "A-", "B+", "B-", "O+", "O-", "AB+", "AB-"]
                        .map((group) => DropdownMenuItem(
                              value: group,
                              child: Text(group),
                            ))
                        .toList(),
                    onChanged: (value) =>
                        setState(() => selectedBloodGroup = value!),
                  ),
                  const SizedBox(height: 16),

                  // ✅ City Input Field
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: "City",
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (val) => selectedCity = val,
                    validator: (val) =>
                        val!.isEmpty ? "Enter a city to search" : null,
                  ),
                  const SizedBox(height: 20),

                  // ✅ Search Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
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

            // ✅ Search Loading Indicator
            if (isSearching) const Center(child: CircularProgressIndicator()),

            // ✅ Show Donor Results
            if (donors.isEmpty && !isSearching)
              const Center(
                child: Text("No donors found."),
              ),

            if (donors.isNotEmpty)
              Column(
                children: donors.map((donor) {
                  return DonorCard(
                    name: donor["name"],
                    age: donor["age"] ?? "N/A", // Age from DB
                    bloodGroup: donor["bloodGroup"],
                    location: donor["city"],
                    distance: donor["distance"] ?? "N/A", // Distance if available
                    contact: donor["contact"],
                    timeLimit: donor["availabilityTime"] ?? "N/A",
                    profilePic: donor["profilePic"] ?? "",
                  );
                }).toList(),
              ),
          ],
        ),
      ),
    );
  }
}
