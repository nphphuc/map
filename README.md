# Ride · Bản đồ đặt xe

Demo Flutter Android/iOS/web mở thẳng bản đồ và luồng đặt xe. Không đăng nhập, thanh toán hoặc điều phối tài xế thật.

## Chạy

Flutter 3.47.3 / Dart 3.13.3. Android cần JDK 21+; iOS cần macOS/Xcode.

```powershell
flutter pub get
flutter run -d web-server --web-hostname 127.0.0.1 --web-port 52341
```

Bản release:

```powershell
flutter build web --release --no-wasm-dry-run
python -m http.server 52341 --bind 127.0.0.1 --directory build/web
```

Mở `http://127.0.0.1:52341/` trên trình duyệt hỗ trợ WebGL2. Build Android trên máy Windows hiện tại:

```powershell
.\tool\build_android.ps1
```

APK: `build/app/outputs/flutter-apk/app-debug.apk`. Các provider hiện tại không cần API key. Desktop bị tắt trong cấu hình riêng của dự án.

## Vị trí và tìm kiếm

Khi mở app, controller yêu cầu vị trí thiết bị mới với độ chính xác cao. Web dùng `maximumAge: 0`, deadline toàn yêu cầu 20 giây. Chưa nhận được tọa độ thì **điểm đón để trống**, bản đồ chỉ hiển thị khung Việt Nam; không tạo điểm đón ở TP.HCM hay dùng địa chỉ người dùng nêu làm mặc định. Nút **Chọn vị trí hiện tại của bạn** nằm trong bước chọn điểm đón. Tọa độ cập nhật ngay, tên địa chỉ được tìm sau. Từ chối quyền, timeout và dịch vụ vị trí tắt có đường phục hồi bằng thử lại/chọn pin.

