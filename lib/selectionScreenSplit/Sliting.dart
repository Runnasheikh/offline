// import 'package:flutter/material.dart';
// import 'package:slideshow_kiosk/SlectionScreen.dart';


// class SplitingScreen extends StatefulWidget {
//   const SplitingScreen({super.key});

//   @override
//   State<SplitingScreen> createState() => _SplitingScreenState();
// }

// class _SplitingScreenState extends State<SplitingScreen> {
//   int splitCount = 1;
//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: () => showDialog(
//         context: context,
//         builder: (context) => AlertDialog(
//           title: Text("Select Split"),
//           actions: [
//             TextButton(
//               onPressed: () {
//                 _updateSplitCount(1);
//                 Navigator.pop(context);
//               },
//               child: Text(
//                 "1",
//                 style: Theme.of(context).textTheme.headline6,
//               ),
//             ),
//             TextButton(
//               onPressed: () {
//                 _updateSplitCount(2);
//                 Navigator.pop(context);
//               },
//               child: Text(
//                 "2",
//                 style: Theme.of(context).textTheme.headline6,
//               ),
//             ),
//             TextButton(
//               onPressed: () {
//                 _updateSplitCount(3);
//                 Navigator.pop(context);
//               },
//               child: Text(
//                 "3",
//                 style: Theme.of(context).textTheme.headline6,
//               ),
//             ),
//           ],
//         ),
//       ),
//       child: ClipRRect(
//         borderRadius: BorderRadius.circular(12),
//         child: Container(
//           padding: const EdgeInsets.all(18),
//           color: Colors.blue,
//           child: Text(
//             "Select Split",
//             style: Theme.of(context)
//                 .textTheme
//                 .headline6!
//                 .copyWith(color: Colors.white),
//           ),
//         ),
//       ),
//     );
//   }

 
// }
