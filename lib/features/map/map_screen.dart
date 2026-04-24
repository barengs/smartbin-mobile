import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../core/theme.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  static const String mapboxToken = 'pk.eyJ1Ijoicm9maWFyZWl2IiwiYSI6ImNsYW9xdHZ4cTB1OWYzcW1xaGVzZm84MGEifQ.xmNfOLtRRRWjk_skQzrR8A';
  static const String mapboxStyle = 'mapbox/streets-v11';
  
  // Center coordinates for Pamekasan (approximate)
  final LatLng _pamekasanCenter = const LatLng(-7.1517, 113.4822);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'LOKASI SMARTBIN',
          style: GoogleFonts.outfit(fontWeight: FontWeight.w900, fontSize: 16, letterSpacing: 1),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Stack(
        children: [
          FlutterMap(
            options: MapOptions(
              initialCenter: _pamekasanCenter,
              initialZoom: 13.0,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://api.mapbox.com/styles/v1/{style}/tiles/{z}/{x}/{y}?access_token={accessToken}',
                additionalOptions: const {
                  'style': mapboxStyle,
                  'accessToken': mapboxToken,
                },
                userAgentPackageName: 'com.example.smartbin',
              ),
              MarkerLayer(
                markers: [
                  Marker(
                    point: _pamekasanCenter,
                    width: 40,
                    height: 40,
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.5),
                            blurRadius: 10,
                          )
                        ],
                      ),
                      child: const Icon(LucideIcons.trash2, color: Colors.white, size: 20),
                    ),
                  ),
                  Marker(
                    point: const LatLng(-7.1600, 113.4900),
                    width: 40,
                    height: 40,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.orange,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: const Icon(LucideIcons.trash2, color: Colors.white, size: 20),
                    ),
                  ),
                ],
              ),
            ],
          ),
          
          // List overlay
          Positioned(
            bottom: 24,
            left: 24,
            right: 24,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 20)
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      const Icon(LucideIcons.navigation, color: AppColors.primary),
                      const SizedBox(width: 12),
                      Text(
                        'SmartBin Terdekat',
                        style: GoogleFonts.outfit(fontWeight: FontWeight.w900),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildLocationItem('SmartBin Alun-alun', '1.2 km'),
                  const Divider(),
                  _buildLocationItem('SmartBin RSUD', '2.5 km'),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildLocationItem(String name, String dist) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(name, style: GoogleFonts.outfit(fontWeight: FontWeight.w600, fontSize: 13)),
          Text(dist, style: GoogleFonts.outfit(fontWeight: FontWeight.w900, color: AppColors.primary, fontSize: 12)),
        ],
      ),
    );
  }
}
