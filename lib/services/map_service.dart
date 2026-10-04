import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/location_model.dart';

class MapService {
  // Danh sách fallback offline nhanh
  static final Map<String, LocationModel> _quickPlaces = {
    'ha noi': LocationModel(latitude: 21.028511, longitude: 105.854444, displayName: 'Hồ Hoàn Kiếm, Hà Nội'),
    'da nang': LocationModel(latitude: 16.054407, longitude: 108.202167, displayName: 'Thành phố Đà Nẵng'),
    'ho chi minh': LocationModel(latitude: 10.776889, longitude: 106.700806, displayName: 'Chợ Bến Thành, TP. Hồ Chí Minh'),
    'sai gon': LocationModel(latitude: 10.776889, longitude: 106.700806, displayName: 'Chợ Bến Thành, TP. Hồ Chí Minh'),
    'landmark 81': LocationModel(latitude: 10.7951, longitude: 106.7218, displayName: 'Landmark 81, TP. Hồ Chí Minh'),
  };

  Future<LocationModel?> searchLocation(String query) async {
    final cleanQuery = query.trim().toLowerCase();
    if (cleanQuery.isEmpty) return null;

    // Kiểm tra danh sách có sẵn
    for (var key in _quickPlaces.keys) {
      if (cleanQuery.contains(key)) {
        return _quickPlaces[key];
      }
    }

    // Gọi API qua Proxy tránh CORS khi chạy trên Web
    final targetUrl = 'https://nominatim.openstreetmap.org/search?q=${Uri.encodeComponent(query)}&format=json&limit=1';
    final proxyUrl = Uri.parse('https://api.allorigins.win/get?url=${Uri.encodeComponent(targetUrl)}');

    try {
      final response = await http.get(proxyUrl).timeout(const Duration(seconds: 8));
      if (response.statusCode == 200) {
        final Map<String, dynamic> proxyData = jsonDecode(response.body);
        final List results = jsonDecode(proxyData['contents']);
        if (results.isNotEmpty) {
          return LocationModel.fromJson(results[0]);
        }
      }
    } catch (e) {
      return null;
    }
    return null;
  }
}