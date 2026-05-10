import 'dart:core';

class RequestInstaller {
  late int planId;
  late int installerId;
  late int userId;
  late double lat;
  late double lng;
  String? referenceId;

  RequestInstaller({
    required this.planId,
    required this.installerId,
    required this.userId,
    required this.lat,
    required this.lng,
    this.referenceId,
  });

  Map<String, dynamic> toJson() {
    return {
      'planId': planId,
      'installerId': installerId,
      'userId': userId,
      'lat': lat,
      'lng': lng,
    };
  }

  factory RequestInstaller.fromJson(Map<String, dynamic> json) {
    return RequestInstaller(
      planId: json['planId'] as int,
      installerId: json['installerId'] as int,
      userId: json['userId'] as int,
      lat: json['lat'] as double,
      lng: json['lng'] as double,
    );
  }

  RequestInstaller copyWith({
    int? planId,
    int? installerId,
    int? userId,
    double? lat,
    double? lng,
    String? referenceId,
  }) {
    return RequestInstaller(
      planId: planId ?? this.planId,
      installerId: installerId ?? this.installerId,
      userId: userId ?? this.userId,
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
      referenceId: referenceId ?? this.referenceId,
    );
  }
}
