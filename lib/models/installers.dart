import 'package:google_maps_flutter/google_maps_flutter.dart';

class Installers {
  late final int id;
  late final String name;
  late final String rating;
  late final String pricePerKm;
  late final LatLng coordinates;

  Installers({
    required this.id,
    required this.name,
    required this.rating,
    required this.pricePerKm,
    required this.coordinates,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'rating': rating,
      'pricePerKm': pricePerKm,
      'coordinates': coordinates,
    };
  }

  factory Installers.fromJson(Map<String, dynamic> json) {
    return Installers(
      id: json['id'] as int,
      name: json['name'].toString(),
      rating: json['rating'].toString(),
      pricePerKm: json['pricePerKm'].toString(),
      coordinates: LatLng(json['lat'] as double, json["lng"] as double),
    );
  }
}

final List<Installers> demoInstallers = [
  Installers(
    id: 11,
    name: 'Ana Torres',
    rating: '9.7',
    pricePerKm: '2.2',
    coordinates: const LatLng(-22.2493, -45.7026),
  ),
  Installers(
    id: 24,
    name: 'Bruno Lima',
    rating: '9.4',
    pricePerKm: '2.0',
    coordinates: const LatLng(-22.2557, -45.6961),
  ),
  Installers(
    id: 37,
    name: 'Installer Test',
    rating: '9.0',
    pricePerKm: '2.5',
    coordinates: const LatLng(-22.2521628, -45.7037394),
  ),
  Installers(
    id: 42,
    name: 'Clara Souza',
    rating: '9.8',
    pricePerKm: '2.8',
    coordinates: const LatLng(-22.2468, -45.7112),
  ),
];

Future<List<Installers>> fetchInstallers(String id) async {
  return Future<List<Installers>>.delayed(
    const Duration(milliseconds: 250),
    () => List<Installers>.unmodifiable(demoInstallers),
  );
}
