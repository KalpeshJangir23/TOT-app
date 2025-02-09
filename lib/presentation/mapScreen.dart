// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:flutter_map/flutter_map.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:latlong2/latlong.dart';
// import 'dart:async';
// import 'package:tot_app/bloc/map_bloc/bloc_map.dart';
// import 'package:tot_app/bloc/map_bloc/map_event.dart';
// import 'package:tot_app/bloc/map_bloc/map_state.dart';
// import 'package:tot_app/constants/theme/app_theme.dart';
// import 'package:tot_app/main.dart';

// class LocationTrackingScreen extends StatefulWidget {
//   const LocationTrackingScreen({super.key});

//   @override
//   State<LocationTrackingScreen> createState() => _LocationTrackingScreenState();
// }

// class _LocationTrackingScreenState extends State<LocationTrackingScreen> {
//   final MapController _mapController = MapController();
//   Timer? _timer;
//   int _seconds = 0;
//   bool _showTripSummary = false;
//   bool _isStarting = false;
//   LatLng? _currentLocation; // Store current location

//   @override
//   void initState() {
//     super.initState();
//     _getCurrentLocation(); // Get initial location
//   }


//   Future<void> _getCurrentLocation() async {
//     bool permission = await LocationPermissionHandler.handleLocationPermission(context);
//     if (!permission) return;

//     try {
//       Position position = await Geolocator.getCurrentPosition(
//           desiredAccuracy: LocationAccuracy.high);
//       setState(() {
//         _currentLocation = LatLng(position.latitude, position.longitude);
//       });

//       context.read<LocationBloc>().add(UpdateLocation(_currentLocation!)); // Dispatch initial location
//     } catch (e) {
//       print("Error getting location: $e");
//     }
//   }

//   @override
//   void dispose() {
//     _timer?.cancel();
//     _mapController.dispose();
//     super.dispose();
//   }

//   void _startTimer() {
//     setState(() {
//       _isStarting = true;
//       _seconds = 0;
//     });

//     Timer(const Duration(seconds: 5), () {
//       setState(() {
//         _isStarting = false;
//       });
//       context.read<LocationBloc>().add(StartTracking(context));
//       _timer?.cancel();
//       _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
//         setState(() {
//           _seconds++;
//         });
//       });
//     });
//   }

//   void _stopTimer() {
//     _timer?.cancel();
//   }

//   String _formatTime(int seconds) {
//     int hours = seconds ~/ 3600;
//     int minutes = (seconds % 3600) ~/ 60;
//     int remainingSeconds = seconds % 60;
//     return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
//   }

