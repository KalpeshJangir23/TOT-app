import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'dart:async';
import 'package:screenshot/screenshot.dart';
import 'package:tot_app/bloc/map_bloc/bloc_map.dart';
import 'package:tot_app/bloc/map_bloc/map_event.dart';
import 'package:tot_app/bloc/map_bloc/map_state.dart';
import 'package:tot_app/constants/theme/app_theme.dart';
import 'package:tot_app/data/model/journey_model.dart';

class LocationTrackingScreen extends StatefulWidget {
  const LocationTrackingScreen({super.key});

  @override
  State<LocationTrackingScreen> createState() => _LocationTrackingScreenState();
}

class _LocationTrackingScreenState extends State<LocationTrackingScreen> {
  final MapController _mapController = MapController();
  final ScreenshotController _screenshotController = ScreenshotController();
  Timer? _timer;
  int _seconds = 0;
  bool _showCountdown = false;

  @override
  void dispose() {
    _timer?.cancel();
    _mapController.dispose();
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    _seconds = 0;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _seconds++;
      });
    });
  }

  void _stopTimer() {
    _timer?.cancel();
  }

  String _formatTime(int seconds) {
    int hours = seconds ~/ 3600;
    int minutes = (seconds % 3600) ~/ 60;
    int remainingSeconds = seconds % 60;
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  Future<void> _saveAndShareScreenshot(Journey journey) async {
   
  }

  @override
  Widget build(BuildContext context) {
    return Screenshot(
      controller: _screenshotController,
      child: Scaffold(
        backgroundColor: AppTheme.backgroundColor,
        appBar: AppBar(
          backgroundColor: AppTheme.primaryColor,
          title: const Text('Jogging Tracker', 
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          elevation: 0,
        ),
        body: BlocConsumer<LocationBloc, LocationState>(
          listener: (context, state) {
            if (state.currentPosition != null) {
              _mapController.move(state.currentPosition!, 18);
            }
          },
          builder: (context, state) {
            return Stack(
              children: [
                SizedBox.expand(
                  child: FlutterMap(
                    mapController: _mapController,
                    options: const MapOptions(
                      initialCenter: LatLng(0, 0),
                      initialZoom: 18,
                    ),
                    children: [
                      TileLayer(
                        urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName: 'com.example.tot_app',
                      ),
                      MarkerLayer(markers: _buildMarkers(state)),
                      PolylineLayer(
                        polylines: [
                          if (state.routeCoordinates.isNotEmpty)
                            Polyline(
                              points: state.routeCoordinates,
                              color: AppTheme.accentColor,
                              strokeWidth: 5,
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
                if (_showCountdown)
                  Center(
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: const Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Get Ready!',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 10),
                          CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(AppTheme.accentColor),
                          ),
                        ],
                      ),
                    ),
                  ),
                Positioned(
                  top: 16,
                  left: 16,
                  right: 16,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Column(
                          children: [
                            const Text('Time',
                              style: TextStyle(
                                color: AppTheme.textSecondaryColor,
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              _formatTime(_seconds),
                              style: const TextStyle(
                                color: AppTheme.textPrimaryColor,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        if (state.journey != null)
                          Column(
                            children: [
                              const Text('Distance',
                                style: TextStyle(
                                  color: AppTheme.textSecondaryColor,
                                  fontSize: 14,
                                ),
                              ),
                              Text(
                                '${state.journey!.distance.toStringAsFixed(2)} km',
                                style: const TextStyle(
                                  color: AppTheme.textPrimaryColor,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  bottom: 32,
                  left: 16,
                  right: 16,
                  child: Column(
                    children: [
                      if (state.source == null)
                        ElevatedButton(
                          onPressed: () {
                            setState(() => _showCountdown = true);
                            Timer(const Duration(seconds: 5), () {
                              setState(() => _showCountdown = false);
                              context.read<LocationBloc>().add(StartTracking(context));
                              _startTimer();
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryColor,
                            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.play_arrow, color: Colors.white),
                              SizedBox(width: 8),
                              Text('Start Tracking',
                                style: TextStyle(color: Colors.white, fontSize: 18)),
                            ],
                          ),
                        ),
                      if (state.source != null && state.destination == null)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            ElevatedButton(
                              onPressed: () {
                                _stopTimer();
                                context.read<LocationBloc>().add(StopTracking());
                                showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: const Text('Save Journey'),
                                    content: const Text('Would you like to save this journey?'),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: const Text('No'),
                                      ),
                                      ElevatedButton(
                                        onPressed: () {
                                          Navigator.pop(context);
                                          if (state.journey != null) {
                                            _saveAndShareScreenshot(state.journey!);
                                          }
                                        },
                                        child: const Text('Yes'),
                                      ),
                                    ],
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.stop, color: Colors.white),
                                  SizedBox(width: 8),
                                  Text('Stop',
                                    style: TextStyle(color: Colors.white, fontSize: 18)),
                                ],
                              ),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                _stopTimer();
                                context.read<LocationBloc>().add(ResetTracking());
                                setState(() {
                                  _seconds = 0;
                                });
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.secondaryColor,
                                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.refresh, color: Colors.white),
                                  SizedBox(width: 8),
                                  Text('Reset',
                                    style: TextStyle(color: Colors.white, fontSize: 18)),
                                ],
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  List<Marker> _buildMarkers(LocationState state) {
    final markers = <Marker>[];
    if (state.source != null) {
      markers.add(
        Marker(
          point: state.source!,
          width: 80,
          height: 80,
          child: const Icon(
            Icons.location_on,
            color: AppTheme.primaryColor,
            size: 40,
          ),
        ),
      );
    }
    if (state.destination != null) {
      markers.add(
        Marker(
          point: state.destination!,
          width: 80,
          height: 80,
          child: const Icon(
            Icons.location_on,
            color: AppTheme.secondaryColor,
            size: 40,
          ),
        ),
      );
    }
    return markers;
  }

  String _formatLatLng(LatLng latLng) {
    return '(${latLng.latitude.toStringAsFixed(4)}, ${latLng.longitude.toStringAsFixed(4)})';
  }
}