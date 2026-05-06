import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../core/theme.dart';

import 'package:provider/provider.dart';
import '../../core/providers/user_provider.dart';
import '../../core/services/api_service.dart';
import '../../core/utils/extensions.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  static const String mapboxToken = 'pk.eyJ1Ijoicm9maWFyZWl2IiwiYSI6ImNsYW9xdHZ4cTB1OWYzcW1xaGVzZm84MGEifQ.xmNfOLtRRRWjk_skQzrR8A';
  static const String mapboxStyle = 'mapbox/streets-v11';
  
  final ApiService _apiService = ApiService();
  List<dynamic> _bins = [];
  bool _isLoading = true;
  
  // Center coordinates for Pamekasan (approximate)
  final LatLng _pamekasanCenter = const LatLng(-7.1517, 113.4822);

  @override
  void initState() {
    super.initState();
    _fetchBins();
  }

  Future<void> _fetchBins() async {
    try {
      final response = await _apiService.getSmartBins();
      if (response.data['success']) {
        setState(() {
          _bins = response.data['data'];
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

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
                markers: _bins.map((bin) {
                  final lat = double.tryParse(bin['latitude'].toString()) ?? 0.0;
                  final lng = double.tryParse(bin['longitude'].toString()) ?? 0.0;
                  final status = bin['status'] ?? 'offline';
                  
                  return Marker(
                    point: LatLng(lat, lng),
                    width: 40,
                    height: 40,
                    child: Container(
                      decoration: BoxDecoration(
                        color: status == 'online' ? AppColors.primary : (status == 'full' ? Colors.red : Colors.grey),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                          )
                        ],
                      ),
                      child: const Icon(LucideIcons.trash2, color: Colors.white, size: 20),
                    ),
                  );
                }).toList(),
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
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                      if (_isLoading)
                        const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (_bins.isEmpty && !_isLoading)
                    Text('Tidak ada SmartBin yang ditemukan', style: GoogleFonts.outfit(color: Colors.grey, fontSize: 12)),
                  ..._bins.take(2).map((bin) => _buildLocationItem(
                    bin['name'] ?? 'SmartBin', 
                    bin['location'] ?? '-',
                    bin['status'] ?? 'offline'
                  )),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildLocationItem(String name, String loc, String status) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: GoogleFonts.outfit(fontWeight: FontWeight.w600, fontSize: 13)),
                Text(loc, style: GoogleFonts.outfit(fontSize: 10, color: Colors.grey)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: status == 'online' ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              status.toUpperCase(),
              style: GoogleFonts.outfit(
                fontWeight: FontWeight.w900, 
                color: status == 'online' ? Colors.green : Colors.red, 
                fontSize: 9
              ),
            ),
          ),
        ],
      ),
    );
  }
}
