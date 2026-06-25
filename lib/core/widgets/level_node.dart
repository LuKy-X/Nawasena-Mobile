// import 'package:flutter/material.dart';
// import 'package:nawasena/app/theme.dart';
// import 'package:nawasena/core/widgets/bouncy_tap.dart';

// enum LevelStatus { locked, active, completed }

// class LevelNode extends StatelessWidget {
//   final String title;
//   final LevelStatus status;
//   final IconData icon; // Ikon utama level
//   final VoidCallback? onTap;

//   const LevelNode({
//     super.key,
//     required this.title,
//     required this.status,
//     required this.icon,
//     this.onTap,
//   });

//   @override
//   Widget build(BuildContext context) {
//     // Ukuran node
//     const double size = 100.0;
//     const double borderWidth = 3.0;

//     // Warna berdasarkan status
//     final Color baseColor;
//     final Color darkColor;
//     final Color lightColor;
//     final Color borderColor;
//     final Color iconColor;
//     final Color textColor;
//     final bool showLock;

//     switch (status) {
//       case LevelStatus.completed:
//         baseColor = AppTheme.successGreen;
//         darkColor = Color.lerp(baseColor, Colors.black, 0.25)!;
//         lightColor = Color.lerp(baseColor, Colors.white, 0.3)!;
//         borderColor = Colors.white.withOpacity(0.6); // border terang untuk efek 3D
//         iconColor = Colors.white;
//         textColor = Colors.white;
//         showLock = false;
//         break;
//       case LevelStatus.active:
//         baseColor = Colors.white;
//         darkColor = Colors.grey.shade300;
//         lightColor = Colors.white;
//         borderColor = AppTheme.primaryOrange;
//         iconColor = AppTheme.primaryOrange;
//         textColor = AppTheme.darkText;
//         showLock = false;
//         break;
//       case LevelStatus.locked:
//         baseColor = Colors.grey.shade300;
//         darkColor = Colors.grey.shade500;
//         lightColor = Colors.grey.shade200;
//         borderColor = Colors.grey.shade400;
//         iconColor = Colors.white;
//         textColor = Colors.transparent; // teks tidak terlihat (tertutup gembok)
//         showLock = true;
//         break;
//     }

//     // Node inti dengan efek 3D
//     final nodeBody = Container(
//       width: size,
//       height: size,
//       decoration: BoxDecoration(
//         shape: BoxShape.circle,
//         gradient: RadialGradient(
//           center: const Alignment(-0.3, -0.3), // sumber cahaya dari kiri atas
//           radius: 0.8,
//           colors: [lightColor, baseColor, darkColor],
//           stops: const [0.2, 0.7, 1.0],
//         ),
//         border: Border.all(
//           color: borderColor,
//           width: borderWidth,
//         ),
//         boxShadow: [
//           // Bayangan bawah tebal (3D)
//           BoxShadow(
//             color: darkColor.withOpacity(0.5),
//             blurRadius: 12,
//             offset: const Offset(0, 6),
//             spreadRadius: 1,
//           ),
//           // Bayangan tambahan lebih gelap di bawah
//           BoxShadow(
//             color: Colors.black.withOpacity(0.2),
//             blurRadius: 4,
//             offset: const Offset(0, 2),
//           ),
//           // Highlight putih di atas (efek pantulan)
//           if (status != LevelStatus.locked)
//             BoxShadow(
//               color: Colors.white.withOpacity(0.8),
//               blurRadius: 4,
//               offset: const Offset(-2, -2),
//               spreadRadius: -1,
//             ),
//         ],
//       ),
//       alignment: Alignment.center,
//       child: Stack(
//         alignment: Alignment.center,
//         children: [
//           // Isi ikon dan teks
//           if (showLock)
//             // Tampilkan gembok besar saat terkunci
//             Icon(
//               Icons.lock_rounded,
//               size: 36,
//               color: iconColor,
//               shadows: [
//                 Shadow(
//                   color: Colors.black.withOpacity(0.2),
//                   blurRadius: 4,
//                   offset: const Offset(0, 3),
//                 ),
//               ],
//             )
//           else
//             Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 // Ikon level
//                 Icon(
//                   icon,
//                   size: 32,
//                   color: iconColor,
//                   shadows: [
//                     Shadow(
//                       color: Colors.black.withOpacity(0.15),
//                       blurRadius: 4,
//                       offset: const Offset(0, 3),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 4),
//                 // Nama level
//                 Text(
//                   title,
//                   style: TextStyle(
//                     fontSize: 11,
//                     fontWeight: FontWeight.w800,
//                     color: textColor,
//                     shadows: [
//                       Shadow(
//                         color: Colors.black.withOpacity(0.1),
//                         blurRadius: 2,
//                         offset: const Offset(0, 1),
//                       ),
//                     ],
//                   ),
//                   textAlign: TextAlign.center,
//                   maxLines: 1,
//                   overflow: TextOverflow.ellipsis,
//                 ),
//               ],
//             ),
//           // Lencana bintang jika completed
//           if (status == LevelStatus.completed)
//             Positioned(
//               top: 4,
//               right: 4,
//               child: Container(
//                 width: 24,
//                 height: 24,
//                 decoration: BoxDecoration(
//                   shape: BoxShape.circle,
//                   gradient: const LinearGradient(
//                     colors: [Colors.yellow, Colors.orange],
//                     begin: Alignment.topLeft,
//                     end: Alignment.bottomRight,
//                   ),
//                   boxShadow: [
//                     BoxShadow(
//                       color: Colors.orange.withOpacity(0.4),
//                       blurRadius: 6,
//                       offset: const Offset(0, 2),
//                     ),
//                   ],
//                 ),
//                 alignment: Alignment.center,
//                 child: const Icon(
//                   Icons.star_rounded,
//                   size: 16,
//                   color: Colors.white,
//                 ),
//               ),
//             ),
//         ],
//       ),
//     );

//     // Bungkus dengan BouncyTap jika tidak terkunci
//     return status == LevelStatus.locked
//         ? nodeBody
//         : BouncyTap(
//             onTap: onTap,
//             child: nodeBody,
//           );
//   }
// }