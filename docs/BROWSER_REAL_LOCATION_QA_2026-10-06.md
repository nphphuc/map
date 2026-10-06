# QA: vị trí thật và tìm kiếm đã chạy trong Codex

Ngày 06/10/2026. Base `d144781`, nhánh `codex/web-location-search-fix`.
URL đang chạy: http://127.0.0.1:52341/.

## Kết quả kiểm tra trực tiếp

| Luồng | Kết quả |
| --- | --- |
| Mở lại ứng dụng | Điểm đón tự lấy từ Windows Location, map chuyển đến tọa độ thiết bị |
| Nguồn thực tế | Windows WiFi; lần mở đầu khoảng 125 m, lần reload cuối 183 m |
| Bấm Vị trí của tôi | Lấy lại dữ liệu Windows; loading kết thúc, không có dialog lỗi |
| Gõ Landmark 81 | Hai kết quả OSM thật xuất hiện, không nhấn Enter |
| Chọn tòa nhà Landmark 81 | Tuyến OSRM thật 16,3 km, 19 phút |
| Giá demo | Tiêu chuẩn 246.000 ₫; Comfort 268.000 ₫; Xe lớn 307.000 ₫ |
| Console ứng dụng | Không có error/warn trong lần kiểm tra |
| Flutter tests | 51/51 PASS |
| Flutter analyze | Không có vấn đề |
| Build web release với companion | PASS, 22,4 giây |

Lần gọi relay tìm kiếm độc lập trả hai địa điểm trong 877 ms. Đây là số đo
trong phiên, không phải cam kết độ trễ của nhà cung cấp. Giá là cấu hình demo,
thời gian OSRM chưa tính giao thông trực tiếp.

Không override tọa độ trình duyệt, không cấp quyền bằng CDP, không đặt tọa độ
246 Võ Văn Hát trong code. Sai số là dữ liệu Windows báo; chưa xác minh với
thiết bị đo GPS độc lập và không thể khẳng định sai số dưới 1 m.

## Cách sửa và phạm vi

- Preview Windows chọn nguồn Windows Location qua companion local. Windows
  kiểm tra quyền vị trí của ứng dụng desktop. Quyền Geolocation của tab Codex
  được giữ nguyên; preview không phụ thuộc trạng thái quyền của nguồn khác.
- Script dùng `GetGeopositionAsync(maximumAge=0, timeout=15 s)`, bỏ vị trí Default
  và fix cũ hơn 30 giây. Client kiểm tra timestamp, accuracy và tọa độ hợp lệ.
  Không lưu điểm đón cố định hoặc cache tọa độ qua lần retry.
- Companion chỉ bind 127.0.0.1. Endpoint đọc vị trí yêu cầu POST, đúng Origin và
  header hành động; chặn cross-site, không mở CORS, không log tọa độ. Đã kiểm thử
  từ chối origin khác, GET và thiếu header trước khi gọi nguồn vị trí.
- Photon Komoot không trả dữ liệu dù TLS kết nối được trong phiên này. Preview
  dùng relay cố định đến Photon KoalaSec, được chủ instance công bố công khai.
  Relay giải quyết thiếu CORS của instance này. Query lọc Việt Nam, không chuyển
  tọa độ thiết bị tới server tìm kiếm; cache được xếp gần điểm đón trên thiết bị.
- Reverse geocoding vẫn dùng provider Komoot hiện có. Khi provider lỗi, tọa độ
  thật vẫn dùng được và tên điểm đón giữ là “Vị trí của bạn”. Tên POI gần đó không
  được biến thành tên vị trí chính xác của người dùng.
- Android/iOS tiếp tục dùng geolocator native. Web deploy thông thường vẫn dùng
  browser Geolocation; companion chỉ bật bằng `LOCAL_DEVICE_LOCATION=true` trên
  loopback. Phiên này chỉ xác minh GPS của bản preview Windows, không xác minh
  GPS trên điện thoại hoặc web deploy.

Chạy lại: `./tool/run_web.ps1`. Script build kèm hai dart-define và chạy server
local. Có thể đổi port bằng `-Port`; dữ liệu vị trí và URL relay không phụ thuộc
địa chỉ hoặc thành phố được hardcode.

## Đối chiếu ETA với Google Maps

Chuyến đến “Hẻm 93 Bùi Văn Bình” trong demo hiển thị 29,9 km / 31 phút;
ảnh Google Maps đến “93 Bùi Văn Bình” hiển thị tuyến đề xuất 30,2 km / 59 phút
và cảnh báo tránh đường đóng trên Mỹ Phước–Tân Vạn. Điểm đón của hai bên
chênh khoảng 9 m theo URL tuyến đã tải; chưa xác nhận tọa độ điểm đến trùng nhau.

Demo lấy distance/duration từ OSRM, chuyển mét sang km và giây sang phút;
chưa tích hợp giao thông trực tiếp hoặc nguồn cảnh báo đường đóng.
Thời gian và giờ đến đang hiển thị chưa được xác minh là ETA theo giao thông
thực tế. Kết quả kiểm thử bên trên xác nhận hoạt động của flow, không xác nhận
ETA tương đương Google Maps/Uber. Đây là giới hạn còn tồn tại trong bản này.

## Bằng chứng giữ tại máy

Ảnh preview có vị trí thiết bị và log kiểm tra được giữ local, không đưa vào
commit của nhánh này.

- `previews/codex-real-location-2026-10-06.jpg`: vị trí thật khi mở ứng dụng.
- `previews/codex-live-search-fixed-2026-10-06.jpg`: live search có kết quả.
- `previews/codex-real-route-fixed-2026-10-06.jpg`: tuyến, khoảng cách và giá.
- `browser-real-location-tests-2026-10-06.log`
- `browser-real-location-analyze-2026-10-06.log`
- `browser-real-location-web-build-2026-10-06.log`

Nguồn: [Windows GetGeopositionAsync](https://learn.microsoft.com/en-us/uwp/api/windows.devices.geolocation.geolocator.getgeopositionasync?view=winrt-26100),
[chủ instance Photon công bố dịch vụ](https://github.com/Freika/dawarich/discussions/693),
[tài liệu Photon](https://github.com/komoot/photon/blob/master/README.md).
