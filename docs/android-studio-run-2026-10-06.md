# Android Studio Run — sửa JDK ngày 06/10/2026

## Nguyên nhân và sửa

Flutter lưu `jdk-dir` trỏ đến Temurin 17.0.20.101. `maplibre_gl 0.27.1` đặt `sourceCompatibility` và `targetCompatibility` Java 21 trong build script của plugin; compiler 17 báo `invalid source release: 21`. App tự target Java 17 không thay thế yêu cầu của plugin.

Script `tool/build_android.ps1` trước đây chọn JBR bằng tham số Gradle riêng, nên build thành công nhưng không sửa JDK mà nút Run của Flutter trong IDE sử dụng.

Đã chạy trên máy này:

```powershell
C:\Src\flutter\bin\flutter.bat config --jdk-dir="C:\Program Files\Android\Android Studio\jbr"
C:\Src\flutter\bin\flutter.bat doctor -v
C:\Src\flutter\bin\flutter.bat run --no-pub -d emulator-5556 -t lib/main.dart
```

Doctor xác nhận Java binary ở Android Studio JBR, version 25.0.3. Đây là cấu hình chung của Flutter trên máy. Không đổi JAVA_HOME hệ thống hoặc commit đường dẫn tuyệt đối vào cấu hình Gradle. README có hướng dẫn chọn JDK; root Gradle script báo lỗi rõ khi JVM thấp hơn 21.

## Kết quả quan sát

| Hạng mục | Kết quả |
|---|---|
| `assembleDebug` qua `flutter run` | PASS, 142,9 giây; không còn `invalid source release: 21` |
| Cài APK vào emulator-5556 | PASS, 4,8 giây |
| Flutter chạy | PASS, Dart VM Service kết nối; process `com.example.map` PID 8995 |
| MapLibre native | PASS, `libmaplibre.so` load `ok`, TextureView renderer nhận GPU emulator |
| Giao diện khởi động | Ảnh xác nhận bản đồ đã vẽ phía sau dialog xin quyền vị trí của Android |
| Quyền/GPS | Chưa chọn quyền; không giả lập hoặc chứng nhận GPS thật |
| IDE Run button | Chưa bấm lại trong IDE; kiểm tra bằng cùng Flutter executable và emulator mà IDE dùng |

Đã detach Flutter CLI để app tiếp tục mở trên emulator. Người dùng chọn quyền vị trí trong dialog; nếu app đã hết thời gian chờ thì dùng nút chọn vị trí hiện tại để thử lại. Nếu Android Studio còn giữ cấu hình cũ, khởi động lại IDE rồi Run.

Build có warnings API deprecated/source Java 8 của các dependency và native-access của JBR. Emulator báo startup frame skips; không chứng nhận FPS hoặc GPS vật lý. Không đổi versions dependency để xử lý lỗi compiler này.

## Bằng chứng

- `android-studio-jdk-doctor-2026-10-06.log`: JDK Flutter thực tế.
- `android-studio-native-smoke-2026-10-06.txt`: các dòng native-load/render liên quan của đúng app process; không thấy FATAL EXCEPTION/Unhandled Exception trong lần đọc.
- `previews/android-jdk-fix-2026-10-06.png`: screenshot emulator.
- Tài liệu [Flutter Java/Gradle](https://docs.flutter.dev/release/breaking-changes/android-java-gradle-migration-guide), [Gradle compatibility](https://docs.gradle.org/current/userguide/compatibility.html).
