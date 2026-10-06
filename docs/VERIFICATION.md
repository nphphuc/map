# Verification — 6 October 2026

## Current build

Windows, Flutter 3.47.3 / Dart 3.13.3. The local release is served at `http://127.0.0.1:52341/`.

| Check | Observed result | Evidence |
|---|---|---|
| Unit/widget | 43/43 passed after the final source edits | `test-run-2026-10-06.log` |
| Analyzer | No issues found | `analyze-2026-10-06.log` |
| Web release | Built successfully, 155.5 seconds | `web-build-2026-10-06.log` |
| Android debug APK | Built successfully, 56 seconds; 218,718,886 bytes | `android-build-2026-10-06.log`; `../build/app/outputs/flutter-apk/app-debug.apk` |
| Served files | HTML, bootstrap, JavaScript, manifest, map style and font all HTTP 200 | `web-http-2026-10-06.json` |
| Bundled route snapshots | None; sample data lives only in test fixtures | Release asset inventory |
| Real routing HTTP | Local HCMC/Hanoi, Da Nang–Hoi An, HCMC–Hanoi returned road geometry, distance and duration; offshore point returned NoSegment | `live-route-qa-2026-10-06.json` |
| New browser UI/console and actual GPS | Not rechecked: browser automation was denied by the access policy | No browser PASS claimed |

Current behavior: pickup starts empty, automatic startup asks the device for a fresh location, autocomplete uses 180 ms debounce with cancellation and a cache of real results, and nationwide road routing uses a published reference distance tariff. There is no fixed city pickup or bundled route fallback. GPS accuracy is reported as received, never fabricated. Very long trips require acknowledgment of the special simulation; operator availability is not simulated as a real booking.

The public search server measured 1.8–3.9 seconds for new queries. Neither instant network results nor 100%/submeter GPS accuracy is certified. Current attribution collapse was changed in CSS but its browser interaction remains unverified. Android install/launch below belongs to the previous build; physical Android/iOS GPS and iOS compilation are still unverified.

See [current QA/QC](QA_QC.md), [Vietnam business research](research/vietnam-operations/report.md), and [README](../README.md) for the pricing tiers, exceptions and repeat commands.

## Historical verification — 5 October 2026

The remaining checks and screenshots describe the previous version. Its 27-test count, Uber labels, fares, fixed suggestions and saved-route fallback do not certify the current version.

Environment: Windows, Flutter 3.47.3 / Dart 3.13.3. Research and source validation are recorded separately under `research/`.

## Completed checks

| Check | Result |
|---|---|
| `flutter pub get` | Passed. Native plugin metadata includes MapLibre and Geolocator; desktop targets disabled in project configuration. |
| `flutter analyze --no-pub` | No issues found. |
| `flutter test --no-pub` | 27 tests passed, including 14 location/recovery checks. |
| `flutter build web --release --no-pub --no-wasm-dry-run` | Passed; JavaScript release output in `build/web`. |
| `tool/build_android.ps1` | Passed with Android Studio JBR 25, including native MapLibre compilation. Final incremental build: 145 tasks, 16 executed. |
| Android APK | `build/app/outputs/flutter-apk/app-debug.apk`, debug signed, 218,704,438 bytes; rebuilt after the location fixes. |
| Pixel 8 emulator | APK installed and Flutter launched `com.example.map/.MainActivity`; ActivityManager reported it resumed and Dart VM service connected. `libmaplibre.so` loaded and the native platform view was created. TextureView mode was checked through hot restart. This is a launch check, not a native visual or performance certification. |

Tests cover accent-insensitive Vietnamese search, whole-VND fares and minimums, real OSRM GeoJSON coordinate order, exact selected pin coordinates, late search/route responses, cancellation, exact saved-route fallback, road-distance interpolation, and the booking/reset flow at 320 and 390 px using the bundled font.

## Browser checks

Tested in the Codex in-app Chromium browser at a temporary 390 × 844 viewport, then restored normal browser sizing. The release demo remains available at `http://127.0.0.1:52341/` for this local session.

