import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';

import '../domain/device_location.dart';
import '../domain/ride_models.dart';

class GeolocatorLocationService implements DeviceLocationService {
  GeolocatorLocationService({
    GeolocatorPlatform? platform,
    bool? web,
    this.deadline = const Duration(seconds: 20),
  }) : _platform = platform ?? GeolocatorPlatform.instance,
       _web = web ?? kIsWeb;

  final GeolocatorPlatform _platform;
  final bool _web;
  final Duration deadline;

  LocationFailure get _permissionFailure => LocationFailure(
    LocationFailureKind.permission,
    _web
        ? 'Trang chưa có quyền vị trí. Cho phép Vị trí trong quyền của trang, rồi thử lại.'
        : 'Ứng dụng chưa có quyền vị trí. Cho phép Vị trí trong cài đặt ứng dụng, rồi thử lại.',
  );

  @override
  Future<DeviceLocation> currentLocation() async {
    try {
      // Includes permission waits: the browser's own timeout excludes time spent
      // waiting for a permission prompt, so it cannot bound the whole operation.
      return await _readLocation().timeout(deadline);
    } on LocationFailure {
      rethrow;
    } on PermissionDeniedException {
      throw _permissionFailure;
    } on LocationServiceDisabledException {
      throw const LocationFailure(
        LocationFailureKind.serviceDisabled,
        'Dịch vụ vị trí đang tắt. Bật Vị trí trên thiết bị, rồi thử lại.',
      );
    } on TimeoutException {
      throw const LocationFailure(
        LocationFailureKind.timeout,
        'Chưa nhận được vị trí. Kiểm tra quyền và dịch vụ Vị trí của thiết bị, rồi thử lại hoặc chọn điểm đón trên bản đồ.',
      );
    } catch (_) {
      throw LocationFailure(
        LocationFailureKind.unavailable,
        _web
            ? 'Trình duyệt chưa cung cấp được vị trí. Kiểm tra Vị trí của thiết bị và quyền trang; mở bằng Chrome/Edge qua localhost hoặc HTTPS nếu cần.'
            : 'Thiết bị chưa cung cấp được vị trí. Kiểm tra GPS và kết nối mạng, hoặc chọn điểm đón trên bản đồ.',
      );
    }
  }

  Future<DeviceLocation> _readLocation() async {
    if (!_web) {
      if (!await _platform.isLocationServiceEnabled()) {
        throw const LocationFailure(
          LocationFailureKind.serviceDisabled,
          'Dịch vụ vị trí đang tắt. Bật Vị trí trên thiết bị, rồi thử lại.',
        );
      }
      var permission = await _platform.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await _platform.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        throw _permissionFailure;
      }
    }
    // On web getCurrentPosition itself requests permission. requestPermission()
    // in geolocator_web 4.1.4 makes an additional, unbounded position request.
    // First cancels the web watch after a fix or stream error. A Dart stream
    // deadline also clears the watch if the browser never supplies a position.
    // This avoids relying on geolocator_web 4.1.4's browser timeout conversion.
    final position = _web
        ? await _platform
              .getPositionStream(
                locationSettings: WebSettings(
                  accuracy: LocationAccuracy.high,
                  timeLimit: const Duration(seconds: 12),
                  maximumAge: Duration.zero,
                ),
              )
              .timeout(deadline)
              .first
        : await _platform.getCurrentPosition(
            locationSettings: const LocationSettings(
              accuracy: LocationAccuracy.high,
              timeLimit: Duration(seconds: 12),
            ),
          );
    if (!position.latitude.isFinite ||
        !position.longitude.isFinite ||
        position.latitude.abs() > 90 ||
        position.longitude.abs() > 180) {
      throw const FormatException('Invalid location coordinates');
    }
    return DeviceLocation(
      GeoPoint(position.latitude, position.longitude),
      accuracyMeters: position.accuracy,
    );
  }
}
