import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bloood_donation_app/core/providers/donor_provider.dart';
import 'package:bloood_donation_app/core/models/donation_request_model.dart';

class SeeDonationRequestsScreen extends StatefulWidget {
  const SeeDonationRequestsScreen({super.key});

  @override
  State<SeeDonationRequestsScreen> createState() => _SeeDonationRequestsScreenState();
}

class _SeeDonationRequestsScreenState extends State<SeeDonationRequestsScreen> {
  @override
  void initState() {
    super.initState();
    _fetchRequests();
  }

  Future<void> _fetchRequests() async {
    final donorProvider = Provider.of<DonorProvider>(context, listen: false);
    await donorProvider.fetchAvailableRequests();
  }

  @override
  Widget build(BuildContext context) {
    final donorProvider = Provider.of<DonorProvider>(context);

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _fetchRequests,
        child: donorProvider.isLoading
            ? const Center(child: CircularProgressIndicator())
            : donorProvider.availableRequests.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.search_off,
                          size: 64,
                          color: Colors.grey,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'No donation requests found',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextButton(
                          onPressed: _fetchRequests,
                          child: const Text('Refresh'),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: donorProvider.availableRequests.length,
                    itemBuilder: (context, index) {
                      final request = donorProvider.availableRequests[index];
                      return _buildRequestCard(request);
                    },
                  ),
      ),
    );
  }

  Widget _buildRequestCard(DonationRequestModel request) {
    final donorProvider = Provider.of<DonorProvider>(context, listen: false);
    
    Color urgencyColor;
    switch (request.urgency) {
      case 'high':
        urgencyColor = Colors.red;
        break;
      case 'medium':
        urgencyColor = Colors.orange;
        break;
      default:
        urgencyColor = Colors.green;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: urgencyColor,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    '${request.urgency.toUpperCase()} URGENCY',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    request.bloodType,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              request.hospitalName,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Patient: ${request.patientName}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 4),
            Text(
              'Address: ${request.address}',
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Contact: ${request.contactNumber}',
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Posted: ${_formatDate(request.createdAt)}',
              style: const TextStyle(
                fontSize: 12,
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Confirm Donation'),
                    content: const Text(
                      'Are you sure you want to accept this donation request? The hospital will be notified and will contact you.',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        child: const Text('Cancel'),
                      ),
                      ElevatedButton(
                        onPressed: () => Navigator.of(context).pop(true),
                        child: const Text('Accept'),
                      ),
                    ],
                  ),
                );

                if (confirmed == true) {
                  await donorProvider.acceptDonationRequest(request.id);
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Donation request accepted!'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(40),
              ),
              child: const Text('Accept Request'),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

