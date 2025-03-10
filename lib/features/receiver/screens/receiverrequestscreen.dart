import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/providers/request.dart';
import 'receiver_create_request.dart';

class ReceiverRequestsScreen extends StatefulWidget {
  const ReceiverRequestsScreen({super.key});

  @override
  _ReceiverRequestsScreenState createState() => _ReceiverRequestsScreenState();
}

class _ReceiverRequestsScreenState extends State<ReceiverRequestsScreen> {
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRequests();
  }

  Future<void> _loadRequests() async {
    try {
      await Provider.of<RequestProvider>(context, listen: false).fetchMyRequests();
    } catch (e) {
      debugPrint("Error fetching requests: $e");
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final requestProvider = Provider.of<RequestProvider>(context);
    final requests = requestProvider.requests;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Your Blood Requests"),
        backgroundColor: Colors.red,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : requests.isEmpty
              ? const Center(
                  child: Text("No blood requests found."),
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
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            _deleteRequest(request['id']);
                          },
                        ),
                      ),
                    );
                  },
                ),

      // ✅ Floating Button to Create a New Request
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.red,
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => const ReceiverCreateRequestScreen()),
          );
        },
      ),
    );
  }

  // ✅ Delete Request Function
  void _deleteRequest(String requestId) async {
    await Provider.of<RequestProvider>(context, listen: false).deleteRequest(requestId);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Request deleted.")),
    );
  }
}
