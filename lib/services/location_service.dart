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
      
      final last = await Geolocator.getLastKnownPosition();
      if (last != null) {
        return last;
      }

      
      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      ).timeout(timeout);

      return pos;
    } on TimeoutException {
      
      return null;
    } catch (_) {
      
      return null;
    }
  }

  double calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    
    final meters = Geolocator.distanceBetween(lat1, lon1, lat2, lon2);

    final km = meters / 1000.0;

    if (km.isNaN || km.isInfinite) {
      return 0.0;
    }

    return km;
  }

  double calculateDistanceMeters(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    return Geolocator.distanceBetween(lat1, lon1, lat2, lon2);
  }

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


