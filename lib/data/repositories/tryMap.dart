import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:tot_app/bloc/map_bloc/bloc_map.dart';
import 'package:tot_app/bloc/map_bloc/map_event.dart';
import 'package:tot_app/bloc/map_bloc/map_state.dart';

class TrackingScreen extends StatelessWidget {
  const TrackingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Live Route Tracker')),
      body: BlocConsumer<RideBloc, RideState>(
        listener: (context, state) {
          if (state is RidePreparation) {
            showCountdownDialog(context);
          } else if (state is RideError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error: ${state.message}')),
            );
            context.read<RideBloc>().add(StopRide());
          }
        },
        builder: (context, state) {
          return Column(
            children: [
              Expanded(
                flex: 6,
                child: _buildMap(context, state),
              ),
              Expanded(
                flex: 4,
                child: _buildControls(context, state),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildMap(BuildContext context, RideState state) {
    return BlocBuilder<RideBloc, RideState>(
      builder: (context, state) {
        Set<Marker> markers = {};

        if (state is RideInProgress) {
          // Add start marker
          if (state.startPosition != null) {
            markers.add(
              Marker(
                markerId: const MarkerId('start'),
                position: state.startPosition!,
                icon: BitmapDescriptor.defaultMarkerWithHue(
                    BitmapDescriptor.hueGreen),
                infoWindow: const InfoWindow(title: 'Start'),
              ),
            );
          }

          // Add current position marker
          if (state.currentPosition != null) {
            markers.add(
              Marker(
                markerId: const MarkerId('current'),
                position: state.currentPosition!,
                icon: BitmapDescriptor.defaultMarkerWithHue(
                    BitmapDescriptor.hueBlue),
                infoWindow: const InfoWindow(title: 'Current Location'),
              ),
            );
          }
        }

        return GoogleMap(
          initialCameraPosition: const CameraPosition(
            target: LatLng(37.42796133580664, -122.085749655962),
            zoom: 15,
          ),
          polylines: state is RideInProgress ? {state.polyline} : {},
          markers: markers,
          myLocationEnabled: true,
          myLocationButtonEnabled: true,
          onMapCreated: (GoogleMapController controller) {
            try {
              context.read<RideBloc>().add(MapCreated(controller));
            } catch (e) {
              print('Error initializing map: $e');
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Error initializing map: $e')),
              );
            }
          },
        );
      },
    );
  }

  Widget _buildControls(BuildContext context, RideState state) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          _buildStats(state),
          const SizedBox(height: 20),
          _buildActionButton(context, state),
        ],
      ),
    );
  }

  Widget _buildStats(RideState state) {
    final duration = state is RideInProgress ? state.duration : Duration.zero;
    final distance = state is RideInProgress ? state.distance : 0.0;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildStatCard('Duration', _formatDuration(duration)),
        _buildStatCard('Distance', '${distance.toStringAsFixed(2)} km'),
      ],
    );
  }

  Widget _buildStatCard(String title, String value) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Text(title, style: const TextStyle(fontSize: 16)),
            Text(value,
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(BuildContext context, RideState state) {
    if (state is RideInProgress) {
      return ElevatedButton.icon(
        icon: const Icon(Icons.stop),
        label: const Text('Stop Tracking'),
        style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
        onPressed: () => context.read<RideBloc>().add(StopRide()),
      );
    }

    return ElevatedButton.icon(
      icon: const Icon(Icons.directions_run),
      label: const Text('Start Tracking'),
      onPressed: () async {
        // Check if location services are enabled
        bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
        if (!serviceEnabled) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Please enable location services to continue.'),
            ),
          );
          return;
        }

        // Check location permissions
        LocationPermission permission = await Geolocator.checkPermission();
        if (permission == LocationPermission.denied) {
          permission = await Geolocator.requestPermission();
          if (permission != LocationPermission.whileInUse &&
              permission != LocationPermission.always) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Location permissions are required.'),
              ),
            );
            return;
          }
        }

        if (permission == LocationPermission.deniedForever) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                  'Location permissions are permanently denied. Please enable them in app settings.'),
            ),
          );
          return;
        }

        // Proceed with starting the ride
        context.read<RideBloc>().add(StartRide());
      },
    );
  }

  void showCountdownDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => const CountdownDialog(),
    );
  }

  String _formatDuration(Duration duration) {
    return '${duration.inMinutes}:${(duration.inSeconds % 60).toString().padLeft(2, '0')}';
  }
}

// ride_bloc.dart





class CountdownDialog extends StatefulWidget {
  const CountdownDialog({super.key});

  @override
  _CountdownDialogState createState() => _CountdownDialogState();
}

class _CountdownDialogState extends State<CountdownDialog> {
  int countdown = 5;

  @override
  void initState() {
    super.initState();
    Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        countdown--;
      });
      if (countdown <= 0) {
        timer.cancel();
        Navigator.pop(context);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Get Ready!'),
      content: Text('Starting tracking in $countdown seconds...'),
    );
  }
}

