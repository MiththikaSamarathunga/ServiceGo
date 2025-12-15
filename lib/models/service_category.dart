import 'package:flutter/material.dart';

class ServiceCategory {
  final String id;
  final String name;
  final IconData icon;
  final Color color;

  ServiceCategory({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
  });

  static List<ServiceCategory> getCategories() {
    return [
      ServiceCategory(
        id: 'electrician',
        name: 'Electrician',
        icon: Icons.electrical_services,
        color: Colors.amber,
      ),
      ServiceCategory(
        id: 'plumber',
        name: 'Plumber',
        icon: Icons.plumbing,
        color: Colors.blue,
      ),
      ServiceCategory(
        id: 'appliance_repair',
        name: 'Appliance Repair',
        icon: Icons.build,
        color: Colors.green,
      ),
    ];
  }
}
