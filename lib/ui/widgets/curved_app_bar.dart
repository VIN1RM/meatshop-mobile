// import 'package:flutter/material.dart';

// class CurvedAppBar extends StatelessWidget implements PreferredSizeWidget {
//   final String title;
//   final Widget? leading;
//   final List<Widget>? actions;
//   final double height;

//   const CurvedAppBar({
//     super.key,
//     required this.title,
//     this.leading,
//     this.actions,
//     this.height = 80,
//   });

//   @override
//   Size get preferredSize => Size.fromHeight(height);

//   @override
//   Widget build(BuildContext context) {
//     return ClipPath(
//       clipper: _BottomCurveClipper(),
//       child: Container(
//         height: height,
//         color: const Color(0xFF3A3A3A),
//         child: SafeArea(
//           child: Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 16),
//             child: Row(
//               children: [
//                 leading ??
//                     Container(
//                       width: 42,
//                       height: 42,
//                       decoration: const BoxDecoration(
//                         color: Colors.white,
//                         shape: BoxShape.circle,
//                       ),
//                       child: ClipOval(
//                         child: Image.asset(
//                           'assets/images/logo1.png',
//                           fit: BoxFit.contain,
//                           errorBuilder: (_, __, ___) => const Icon(
//                             Icons.storefront_outlined,
//                             color: Color(0xFFC0392B),
//                             size: 22,
//                           ),
//                         ),
//                       ),
//                     ),
//                 const SizedBox(width: 10),
//                 Text(
//                   title,
//                   style: const TextStyle(
//                     color: Colors.white,
//                     fontSize: 22,
//                     fontWeight: FontWeight.bold,
//                     letterSpacing: 0.5,
//                   ),
//                 ),
//                 const Spacer(),

//                 ...?actions ??
//                     [
//                       Container(
//                         width: 38,
//                         height: 38,
//                         decoration: BoxDecoration(
//                           border: Border.all(color: Colors.white, width: 1.5),
//                           shape: BoxShape.circle,
//                         ),
//                         child: const Icon(
//                           Icons.help_outline,
//                           color: Colors.white,
//                           size: 20,
//                         ),
//                       ),
//                     ],
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

// class _BottomCurveClipper extends CustomClipper<Path> {
//   @override
//   Path getClip(Size size) {
//     final path = Path();
//     path.lineTo(0, size.height - 20);
//     path.quadraticBezierTo(
//       size.width / 2,
//       size.height + 20,
//       size.width,
//       size.height - 20,
//     );
//     path.lineTo(size.width, 0);
//     path.close();
//     return path;
//   }

//   @override
//   bool shouldReclip(_BottomCurveClipper oldClipper) => false;
// }
