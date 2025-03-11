import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/colors.dart';
import '../../../core/providers/request.dart';

class DonorBloodRequestsScreen extends StatefulWidget {
  const DonorBloodRequestsScreen({super.key});

  @override
  _DonorBloodRequestsScreenState createState() =>
      _DonorBloodRequestsScreenState();
}

class _DonorBloodRequestsScreenState extends State<DonorBloodRequestsScreen> {
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRequests();
  }

  Future<void> _loadRequests() async {
    await Provider.of<RequestProvider>(context, listen: false)
        .fetchActiveRequests();

    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final requestProvider = Provider.of<RequestProvider>(context);
    final requests = requestProvider.requests;

    return Scaffold(
      backgroundColor: backgroundColor, // ✅ Updated background

      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : requests.isEmpty
              ? const Center(
                  child: Text("No pending blood requests.",
                      style: TextStyle(fontSize: 16)),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: requests.length,
                  itemBuilder: (context, index) {
                    final request = requests[index];

                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.white, // ✅ Card background
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.black, width: 1.5),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            spreadRadius: 2,
                            blurRadius: 5,
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // ✅ Blood Group
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Blood Group: ${request['bloodGroup']}",
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.info_outline,
                                      color: Colors.black54),
                                  tooltip: "View Requester Info",
                                  onPressed: () => _showRequesterInfo(request),
                                ),
                              ],
                            ),

                            const SizedBox(height: 5),

                            // ✅ Units & Location
                            Text(
                              "Units: ${request['units']}",
                              style: const TextStyle(
                                  fontSize: 16, color: Colors.black87),
                            ),
                            Text(
                              "Location: ${request['location']}",
                              style: const TextStyle(
                                  fontSize: 16, color: Colors.black87),
                            ),
                            const SizedBox(height: 14),

                            // ✅ Accept & Reject Buttons
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 24, vertical: 10),
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8)),
                                  ),
                                  onPressed: () =>
                                      _acceptRequest(request['id']),
                                  child: const Text("Accept",
                                      style: TextStyle(fontSize: 16)),
                                ),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 24, vertical: 10),
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8)),
                                  ),
                                  onPressed: () =>
                                      _rejectRequest(request['id']),
                                  child: const Text("Reject",
                                      style: TextStyle(fontSize: 16)),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }

  // ✅ Show Requester Info
  void _showRequesterInfo(Map<String, dynamic> request) async {
    final receiverId = request["receiverId"];
    final receiverData = await Provider.of<RequestProvider>(
      context,
      listen: false,
    ).fetchDonorDetails(receiverId);

    if (receiverData == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error fetching receiver info.")),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        backgroundColor: Colors.white,
        title: Text(receiverData["name"] ?? "Unknown"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Contact: ${receiverData["contact"]}"),
            Text("City: ${receiverData["city"]}"),
            Text("Blood Group: ${receiverData["bloodGroup"]}"),
            const SizedBox(height: 16),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Close", style: TextStyle(color: Colors.black)),
          ),
        ],
      ),
    );
  }

  // ✅ Reject Request
  void _rejectRequest(String requestId) async {
    await Provider.of<RequestProvider>(context, listen: false)
        .rejectRequest(requestId);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("You rejected this request.")),
    );
    _loadRequests();
  }

  // ✅ Accept Request
  void _acceptRequest(String requestId) async {
    await Provider.of<RequestProvider>(context, listen: false)
        .acceptRequest(requestId);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("You accepted this request.")),
    );
    _loadRequests();
  }
}
