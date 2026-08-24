/// Bảng thành phố nhúng sẵn để đặt toạ độ cho home.
///
/// Cố ý KHÔNG xin quyền vị trí thiết bị: thời tiết chỉ cần độ chính xác cấp
/// thành phố, còn quyền GPS kéo theo purpose string, privacy manifest và câu
/// hỏi từ App Review về việc tại sao app điều khiển rèm cần biết vị trí.
class CityEntry {
  final String name;
  final String country;
  final double latitude;
  final double longitude;

  const CityEntry(this.name, this.country, this.latitude, this.longitude);
}

const List<CityEntry> kCityCatalog = [
  // Việt Nam — thị trường chính
  CityEntry('Ho Chi Minh City', 'Vietnam', 10.8231, 106.6297),
  CityEntry('Hanoi', 'Vietnam', 21.0278, 105.8342),
  CityEntry('Da Nang', 'Vietnam', 16.0544, 108.2022),
  CityEntry('Hai Phong', 'Vietnam', 20.8449, 106.6881),
  CityEntry('Can Tho', 'Vietnam', 10.0452, 105.7469),
  CityEntry('Nha Trang', 'Vietnam', 12.2388, 109.1967),
  // Đông Nam Á
  CityEntry('Singapore', 'Singapore', 1.3521, 103.8198),
  CityEntry('Bangkok', 'Thailand', 13.7563, 100.5018),
  CityEntry('Kuala Lumpur', 'Malaysia', 3.1390, 101.6869),
  CityEntry('Jakarta', 'Indonesia', -6.2088, 106.8456),
  CityEntry('Manila', 'Philippines', 14.5995, 120.9842),
  // Đông Á
  CityEntry('Tokyo', 'Japan', 35.6762, 139.6503),
  CityEntry('Osaka', 'Japan', 34.6937, 135.5023),
  CityEntry('Seoul', 'South Korea', 37.5665, 126.9780),
  CityEntry('Busan', 'South Korea', 35.1796, 129.0756),
  CityEntry('Beijing', 'China', 39.9042, 116.4074),
  CityEntry('Shanghai', 'China', 31.2304, 121.4737),
  CityEntry('Guangzhou', 'China', 23.1291, 113.2644),
  CityEntry('Shenzhen', 'China', 22.5431, 114.0579),
  CityEntry('Hong Kong', 'Hong Kong', 22.3193, 114.1694),
  CityEntry('Taipei', 'Taiwan', 25.0330, 121.5654),
  CityEntry('Kaohsiung', 'Taiwan', 22.6273, 120.3014),
  // Nam Á
  CityEntry('Mumbai', 'India', 19.0760, 72.8777),
  CityEntry('New Delhi', 'India', 28.6139, 77.2090),
  // Trung Đông
  CityEntry('Dubai', 'United Arab Emirates', 25.2048, 55.2708),
  CityEntry('Abu Dhabi', 'United Arab Emirates', 24.4539, 54.3773),
  CityEntry('Riyadh', 'Saudi Arabia', 24.7136, 46.6753),
  CityEntry('Doha', 'Qatar', 25.2854, 51.5310),
  CityEntry('Cairo', 'Egypt', 30.0444, 31.2357),
  // Châu Âu
  CityEntry('London', 'United Kingdom', 51.5074, -0.1278),
  CityEntry('Paris', 'France', 48.8566, 2.3522),
  CityEntry('Berlin', 'Germany', 52.5200, 13.4050),
  CityEntry('Munich', 'Germany', 48.1351, 11.5820),
  CityEntry('Frankfurt', 'Germany', 50.1109, 8.6821),
  CityEntry('Madrid', 'Spain', 40.4168, -3.7038),
  CityEntry('Barcelona', 'Spain', 41.3874, 2.1686),
  CityEntry('Rome', 'Italy', 41.9028, 12.4964),
  CityEntry('Milan', 'Italy', 45.4642, 9.1900),
  CityEntry('Lisbon', 'Portugal', 38.7223, -9.1393),
  CityEntry('Porto', 'Portugal', 41.1579, -8.6291),
  CityEntry('Amsterdam', 'Netherlands', 52.3676, 4.9041),
  CityEntry('Zurich', 'Switzerland', 47.3769, 8.5417),
  CityEntry('Vienna', 'Austria', 48.2082, 16.3738),
  CityEntry('Moscow', 'Russia', 55.7558, 37.6173),
  CityEntry('Saint Petersburg', 'Russia', 59.9311, 30.3609),
  // Bắc Mỹ
  CityEntry('New York', 'United States', 40.7128, -74.0060),
  CityEntry('Los Angeles', 'United States', 34.0522, -118.2437),
  CityEntry('San Francisco', 'United States', 37.7749, -122.4194),
  CityEntry('Chicago', 'United States', 41.8781, -87.6298),
  CityEntry('Seattle', 'United States', 47.6062, -122.3321),
  CityEntry('Toronto', 'Canada', 43.6532, -79.3832),
  CityEntry('Vancouver', 'Canada', 49.2827, -123.1207),
  // Mỹ Latin
  CityEntry('Mexico City', 'Mexico', 19.4326, -99.1332),
  CityEntry('Bogota', 'Colombia', 4.7110, -74.0721),
  CityEntry('Lima', 'Peru', -12.0464, -77.0428),
  CityEntry('Santiago', 'Chile', -33.4489, -70.6693),
  CityEntry('Buenos Aires', 'Argentina', -34.6037, -58.3816),
  CityEntry('Sao Paulo', 'Brazil', -23.5505, -46.6333),
  CityEntry('Rio de Janeiro', 'Brazil', -22.9068, -43.1729),
  // Châu Đại Dương
  CityEntry('Sydney', 'Australia', -33.8688, 151.2093),
  CityEntry('Melbourne', 'Australia', -37.8136, 144.9631),
  CityEntry('Auckland', 'New Zealand', -36.8485, 174.7633),
];

/// Tìm theo tên hoặc quốc gia, bỏ qua hoa thường và khoảng trắng thừa.
List<CityEntry> searchCities(String query) {
  final q = query.trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' ');
  if (q.isEmpty) return kCityCatalog;
  return kCityCatalog
      .where((c) =>
          c.name.toLowerCase().contains(q) ||
          c.country.toLowerCase().contains(q))
      .toList();
}