//   void _showTripDetails(LocationState state) {
//     setState(() {
//       _showTripSummary = true;
//     });
//     showModalBottomSheet(
//       context: context,
//       isDismissible: false,
//       enableDrag: false,
//       builder: (context) => WillPopScope(
//         onWillPop: () async => false,
//         child: Container(
//           padding: const EdgeInsets.all(20),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               const Text(
//                 'Trip Summary',
//                 style: TextStyle(
//                   fontSize: 24,
//                   fontWeight: FontWeight.bold,
//                   color: AppTheme.primaryColor,
//                 ),
//               ),
//               const SizedBox(height: 20),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceAround,
//                 children: [
//                   _buildSummaryItem(
//                     icon: Icons.timer,
//                     title: 'Duration',
//                     value: _formatTime(_seconds),
//                   ),
//                   // _buildSummaryItem(
//                   //   icon: Icons.directions_walk,
//                   //   title: 'Distance',
//                   //   value: '${state.distance.toStringAsFixed(2)} km',
//                   // ),
//                 ],
//               ),
//               const SizedBox(height: 30),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                 children: [
//                   ElevatedButton(
//                     onPressed: () {
//                       Navigator.pop(context);
//                       context.read<LocationBloc>().add(ResetTracking());
//                       setState(() {
//                         _seconds = 0;
//                         _showTripSummary = false;
//                       });
//                     },
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: AppTheme.secondaryColor,
//                     ),
//                     child: const Text('Start New Walk'),
//                   ),
//                   ElevatedButton(
//                     onPressed: () {
//                       // Add save functionality here
//                       Navigator.pop(context);
//                       context.read<LocationBloc>().add(ResetTracking());
//                       setState(() {
//                         _seconds = 0;
//                         _showTripSummary = false;
//                       });
//                       ScaffoldMessenger.of(context).showSnackBar(
//                         const SnackBar(
//                           content: Text('Trip saved successfully!'),
//                           backgroundColor: Colors.green,
//                         ),
//                       );
//                     },
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: AppTheme.primaryColor,
//                     ),
//                     child: const Text('Save Trip'),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildSummaryItem({
//     required IconData icon,
//     required String title,
//     required String value,
//   }) {
//     return Column(
//       children: [
//         Icon(icon, size: 30, color: AppTheme.primaryColor),
//         const SizedBox(height: 8),
//         Text(
//           title,
//           style: const TextStyle(
//             fontSize: 16,
//             color: AppTheme.textSecondaryColor,
//           ),
//         ),
//         const SizedBox(height: 4),
//         Text(
//           value,
//           style: const TextStyle(
//             fontSize: 20,
//             fontWeight: FontWeight.bold,
//             color: AppTheme.textPrimaryColor,
//           ),
//         ),
//       ],
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppTheme.backgroundColor,
//       appBar: AppBar(
//         backgroundColor: AppTheme.primaryColor,
//         title: const Text(
//           'Start a Walk',
//           style:
//               TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
//         ),
//         elevation: 0,
//       ),
//       body: BlocConsumer<LocationBloc, LocationState>(
//         listener: (context, state) {
//           if (state.currentPosition != null && state.isTracking) {
//             _mapController.move(state.currentPosition!, 18);
//           }
//         },
//         builder: (context, state) {
//           return Stack(
//             children: [
//               FlutterMap(
//                 mapController: _mapController,
//                 options: MapOptions(
//                   initialCenter: state.currentPosition ?? _currentLocation ?? const LatLng(0, 0), // Use _currentLocation if available
//                   initialZoom: 18,
//                 ),
//                 children: [
//                   TileLayer(
//                     urlTemplate:
//                         'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
//                     userAgentPackageName: 'com.example.tot_app',
//                   ),
//                   PolylineLayer(
//                     polylines: [
//                       Polyline(
//                         points: state.routeCoordinates, // Use routeCoordinates from state
//                         color: AppTheme.accentColor,
//                         strokeWidth: 4.0,
//                         isDotted: false,
//                       ),
//                     ],
//                   ),
//                   MarkerLayer(
//                     markers: [
//                       if (state.currentPosition != null)
//                         Marker(
//                           point: state.currentPosition!,
//                           width: 80,
//                           height: 80,
//                           child: const Icon(
//                             Icons.my_location,
//                             color: AppTheme.primaryColor,
//                             size: 40,
//                           ),
//                         ),
//                       if (state.source != null)
//                         Marker(
//                           point: state.source!,
//                           width: 80,
//                           height: 80,
//                           child: const Icon(
//                             Icons.trip_origin,
//                             color: AppTheme.primaryColor,
//                             size: 40,
//                           ),
//                         ),
//                       if (state.destination != null)
//                         Marker(
//                           point: state.destination!,
//                           width: 80,
//                           height: 80,
//                           child: const Icon(
//                             Icons.location_on,
//                             color: AppTheme.secondaryColor,
//                             size: 40,
//                           ),
//                         ),
//                     ],
//                   ),
//                 ],
//               ),
//               // Stats Panel
//               Positioned(
//                 top: 16,
//                 left: 16,
//                 right: 16,
//                 child: Container(
//                   padding: const EdgeInsets.all(16),
//                   decoration: BoxDecoration(
//                     color: Colors.white,
//                     borderRadius: BorderRadius.circular(15),
//                     boxShadow: [
//                       BoxShadow(
//                         color: Colors.black.withOpacity(0.1),
//                         blurRadius: 10,
//                         offset: const Offset(0, 5),
//                       ),
//                     ],
//                   ),
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceAround,
//                     children: [
//                       Column(
//                         children: [
//                           const Text(
//                             'Time',
//                             style: TextStyle(
//                               color: AppTheme.textSecondaryColor,
//                               fontSize: 14,
//                             ),
//                           ),
//                           Text(
//                             _formatTime(_seconds),
//                             style: const TextStyle(
//                               color: AppTheme.textPrimaryColor,
//                               fontSize: 24,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                         ],
//                       ),
//                       const Column(
//                         children: [
//                           Text(
//                             'Distance',
//                             style: TextStyle(
//                               color: AppTheme.textSecondaryColor,
//                               fontSize: 14,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//               // Control Buttons
//               Positioned(
//                 bottom: 32,
//                 left: 16,
//                 right: 16,
//                 child: Column(
//                   children: [
//                     if (!state.isTracking && state.source == null)
//                       ElevatedButton(
//                         onPressed: _isStarting ? null : () => _startTimer(),
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: AppTheme.primaryColor,
//                           padding: const EdgeInsets.symmetric(
//                               horizontal: 32, vertical: 16),
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(30),
//                           ),
//                         ),
//                         child: Row(
//                           mainAxisSize: MainAxisSize.min,
//                           children: [
//                             _isStarting
//                                 ? const SizedBox(
//                                     width: 20,
//                                     height: 20,
//                                     child: CircularProgressIndicator(
//                                       color: Colors.white,
//                                       strokeWidth: 2,
//                                     ),
//                                   )
//                                 : const Icon(Icons.play_arrow,
//                                     color: Colors.white),
//                             const SizedBox(width: 8),
//                             Text(
//                               _isStarting
//                                   ? 'Starting in 5s...'
//                                   : 'Start Tracking',
//                               style: const TextStyle(
//                                   color: Colors.white, fontSize: 18),
//                             ),
//                           ],
//                         ),
//                       ),
//                     if (state.isTracking)
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                         children: [
//                           ElevatedButton(
//                             onPressed: () {
//                               _stopTimer();
//                               context.read<LocationBloc>().add(StopTracking());
//                               _showTripDetails(state);
//                             },
//                             style: ElevatedButton.styleFrom(
//                               backgroundColor: Colors.red,
//                               padding: const EdgeInsets.symmetric(
//                                   horizontal: 32, vertical: 16),
//                               shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(30),
//                               ),
//                             ),
//                             child: const Row(
//                               mainAxisSize: MainAxisSize.min,
//                               children: [
//                                 Icon(Icons.stop, color: Colors.white),
//                                 SizedBox(width: 8),
//                                 Text('Stop',
//                                     style: TextStyle(
//                                         color: Colors.white, fontSize: 18)),
//                               ],
//                             ),
//                           ),
//                           ElevatedButton(
//                             onPressed: () {
//                               _stopTimer();
//                               context.read<LocationBloc>().add(ResetTracking());
//                               setState(() {
//                                 _seconds = 0;
//                               });
//                             },
//                             style: ElevatedButton.styleFrom(
//                               backgroundColor: AppTheme.secondaryColor,
//                               padding: const EdgeInsets.symmetric(
//                                   horizontal: 32, vertical: 16),
//                               shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(30),
//                               ),
//                             ),
//                             child: const Row(
//                               mainAxisSize: MainAxisSize.min,
//                               children: [
//                                 Icon(Icons.refresh, color: Colors.white),
//                                 SizedBox(width: 8),
//                                 Text('Reset',
//                                     style: TextStyle(
//                                         color: Colors.white, fontSize: 18)),
//                               ],
//                             ),
//                           ),
//                         ],
//                       ),
//                   ],
//                 ),
//               ),
//             ],
//           );
//         },
//       ),
//     );
//   }

//   List<Marker> _buildMarkers(LocationState state) {
//     final markers = <Marker>[];
//     if (state.source != null) {
//       markers.add(
//         Marker(
//           point: state.source!,
//           width: 80,
//           height: 80,
//           child: const Icon(
//             Icons.location_on,
//             color: AppTheme.primaryColor,
//             size: 40,
//           ),
//         ),
//       );
//     }
//     if (state.destination != null) {
//       markers.add(
//         Marker(
//           point: state.destination!,
//           width: 80,
//           height: 80,
//           child: const Icon(
//             Icons.location_on,
//             color: AppTheme.secondaryColor,
//             size: 40,
//           ),
//         ),
//       );
//     }
//     return markers;
//   }

//   String _formatLatLng(LatLng latLng) {
//     return '(${latLng.latitude.toStringAsFixed(4)}, ${latLng.longitude.toStringAsFixed(4)})';
//   }
// }
