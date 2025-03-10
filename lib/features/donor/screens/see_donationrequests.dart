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
    await Provider.of<RequestProvider>(context, listen: false).fetchActiveRequests();
    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final requestProvider = Provider.of<RequestProvider>(context);
    final requests = requestProvider.requests;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Blood Requests"),
        backgroundColor: primaryColor,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : requests.isEmpty
              ? const Center(
                  child: Text("No pending blood requests."),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: requests.length,
                  itemBuilder: (context, index) {
                    final request = requests[index];

                    return Card(
                      elevation: 3,
                      margin: const EdgeInsets.only(bottom: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(12),
                        title: Text(
                          "Blood Group: ${request['bloodGroup']}",
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Text(
                          "Units: ${request['units']}\nLocation: ${request['location']}",
                          style: const TextStyle(fontSize: 16),
                        ),
                        trailing: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            foregroundColor: Colors.white,
                          ),
                          onPressed: () {
                            _acceptRequest(request['id']);
                          },
                          child: const Text("Accept"),
                        ),
                      ),
                    );
                  },
                ),
    );
  }

  // ✅ Accept Request Function
  void _acceptRequest(String requestId) async {
    await Provider.of<RequestProvider>(context, listen: false)
        .acceptRequest(requestId);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("You accepted this request.")),
    );
  }
}
