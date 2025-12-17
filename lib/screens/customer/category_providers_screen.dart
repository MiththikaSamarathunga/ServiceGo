import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../../models/service_category.dart';
import '../../models/service_provider_model.dart';
import '../../services/firestore_service.dart';
import '../../services/location_service.dart';
import 'provider_detail_screen.dart';

class CategoryProvidersScreen extends StatefulWidget {
  final ServiceCategory category;

  const CategoryProvidersScreen({super.key, required this.category});

  @override
  State<CategoryProvidersScreen> createState() => _CategoryProvidersScreenState();
}

class _CategoryProvidersScreenState extends State<CategoryProvidersScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  final LocationService _locationService = LocationService();
  Position? _userPosition;
  @override

  void initState() {
    super.initState();
    _loadUserLocation();
  }

  Future<void> _loadUserLocation() async {

    Position? position = await _locationService.getCurrentLocation();
    
    setState(() {
      _userPosition = position ?? Position(
        latitude: 6.9271,
        longitude: 79.8612,
        timestamp: DateTime.now(),
        accuracy: 0,
        altitude: 0,
        heading: 0,
        speed: 0,
        speedAccuracy: 0,
        altitudeAccuracy: 0,
        headingAccuracy: 0,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.category.name),
      ),
      body: StreamBuilder<List<ServiceProviderModel>>(
        stream: _firestoreService.getProvidersByCategory(widget.category.id),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    widget.category.icon,
                    size: 80,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'No providers available',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          List<ServiceProviderModel> providers = snapshot.data!;

          if (_userPosition != null) {
            providers = _locationService.sortByDistance(
              providers,
              _userPosition!.latitude,
              _userPosition!.longitude,
            );
          }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: providers.length,
              itemBuilder: (context, index) {
                    final provider = providers[index];
                    double? distance;
                    
                    if (_userPosition != null) {
                      distance = _locationService.calculateDistance(
                        _userPosition!.latitude,
                        _userPosition!.longitude,
                        provider.latitude,
                        provider.longitude,
                      );
                    
                    }

                    return _ProviderCard(
                      provider: provider,
                      distance: distance,
                      category: widget.category,
                    );
                  },
                );
        },
      ),
    );
  }
}

class _ProviderCard extends StatelessWidget {
  final ServiceProviderModel provider;
  final double? distance;
  final ServiceCategory category;

  const _ProviderCard({
    required this.provider,
    required this.distance,
    required this.category,
    
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 4,
      child: InkWell(
              onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ProviderDetailScreen(
                provider: provider,
                distance: distance,
              ),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: category.color,
                child: Icon(
                  category.icon,
                  size: 30,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      provider.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            provider.location,
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ),
                      ],
                    ),
                    if (distance != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          '${distance!.toStringAsFixed(1)} km away',
                          style: const TextStyle(
                            color: Colors.blue,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: Colors.grey[400]),
            ],
          ),
        ),
      ),
    );
  }
}
