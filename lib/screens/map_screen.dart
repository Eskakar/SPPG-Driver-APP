import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:dio/dio.dart';

class MapScreen extends StatefulWidget {
  final double driverLat;
  final double driverLng;
  final double sekolahLat;
  final double sekolahLng;

  const MapScreen({
    super.key,
    required this.driverLat,
    required this.driverLng,
    required this.sekolahLat,
    required this.sekolahLng,
  });

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  List<LatLng> routePoints = [];
  double distanceKm = 0;

  @override
  void initState() {
    super.initState();
    fetchRoute();
  }

  Future<void> fetchRoute() async {
    try {
      final url = "http://router.project-osrm.org/route/v1/driving/"
          "${widget.driverLng},${widget.driverLat};"
          "${widget.sekolahLng},${widget.sekolahLat}"
          "?overview=full&geometries=geojson";

      final res = await Dio().get(url);
      final data = res.data;
      final routes = data["routes"];

      if (routes == null || routes.isEmpty) {
        debugPrint("NO ROUTE FOUND");
        return;
      }

      final coords = routes[0]["geometry"]["coordinates"];

      setState(() {
        routePoints = coords
            .map<LatLng>((c) => LatLng(c[1].toDouble(), c[0].toDouble()))
            .toList();
        distanceKm = (data["routes"][0]["distance"] ?? 0) / 1000;
      });
    } catch (e) {
      debugPrint("ROUTE ERROR: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Tracking Map")),
      body: Stack(
        children: [
          FlutterMap(
            options: MapOptions(
              initialCenter: LatLng(widget.driverLat, widget.driverLng),
              initialZoom: 14,
            ),
            children: [
              // MENGGUNAKAN OPENSTREETMAP (Gratis, tidak butuh API Key)
              TileLayer(
                urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
                userAgentPackageName: 'com.sppg.driver.app',
              ),

              // Garis Rute (Polyline)
              if (routePoints.isNotEmpty)
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: routePoints,
                      strokeWidth: 5,
                      color: Colors.blue,
                    ),
                  ],
                ),

              // Marker Driver & Sekolah
              MarkerLayer(
                markers: [
                  Marker(
                    point: LatLng(widget.driverLat, widget.driverLng),
                    width: 40,
                    height: 40,
                    child: const Icon(Icons.directions_car, color: Colors.blue, size: 35),
                  ),
                  Marker(
                    point: LatLng(widget.sekolahLat, widget.sekolahLng),
                    width: 40,
                    height: 40,
                    child: const Icon(Icons.school, color: Colors.red, size: 35),
                  ),
                ],
              ),
            ],
          ),

          // Card Info Jarak agar lebih rapi
          Positioned(
            top: 10,
            left: 10,
            right: 10,
            child: Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Text(
                  "Jarak ke Sekolah: ${distanceKm.toStringAsFixed(2)} km",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}