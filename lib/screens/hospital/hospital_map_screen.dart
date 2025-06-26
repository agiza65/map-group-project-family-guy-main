
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:Care_Plus/screens/hospital/hospital_map_logic.dart';

class HospitalMapScreen extends StatefulWidget {
  const HospitalMapScreen({super.key});

  @override
  State<HospitalMapScreen> createState() => _HospitalMapScreenState();
}

class _HospitalMapScreenState extends State<HospitalMapScreen> {
  final HospitalMapLogic _logic = HospitalMapLogic();
  // ignore: unused_field
  GoogleMapController? _mapController;

  LatLng? _current;
  Set<Marker> _markers = {};
  bool _showing = false;

  @override
  void initState() {
    super.initState();
    _initLocation();
  }

  Future<void> _initLocation() async {
    final loc = await _logic.getCurrentLocation();
    if (!mounted) return;
    setState(() => _current = loc);
  }

  Future<void> _toggleHospitals() async {
    if (_showing) {
      setState(() {
        _markers.clear();
        _showing = false;
      });
      return;
    }
    if (_current == null) return;

    final hosps = await _logic.fetchHospitals(_current!);
    final mks = _logic.createMarkers(hosps, context);
    if (!mounted) return;
    setState(() {
      _markers = Set.of(mks);
      _showing = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nearby Hospitals'),
        backgroundColor: Colors.teal,
      ),
      body: _current == null
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // 说明卡片
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Card(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text('📍 Nearby Hospitals',
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold)),
                          SizedBox(height: 6),
                          Text(
                              'View hospital information (2 km radius): phone, rating & opening hours.'),
                        ],
                      ),
                    ),
                  ),
                ),
                // Google Map
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.55,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(18),
                      child: GoogleMap(
                        initialCameraPosition:
                            CameraPosition(target: _current!, zoom: 15),
                        markers: _markers,
                        onMapCreated: (c) => _mapController = c,
                        myLocationEnabled: true,
                        myLocationButtonEnabled: true,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                // button
                Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: ElevatedButton.icon(
                    onPressed: _toggleHospitals,
                    icon: const Icon(Icons.local_hospital),
                    label:
                        Text(_showing ? 'Clear Hospitals' : 'Show Hospitals'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFB6E2B6),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
