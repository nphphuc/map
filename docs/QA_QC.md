# QA/QC — demo bản đồ và vị trí

Ngày cập nhật: 06/10/2026. Môi trường: Windows, Flutter 3.47.3; bản web release và Android debug APK. Phạm vi: bản đồ và flow đặt xe, không có xác thực hoặc thanh toán. Browser UI/GPS thật của bản mới chưa được kiểm tra lại; kiểm tra emulator và ảnh cũ được ghi riêng trong phần lịch sử.

## Cập nhật chức năng ngày 06/10/2026

Phần bên dưới mô tả bản hiện tại. Các bảng và ảnh ngày 05/10 là lịch sử của bản trước; biểu phí cũ, điểm đón cố định và tuyến lưu sẵn đã được thay thế.

| Kiểm tra | Bằng chứng | Kết quả |
|---|---|---|
| Mở app lấy GPS, không hardcode điểm đón | Controller/widget tests; pickup ban đầu null; khởi tạo gọi device service một lần | PASS xử lý |
| Demo tại thành phố khác | Hai controller nhận tọa độ thiết bị khác nhau | PASS xử lý |
| Từ chối vị trí | Pickup vẫn null; chọn điểm đến trước thì bắt buộc chọn điểm đón | PASS |
| Chọn vị trí hiện tại | Nút có nhãn rõ, lấy fix mới, giữ tọa độ, chuyển flow | PASS widget |
| Độ chính xác | Accuracy 124 m vẫn báo 124 m, không thay bằng 1 m | PASS tính trung thực; không chứng nhận sai số GPS thật |
| Gõ tìm kiếm | Dispatch sau 180 ms; cache thật hiện ngay; hủy HTTP cũ; tránh response cũ | PASS |
| Tìm kiếm không trả headers | Deadline 6 giây bao gồm toàn bộ request | PASS |
| Phạm vi | Photon lọc countrycode VN, routing kiểm tra country và bounding box | PASS; chưa chứng nhận biên giới bằng polygon |
| Giá theo bậc | 2, 12, 25 km và phần vượt; tổng/rounding nhất quán | PASS |
| Chuyến xa | 35 km; 300 km hoặc 8 giờ; yêu cầu xác nhận mô phỏng đặc biệt | PASS |
| Đổi hành trình/giá hết hạn | Reroute; reset xác nhận đặc biệt; chặn quote quá 2 phút | PASS |
| Tuyến dài | 12.000 điểm + điểm trùng; endpoint đúng; nội suy theo đường | PASS |
| UI nhỏ và bàn phím | 320 px, chữ 130%, keyboard inset 280 px; form cuộn, nút chọn GPS dùng được | PASS widget |
| Không có đường | OSRM NoSegment, bán kính 200 m; có thông báo chỉnh pin, không giá/tuyến giả | PASS unit và HTTP |
| Luồng đặt xe | Hai cỡ 320/390 px từ tìm điểm đến đến hoàn tất/reset | PASS widget |
| Chữ Uber/toast GPS | Đã loại khỏi mã UI; accuracy giữ trong bộ chọn điểm đón | PASS source/widget |
| Attribution thu gọn | CSS giữ nút thông tin và nguồn mở rộng | Đã sửa mã; CHƯA KIỂM TRA thao tác trên browser trong lượt này |
| Unit/widget | 43 tests, log `test-run-2026-10-06.log` | PASS |
| Analyzer | `flutter analyze --no-pub` | PASS |
| Web release | Build sau các sửa đổi cuối, 155,5 giây; log `web-build-2026-10-06.log` | PASS |
| Android APK | Build sau các sửa đổi cuối, 56 giây; 218.718.886 bytes; log `android-build-2026-10-06.log` | PASS build, chưa cài/QA UI lại |
| Web đang phục vụ | HTML, bootstrap, JS, manifest, style và font HTTP 200; `web-http-2026-10-06.json` | PASS HTTP |
| Asset bản release | Không có route snapshot hoặc địa điểm mẫu trong bundle | PASS |
| GPS thật, sai số dưới 1 m | Cần thiết bị và nguồn định vị thật | CHƯA ĐẠT yêu cầu bảo đảm; phần mềm không thể cam kết 100%/dưới 1 m |
| UI và console trình duyệt | Công cụ mở URL bị chính sách truy cập từ chối | CHƯA KIỂM TRA lại; không coi widget tests là browser QA |

