import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/services.dart';

class DetailedDonorPage extends StatefulWidget {
  final String name;
  final String age;
  final String bloodGroup;
  final String location;
  final String contact;
  final String? profilePic;
  final bool isAvailable;
  final String lastDonationDate;
  final String notes;

  const DetailedDonorPage({
    super.key,
    required this.name,
    required this.age,
    required this.bloodGroup,
    required this.location,
    required this.contact,
    this.profilePic,
    required this.isAvailable,
    required this.lastDonationDate,
    required this.notes,
  });

  @override
  State<DetailedDonorPage> createState() => _DetailedDonorPageState();
}

class _DetailedDonorPageState extends State<DetailedDonorPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeInAnimation;
  late Animation<Offset> _slideAnimation;
  bool _showContactOptions = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeInAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // ✅ Call Donor
  Future<void> callDonor(String phoneNumber) async {
    HapticFeedback.mediumImpact();
    // Check & Request Call Permission
    PermissionStatus status = await Permission.phone.request();
    if (status.isGranted) {
      final Uri launchUri = Uri(scheme: 'tel', path: phoneNumber);
      if (await canLaunchUrl(launchUri)) {
        await launchUrl(launchUri);
      } else {
        _showErrorSnackBar("Could not launch phone dialer");
      }
    } else {
      _showErrorSnackBar("Call permission denied");
    }
  }

  // ✅ WhatsApp Chat
  Future<void> chatOnWhatsApp(String phoneNumber, String donorName) async {
    HapticFeedback.mediumImpact();
    // Format number (remove +, spaces, or dashes)
    phoneNumber = phoneNumber.replaceAll(RegExp(r'[^\d]'), '');

    String message =
        "Hello $donorName, I found you on the Blood Donation app. Are you available for donation?";
    final Uri whatsappUrl = Uri.parse(
      "https://wa.me/$phoneNumber?text=${Uri.encodeComponent(message)}",
    );

    if (await canLaunchUrl(whatsappUrl)) {
      await launchUrl(whatsappUrl);
    } else {
      _showErrorSnackBar("Could not open WhatsApp");
    }
  }

  // ✅ Share Donor Info
  void _shareDonorInfo() async {
    HapticFeedback.mediumImpact();
    final String shareMessage = "Donor Details:\n"
        "Name: ${widget.name}\n"
        "Age: ${widget.age}\n"
        "Blood Group: ${widget.bloodGroup}\n"
        "Location: ${widget.location}\n"
        "Contact: ${widget.contact}\n"
        "Last Donation: ${(widget.lastDonationDate.isNotEmpty && widget.lastDonationDate != 'N/A') ? widget.lastDonationDate.split(' ')[0] : 'N/A'}\n"
        "Availability: ${widget.isAvailable ? 'Available' : 'Not Available'}";

    final Uri shareUrl =
        Uri.parse("https://wa.me/?text=${Uri.encodeComponent(shareMessage)}");
    if (await canLaunchUrl(shareUrl)) {
      await launchUrl(shareUrl);
    } else {
      _showErrorSnackBar("Could not open WhatsApp for sharing");
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red[700],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(10),
      ),
    );
  }

  void _toggleContactOptions() {
    setState(() {
      _showContactOptions = !_showContactOptions;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.8),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(Icons.arrow_back, color: Colors.redAccent),
          ),
        ),
        actions: [
          GestureDetector(
            onTap: _shareDonorInfo,
            child: Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.8),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Padding(
                padding: EdgeInsets.all(8.0),
                child: Icon(Icons.share, color: Colors.redAccent),
              ),
            ),
          ),
        ],
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color(0xFFEF5350).withOpacity(0.8), // Vibrant red at top
              const Color(0xFFFFCDD2).withOpacity(0.9), // Lighter red/pink
              Colors.white, // White at bottom
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: const [0.0, 0.3, 0.7],
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeInAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  children: [
                    const SizedBox(height: 20),

                    // ✅ Profile Image with Blood Group Badge
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        // Shadow effect
                        Container(
                          width: 130,
                          height: 130,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 20,
                                spreadRadius: 5,
                              ),
                            ],
                          ),
                        ),
                        // Profile image
                        Hero(
                          tag: 'donor-${widget.name}',
                          child: Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 4),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 8,
                                  spreadRadius: 2,
                                ),
                              ],
                              image: (widget.profilePic?.isNotEmpty ?? false)
                                  ? DecorationImage(
                                      image: NetworkImage(widget.profilePic!),
                                      fit: BoxFit.cover,
                                    )
                                  : null,
                            ),
                            child: (widget.profilePic == null ||
                                    widget.profilePic!.isEmpty)
                                ? const Icon(Icons.person,
                                    size: 60, color: Colors.grey)
                                : null,
                          ),
                        ),
                        // Blood group badge
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Text(
                              widget.bloodGroup,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // ✅ Name & Age
                    Text(
                      widget.name,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    Text(
                      "${widget.age} years",
                      style: const TextStyle(
                        fontSize: 18,
                        color: Colors.black54,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 16),

                    // ✅ Availability Status
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 40),
                      padding: const EdgeInsets.symmetric(
                          vertical: 8, horizontal: 16),
                      decoration: BoxDecoration(
                        color: widget.isAvailable
                            ? Colors.green.shade50
                            : Colors.red.shade50,
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(
                          color: widget.isAvailable ? Colors.green : Colors.red,
                          width: 1.5,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            widget.isAvailable
                                ? Icons.check_circle
                                : Icons.cancel,
                            color:
                                widget.isAvailable ? Colors.green : Colors.red,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            widget.isAvailable
                                ? "Available for Donation"
                                : "Not Available",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: widget.isAvailable
                                  ? Colors.green.shade700
                                  : Colors.red.shade700,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 30),

                    // ✅ Information Card
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            spreadRadius: 5,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Donor Information",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            const Divider(height: 30),
                            InfoRow(
                              icon: Icons.location_on,
                              iconColor: Colors.redAccent,
                              label: "Location",
                              value: widget.location,
                            ),
                            if (widget.lastDonationDate.isNotEmpty &&
                                widget.lastDonationDate != "N/A")
                              InfoRow(
                                icon: Icons.calendar_today,
                                iconColor: Colors.blue,
                                label: "Last Donation",
                                value: widget.lastDonationDate.split(' ')[0],
                              ),
                            InfoRow(
                              icon: Icons.phone,
                              iconColor: Colors.green,
                              label: "Contact",
                              value: widget.contact,
                            ),
                            if (widget.notes.isNotEmpty)
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 16),
                                  Row(
                                    children: [
                                      Icon(Icons.note,
                                          color: Colors.amber[700]),
                                      const SizedBox(width: 10),
                                      const Text(
                                        "Notes:",
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black87,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.amber[50],
                                      borderRadius: BorderRadius.circular(10),
                                      border:
                                          Border.all(color: Colors.amber[100]!),
                                    ),
                                    child: Text(
                                      widget.notes,
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontStyle: FontStyle.italic,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 30),

                    // ✅ Contact Buttons
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        children: [
                          // Main contact button
                          GestureDetector(
                            onTap: _toggleContactOptions,
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.red.shade700,
                                    Colors.red.shade500
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(15),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.red.withOpacity(0.3),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.contact_phone,
                                    color: Colors.white,
                                    size: 24,
                                  ),
                                  const SizedBox(width: 10),
                                  const Text(
                                    "Contact Donor",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Icon(
                                    _showContactOptions
                                        ? Icons.keyboard_arrow_up
                                        : Icons.keyboard_arrow_down,
                                    color: Colors.white,
                                  ),
                                ],
                              ),
                            ),
                          ),

                          // Expandable contact options
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            height: _showContactOptions ? 140 : 0,
                            curve: Curves.easeInOut,
                            child: SingleChildScrollView(
                              physics: const NeverScrollableScrollPhysics(),
                              child: Column(
                                children: [
                                  const SizedBox(height: 10),
                                  // Call button
                                  ContactButton(
                                    icon: Icons.phone,
                                    label: "Call Now",
                                    color: Colors.green.shade600,
                                    onTap: () => callDonor(widget.contact),
                                  ),

                                  const SizedBox(height: 10),

                                  // WhatsApp button
                                  ContactButton(
                                    icon: Icons.message,
                                    label: "WhatsApp",
                                    color: const Color(
                                        0xFF25D366), // WhatsApp green
                                    onTap: () => chatOnWhatsApp(
                                        widget.contact, widget.name),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ✅ Enhanced Info Row Widget
class InfoRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;

  const InfoRow({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ✅ Contact Button Widget
class ContactButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const ContactButton({
    super.key,
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(width: 10),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
