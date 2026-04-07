// ============ STEP 2: GPS TRACKING ============
// This file shows what to ADD to your Step 1 app

// ADD THIS TO pubspec.yaml:
// dependencies:
//   flutter:
//     sdk: flutter
//   geolocator: ^9.0.0
import 'dart:math';

import 'package:geolocator/geolocator.dart';

// Create this new file: lib/services/location_service.dart

class LocationService {
  // Check if location services are enabled
  static Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  // Request location permission
  static Future<LocationPermission> requestLocationPermission() async {
    final status = await Geolocator.requestPermission();
    return status;
  }

  // Get current position once
  static Future<Position?> getCurrentPosition() async {
    try {
      // Request permission first
      final permission = await requestLocationPermission();

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        print('Location permission denied');
        return null;
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best,
      );
      return position;
    } catch (e) {
      print('Error getting location: $e');
      return null;
    }
  }

  // Stream location updates while tracking
  static Stream<Position> getLocationUpdates() {
    return Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.best,
        distanceFilter: 10, // Update every 10 meters
      ),
    );
  }

  // Calculate distance between two points using Haversine formula
  static double calculateDistance(
      double lat1, double lon1, double lat2, double lon2) {
    const p = 0.017453292519943295; // Math.PI / 180
    final a = 0.5 -
        cos((lat2 - lat1) * p) / 2 +
        cos(lat1 * p) * cos(lat2 * p) * (1 - cos((lon2 - lon1) * p)) / 2;
    return 12742 * asin(sqrt(a)); // 2 * R; R = 6371 km
  }
}

// Import for the math functions


// ============ HOW TO USE IN YOUR APP ============
// 
// In your TrackingScreen, replace the simple _isTracking logic with:
//
// class _TrackingScreenState extends State<TrackingScreen> {
//   bool _isTracking = false;
//   double _distance = 0.0;
//   double _currentSpeed = 0.0;
//   double _maxSpeed = 0.0;
//   List<Position> _positions = [];
//
//   void _startTracking() async {
//     // Check if location service is enabled
//     bool serviceEnabled = await LocationService.isLocationServiceEnabled();
//     if (!serviceEnabled) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Please enable location services')),
//       );
//       return;
//     }
//
//     setState(() {
//       _isTracking = true;
//       _distance = 0.0;
//       _positions = [];
//     });
//
//     // Listen to location updates
//     LocationService.getLocationUpdates().listen(
//       (Position position) {
//         setState(() {
//           // Calculate distance between last position and current
//           if (_positions.isNotEmpty) {
//             final lastPos = _positions.last;
//             final dist = LocationService.calculateDistance(
//               lastPos.latitude,
//               lastPos.longitude,
//               position.latitude,
//               position.longitude,
//             );
//             _distance += dist;
//           }
//
//           // Update speed
//           _currentSpeed = position.speed * 3.6; // m/s to km/h
//           if (_currentSpeed > _maxSpeed) {
//             _maxSpeed = _currentSpeed;
//           }
//
//           _positions.add(position);
//         });
//       },
//       onError: (error) {
//         print('Location stream error: $error');
//       },
//     );
//   }
//
//   void _stopTracking() {
//     setState(() {
//       _isTracking = false;
//     });
//   }
// }