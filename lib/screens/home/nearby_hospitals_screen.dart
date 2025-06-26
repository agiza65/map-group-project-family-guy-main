import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

class NearbyHospitalsScreen extends StatelessWidget {
  NearbyHospitalsScreen({Key? key}) : super(key: key);

  final List<Map<String, dynamic>> mockHospitals = [
    {
      'name': 'City Hospital',
      'lat': 37.4221,
      'lng': -122.0841,
    },
    {
      'name': 'Sunrise Clinic',
      'lat': 37.4218,
      'lng': -122.0839,
    },
    {
      'name': 'St. Mary\'s Medical',
      'lat': 37.4215,
      'lng': -122.0852,
    },
  ];

  Future<void> _launchMaps(double lat, double lng) async {
    final Uri url = Uri.parse("https://www.google.com/maps/dir/?api=1&destination=$lat,$lng");
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch Maps');
    }
  }

  @override
  Widget build(BuildContext context) {
    final LatLng userLocation = LatLng(37.4220, -122.0841); // Dummy user location

    return Scaffold(
      appBar: AppBar(
        title: const Text('Nearby Hospitals'),
        backgroundColor: Colors.teal,
      ),
      body: Stack(
        children: [
          FlutterMap(
            options: MapOptions(
              center: userLocation,
              zoom: 16.0,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                subdomains: const ['a', 'b', 'c'],
              ),
              MarkerLayer(
                markers: [
                  Marker(
                    width: 40,
                    height: 40,
                    point: userLocation,
                    child: const Icon(Icons.person_pin_circle, color: Colors.blue, size: 40),
                  ),
                  ...mockHospitals.map((hospital) => Marker(
                        width: 60,
                        height: 60,
                        point: LatLng(hospital['lat'], hospital['lng']),
                        child: GestureDetector(
                          onTap: () => _showHospitalPopup(context, hospital),
                          child: Column(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(4),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black26,
                                      blurRadius: 3,
                                    )
                                  ],
                                ),
                                child: Text(
                                  hospital['name'],
                                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                                ),
                              ),
                              const Icon(Icons.location_on, color: Colors.red, size: 36),
                            ],
                          ),
                        ),
                      ))
                ],
              )
            ],
          ),
        ],
      ),
    );
  }

  void _showHospitalPopup(BuildContext context, Map<String, dynamic> hospital) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 40),
        child: Wrap(
          children: [
            Center(
              child: Text(
                hospital['name'],
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () => _launchMaps(hospital['lat'], hospital['lng']),
              icon: const Icon(Icons.navigation),
              label: const Text('Navigate Here'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
