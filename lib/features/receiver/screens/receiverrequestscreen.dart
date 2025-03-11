import 'package:bloood_donation_app/core/widgets/customappbar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:lottie/lottie.dart';
import '../../../core/constants/colors.dart';
import '../../../core/providers/request.dart';
import 'receiver_create_request.dart';

class ReceiverRequestsScreen extends StatefulWidget {
  const ReceiverRequestsScreen({Key? key}) : super(key: key);

  @override
  _ReceiverRequestsScreenState createState() => _ReceiverRequestsScreenState();
}

class _ReceiverRequestsScreenState extends State<ReceiverRequestsScreen>
    with TickerProviderStateMixin {
  bool isLoading = true;
  late AnimationController _lottieController;

  @override
  void initState() {
    super.initState();
    _lottieController = AnimationController(vsync: this);
    _loadRequests();
  }

  @override
  void dispose() {
    _lottieController.dispose();
    super.dispose();
  }

  Future<void> _loadRequests() async {
    try {
      await Provider.of<RequestProvider>(context, listen: false)
          .fetchMyRequests();
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
      backgroundColor: backgroundColor,
      appBar: CustomAppBar(),
      body: isLoading
          ? Center(
              child: Lottie.network(
                'https://assets3.lottiefiles.com/packages/lf20_UJNc2t.json',
                controller: _lottieController,
                onLoaded: (composition) {
                  _lottieController
                    ..duration = composition.duration
                    ..repeat();
                },
              ),
            )
          : requests.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Lottie.network(
                        'https://assets3.lottiefiles.com/packages/lf20_mbrocy0r.json',
                        width: 200,
                        height: 200,
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        "No blood requests found.",
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: requests.length,
                  itemBuilder: (context, index) {
                    final request = requests[index];

                    // ✅ Fix: Assign default values to avoid null errors
                    final String bloodGroup = request['bloodGroup'] ?? "N/A";
                    final int units = request['units'] ?? 0;
                    final String location = request['location'] ?? "Unknown";
                    final String status = request['status'] ?? "Pending";

                    return Slidable(
                      endActionPane: ActionPane(
                        motion: const ScrollMotion(),
                        children: [
                          SlidableAction(
                            onPressed: (context) =>
                                _deleteRequest(request['id']),
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                            icon: Icons.delete,
                            label: 'Delete',
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ],
                      ),
                      child: Card(
                        elevation: 5,
                        margin: const EdgeInsets.only(bottom: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: const BorderSide(color: Colors.black, width: 1),
                        ),
                        child: ExpansionTile(
                          leading: CircleAvatar(
                            backgroundColor: primaryColor,
                            child: Text(
                              bloodGroup,
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          title: Text(
                            "Blood Group: $bloodGroup",
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            "Units: $units",
                            style: const TextStyle(fontSize: 16),
                          ),
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("Location: $location",
                                      style: const TextStyle(fontSize: 16)),
                                  const SizedBox(height: 8),
                                  Text("Status: $status",
                                      style: const TextStyle(fontSize: 16)),
                                  const SizedBox(height: 8),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => const ReceiverCreateRequestScreen()),
          );
        },
        backgroundColor: primaryColor,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text("New Request", style: TextStyle(color: Colors.white)),
      ),
    );
  }

  void _deleteRequest(String requestId) async {
    await Provider.of<RequestProvider>(context, listen: false)
        .deleteRequest(requestId);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text("Request deleted."),
        backgroundColor: primaryColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}
