import 'dart:async';

import '../models/request.dart';

class DataRepository {
  static final StreamController<List<RequestInstaller>> _controller =
      StreamController<List<RequestInstaller>>.broadcast();

  static final List<RequestInstaller> _requests = [
    RequestInstaller(
      referenceId: 'demo-request-1',
      planId: 1,
      installerId: 37,
      userId: 1,
      lat: -22.2479,
      lng: -45.7086,
    ),
  ];

  Stream<List<RequestInstaller>> getStream() {
    Future<void>.microtask(_emit);
    return _controller.stream;
  }

  Future<RequestInstaller> addRequest(RequestInstaller request) async {
    final requestWithId = request.copyWith(
      referenceId: request.referenceId ??
          'local-${DateTime.now().microsecondsSinceEpoch}',
    );
    _requests.add(requestWithId);
    _emit();
    return requestWithId;
  }

  void updateRequest(RequestInstaller request) {
    final index = _requests.indexWhere(
      (item) => item.referenceId == request.referenceId,
    );
    if (index == -1) return;

    _requests[index] = request;
    _emit();
  }

  void deleteRequest(RequestInstaller request) {
    _requests.removeWhere((item) {
      if (request.referenceId != null) {
        return item.referenceId == request.referenceId;
      }

      return item.planId == request.planId &&
          item.installerId == request.installerId &&
          item.userId == request.userId;
    });
    _emit();
  }

  static void _emit() {
    if (!_controller.isClosed) {
      _controller.add(List<RequestInstaller>.unmodifiable(_requests));
    }
  }
}
