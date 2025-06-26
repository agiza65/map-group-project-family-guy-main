import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class Hospital {
  final String name;
  final String address;
  final String phone;
  final String rating;
  final String openingHours;
  final LatLng location;

  const Hospital({
    required this.name,
    required this.address,
    required this.phone,
    required this.rating,
    required this.openingHours,
    required this.location,
  });
}

class HospitalMapLogic {
  HospitalMapLogic() : _apiKey = dotenv.env['GOOGLE_MAPS_API_KEY'];
  final String? _apiKey;

  // current location
  Future<LatLng?> getCurrentLocation() async {
    LocationPermission perm = await Geolocator.checkPermission();
    if (perm == LocationPermission.denied ||
        perm == LocationPermission.deniedForever) {
      perm = await Geolocator.requestPermission();
      if (perm != LocationPermission.always &&
          perm != LocationPermission.whileInUse) {
        return null;
      }
    }
    final pos = await Geolocator.getCurrentPosition();
    return LatLng(pos.latitude, pos.longitude);
  }

  // nearby place
  Future<List<Hospital>> fetchHospitals(LatLng center) async {
    if (_apiKey == null) return [];
    final loc = '${center.latitude},${center.longitude}';
    final nearbyUrl = Uri.parse(
      'https://maps.googleapis.com/maps/api/place/nearbysearch/json'
      '?location=$loc&radius=2000&type=hospital&key=$_apiKey',
    );

    final nearbyRes = await http.get(nearbyUrl);
    final results = (jsonDecode(nearbyRes.body)['results'] as List?) ?? [];

    final futures = results.map((p) async {
      final placeId = p['place_id'];
      final detailUrl = Uri.parse(
        'https://maps.googleapis.com/maps/api/place/details/json'
        '?place_id=$placeId'
        '&fields=formatted_phone_number,opening_hours&key=$_apiKey',
      );

      String phone = 'None';
      String opening = 'None';
      try {
        final det = await http.get(detailUrl);
        final detJson = jsonDecode(det.body)['result'];
        phone = detJson?['formatted_phone_number'] ?? 'None';
        final weekday = detJson?['opening_hours']?['weekday_text'];
        if (weekday is List && weekday.isNotEmpty) {
          opening = weekday.join('\n');
        }
      } catch (_) {}

      return Hospital(
        name: p['name'] ?? 'Unknown',
        address: p['vicinity'] ?? 'Unknown',
        phone: phone,
        rating: (p['rating'] ?? '0').toString(),
        openingHours: opening,
        location: LatLng(
          p['geometry']['location']['lat'],
          p['geometry']['location']['lng'],
        ),
      );
    });

    return Future.wait(futures);
  }

  //  Marker 工厂
  List<Marker> createMarkers(List<Hospital> list, BuildContext ctx) {
    return list.map((h) {
      return Marker(
        markerId: MarkerId(
          '${h.name}-${h.location.latitude}-${h.location.longitude}',
        ),
        position: h.location,
        infoWindow: InfoWindow(
          title: h.name,
          snippet: 'More detail',
          onTap: () => _showDetailDialog(ctx, h),
        ),
      );
    }).toList();
  }

  // infodialog
  void _showDetailDialog(BuildContext pageCtx, Hospital h) {
    showDialog(
      context: pageCtx,
      builder: (dialogCtx) {
        return AlertDialog(
          title: Text(h.name),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('📍 Address: ${h.address}'),
              Text('📞 Tel: ${h.phone}'),
              Text('⭐ Rating: ${h.rating}'),
              const SizedBox(height: 8),
              Text('🕒 Opening Hours:${h.openingHours}'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogCtx),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }
}