### HTTP dịch vụ thật và độ trễ

Kiểm tra ngày 06/10 qua các tọa độ mẫu công khai, không dùng vị trí cá nhân. OSRM trả: TP.HCM local 4.407,2 m / 392,4 giây; Hà Nội local 4.166,8 m / 412 giây; Đà Nẵng → Hội An 30.884,2 m / 1.695,6 giây; TP.HCM → Hà Nội 1.492.195,7 m / 68.071,4 giây, geometry 16.990 điểm. Đây là các kết quả của routing engine tại lần gọi, không phải xác nhận giao thông, thời gian nghỉ hay việc một hãng nhận chuyến. Giá Tiêu chuẩn tham chiếu lần lượt 68.000 / 64.000 / 452.000 / 19.888.000 ₫. Điểm ngoài đường ô tô trả HTTP 400 / NoSegment. Log và script tái tạo: `live-route-qa-2026-10-06.json`, `../tool/verify_live_routes.ps1`.

Photon với filter VN trả các truy vấn “Nhà hát”, “Nhà hát Hà Nội”, “Nhà văn hóa sinh viên” trong khoảng 3.893 / 2.337 / 1.822 ms. Vì vậy **chưa đạt cam kết mọi kết quả online tức thì hoặc dưới 1 giây**. Đã sửa phía ứng dụng sang autocomplete khi gõ và deadline ngắn; máy chủ công cộng vẫn quyết định độ trễ, mức độ đầy đủ POI/số nhà. Cần provider có quota/SLA hoặc geocoder tự host để có cam kết vận hành. Không dùng public Nominatim để autocomplete.

### Quy tắc hiện tại

Nguồn [nghiệp vụ Việt Nam](research/vietnam-operations/report.md) gồm 14 nguồn chính thức và validator logs. Bảng Green SM TP.HCM là cấu hình tham chiếu cố định của demo toàn quốc; giá, phạm vi, xe khả dụng và phụ phí trên app thật có thể khác. Ngưỡng 300 km/8 giờ và quote TTL 2 phút là quy tắc demo. Chỉ có dữ liệu tài xế là mô phỏng; không bundle điểm đón/địa điểm gợi ý TP.HCM hoặc route snapshots vào ứng dụng nữa.

