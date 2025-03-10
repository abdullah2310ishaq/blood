import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/services.dart';

class DonorCard extends StatefulWidget {
  final String name;
  final String age;
  final String bloodGroup;
  final String location;
  final String contact;
  final String lastDonationDate;
  final bool isAvailable;
  final String profilePic;

  const DonorCard({
    super.key,
    required this.name,
    required this.age,
    required this.bloodGroup,
    required this.location,
    required this.contact,
    required this.lastDonationDate,
    required this.isAvailable,
    required this.profilePic,
  });

  @override
  _DonorCardState createState() => _DonorCardState();
}

class _DonorCardState extends State<DonorCard> {
  bool _isCopied = false;

  void _makePhoneCall() async {
    final Uri launchUri = Uri(scheme: 'tel', path: widget.contact);
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("❌ Could not launch phone dialer.")),
      );
    }
  }

  void _copyContact() {
    Clipboard.setData(ClipboardData(text: widget.contact));
    setState(() => _isCopied = true);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("📋 Phone number copied to clipboard!")),
    );
    Future.delayed(const Duration(seconds: 2), () {
      setState(() => _isCopied = false);
    });
  }

  void _shareDonorInfo() async {
    String message = "🩸 Donor Information:\n"
        "👤 Name: ${widget.name}\n"
        "🎂 Age: ${widget.age}\n"
        "💉 Blood Group: ${widget.bloodGroup}\n"
        "📍 Location: ${widget.location}\n"
        "📞 Contact: ${widget.contact}\n"
        "⏳ Last Donation: ${widget.lastDonationDate.isNotEmpty ? widget.lastDonationDate.split(' ')[0] : 'Not available'}";

    final Uri whatsappUrl = Uri.parse("https://wa.me/?text=${Uri.encodeComponent(message)}");

    if (await canLaunchUrl(whatsappUrl)) {
      await launchUrl(whatsappUrl);
    } else {
      debugPrint("❌ Could not open WhatsApp.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ✅ Blood Group & Donor Details
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // ✅ Blood Group (Left Side)
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.red[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.center,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      widget.bloodGroup,
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.red),
                    ),
                    const SizedBox(height: 4),
                    const Icon(Icons.bloodtype, color: Colors.red, size: 24),
                  ],
                ),
              ),
              const SizedBox(width: 16),

              // ✅ Donor Name & Location
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "${widget.name}, ${widget.age} yrs",
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.location_on, size: 16, color: Colors.grey),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(widget.location, style: const TextStyle(fontSize: 14, color: Colors.grey), overflow: TextOverflow.ellipsis),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // ✅ Call Button
              IconButton(
                icon: const Icon(Icons.phone, color: Colors.green, size: 28),
                onPressed: _makePhoneCall,
              ),
            ],
          ),

          const SizedBox(height: 12),

          // ✅ Availability Status
          Row(
            children: [
              Icon(widget.isAvailable ? Icons.check_circle : Icons.cancel, size: 18, color: widget.isAvailable ? Colors.green : Colors.red),
              const SizedBox(width: 6),
              Text(
                widget.isAvailable ? "✅ Available for Donation" : "❌ Not Available",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: widget.isAvailable ? Colors.green : Colors.red),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // ✅ Last Donation Date (Only Date, No Time)
          Row(
            children: [
              const Icon(Icons.history, size: 18, color: Colors.orange),
              const SizedBox(width: 6),
              Text(
                widget.lastDonationDate.isNotEmpty
                    ? "Last Donation: ${widget.lastDonationDate.split(' ')[0]}"
                    : "No record",
                style: const TextStyle(fontSize: 16),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // ✅ Copy & Share Buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // ✅ Copy Number Button
              Expanded(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.black, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 12)),
                  onPressed: _copyContact,
                  icon: Icon(_isCopied ? Icons.check_circle : Icons.copy, size: 18),
                  label: Text(_isCopied ? "Copied" : "Copy"),
                ),
              ),
              const SizedBox(width: 10),

              // ✅ Share Button
              Expanded(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 12)),
                  onPressed: _shareDonorInfo,
                  icon: const Icon(Icons.share, size: 18),
                  label: const Text("Share"),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
