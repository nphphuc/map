import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';
import 'package:map/core/app_theme.dart';

import 'fixtures/places.dart';

import 'package:map/features/booking/data/geolocator_location_service.dart';
import 'package:map/features/booking/domain/device_location.dart';
import 'package:map/features/booking/domain/ride_models.dart';
import 'package:map/features/booking/presentation/booking_controller.dart';
import 'package:map/features/booking/presentation/booking_screen.dart';

const gpsPoint = GeoPoint(10.78123, 106.71234);
const gpsLocation = DeviceLocation(gpsPoint, accuracyMeters: 24.3);

class TestPlatform extends GeolocatorPlatform {
  bool serviceEnabled = true;
  LocationPermission permission = LocationPermission.whileInUse;
  LocationPermission requestedPermission = LocationPermission.whileInUse;
  Completer<LocationPermission>? permissionPending;
  Completer<Position>? positionPending;
  Exception? positionError;
  int permissionRequests = 0;
  int permissionChecks = 0;
  int positionRequests = 0;
  int streamRequests = 0;
  int streamCancellations = 0;
  LocationSettings? settings;

  @override
  Stream<Position> getPositionStream({LocationSettings? locationSettings}) {
    streamRequests++;
    settings = locationSettings;
    late StreamController<Position> stream;
    stream = StreamController<Position>(
      onListen: () async {
        try {
          final point = await getCurrentPosition(
            locationSettings: locationSettings,
          );
          if (!stream.isClosed) stream.add(point);
        } catch (error) {
          if (!stream.isClosed) stream.addError(error);
        }
      },
      onCancel: () {
        streamCancellations++;
        return stream.close();
      },
    );
    return stream.stream;
  }

  @override
  Future<bool> isLocationServiceEnabled() async => serviceEnabled;
  @override
  Future<LocationPermission> checkPermission() async {
    permissionChecks++;
    return permission;
  }

  @override
  Future<LocationPermission> requestPermission() async {
    permissionRequests++;
    return permissionPending?.future ?? requestedPermission;
  }

  @override
  Future<Position> getCurrentPosition({
    LocationSettings? locationSettings,
  }) async {
    positionRequests++;
    settings = locationSettings;
    if (positionError != null) throw positionError!;
    if (positionPending != null) return positionPending!.future;
    return Position(
      latitude: gpsPoint.latitude,
      longitude: gpsPoint.longitude,
      timestamp: DateTime(2026, 10, 5),
      accuracy: 24.3,
      altitude: 0,
      altitudeAccuracy: 1,
      heading: 0,
      headingAccuracy: 1,
      speed: 0,
      speedAccuracy: 1,
    );
  }
}

class TestLocationService implements DeviceLocationService {
  Completer<DeviceLocation>? pending;
  LocationFailure? failure;
  @override
  Future<DeviceLocation> currentLocation() async {
    if (failure != null) throw failure!;
    return pending?.future ?? gpsLocation;
  }
}

class LocationTestRepository implements BookingRepository {
  Completer<Place>? addressPending;
  bool reverseFails = false;
  int routeRequests = 0;
  int reverseRequests = 0;
  @override
  Future<Place> reverse(GeoPoint point) async {
    reverseRequests++;
    if (reverseFails) throw const MapServiceException('Offline');
    if (addressPending != null) return addressPending!.future;
    return Place(id: 'address', name: 'Địa chỉ GPS', address: '', point: point);
  }

  @override
  Future<TripRoute> route(Place pickup, Place destination) async {
    routeRequests++;
    return TripRoute(
      points: [pickup.point, destination.point],
      distanceMeters: 2200,
      durationSeconds: 200,
    );
  }

  @override
  Future<List<Place>> search(String query, GeoPoint? near) async => [];
  @override
  void dispose() {}
}

