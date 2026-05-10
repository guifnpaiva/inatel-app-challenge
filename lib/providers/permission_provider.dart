import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

enum LocationProviderStatus {
  Initial,
  Loading,
  Success,
  Error,
}

class LocationProvider with ChangeNotifier {
  late Position _userLocation;

  LocationProviderStatus _status = LocationProviderStatus.Initial;

  Position get userLocation => _userLocation;

  LocationProviderStatus get status => _status;

  Future<void> getLocation() async {
    try {
      final permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        _updateStatus(LocationProviderStatus.Loading);
        final requestedPermission = await Geolocator.requestPermission();
        if (requestedPermission == LocationPermission.whileInUse ||
            requestedPermission == LocationPermission.always) {
          await _loadCurrentPosition();
        } else {
          _updateStatus(LocationProviderStatus.Error);
        }
      } else {
        _updateStatus(LocationProviderStatus.Loading);
        await _loadCurrentPosition();
      }
    } catch (_) {
      _updateStatus(LocationProviderStatus.Error);
    }
  }

  Future<void> _loadCurrentPosition() async {
    _userLocation = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    ).timeout(const Duration(seconds: 20));
    _updateStatus(LocationProviderStatus.Success);
  }

  void _updateStatus(LocationProviderStatus status) {
    if (_status != status) {
      _status = status;
      notifyListeners();
    }
  }
}
