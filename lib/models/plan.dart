class Plan {
  late final int id;
  late final String isp;
  late final String data_capacity;
  late final String download_speed;
  late final String upload_speed;
  late final String description;
  late final String price;
  late final String type_net;

  Plan({
    required this.id,
    required this.isp,
    required this.data_capacity,
    required this.download_speed,
    required this.upload_speed,
    required this.description,
    required this.price,
    required this.type_net,
  });

  // From JSON
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'isp': isp,
      'data_capacity': data_capacity,
      'download_speed': download_speed,
      'upload_speed': upload_speed,
      'description': description,
      'price': price,
      'type_net': type_net,
    };
  }

  // To JSON
  factory Plan.fromJson(Map<String, dynamic> json) {
    return Plan(
      id: json['id'] as int,
      isp: json['isp'] == null ? "Unknown" : json["isp"],
      data_capacity: json['data_capacity'] == null
          ? "Unknown"
          : json["data_capacity"].toString(),
      download_speed: json['download_speed'] == null
          ? "Unknown"
          : json["download_speed"].toString(),
      upload_speed: json['upload_speed'] == null
          ? "Unknown"
          : json["upload_speed"].toString(),
      description: json['description'] == null
          ? "No Description Avaliable"
          : json["description"],
      price: json['price_per_month'] == null
          ? "Unknown"
          : json["price_per_month"].toString(),
      type_net: json['type_of_internet'] == null
          ? "Unknown"
          : json["type_of_internet"],
    );
  }
}

final List<Plan> demoPlans = [
  Plan(
    id: 1,
    isp: 'Viasat',
    data_capacity: '150',
    download_speed: '50',
    upload_speed: '10',
    description: 'Residential satellite internet plan for remote areas.',
    price: '129.90',
    type_net: 'Satellite',
  ),
  Plan(
    id: 2,
    isp: 'Viasat',
    data_capacity: '300',
    download_speed: '100',
    upload_speed: '20',
    description: 'Higher throughput satellite internet plan.',
    price: '189.90',
    type_net: 'Satellite',
  ),
  Plan(
    id: 3,
    isp: 'SuperSat',
    data_capacity: '200',
    download_speed: '80',
    upload_speed: '15',
    description: 'Low-latency satellite package for homes and small offices.',
    price: '149.90',
    type_net: 'Satellite',
  ),
  Plan(
    id: 4,
    isp: 'TechWeb',
    data_capacity: '500',
    download_speed: '300',
    upload_speed: '100',
    description: 'Fiber plan used as a city benchmark in demo mode.',
    price: '119.90',
    type_net: 'Fiber',
  ),
  Plan(
    id: 5,
    isp: 'StirWay',
    data_capacity: '100',
    download_speed: '30',
    upload_speed: '8',
    description: 'Entry-level wireless broadband plan.',
    price: '89.90',
    type_net: 'Radio',
  ),
  Plan(
    id: 6,
    isp: 'Viva',
    data_capacity: '350',
    download_speed: '150',
    upload_speed: '40',
    description: 'Balanced urban broadband plan.',
    price: '109.90',
    type_net: 'Fiber',
  ),
];

Future<List<Plan>> fetchPlans(String state) async {
  return Future<List<Plan>>.delayed(
    const Duration(milliseconds: 250),
    () => List<Plan>.unmodifiable(demoPlans),
  );
}

Future<Plan> fetchPlansId(String id) async {
  return demoPlans.firstWhere(
    (plan) => plan.id.toString() == id,
    orElse: () => demoPlans.first,
  );
}
