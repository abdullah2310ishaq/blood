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
      backgroundColor: primaryColor,
      appBar: AppBar(
        title: const Text("Find Donors"),
        backgroundColor: secondaryColor,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Column(
          children: [
            // ✅ Search Form
            Form(
              key: _formKey,
              child: Column(
                children: [
                  // Blood Group
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Select Blood Group",
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                  DropdownButtonFormField<String>(
                    value: selectedBloodGroup,
                    dropdownColor: secondaryColor,
                    items: ["A+", "A-", "B+", "B-", "O+", "O-", "AB+", "AB-"]
                        .map((group) => DropdownMenuItem(
                              value: group,
                              child: Text(
                                group,
                                style: const TextStyle(color: Colors.white),
                              ),
                            ))
                        .toList(),
                    onChanged: (value) =>
                        setState(() => selectedBloodGroup = value!),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: secondaryColor.withOpacity(0.8),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // City Input
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Enter City",
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                  TextFormField(
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: secondaryColor.withOpacity(0.8),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                      hintText: "City",
                      hintStyle: const TextStyle(color: Colors.white70),
                    ),
                    style: const TextStyle(color: Colors.white),
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
                        backgroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: _searchDonors,
                      child: Text(
                        "Search Donors",
                        style: TextStyle(fontSize: 18, color: primaryColor),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Loading
            if (isSearching) const Center(child: CircularProgressIndicator()),

            // No donors found
            if (donors.isEmpty && !isSearching)
              const Center(
                child: Padding(
                  padding: EdgeInsets.only(top: 20),
                  child: Text(
                    "No donors found.",
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                ),
              ),

            // Show Donor Cards
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
}