Web yêu cầu accuracy cao, maximumAge 0; deadline 20 giây vẫn áp dụng. Vị trí gần đúng có hành động chỉnh pin. `accuracy` là số nguồn định vị báo; theo [W3C Geolocation](https://www.w3.org/TR/geolocation/) đây là mức tin cậy 95% tính theo mét, không phải bảo đảm tọa độ chính xác tuyệt đối.

## Tiêu chí

Chỉ ghi **PASS** khi có kết quả quan sát hoặc assertion cụ thể. Phân biệt kiểm thử bằng dữ liệu mẫu, dịch vụ bản đồ thật và GPS thật của thiết bị. Lỗi môi trường vẫn được ghi là chưa đạt ở môi trường đó; không coi một nút có spinner là chức năng đã chạy thành công.

## Lịch sử khởi động ngày 06/10, trước cập nhật chức năng

- Trước khi chạy lại, cổng 52341 không có tiến trình phục vụ. Đã khởi động lại HTTP server chỉ trên `127.0.0.1`, dùng bản release trong `build/web`.
- HTTP: trang chủ, Flutter bootstrap, JavaScript, style bản đồ và font Manrope đều trả 200.
- Dịch vụ thật: OpenFreeMap TileJSON/sprite/font, Photon search và OSRM route đều trả 200, có `Access-Control-Allow-Origin: *`. Photon trả 2 kết quả cho truy vấn Landmark 81. OSRM trả `Ok`, 4407.2 m / 392.4 giây cho Nhà hát Thành phố → Landmark 81.
- `flutter analyze --no-pub`: không có issue. `flutter test --no-pub --reporter expanded`: 27/27 tests pass.
- Công cụ trình duyệt từ chối mở URL do chính sách truy cập. Không thực hiện thao tác UI, không thu được console mới và không kiểm tra lại GPS thật trong lượt này. Kết quả GPS timeout bên dưới là bằng chứng của ngày 05/10, không phải phép đo mới.
- Không sửa mã ứng dụng trong lượt này: lỗi quan sát được là server local đã dừng. Cần tải lại trang trong trình duyệt để kiểm tra giao diện sau khi server được khởi động.

## Kết quả lịch sử ngày 05/10/2026

| Hạng mục | Cách kiểm tra | Kết quả |
|---|---|---|
| Phân tích mã | `flutter analyze --no-pub` | PASS, không có issue |
| Unit/widget | `flutter test --no-pub` | PASS, 27 tests |
| Web release | Build JavaScript và mở bản release | PASS |
| Android | Build APK, cài, mở Flutter, tải thư viện MapLibre native | PASS cho smoke check; chưa chứng nhận UI/touch/GPS thật |
| Mở app | Mở URL mới | PASS, map và điểm đến xuất hiện trực tiếp |
| Routing và giá | Nhà hát Thành phố → Landmark 81, OSRM thật | PASS, 4.4 km / 7 phút; giá demo 48k / 63k / 74k |
| Tìm địa điểm mới | Photon: “Bảo tàng mỹ thuật” | PASS, kết quả ngoài danh sách mẫu và tuyến mới 1.4 km / 3 phút |
| Đặt chuyến | Chọn xe → xác nhận → mô phỏng → hoàn tất → reset | PASS trên web và widget tests |
| GPS có tọa độ | HTML fixture riêng cung cấp 10.7794, 106.6921, sai số 18 m qua SDK web thật | PASS xử lý đầu vào; đây là tọa độ mẫu công khai |
| Tuyến sau GPS | Tọa độ mẫu ở bảo tàng → Landmark 81, routing thật | PASS, 5.7 km / 9 phút; giá demo 58k / 76k / 91k |
| Quyền bị từ chối | SDK web nhận lỗi geolocation code 1 từ fixture | PASS, thông báo thiếu quyền và đường phục hồi |
| Không có phản hồi | Deadline trong tests và trình duyệt | PASS xử lý timeout, không quay vô hạn |
| Retry | Từ thiếu quyền sang có tọa độ trong widget test | PASS, đóng dialog và cập nhật điểm đón |
| Chọn tay khi GPS lỗi | Dialog → chọn trên bản đồ | PASS, mở pin chọn điểm đón |
| Giao diện nhỏ | 320 × 640, chữ 130%, font Manrope thật | PASS dialog vị trí và phục hồi, không overflow |
| GPS thật trong Codex | Probe `navigator.geolocation` trên đúng origin 127.0.0.1:52341 | **CHƯA ĐẠT**: browser trả code 3, `Timeout expired` |
| GPS thật Android/iOS | Thiết bị vật lý | **CHƯA KIỂM TRA** |
| iOS build | Cần macOS/Xcode | **CHƯA KIỂM TRA** trên Windows |

## Lỗi tìm được và cách sửa

### 1. Nút vị trí có thể chờ vô hạn trên web

Source package đang dùng: `geolocator_web 4.1.4`. `requestPermission()` tự gọi `getCurrentPosition()` không có timeout. HTML adapter còn chuyển Duration sang microseconds trước khi đưa vào trường timeout của browser, vốn dùng milliseconds. Vì vậy chỉ đặt `LocationSettings.timeLimit = 12 seconds` chưa bảo đảm giới hạn thực tế trên web.

**Sửa:** bỏ lần gọi xin quyền riêng trên web; dùng position stream với deadline trong Dart và lấy sự kiện đầu tiên. Subscription được hủy sau thành công hoặc timeout/error. Native vẫn kiểm tra dịch vụ và quyền, với deadline toàn luồng. Nút trở lại trạng thái có thể dùng, đồng thời hiện thông báo và hai hành động phục hồi.

### 2. Tọa độ thành công bị chậm vì đợi tên địa chỉ

**Sửa:** cập nhật điểm đón, camera và sai số thiết bị báo ngay khi có tọa độ. Reverse geocoding chạy sau; lỗi địa chỉ vẫn giữ tọa độ thật. Tên POI không được dùng để thay tọa độ GPS bằng tâm của POI.

### 3. Kết quả GPS cũ có thể ghi đè thao tác mới

**Sửa:** chọn địa điểm, quay lại, reset hoặc di chuyển pin làm mất hiệu lực kết quả GPS/confirm cũ. Trong bước chọn điểm đến bằng pin, GPS chỉ di chuyển pin; không âm thầm thay điểm đón đã có.

### 4. Ghép lớp bản đồ Android

Smoke check ban đầu báo cảnh báo context ở Virtual Display. Chọn TextureView trước `runApp` để Flutter ghép được bản đồ với sheet/pin; hot restart xác nhận native platform view chuyển sang view hierarchy. Đây không phải số đo FPS. Emulator có startup frame skips nên cần đo trên điện thoại trước khi khẳng định hiệu năng.

## Kết quả GPS thật của Codex

Probe độc lập trên cùng origin, không giả lập tọa độ và không gửi tọa độ đến Photon/OSRM:

```text
Secure context: true
Geolocation API: true
Permission: prompt
Geolocation error 3: Timeout expired
```

Đây là kết quả của phiên kiểm tra trên máy này. Nó không chứng minh mọi trình duyệt Codex đều không hỗ trợ vị trí, và không đủ để khẳng định hệ điều hành đã tắt vị trí. Browser chưa cung cấp tọa độ trong lần kiểm tra; code Flutter không thể tự cấp quyền hoặc bật nguồn định vị của host.

Hướng kiểm tra thực tế: mở `http://127.0.0.1:52341/` bằng Chrome/Edge ngoài Codex, cho phép Vị trí cho trang, bật Vị trí của hệ điều hành; hoặc cài APK trên Android, bật dịch vụ vị trí và cấp quyền cho ứng dụng. Khi có tọa độ, app hiện “Đã lấy vị trí · sai số khoảng … m”. Khi chưa có, chọn điểm đón trên bản đồ để tiếp tục demo.

## Bằng chứng

- [GPS thành công với fixture công khai](previews/location-success-fixture.jpg)
- [Tuyến và giá sau đổi điểm đón](previews/location-route-fixture.jpg)
- [Quyền bị từ chối với fixture](previews/location-denied-fixture.jpg)
- [Timeout trong app](previews/location-timeout.jpg)
- [Timeout của position stream trên bản release cuối](previews/location-timeout-fixture.jpg)
- [Probe quyền/timeout thật trong Codex](previews/codex-location-probe.jpg)

Fixture chỉ chạy trên cổng QA riêng và có nhãn rõ trên màn hình. Các file fixture tạm được xóa khỏi `build/web` sau kiểm tra; app chính không chứa bộ giả lập vị trí. Source fixture để tái tạo kiểm tra nằm tại `tool/browser_fixtures/`.

## Gate còn lại trên điện thoại

1. Cấp quyền lần đầu, từ chối, bật lại quyền và retry.
2. GPS thật: điểm đón, sai số và camera khớp vị trí thiết bị.
3. Chọn địa điểm, kéo pin, zoom, quay lại và reset bằng touch.
4. Kiểm tra lúc mất mạng, mạng chậm, đổi app rồi quay lại.
5. Đo frame timing ở profile/release; Android emulator debug không đại diện cho điện thoại thật.

Không cần các gate này để xem demo web; cần hoàn tất trước khi xem bản mobile là đã được nghiệm thu trên thiết bị thật.