Không thể bảo đảm GPS chính xác 100% hoặc dưới 1 m bằng code Flutter. `accuracy` là số thiết bị/trình duyệt báo, được hiển thị trung thực trong bộ chọn điểm đón. Khi vị trí gần đúng, người dùng chỉnh pin đến cửa/lối đón. Hệ điều hành, phần cứng, trong nhà và quyền vị trí gần đúng có thể làm sai số lớn. Xem chuẩn [W3C Geolocation](https://www.w3.org/TR/geolocation/).

Autocomplete chạy khi gõ từ 2 ký tự, debounce 180 ms; kết quả thật đã tìm trong phiên hiện ngay, truy vấn HTTP cũ bị hủy, kết quả cũ không ghi đè câu mới. Photon lọc Việt Nam và ưu tiên gần điểm đón. Không dùng danh sách địa điểm TP.HCM mặc định. Dữ liệu OSM có thể thiếu số nhà/POI; chọn pin nếu kết quả không đủ chính xác.

Máy chủ Photon công cộng không có SLA. Đo ngày 06/10: một số truy vấn mất khoảng 1,8–3,9 giây. Deadline tìm kiếm là 6 giây, bao gồm cả chờ HTTP headers. Muốn đảm bảo autocomplete có độ trễ thấp cần geocoder tự host hoặc dịch vụ có quota/SLA; đây là giới hạn provider, không thể giải quyết chỉ bằng giảm debounce.

## Tuyến đường và nghiệp vụ

MapLibre + OpenFreeMap dựng bản đồ vector. Attribution web được thu vào nút thông tin, vẫn mở được nguồn bản đồ. OSRM trả tuyến ô tô, mét và giây. Requests cách nhau ít nhất 1,1 giây. Hai điểm cần có đường ô tô gần trong bán kính 200 m. Không có tuyến, ngoài Việt Nam, hai điểm quá gần hoặc mất mạng thì không hiển thị giá/chuyến giả.

Chọn điểm đón/đến bất kỳ trong Việt Nam để tìm tuyến. Kiểm tra phạm vi sơ bộ bằng mã quốc gia từ geocoder và bounding box; bounding box không thay thế ranh giới quốc gia chính xác, đặc biệt ở biên giới. Routing engine quyết định tuyến khả dụng; không cam kết mọi đảo, biển, đường cấm hay số nhà đều có đường ô tô.

Chuyến từ 35 km được nhận diện là đường dài. Từ 300 km hoặc thời gian lái xe 8 giờ cần xác nhận mô phỏng chuyến đặc biệt. Hai mốc sau là quy tắc demo, không phải giới hạn chung của các hãng. SG–Hà Nội vẫn xem được tuyến/giá tham khảo và mô phỏng sau xác nhận. Không bảo đảm hãng nhận chuyến, có xe hay thời gian nghỉ của tài xế.

Đổi điểm đón/đến làm mất hiệu lực tuyến/giá cũ và tính lại. Giá hết hiệu lực sau 2 phút thì cần cập nhật trước đặt demo. Reset giữ điểm đón người dùng chọn, không trả về một địa chỉ hardcode. Các tài xế quanh điểm đón và hành trình 25 giây là mô phỏng; không có ETA tài xế thật. Tuyến dài dùng khoảng cách tích lũy và tìm kiếm nhị phân để di chuyển xe, không tính lại hàng nghìn đoạn ở mỗi frame.

## Giá tham khảo

Cấu hình theo bảng khoảng cách Green SM TP.HCM đọc ngày 06/10/2026, áp dụng thống nhất **cho demo**. Đây không phải biểu giá toàn quốc, báo giá trực tiếp hoặc cam kết giá của hãng. Tên xe trên UI là tên chung.

| Loại demo | 2 km đầu | Km >2 đến 12 | Km >12 đến 25 | Km >25 |
|---|---:|---:|---:|---:|
| Tiêu chuẩn | 30.500 ₫ | 15.200 ₫/km | 14.700 ₫/km | 13.300 ₫/km |
| Comfort | 34.400 ₫ | 16.500 ₫/km | 16.000 ₫/km | 14.400 ₫/km |
| Xe lớn | 39.500 ₫ | 18.900 ₫/km | 18.400 ₫/km | 16.500 ₫/km |

Cộng phần khoảng cách thực ở từng bậc, làm tròn tổng lên 1.000 ₫. UI có Chi tiết giá. Không tự thêm giá surge, thuế, khuyến mãi hoặc phí chờ khi thiếu dữ liệu. Cầu đường, bến bãi, sân bay, thời gian chờ/nghỉ và phụ phí được ghi **chưa bao gồm**. Thời gian OSRM là thời gian lái xe ước tính, không tính giao thông trực tiếp. Giá trên app thật có thể khác.

Nguồn: [Green SM TP.HCM](https://www.greensm.com/vn-vi/news/bang-gia-xe-taxi-sai-gon). Đối chiếu Grab/be/Xanh SM và ngoại lệ trong [báo cáo nghiệp vụ](docs/research/vietnam-operations/report.md).

## QA

```powershell
flutter analyze --no-pub
flutter test --no-pub --reporter expanded
.\tool\verify_live_routes.ps1
```

Tests kiểm tra GPS tự động không hardcode, đổi thành phố, quyền/timeout, tọa độ chính xác giữ nguyên, GPS cũ không ghi đè pin mới, autocomplete/cancel/cache/deadline, routing, các bậc giá, quote hết hạn, xác nhận chuyến xa, playback và UI nhỏ có bàn phím/chữ 130%.

[QA/QC](docs/QA_QC.md) phân biệt unit/widget, HTTP dịch vụ thật, UI trình duyệt và GPS thật. Bộ kiểm tra vị trí mẫu nằm riêng trong `tool/browser_fixtures`, không chạy trong app chính. Địa điểm và route mẫu chỉ nằm trong `test/fixtures`, không bundle vào bản demo.

## Mã nguồn

`lib/features/booking/domain` chứa tọa độ, route và giá; `data` chứa geolocation/HTTP/search cache; `presentation` chứa controller, bản đồ, sheet và flow. `assets/map` có style; `assets/fonts` có Manrope/OFL. Constructor injection và ChangeNotifier giữ demo nhỏ gọn.

[Nghiên cứu SDK](docs/research/report.md) · [Nghiệp vụ Việt Nam](docs/research/vietnam-operations/report.md) · [Thiết kế](docs/DESIGN.md) · [Xác minh](docs/VERIFICATION.md)
