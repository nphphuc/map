# Design decisions

## Current adjustments — 6 October 2026

UI dùng tên Ride và loại xe chung; bỏ chữ Uber và toast trạng thái GPS trên map. Dòng nguồn bản đồ web thu vào nút thông tin, vẫn giữ attribution. Khi mở app, lấy vị trí thiết bị; khi chưa có fix, bản đồ là khung toàn quốc và pickup trống. Bộ chọn điểm đón có nút “Chọn vị trí hiện tại của bạn”, sai số thiết bị và chỉnh pin nếu gần đúng. Không sử dụng seed địa điểm ở một thành phố. Form tìm kiếm cuộn toàn bộ khi bàn phím mở; kết quả cập nhật theo lúc gõ, cache thật hiện ngay. Các quy tắc và biểu phí hiện tại nằm trong [nghiệp vụ Việt Nam](research/vietnam-operations/report.md).

This is an educational Uber-inspired map and ride selection demo, based on the user's screenshots and official rider-flow documentation linked in the research report. It does not claim to use Uber's implementation or proprietary design tokens.

## Visual system

The map carries the screen. A white sheet groups the one decision needed at each step; black is reserved for the route, type, selection outline and primary action. Geometry is a pickup circle, destination square and a single continuous driving route. Controls use round white buttons above the map.

| Token | Value | Purpose |
|---|---|---|
| Ink | #000000 | Route and primary actions |
| Sheet | #FFFFFF | Booking content |
| Quiet surface | #F3F3F3 | Input and secondary content |
| Map land | #F1F2F1 | Low contrast background |
| Water | #BCD8E4 | Geographic orientation |
| Park | #DCE9DA | Geographic orientation |

Manrope is bundled under OFL, using 12/14/16/20/24/28 px roles and a restrained weight range. It supplies consistent Vietnamese text across platforms. The proprietary Uber Move font is not bundled. Car artwork and map markers are drawn in code, without runtime image downloads.

## Layout

The mobile layout keeps the map above the sheet. Search expands the sheet, the pin step gives the map more space, and route selection retains visible geography and all three quotes. At larger web sizes the same flow is centered with a maximum width of 560 px. Scrollable panel content and a persistent CTA accommodate narrow screens and larger text. No account, marketing, dashboard or unrelated navigation is added.

## Motion

Sheet resizing uses 380 ms ease-in-out cubic, content cross-fades use 230 ms, selected rows use 180 ms, route camera fitting uses 700 ms and road reveal uses 900 ms. These are this project's design choices, not published Uber specifications. Camera fitting waits for the map's resized viewport. Provider updates are serialized and unchanged sources are not resent each frame.

System disableAnimations/reduceMotion preferences bypass sheet, camera and route animation. Playback remains user initiated; under reduced motion, the map car stays still until completion. The full route and quote appear before confirmation is possible.

Android uses MapLibre's TextureView mode (`useHybridComposition = true`, set before `runApp`) so Flutter can composite the map with the animated sheet and pin. In this SDK the flag does not select Flutter's Hybrid Composition API. TextureView has a rendering cost; physical-device frame timing remains unmeasured.

## Review criteria

Legible provider credits, real road geometry, exact selected pin coordinates, clear distinction between a route estimate and live traffic, visible demo fare explanation, functional back/reset and useful network errors take priority over decorative effects. See VERIFICATION.md for actual checks and remaining platform limitations.
