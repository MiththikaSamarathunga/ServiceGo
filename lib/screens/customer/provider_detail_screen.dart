import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/services.dart';
import 'dart:io' show Platform;
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:provider/provider.dart';
import '../../models/service_provider_model.dart';
import '../../services/favorites_service.dart';
import '../../providers/auth_provider.dart';

class ProviderDetailScreen extends StatefulWidget {
  final ServiceProviderModel provider;
  final double? distance;

  const ProviderDetailScreen({
    super.key,
    required this.provider,
    this.distance,
  });

  @override
  State<ProviderDetailScreen> createState() => _ProviderDetailScreenState();
}

class _ProviderDetailScreenState extends State<ProviderDetailScreen> {
  final FavoritesService _favoritesService = FavoritesService();
  bool _isFavorite = false;

  @override
  void initState() {
    super.initState();
    _checkFavoriteStatus();
  }

  Future<void> _checkFavoriteStatus() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userId = authProvider.firebaseUser?.uid;
    
    if (userId != null) {
      final isFav = await _favoritesService.isFavorite(userId, widget.provider.uid);
      setState(() {
        _isFavorite = isFav;
      });
    }
  }

  Future<void> _toggleFavorite() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userId = authProvider.firebaseUser?.uid;
    
    if (userId != null) {
      if (_isFavorite) {
        await _favoritesService.removeFavorite(userId, widget.provider.uid);
      } else {
        await _favoritesService.addFavorite(userId, widget.provider.uid);
      }
      setState(() {
        _isFavorite = !_isFavorite;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _isFavorite
                  ? 'Added to favorites'
                  : 'Removed from favorites',
            ),
          ),
        );
      }
    }
  }

  Future<void> _makePhoneCall() async {
    final raw = widget.provider.phone;

    if (raw.trim().isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No phone number available for this provider')),
        );
      }
      return;
    }

    final cleaned = raw.replaceAll(RegExp(r"[^0-9+]"), '');
    if (cleaned.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Provider phone number is invalid')),
        );
      }
      return;
    }

    final Uri phoneUri = Uri(scheme: 'tel', path: cleaned);

    try {
      if (Platform.isAndroid) {
        final status = await Permission.phone.status;
        if (!status.isGranted) {
          final result = await Permission.phone.request();
          if (!result.isGranted) {
            if (result.isPermanentlyDenied) {
              if (mounted) {
                final openSettings = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Permission required'),
                    content: const Text('Call permission is blocked. Open app settings to enable direct calls?'),
                    actions: [
                      TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Cancel')),
                      TextButton(onPressed: () => Navigator.of(ctx).pop(true), child: const Text('Open Settings')),
                    ],
                  ),
                );

                if (openSettings == true) {
                  await openAppSettings();
                }
              }
            }
            if (await canLaunchUrl(phoneUri)) {
              await launchUrl(phoneUri, mode: LaunchMode.externalApplication);
            } else {
              await Clipboard.setData(ClipboardData(text: cleaned));
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Call permission denied. Number copied to clipboard: $cleaned')),
                );
              }
            }
            return;
          }
        }
        final didCall = await FlutterPhoneDirectCaller.callNumber(cleaned);
        if (didCall == null || didCall == false) {
          if (await canLaunchUrl(phoneUri)) {
            await launchUrl(phoneUri, mode: LaunchMode.externalApplication);
          } else {
            await Clipboard.setData(ClipboardData(text: cleaned));
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Direct call failed. Number copied to clipboard: $cleaned')),
              );
            }
          }
        }
        return;
      }

      if (await canLaunchUrl(phoneUri)) {
        final launched = await launchUrl(phoneUri, mode: LaunchMode.externalApplication);
        if (!launched && mounted) {
          await Clipboard.setData(ClipboardData(text: cleaned));
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Could not open dialer. Number copied to clipboard: $cleaned')),
            );
          }
        }
        return;
      }

      await Clipboard.setData(ClipboardData(text: cleaned));
      if (mounted) {
        showDialog<void>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Call not available'),
            content: Text('Your device cannot open the phone dialer. The number has been copied to the clipboard: $cleaned'),
            actions: [
              TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('OK')),
            ],
          ),
        );
      }
    } catch (e) {
      await Clipboard.setData(ClipboardData(text: cleaned));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error opening dialer/direct-call. Number copied to clipboard: $cleaned')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Provider Details'),
        actions: [
          IconButton(
            icon: Icon(
              _isFavorite ? Icons.favorite : Icons.favorite_border,
              color: _isFavorite ? Colors.red : null,
            ),
            onPressed: _toggleFavorite,
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(32),
                color: Colors.blue,
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 60,
                      backgroundColor: Colors.white,
                      child: Text(
                        widget.provider.name[0].toUpperCase(),
                        style: const TextStyle(
                          fontSize: 48,
                          color: Colors.blue,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      widget.provider.name,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.provider.serviceCategory
                          .replaceAll('_', ' ')
                          .toUpperCase(),
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Contact Information',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ListTile(
                      leading: const Icon(Icons.phone, color: Colors.blue),
                      title: const Text('Phone'),
                      subtitle: Text(widget.provider.phone),
                      contentPadding: EdgeInsets.zero,
                    ),
                    ListTile(
                      leading: const Icon(Icons.email, color: Colors.blue),
                      title: const Text('Email'),
                      subtitle: Text(widget.provider.email),
                      contentPadding: EdgeInsets.zero,
                    ),
                    ListTile(
                      leading: const Icon(Icons.location_on, color: Colors.blue),
                      title: const Text('Location'),
                      subtitle: Text(widget.provider.location),
                      contentPadding: EdgeInsets.zero,
                    ),
                    if (widget.distance != null)
                      ListTile(
                        leading: const Icon(Icons.directions, color: Colors.blue),
                        title: const Text('Distance'),
                        subtitle: Text('${widget.distance!.toStringAsFixed(1)} km away'),
                        contentPadding: EdgeInsets.zero,
                      ),

                    if (widget.provider.description != null &&
                        widget.provider.description!.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      const Text(
                        'About',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        widget.provider.description!,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[700],
                        ),
                      ),
                    ],
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _makePhoneCall,
                        icon: const Icon(Icons.phone),
                        label: const Text('Call Now'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
