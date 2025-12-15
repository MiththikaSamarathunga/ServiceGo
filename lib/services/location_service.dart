import 'dart:async';

import 'package:geolocator/geolocator.dart';
import '../models/service_provider_model.dart';

class LocationService {
  Future<Position?> getCurrentLocation({Duration timeout = const Duration(seconds: 10)}) async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return null;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return null;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return null;
    }

    try {
      // first try last known position (fast)
      final last = await Geolocator.getLastKnownPosition();
      if (last != null) {
        return last;
      }

      // try to get a fresh reading but limit how long we wait
      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      ).timeout(timeout);

      return pos;
    } on TimeoutException {
      // timed out waiting for a GPS fix
      return null;
    } catch (_) {
      // other failures -> return null so caller can handle fallback
      return null;
    }
  }

  /// Returns the distance in kilometers between two points.
  ///
  /// Uses `Geolocator.distanceBetween(...)` (which returns meters) for
  /// consistent, platform-provided calculation and converts to kilometers.
  /// This avoids subtle floating/implementation differences from a
  /// hand-rolled haversine implementation.
  double calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    // Geolocator.distanceBetween returns meters.
    final meters = Geolocator.distanceBetween(lat1, lon1, lat2, lon2);

    // Convert to kilometers with a stable double division.
    final km = meters / 1000.0;

    // Protect against tiny negative values (shouldn't happen with distanceBetween)
    // and return a small-precision-normalised result.
    if (km.isNaN || km.isInfinite) {
      return 0.0;
    }

    return km;
  }

  /// Returns distance in meters between two points (more convenient precision)
  double calculateDistanceMeters(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    return Geolocator.distanceBetween(lat1, lon1, lat2, lon2);
  }

  // helper functions removed — using Geolocator.distanceBetween for accuracy

  List<ServiceProviderModel> sortByDistance(
    List<ServiceProviderModel> providers,
    double userLat,
    double userLon,
  ) {
    providers.sort((a, b) {
      double distanceA = calculateDistance(userLat, userLon, a.latitude, a.longitude);
      double distanceB = calculateDistance(userLat, userLon, b.latitude, b.longitude);
      return distanceA.compareTo(distanceB);
    });
    return providers;
  }
}

// import 'package:geolocator/geolocator.dart';
// import 'dart:math';
// import '../models/service_provider_model.dart';

// class LocationService {
//   Future<Position?> getCurrentLocation() async {
//     bool serviceEnabled;
//     LocationPermission permission;

//     serviceEnabled = await Geolocator.isLocationServiceEnabled();
//     if (!serviceEnabled) {
//       return null;
//     }

//     permission = await Geolocator.checkPermission();
//     if (permission == LocationPermission.denied) {
//       permission = await Geolocator.requestPermission();
//       if (permission == LocationPermission.denied) {
//         return null;
//       }
//     }

//     if (permission == LocationPermission.deniedForever) {
//       return null;
//     }

//     return await Geolocator.getCurrentPosition(
//       desiredAccuracy: LocationAccuracy.high,
//     );
//   }

//   double calculateDistance(
//     double lat1,
//     double lon1,
//     double lat2,
//     double lon2,
//   ) {
//     const double earthRadius = 6371;
    
//     double dLat = _toRadians(lat2 - lat1);
//     double dLon = _toRadians(lon2 - lon1);

//     double a = sin(dLat / 2) * sin(dLat / 2) +
//         cos(_toRadians(lat1)) *
//             cos(_toRadians(lat2)) *
//             sin(dLon / 2) *
//             sin(dLon / 2);

//     double c = 2 * atan2(sqrt(a), sqrt(1 - a));

//     return earthRadius * c;
//   }

//   double _toRadians(double degree) {
//     return degree * pi / 180;
//   }

//   List<ServiceProviderModel> sortByDistance(
//     List<ServiceProviderModel> providers,
//     double userLat,
//     double userLon,
//   ) {
//     providers.sort((a, b) {
//       double distanceA = calculateDistance(userLat, userLon, a.latitude, a.longitude);
//       double distanceB = calculateDistance(userLat, userLon, b.latitude, b.longitude);
//       return distanceA.compareTo(distanceB);
//     });
//     return providers;
//   }
// }