BookingController fixtureController(
  BookingRepository repository, {
  DeviceLocationService? locationService,
}) =>
    BookingController(repository, locationService: locationService)
      ..pickup = demoPickup;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    final fonts = FontLoader('Manrope')
      ..addFont(rootBundle.load('assets/fonts/Manrope.ttf'));
    await fonts.load();
  });

  test(
    'Web gets one bounded position without the unbounded permission call',
    () async {
      final platform = TestPlatform()..permission = LocationPermission.denied;
      final location = await GeolocatorLocationService(
        platform: platform,
        web: true,
      ).currentLocation();
      expect(platform.permissionRequests, 0);
      expect(platform.permissionChecks, 0);
      expect(platform.positionRequests, 1);
      expect(platform.streamRequests, 1);
      expect(platform.streamCancellations, 1);
      expect(platform.settings!.timeLimit, const Duration(seconds: 12));
      expect(location.point.cacheKey, gpsPoint.cacheKey);
      expect(location.accuracyMeters, 24.3);
    },
  );

  testWidgets(
    'Whole web operation times out even if the provider never replies',
    (tester) async {
      final platform = TestPlatform()..positionPending = Completer<Position>();
      final expectation = expectLater(
        GeolocatorLocationService(
          platform: platform,
          web: true,
        ).currentLocation(),
        throwsA(
          isA<LocationFailure>().having(
            (e) => e.kind,
            'kind',
            LocationFailureKind.timeout,
          ),
        ),
      );
      await tester.pump(const Duration(seconds: 21));
      await expectation;
      expect(platform.streamCancellations, 1);
    },
  );

  testWidgets('Native permission prompt is also bounded', (tester) async {
    final platform = TestPlatform()
      ..permission = LocationPermission.denied
      ..permissionPending = Completer<LocationPermission>();
    final expectation = expectLater(
      GeolocatorLocationService(
        platform: platform,
        web: false,
      ).currentLocation(),
      throwsA(
        isA<LocationFailure>().having(
          (e) => e.kind,
          'kind',
          LocationFailureKind.timeout,
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(seconds: 21));
    await expectation;
    expect(platform.streamCancellations, 0);
    expect(platform.positionRequests, 0);
  });

  test('Native first permission grant proceeds to one GPS fix', () async {
    final platform = TestPlatform()..permission = LocationPermission.denied;
    final location = await GeolocatorLocationService(
      platform: platform,
      web: false,
    ).currentLocation();
    expect(platform.permissionRequests, 1);
    expect(platform.positionRequests, 1);
    expect(platform.streamRequests, 0);
    expect(platform.settings!.accuracy, LocationAccuracy.high);
    expect(location.point.cacheKey, gpsPoint.cacheKey);
  });

  test('Native disabled service and permanent denial keep distinct recovery messages', () async {
    final platform = TestPlatform()..serviceEnabled = false;
    final service = GeolocatorLocationService(platform: platform, web: false);
    await expectLater(
      service.currentLocation(),
      throwsA(
        isA<LocationFailure>().having(
          (e) => e.kind,
          'kind',
          LocationFailureKind.serviceDisabled,
        ),
      ),
    );
    platform.serviceEnabled = true;
    platform.permission = LocationPermission.deniedForever;
    await expectLater(
      service.currentLocation(),
      throwsA(
        isA<LocationFailure>().having(
          (e) => e.kind,
          'kind',
          LocationFailureKind.permission,
        ),
      ),
    );
    expect(platform.positionRequests, 0);
    expect(platform.permissionRequests, 0);
  });

  test(
    'Web distinguishes permission denial and unavailable position',
    () async {
      final platform = TestPlatform()
        ..positionError = PermissionDeniedException('Denied');
      final service = GeolocatorLocationService(platform: platform, web: true);
      await expectLater(
        service.currentLocation(),
        throwsA(
          isA<LocationFailure>().having(
            (e) => e.kind,
            'kind',
            LocationFailureKind.permission,
          ),
        ),
      );
      platform.positionError = const FormatException('Position unavailable');
      await expectLater(
        service.currentLocation(),
        throwsA(
          isA<LocationFailure>().having(
            (e) => e.kind,
            'kind',
            LocationFailureKind.unavailable,
          ),
        ),
      );
    },
  );

  testWidgets(
    'GPS moves the map before slow reverse geocoding and retains the exact point',
    (tester) async {
      final repository = LocationTestRepository()
        ..addressPending = Completer<Place>();
      final controller = fixtureController(
        repository,
        locationService: TestLocationService(),
      );
      final pending = controller.locate();
      await tester.pump();
      expect(controller.locating, isFalse);
      expect(controller.pickup!.point.cacheKey, gpsPoint.cacheKey);
      expect(controller.locationNotice, contains('25 m'));
      repository.addressPending!.complete(demoPlaces.first);
      await pending;
      expect(controller.pickup!.name, 'Landmark 81');
      expect(controller.pickup!.point.latitude, gpsPoint.latitude);
      expect(controller.pickup!.point.longitude, gpsPoint.longitude);
      controller.dispose();
    },
  );

  test('Address failure does not discard a successful GPS fix', () async {
    final controller = fixtureController(
      LocationTestRepository()..reverseFails = true,
      locationService: TestLocationService(),
    );
    await controller.locate();
    expect(controller.pickup!.point.cacheKey, gpsPoint.cacheKey);
    expect(controller.locationFailure, isNull);
    expect(controller.locating, isFalse);
    controller.dispose();
  });

  test('GPS recomputes the route and quote using the new pickup', () async {
    final repository = LocationTestRepository();
    final controller = fixtureController(
      repository,
      locationService: TestLocationService(),
    );
    await controller.selectPlace(demoPlaces.first);
    await controller.locate();
    expect(repository.routeRequests, 2);
    expect(controller.tripRoute!.points.first.cacheKey, gpsPoint.cacheKey);
    expect(controller.fare, 34000);
    controller.dispose();
  });

  test('Late GPS cannot overwrite a manually selected pickup', () async {
    final service = TestLocationService()
      ..pending = Completer<DeviceLocation>();
    final repository = LocationTestRepository();
    final controller = fixtureController(repository, locationService: service);
    final pending = controller.locate();
    controller.openSearch(pickupField: true);
    await controller.selectPlace(demoPlaces[1]);
    service.pending!.complete(gpsLocation);
    await pending;
    expect(controller.pickup!.id, 'airport');
    expect(repository.reverseRequests, 0);
    expect(controller.locating, isFalse);
    controller.dispose();
  });

  test(
    'GPS in destination pin mode leaves the current pickup unchanged',
    () async {
      final controller = fixtureController(
        LocationTestRepository(),
        locationService: TestLocationService(),
      );
      controller.openSearch();
      controller.openPin();
      await controller.locate();
      expect(controller.pickup!.point.cacheKey, demoPickup.point.cacheKey);
      expect(controller.pendingPin!.cacheKey, gpsPoint.cacheKey);
      await controller.confirmPin();
      expect(controller.destination!.point.cacheKey, gpsPoint.cacheKey);
      expect(controller.pickup!.point.cacheKey, demoPickup.point.cacheKey);
      controller.dispose();
    },
  );

  test('Manual pin movement cancels a pending GPS request', () async {
    final service = TestLocationService()
      ..pending = Completer<DeviceLocation>();
    final controller = fixtureController(
      LocationTestRepository(),
      locationService: service,
    );
    controller.openSearch(pickupField: true);
    controller.openPin();
    final pending = controller.locate();
    controller.movePin(demoPlaces.first.point);
    service.pending!.complete(gpsLocation);
    await pending;
    expect(controller.pendingPin!.cacheKey, demoPlaces.first.point.cacheKey);
    expect(controller.locating, isFalse);
    controller.dispose();
  });

  testWidgets(
    'Location failure dialog fits a small phone and manual recovery works',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(320, 640));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.pumpWidget(
        MaterialApp(
          theme: rideTheme(),
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context)
                .copyWith(textScaler: const TextScaler.linear(1.3)),
            child: child!,
          ),
          home: BookingScreen(
            repository: LocationTestRepository(),
            locationService: TestLocationService()
              ..failure = const LocationFailure(
                LocationFailureKind.permission,
                'Trang chưa có quyền vị trí. Cho phép Vị trí trong quyền của trang, rồi thử lại.',
              ),
            mapBuilder: (_) => const ColoredBox(color: Colors.grey),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Vị trí của tôi'));
      await tester.pumpAndSettle();
      expect(find.text('Vị trí chưa sẵn sàng'), findsOneWidget);
      expect(find.text('Thử lại'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.tap(find.text('Chọn trên bản đồ'));
      await tester.pumpAndSettle();
      expect(find.text('Xác nhận điểm đón'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'Retry after permission recovery updates pickup and exits the dialog',
    (tester) async {
      final service = TestLocationService()
        ..failure = const LocationFailure(
          LocationFailureKind.permission,
          'Trang chưa có quyền vị trí.',
        );
      await tester.pumpWidget(
        MaterialApp(
          theme: rideTheme(),
          home: BookingScreen(
            repository: LocationTestRepository(),
            locationService: service,
            mapBuilder: (_) => const ColoredBox(color: Colors.grey),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Vị trí của tôi'));
      await tester.pumpAndSettle();
      service.failure = null;
      await tester.tap(find.text('Thử lại'));
      await tester.pumpAndSettle();
      expect(find.text('Vị trí chưa sẵn sàng'), findsNothing);
      expect(find.text('Đón tại Địa chỉ GPS'), findsOneWidget);
      expect(find.textContaining('Đã lấy vị trí'), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );
}
