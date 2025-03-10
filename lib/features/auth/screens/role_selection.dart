// import 'package:flutter/material.dart';

// import '../../../core/services/auth_service.dart';
// import '../../donor/screens/donor_profile_screen.dart';
// import '../../receiver/screens/reciever_homescreen.dart';

// class RoleSelectionScreen extends StatelessWidget {
//   final String userId;
//   const RoleSelectionScreen({Key? key, required this.userId}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Select Your Role"),
//         backgroundColor: Colors.red,
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             const Text(
//               "Please select your role",
//               style: TextStyle(
//                 fontSize: 20,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//             const SizedBox(height: 30),
//             Row(
//               children: [
//                 // Donor Card
//                 Expanded(
//                   child: GestureDetector(
//                     onTap: () async {
//                       await AuthService().setUserRole(userId, "donor");
//                       Navigator.pushReplacement(
//                         context,
//                         MaterialPageRoute(
//                             builder: (context) => const DonorProfileScreen()),
//                       );
//                     },
//                     child: Card(
//                       elevation: 4,
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                       child: Padding(
//                         padding: const EdgeInsets.all(16.0),
//                         child: Column(
//                           mainAxisSize: MainAxisSize.min,
//                           children: const [
//                             Icon(Icons.favorite, color: Colors.red, size: 60),
//                             SizedBox(height: 12),
//                             Text(
//                               "Donor",
//                               style: TextStyle(
//                                 fontSize: 18,
//                                 fontWeight: FontWeight.bold,
//                               ),
//                             ),
//                             SizedBox(height: 8),
//                             Text(
//                               "I want to donate blood",
//                               textAlign: TextAlign.center,
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),
//                 const SizedBox(width: 20),
//                 // Receiver Card
//                 Expanded(
//                   child: GestureDetector(
//                     onTap: () async {
//                       await AuthService().setUserRole(userId, "receiver");
//                       Navigator.pushReplacement(
//                         context,
//                         MaterialPageRoute(
//                             builder: (context) => const ReceiverHomeScreen()),
//                       );
//                     },
//                     child: Card(
//                       elevation: 4,
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                       child: Padding(
//                         padding: const EdgeInsets.all(16.0),
//                         child: Column(
//                           mainAxisSize: MainAxisSize.min,
//                           children: const [
//                             Icon(Icons.local_hospital,
//                                 color: Colors.blue, size: 60),
//                             SizedBox(height: 12),
//                             Text(
//                               "Receiver",
//                               style: TextStyle(
//                                 fontSize: 18,
//                                 fontWeight: FontWeight.bold,
//                               ),
//                             ),
//                             SizedBox(height: 8),
//                             Text(
//                               "I need blood for a patient",
//                               textAlign: TextAlign.center,
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