- Default screen immediately opens the map and destination input.
- Vector tiles, provider credits, nearby illustrative cars, pickup circle and destination square rendered visibly.
- Nhà hát Thành phố → Landmark 81 displayed 4.4 km / 7 min and demo fares 48,000 / 63,000 / 74,000 VND; the live OSRM response was 4,407.2 m / 392.4 s.
- A live search outside the curated list, “Bảo tàng mỹ thuật”, returned Photon places. Selecting the first HCMC result fetched a new driving route (1.4 km / 3 min), with recalculated fare minimums.
- Pin mode showed a fixed pin and resolved its address. Confirmation returned to the booking flow. The artwork stem tip is aligned to the map camera center.
- Release flow: choose UberX → confirm stops → place demo trip → start 25-second playback → “Bạn đã đến nơi” → new trip resets to home.
- No new console errors/warnings were captured during the release run after 12:17 UTC. Earlier development hot restarts logged disposed-engine-view assertions; the final check used a fresh release page load.

Screenshots: [home](previews/home.jpg), [ride choice](previews/ride-choice.jpg), [completion](previews/complete.jpg).

## Location correction and QA/QC

The user reported location failure in the Codex in-app browser. Detailed reproduction, fixes, evidence and remaining limitations are in [QA/QC](QA_QC.md).

- The previous web `requestPermission()` path called an unbounded position request in geolocator_web 4.1.4. Its HTML adapter also passes `timeLimit.inMicroseconds` into the browser timeout field, which expects milliseconds. Thus the previous nominal 12-second setting did not bound the actual browser operation correctly.
- Web now requests one fix through a position stream with a Dart deadline; `.first` cancels the watch after a fix or timeout/error. Native permission handling keeps its own overall deadline. UI wait is bounded to 20 seconds.
- Successful coordinates update the map immediately, ahead of address lookup. Geocoding failure does not discard a GPS fix. Manual pickup/pin selection cancels late results.
- The actual Codex browser was probed on the same origin with unmodified `navigator.geolocation`. Secure context and Geolocation API were available; permission query reported `prompt`; the request returned error 3, `Timeout expired`. Real device coordinates were not shown or sent to map providers by this probe. Actual device location in this browser is **not marked passed**.
- A clearly labeled HTML fixture on a separate QA port supplied public museum coordinates through the normal geolocator web bridge. UI showed 18 m accuracy, moved pickup, resolved the address via Photon, and fetched a new route to Landmark 81: 5.7 km / 9 min and fares 58,000 / 76,000 / 91,000 VND. A denied-permission fixture showed the correct recovery dialog. These verify app handling of supplied GPS data, not physical-device GPS.

## Limits and follow-up on a phone

- iOS configuration is present, including the optional location usage description; iOS build/runtime was not tested on Windows.
- Android was checked through build/install/launch tooling. Native visual inspection, touch interactions, GPS permission acceptance and physical-device frame timing remain to be checked on a phone. The headless emulator logged substantial startup frame skips on this host, so no FPS or smoothness benchmark is claimed.
- The Android template/plugins emit nonfatal Gradle/Kotlin deprecation warnings. Web icon tree shaking emits a Cupertino font inventory warning; this interface uses Material icons and no missing icon was observed in the reviewed flow.
- Public map/search/routing endpoints need internet and offer no application SLA. Saved routes cover only six exact demo coordinate pairs; arbitrary destinations require a live routing response.
- Route duration is an estimate without a live traffic feed. Prices and cars are clearly marked as demo data; there is no driver dispatch, account or payment integration.

## Repeat

```powershell
flutter pub get
flutter analyze
flutter test
flutter build web --release --no-wasm-dry-run
.\tool\build_android.ps1
```

On an Android device, configure Flutter to use a compatible JDK 21+ before `flutter run -d <device-id>`, or install the already-built APK. See the README for the local build helper and provider/fare details.
