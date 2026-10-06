# Demo bản đồ Flutter với flow đặt xe lấy cảm hứng từ Uber

Ngày nghiên cứu: **05/10/2026**, múi giờ Asia/Saigon. Phạm vi: demo mobile, có bản web để xem; không đăng nhập, đăng ký, thanh toán hoặc đặt xe thật. Đây là báo cáo lựa chọn kỹ thuật và đặc tả triển khai, không phải chứng nhận của Uber hay biên bản kiểm thử bản build.

## Executive Summary

Đề xuất xây dựng demo bằng Flutter và MapLibre GL, dùng OpenFreeMap cho bản đồ vector, Photon cho tìm địa điểm và OSRM cho tuyến đường ô tô. Stack này phù hợp yêu cầu mở ứng dụng là thấy ngay bản đồ và ô chọn điểm đến, không cần tài khoản người dùng hoặc key cho lớp bản đồ. MapLibre hỗ trợ Android, iOS và web; OpenFreeMap công bố public instance không yêu cầu đăng ký hoặc API key. Đây là lựa chọn cho demo học tập quy mô nhỏ, với giới hạn dịch vụ công khai được ghi rõ. [3] [4] [20]

Flow đề xuất là chọn điểm đến, chỉnh điểm đón, xem tuyến cùng khoảng cách và thời gian, chọn loại xe rồi xác nhận mô phỏng. Trình tự này dựa trên hướng dẫn đặt xe chính thức của Uber. Giá được tính bằng công thức demo minh bạch, không lấy giá Uber hoặc giả lập dữ liệu giao thông đang diễn ra. OSRM cung cấp khoảng cách đường đi theo mét và thời gian dự báo theo giây; tài liệu Uber cho thấy giá thật còn phụ thuộc nhiều yếu tố ngoài hai đại lượng đó. [1] [2] [8]

Google Maps cộng Places và Routes là phương án nâng cấp khi cần tìm địa điểm và traffic ETA với tài khoản billing, API key cấu hình đúng. Mapbox Flutter hiện đã hỗ trợ web cùng mobile, nên đánh giá cũ cho rằng chỉ mobile không còn phù hợp. Demo chọn MapLibre vì giảm bước cấu hình ban đầu và cho phép sửa style vector, không phải vì đã đo được hiệu năng vượt hai SDK khác. [13] [14] [15] [16]

## Introduction — phạm vi, giả định và tiêu chí thành công

Yêu cầu được hiểu là làm lại một demo bản đồ đang không dùng được thành trải nghiệm đặt xe gọn, dễ trình bày trên điện thoại. Hai ảnh tham khảo giúp xác định hướng thẩm mỹ và bối cảnh bài học. Chúng không chứng minh Uber dùng một SDK, kiến trúc hay bộ hiệu ứng Flutter cụ thể. Mục tiêu hợp lý là tái tạo cách tổ chức thông tin: bản đồ làm nền chính, một hành động nổi bật ở mỗi bước, thông tin chuyến đi hiện đúng lúc người dùng cần quyết định.

Thành công về sản phẩm nghĩa là người xem không phải đi qua màn hình xác thực; có thể tìm hoặc chọn địa điểm gợi ý, thay điểm đón, nhìn đường đi chạy theo mạng đường, hiểu khoảng cách và thời gian, so sánh lựa chọn xe cùng giá demo rồi chạy mô phỏng. Địa điểm mặc định ở TP.HCM là giả định phục vụ trình diễn. Tọa độ mặc định phải được mô tả là điểm đón demo khi chưa có quyền vị trí, không được gắn nhãn GPS hiện tại của người xem.

Báo cáo dùng nguồn chính thức của nhà cung cấp, maintainer và Uber. Những phát biểu về tính năng API có thể chỉ có một nguồn chính thức vì đó là định nghĩa của chính API. Các quyết định thiết kế được ghi là đề xuất kỹ thuật và đối chiếu nhiều nguồn. Không dùng số liệu benchmark, mức độ chính xác bản đồ Việt Nam hay đánh giá độ mượt nếu chưa có phép đo. Quyết định triển khai được giữ riêng với kết quả kiểm thử: việc một package hỗ trợ Android không đồng nghĩa APK của dự án đã build thành công.

Giới hạn thực tế được đặt ngay từ đầu. Bản đồ, tìm kiếm và routing là ba dịch vụ khác nhau; lớp hiển thị không tự biết đường nào ô tô được đi hoặc quán nào còn mở. Giữ các dịch vụ sau repository giúp demo hiện tại đơn giản mà vẫn có đường nâng cấp. Đây là suy luận kết hợp phạm vi renderer MapLibre, tính năng geocoder Photon, hợp đồng route OSRM và hướng dẫn tách UI/data của Flutter. [3] [6] [8] [10]

## Main Analysis

### 1. Chọn SDK và dữ liệu: ưu tiên demo mở được ngay, có đường nâng cấp

Google Maps Flutter hỗ trợ Android, iOS và web. Cấu hình chính thức yêu cầu bật billing, tạo API key, thêm key vào từng nền tảng và khuyến nghị key riêng với restriction tương ứng. Để có tuyến đường và tìm địa điểm, cần đánh giá thêm Routes và Places thay vì xem map widget là toàn bộ hệ thống. Routes có chế độ driving traffic-aware và trả distance, duration, polyline; Places cũng yêu cầu billing cùng credential. [13] [14] [15]

Đề xuất dùng stack Google khi điều kiện triển khai cho phép quản lý credential và ngân sách dịch vụ, đặc biệt nếu người dùng muốn ETA có xét traffic. Cần ghi rõ đây là lựa chọn kiến trúc từ tài liệu, không phải kết luận rằng dữ liệu địa điểm của Google chính xác hơn mọi đối thủ tại TP.HCM. Dự án phải thử các điểm đón khó, lối vào sân bay và địa chỉ tiếng Việt trước khi tuyên bố chất lượng. Key hợp lệ còn phụ thuộc API đã enable, loại restriction và bundle/package/domain đang chạy. [13] [14] [15]

Mapbox Flutter SDK hiện tại có web support cùng Android và iOS; trang cài đặt dùng ví dụ v3.0.0, public access token qua biến build và nêu core APIs trên web chưa hoàn toàn ngang mobile. Tài liệu style cho phép tạo custom style trong Mapbox Studio, dùng URL hoặc JSON và thao tác layer khi runtime. Directions có profile driving-traffic, nhưng traffic chỉ có tại vùng hỗ trợ và có thể quay về driving ở vùng thiếu coverage. Vì vậy không loại Mapbox chỉ vì yêu cầu web; cũng không hứa traffic Việt Nam đã đầy đủ khi chưa xác minh. [16] [17] [18]

MapLibre GL phù hợp lựa chọn triển khai hiện tại vì renderer trung lập với provider, hỗ trợ style vector và mobile/web. Version được chọn là `maplibre_gl 0.27.1`; trang package của publisher MapLibre xác nhận Android, iOS, web, nêu các yêu cầu Flutter, Dart, JDK và hệ điều hành. Cần giữ lockfile để người khác tái tạo dependency. Đây là version được chọn cho demo, không phải một cam kết rằng nó sẽ luôn là version mới nhất hoặc không có regression. [3] [20]

OpenFreeMap cung cấp tiles từ OpenStreetMap, công bố public instance không cần key/registration và không áp giới hạn lượt xem/request; đồng thời không có SLA. Quick Start cho phép dùng cùng styles trên MapLibre Native và chỉnh màu, labels, POI bằng style riêng. Điều này tạo cơ sở cho lựa chọn Positron sáng, ít nhiễu, tùy biến trong asset JSON. Khi style nằm trong app vẫn phải tải tiles, glyphs và sprite từ mạng nếu các URL còn trỏ public instance; local style không làm demo trở thành offline map. [4] [5]

Với mục tiêu dễ mở lớp học, đề xuất đóng gói style JSON đã chỉnh trong assets và để map renderer đọc từ đó. Màu nền xám rất nhạt, đường trắng có viền đủ rõ, nước xanh nhạt, công viên xanh giảm bão hòa, labels quan trọng màu xám đậm. Tuyến đặt xe dùng đường đen rõ và marker tương phản cao. Đây là đặc tả thẩm mỹ của demo. Không gọi bảng màu đó là Uber Design System chính thức, không sao chép một logo để khiến người xem hiểu đây là ứng dụng của Uber.

| Lựa chọn | Mobile / web theo tài liệu | Điều kiện dịch vụ | Phù hợp với demo này |
|---|---|---|---|
| Google Maps + Places + Routes | Android, iOS, web [13] | Billing, key, API/restrictions đúng [13] [15] | Phương án nâng cấp có traffic-aware route [14] |
| Mapbox Flutter + Directions | Android, iOS, web; còn chênh feature parity [16] | Public token; routing có usage theo request [16] [17] | Mạnh về custom style; cần token và kiểm tra coverage [18] [17] |
| MapLibre + OpenFreeMap + Photon + OSRM | Android, iOS, web [20] | Public endpoint nhỏ; không SLA; phải tôn trọng policy [4] [6] [9] | Lựa chọn triển khai hiện tại, mở demo không key |

Sự khác nhau quan trọng là quyền kiểm soát dữ liệu và vận hành. MapLibre cho phép thay tiles mà không đổi flow đặt xe, nhưng đội phát triển phải ghép geocoder/routing đúng hợp đồng. Google và Mapbox giảm số lựa chọn riêng nhưng thêm quy trình credential. Với demo không auth, không backend đặt xe, lợi ích của lớp adapter nhỏ rõ ràng hơn việc xây một hệ thống tích hợp nhiều microservice. Đây là khuyến nghị từ việc đối chiếu renderer, API provider và kiến trúc Flutter. [3] [6] [8] [10] [13] [16]

### 2. Flow đặt xe và ngôn ngữ thiết kế: mỗi bước giải quyết một quyết định

Hướng dẫn chính thức của Uber bắt đầu bằng ô điểm đến, đặt pickup theo GPS có thể sửa, chọn vehicle, request và đôi khi xác nhận pickup. Vị trí tài xế cùng ETA đến điểm đón hiện sau khi có tài xế nhận. Đây là nguồn cho thứ tự tương tác, không phải specification pixel hoặc animation của ứng dụng Uber hôm nay ở mọi thị trường. Demo giữ phần chọn địa điểm và xem tuyến, còn bước xe nhận chỉ được mô phỏng. [1]

Đề xuất trạng thái mở đầu hiển thị bản đồ đã tải, marker điểm đón và bottom sheet thấp. Ô “Bạn muốn đi đâu?” là hành động chính, phía dưới có vài địa điểm gợi ý ở TP.HCM để trình diễn nhanh. Có một nút về vị trí hiện tại; nút chỉ yêu cầu permission khi người dùng chọn, và khi bị từ chối thì map vẫn hoạt động ở điểm demo. Không bắt người dùng cấp GPS để thử tìm điểm đến hoặc xem đường đi. Đây là lựa chọn trải nghiệm phù hợp phạm vi được yêu cầu.

Khi chọn ô tìm kiếm, sheet mở lên để bàn phím và kết quả có chỗ đọc. Hai trường pickup và destination phải cho thấy đang sửa trường nào. Địa điểm gợi ý dùng tên chính và một dòng địa chỉ phụ, có trạng thái loading, không tìm thấy, lỗi mạng riêng. Dòng “không tìm thấy địa điểm” không dùng thay cho timeout. Chọn kết quả là sự kiện rõ ràng; ứng dụng chỉ lấy route sau khi có cả hai tọa độ phù hợp, thay vì gọi routing mỗi lần gõ một ký tự.

Khi người dùng chọn trên bản đồ, đề xuất đặt một pin cố định ở tâm vùng tương tác rồi đọc tọa độ tâm sau khi camera dừng. Trước lúc xác nhận, tên địa chỉ đang cập nhật nên hiện trạng thái chờ; nếu reverse geocode thất bại vẫn có thể giữ tọa độ với nhãn dễ hiểu. Không đổi pickup âm thầm theo mỗi gesture. Người dùng phải biết mình đang chỉnh điểm đón hay điểm đến, có nút quay lại và một CTA xác nhận tương ứng. Đây là quyết định UI; API reverse của Photon chỉ cung cấp dữ liệu địa chỉ, không tự giải quyết quy trình này. [7]

Sau khi nhận tuyến, sheet hiển thị tổng quãng đường và thời gian chuyến, rồi các loại xe demo. Ví dụ có “Tiêu chuẩn”, “Thoải mái”, “6 chỗ”, để tránh phụ thuộc danh mục Uber thật từng thành phố. Mỗi hàng gồm hình/icon xe nhỏ, tên, sức chứa mô phỏng và giá demo. Cùng route cho các loại ô tô trong phạm vi demo; khác nhau ở công thức giá và capacity. Không giả vờ đã hỏi hệ thống dispatch về số xe đang quanh người dùng.

Giá phải xuất hiện trước nút xác nhận. Uber mô tả upfront pricing có estimated time/distance cùng các yếu tố khác; demo lấy nguyên tắc đưa thông tin trước quyết định, không lấy thuật toán tính giá của họ. Khi route chưa có hoặc đã bị đổi pickup/destination, CTA xác nhận phải bị khóa tới khi có dữ liệu phù hợp. Hiển thị giá cũ cạnh tuyến mới là lỗi nghiêm trọng hơn một hiệu ứng không mượt, nên controller phải quản lý giá như một phần của route quote hiện hành. [2]

Đặc tả chuyển động nên dùng các animation có mục đích: sheet mở/thu, cross-fade giữa nội dung, chọn hàng xe, fit camera sau route và marker nhấc lên khi kéo bản đồ. Đề xuất thời lượng ngắn, easing dễ chịu, tránh nhiều vùng rung/lấp lánh đồng thời. Thời lượng cụ thể là thông số thiết kế cần điều chỉnh bằng quan sát thiết bị, không phải giá trị chuẩn Uber đã xác minh. Route reveal chỉ dùng nếu không làm chậm việc đọc tuyến hoặc tạo hiểu nhầm tuyến đang được dẫn đường trực tiếp.

Về giảm chuyển động, Flutter có flag disableAnimations và tài liệu hiện tại nói iOS reduceMotion được expose riêng. Đề xuất đọc cả yêu cầu disableAnimations và reduceMotion nơi SDK local hỗ trợ, bỏ chuyển động lặp/marker pulse/camera fly không cần thiết. Screen reader cần đọc tên địa điểm, đơn vị khoảng cách, giá tiền và trạng thái; màu đen/trắng thôi chưa bảo đảm accessibility. Văn bản dài và font scale lớn phải được kiểm tra ở bottom sheet vì nơi này chứa quyết định chính của chuyến. [19]

Sau xác nhận demo, có thể hiện tiến trình xe mô phỏng trên route và nút reset. Tên trạng thái nên là “Mô phỏng chuyến đi” để không hứa gọi xe thật. Nếu hiển thị xe tiến dọc tuyến thì đó là visual simulation; tốc độ chạy mô phỏng không dùng để đo thời gian route. Flow dừng ở bản đồ và quote đáp ứng bài học tốt hơn việc thêm chat, ví, khuyến mãi, đánh giá hoặc profile chưa được yêu cầu. Đây là lựa chọn phạm vi để người xem hiểu phần maps đã làm được.

### 3. Khoảng cách, địa điểm, thời gian và tiền: giữ dữ liệu thật trong phần có thể kiểm chứng

Photon là geocoder dựa trên dữ liệu OSM, hỗ trợ search-as-you-type, multilingual, location bias và reverse geocode. Public demo cho phép dùng ở mức reasonable nhưng có thể throttle hoặc ban khi dùng nhiều, không bảo đảm availability. API có forward `/api`, reverse `/reverse`, lat/lon focus, bbox và limit. Demo dùng debounce cho input, giới hạn số kết quả và cache nhỏ là lựa chọn để giảm request; đó không phải bằng chứng dịch vụ có quota unlimited. [6] [7]

Đề xuất search ưu tiên TP.HCM hoặc camera hiện tại, nhưng không buộc kết quả phải ở đúng một điểm nhỏ đến mức không tìm được sân bay. Curated places giúp mở demo nhanh khi tìm kiếm lỗi, song kết quả curated phải là danh sách riêng rõ nguồn nội bộ và tọa độ đã kiểm tra. Không ghép tên “Landmark 81” với tọa độ bịa chỉ để trông đúng. Với remote result, model lưu tọa độ và địa chỉ cùng một record; view không tự suy ra tọa độ từ tên hiển thị.

Không dùng public Nominatim cho autocomplete. Policy của `nominatim.openstreetmap.org` cấm triển khai autocomplete client; policy đó khác với một instance do bên khác tự vận hành. Việc chuyển request qua proxy không tự đổi một workload bị cấm thành workload được phép. Photon là lựa chọn phù hợp tính năng cần xây hơn, còn proxy chỉ hữu ích khi thực sự cần kiểm soát cache, credential hoặc đổi provider của hệ thống do mình vận hành. [11] [6]

OSRM Route object định nghĩa distance bằng mét, duration bằng giây và geometry theo format request. Demo nên yêu cầu driving với full GeoJSON để route chạy theo đường, lưu toàn bộ geometry và dùng kết quả route làm nguồn cho quote. Tọa độ GeoJSON theo thứ tự longitude, latitude; map API Dart thường có constructor latitude, longitude, nên mapping cần chủ động và kiểm tra. Không dùng đường thẳng giữa pickup/destination để đóng giả tuyến ô tô khi API không tìm được route. [8]

Thời gian OSRM ở đây là ước lượng của routing profile, không được ghi “traffic trực tiếp”. OSRM nói speed datasource mặc định thường là lua profile, có khả năng cập nhật tốc độ bằng dữ liệu riêng; báo cáo không tuyên bố engine hoàn toàn không thể xử lý traffic. Vấn đề là integration public demo không có evidence nguồn traffic realtime đã được cấp. Khi nâng cấp cần provider và cấu hình traffic có kiểm chứng, ví dụ Routes TRAFFIC_AWARE hoặc Mapbox driving-traffic tại vùng hỗ trợ. [8] [14] [17]

Phải phân biệt thời gian đi từ pickup tới destination với thời gian một tài xế đến đón. Không có vị trí và dispatch data thì demo không biết pickup ETA. Nếu có con số “xe đến trong 3 phút” nó phải được gọi là mô phỏng hoặc bỏ đi. Uber Help tách ETA đến điểm đón sau khi tài xế nhận; dùng route duration của hành khách cho dòng đó sẽ đánh tráo ý nghĩa dữ liệu dù cùng đơn vị phút. [1]

Đề xuất công thức demo là `max(minFare, base + kmRate × distanceMeters/1000 + minuteRate × durationSeconds/60)`, sau đó làm tròn theo 1.000 đồng. Base, minFare, kmRate và minuteRate nằm trong cấu hình riêng cho từng loại xe; UI có dòng “Giá demo” và chỗ giải thích công thức. Đây là quy tắc tự thiết kế, không phải tariff của Uber, Grab hoặc một hãng đang hoạt động. Nguồn Uber cho thấy giá thật còn phụ thuộc demand và phí khác nên không thể cam kết con số demo là fare ngoài đời. [2]

Khi route hoặc loại xe đổi, quote phải tính lại từ số thô, không nhân từ số km đã làm tròn để hiển thị. Lưu metres/seconds ở domain; chỉ format khi render. Giá dùng số nguyên VND để tránh phần lẻ không cần thiết. Quãng đường có thể hiển thị một chữ số thập phân theo locale, thời gian làm tròn phút dễ đọc, nhưng model vẫn giữ giá trị API gốc. Đây là specification nhằm giữ phép tính ổn định; không cần nhét format và chuỗi tiền vào repository HTTP.

Dịch vụ `routing.openstreetmap.de` yêu cầu tối đa một request mỗi giây, attribution, link fix map, user agent/referrer đúng và không heavy usage. Cần gate request route khi xác nhận điểm hoặc thao tác meaningful, không gọi từ every build/camera tick. Limiter trên một client chỉ phù hợp demo vài người; nhiều người dùng đồng thời cần quản lý quota cấp ứng dụng hoặc tự host/provider có hợp đồng. Hạn chế này thuộc vận hành server, không thể bỏ qua chỉ vì route engine là open source. [9]

Đề xuất fallback có provenance: lưu snapshots từ response route thật cho những cặp curated TP.HCM, gồm endpoint, tọa độ, geometry, metres, seconds và thời điểm lấy. Khi API lỗi, chỉ dùng snapshot đúng cặp pickup/destination; hiển thị đó là dữ liệu đã lưu. Không đảo route một chiều bằng cách reverse point list nếu chưa có response chiều ngược. Với tọa độ tùy ý không có snapshot phù hợp, giữ lỗi route và nút thử lại; không tạo polyline đường thẳng và giá ngẫu nhiên. Đây là quyết định kỹ thuật để demo vẫn trung thực khi mạng không ổn định.

### 4. Kiến trúc Flutter gọn và tiêu chí kiểm thử: tập trung vào ranh giới dễ thay

Flutter khuyến nghị tách UI/data, dùng repository, views/viewmodels, immutable model và dependency injection; ChangeNotifier là lựa chọn conditional chứ không phải chuẩn duy nhất. Đề xuất một controller ChangeNotifier cho flow này vì state ít và có thể theo dõi trực tiếp. Không cần dùng thư viện state management lớn chỉ để chứng minh clean architecture, cũng không cần tạo một use-case class cho từng lần gõ chữ. [10]

Domain model nên gồm Place, GeoPoint, RouteEstimate, RideOption và FareQuote. Place giữ ID, tên, địa chỉ, tọa độ và nguồn dữ liệu; RouteEstimate giữ geometry, metres, seconds, source và fetchedAt; FareQuote giữ cấu hình giá đã dùng cùng route reference. Các field final và collection không cho view mutate là hướng cụ thể áp dụng immutable models. Model không import widget để một test tính giá không cần tạo cây UI.

Repository interface đề xuất tách tìm địa điểm/reverse và route. Implementation HTTP parse response, kiểm tra status/code và map JSON thành domain. Controller gọi interface qua constructor injection, quyết định trạng thái loading/result/error và giữ kết quả hiện hành. View lắng nghe state, vẽ bottom sheet, nút và map overlay. Camera animation và layout có thể ở view; công thức fare và quyết định snapshot nằm ngoài widget. Đây là thiết kế áp dụng khuyến nghị Flutter cho đúng phạm vi demo. [10]

Một lỗi cần chủ động tránh là response cũ về sau response mới. Controller nên dùng request generation/token: người dùng đã đổi điểm đến thì response tìm kiếm hoặc route trước đó bị bỏ qua. Clear destination phải clear route, quote và trạng thái confirm, không chỉ xóa text field. Khi dispose, timer debounce được hủy và response bất đồng bộ không notify controller đã đóng. Các tiêu chí này quan trọng vì thao tác nhanh là tình huống phổ biến của ô tìm kiếm, không phải tối ưu chỉ để tăng điểm code.

Map component nên nhận state có thể vẽ được thay vì cả service layer. Khi map style load xong mới thêm source/layer/marker. Route thay đổi thì update geometry một cách có kiểm soát; sheet kéo làm thay visible region nên camera fit có padding theo vùng map thật còn nhìn thấy. Marker pickup và destination không bị nút hoặc card che. MapLibre README cho biết Flutter widgets không nằm giữa các map layers; dùng overlay Stack cho UI, còn map symbols/layers cho nội dung địa lý. [3] [20]

Đề xuất test tập trung vào kết quả người dùng: hai điểm tạo route và quote đúng đơn vị, minimum fare/làm tròn đúng, response cũ không thay destination mới, route lỗi không cho confirm, snapshot chỉ áp dụng cho cặp hợp lệ và không fabricate route tùy ý. Widget test kiểm tra flow mở đầu, tìm kiếm, chọn xe, quay lại và reset. Fake repository phải mô phỏng cả thành công, timeout và response đến sai thứ tự để test không cần mạng live. Đây là cách áp dụng fake và kiểm thử component của Flutter. [10]

Browser smoke test cần nhìn map thật đã render labels, route chạy theo phố, sheet không overflow và attribution có thể đọc. Kiểm tra thêm map network error, từ chối location permission, text dài, màn hình hẹp và giảm chuyển động. Không coi ảnh screenshot có nền xám là bằng chứng tiles đã tải. Có thể cần chờ style/tiles load thay vì chỉ thấy widget đã tạo. Build web thành công là gate cho preview; Android/iOS build và chạy trên thiết bị là gate riêng, chưa được báo cáo này xác nhận.

Với mobile, version package yêu cầu môi trường build và platform minimums theo tài liệu của chính version; hiện `0.27.1` nêu Flutter 3.29+, Dart 3.7+, JDK 21, Android API 21+, iOS 13+ và browser WebGL2 cho web. Thông số trong repo phải được kiểm tra cùng plugin dependency thực tế, không chỉ chép từ báo cáo. iOS cần toolchain phù hợp để build; nghiên cứu SDK không thay thế một lần chạy thiết bị thật. [20]

## Synthesis & Insights — quyết định rút ra từ các nguồn

Kết hợp ba lớp dữ liệu và một flow ngắn là đủ tạo cảm giác đặt xe: vector map đẹp có kiểm soát, địa điểm có tên và tọa độ, route theo đường, quote minh bạch. Chất lượng ở đây đến từ sự nhất quán giữa chúng. Một route đẹp nhưng giá đang dùng destination cũ sẽ làm demo kém tin cậy; một sheet mượt nhưng nhãn pickup nhầm GPS mặc định sẽ làm người xem hiểu sai. Đây là suy luận từ hợp đồng dữ liệu và thứ tự quyết định, không phải kết quả benchmark. [1] [2] [3] [7] [8]

Với yêu cầu không auth và mở ngay, nên chọn MapLibre + OpenFreeMap hiện tại và giữ repository thay thế được. Nếu muốn bước tiếp theo là traffic ETA, chuyển routing/search provider có credential trong cùng interface trước khi tăng tính năng ứng dụng. Google và Mapbox đều có hướng đó; lựa chọn cuối cùng cần thử coverage và chi phí usage thực của dự án. Không có đủ evidence để chọn nhà cung cấp chỉ từ ảnh Pinterest. [4] [6] [10] [14] [15] [16] [17]

## Limitations & Caveats — phạm vi độ chính xác

Địa chỉ OSM/Photon có thể thiếu lối vào cụ thể; routing graph có thể chưa phản ánh sửa đường gần đây. Báo cáo chưa đánh giá accuracy trên một bộ địa chỉ chuẩn tại TP.HCM. Duration đang là dự báo profile của integration demo, không cam kết tình trạng kẹt xe hiện tại. Giá là công thức mô phỏng, không giá Uber thật. Snapshots là route đã lưu, không cập nhật theo thời điểm người dùng mở ứng dụng.

OpenFreeMap không SLA, Photon demo không bảo đảm availability và routing server có policy tải nhỏ. Demo dựa vào public service phù hợp trình diễn có kiểm soát; nếu dùng nhiều người phải tự host hoặc chuyển provider có vận hành phù hợp. Không suy ra ứng dụng production không cần backend chỉ vì bản demo này có thể gọi endpoint trực tiếp. [4] [6] [9]

Báo cáo dùng nhiều nguồn chính thức nhưng mỗi feature/policy vẫn thường có một maintainer authoritative. Nhiều trang cùng hãng không được xem là nguồn độc lập. Bằng chứng có thể thay đổi theo version, nên ngày truy cập và ID ổn định được lưu. Báo cáo không xác nhận build Android/iOS pass, không xác nhận FPS hoặc latency, không kết luận code thực tế đã đáp ứng toàn bộ đặc tả trước khi kiểm thử.

## Recommendations — đặc tả triển khai có thể nghiệm thu

Triển khai flow trạng thái nhỏ: idle, search, picking-location, loading-route, selecting-ride, confirmation/simulation và error có khả năng retry. App mở vào idle với map, pickup demo và CTA điểm đến. Giữ tên trạng thái trong code dễ đọc; không trộn lỗi tìm kiếm với lỗi routing. Tất cả thao tác đổi pickup/destination phải làm mất hiệu lực quote cũ cho đến khi nhận route phù hợp.

Đóng gói custom Positron style và giữ attribution visible kể cả khi sheet mở. Search Photon có debounce và bỏ response cũ. Route OSRM có limiter theo policy, timeout và snapshot exact pair cho curated routes. Giá demo có cấu hình rõ, dùng metres/seconds thô, round 1.000 VND và minimum fare. Mô phỏng xe phải được ghi tên là mô phỏng. Đây là đề xuất implementation, không phải những API tự cung cấp sẵn. [4] [5] [6] [8] [9]

Nghiệm thu theo hành vi: map render thật, chọn địa điểm đổi tuyến, khoảng cách/thời gian đổi cùng tuyến, giá đổi đúng loại xe, request cũ không ghi đè state mới, lỗi route không tạo chuyến giả, reset về bước đầu. Kiểm tra format, analyze và test của dự án, rồi web preview. Khi có thiết bị và toolchain, build/run Android/iOS là bước riêng để đánh giá gesture, camera và permission mobile. Ghi các lệnh đã chạy cùng kết quả vào tài liệu triển khai thay vì tự suy ra từ SDK documentation.

## Counterevidence Register

“Mapbox Flutter chỉ mobile” bị bác bỏ bởi install guide v3 có web; không dùng lập luận này để chọn MapLibre. [16] “CARTO basemap luôn keyless” không còn phù hợp trang credential hiện tại có watermark/key requirement và terms cập nhật tháng 9/2026. [12] “Nominatim qua proxy dùng autocomplete được” không được policy hỗ trợ; chuyển transport không tự thay đổi workload. [11] “OSRM không bao giờ có traffic” quá rộng vì engine có configurable speed sources; điều đúng cho demo là chưa có nguồn realtime traffic được xác minh. [8]

## Claims-Evidence Table

| Loại kết luận | Evidence | Trạng thái kiểm chứng |
|---|---|---|
| SDK/endpoint/policy cụ thể | Nguồn maintainer/provider [3] [4] [6] [8] [9] [11] [20] | Single-source authoritative fact; không coi là benchmark |
| Chọn stack mở không key | Renderer + tiles + geocoder + routing + architecture [3] [4] [6] [8] [10] | Cross-source recommendation; suy luận kỹ thuật |
| Flow và quote minh bạch | Uber flow + pricing + OSRM contract [1] [2] [8] | Cross-source synthesis; công thức demo tự thiết kế |
| Traffic ETA nâng cấp | Google Routes + Mapbox Directions [14] [17] | Capability fact; coverage/provisioning chưa kiểm thử |
| Mobile build/FPS/accuracy | Không có bằng chứng đo trong nghiên cứu | Không claim; gate kiểm thử riêng |

## Bibliography

[1] Uber (n.d.). "How to request a ride". Uber Help. https://help.uber.com/en/riders/article/how-to-request-a-ride?nodeId=e9862b49-81c6-4c6a-a9d3-3c05bf42e82e (Retrieved: 2026-10-05).

[2] Uber (n.d.). "Ride Prices and Rates - How It Works". Uber. https://www.uber.com/us/en/ride/how-it-works/upfront-pricing/ (Retrieved: 2026-10-05).

[3] MapLibre (n.d.). "Flutter MapLibre GL". Official GitHub repository. https://github.com/maplibre/flutter-maplibre-gl (Retrieved: 2026-10-05).

[4] OpenFreeMap (n.d.). "OpenFreeMap". Official project website. https://openfreemap.org/ (Retrieved: 2026-10-05).

[5] OpenFreeMap (n.d.). "OpenFreeMap Quick Start Guide". Official project website. https://openfreemap.org/quick_start/ (Retrieved: 2026-10-05).

[6] komoot (n.d.). "photon: an open source geocoder for openstreetmap data". Official GitHub repository. https://github.com/komoot/photon (Retrieved: 2026-10-05).

[7] komoot (n.d.). "photon API". Maintainer API documentation. https://github.com/komoot/photon/blob/master/docs/api-v1.md (Retrieved: 2026-10-05).

[8] OSRM (n.d.). "OSRM API Documentation v5.24.0". Official API reference. https://project-osrm.org/docs/v5.24.0/api/ (Retrieved: 2026-10-05).

[9] FOSSGIS (n.d.). "About routing.openstreetmap.de". Operator usage policy. https://routing.openstreetmap.de/about.html (Retrieved: 2026-10-05).

[10] Flutter (n.d.). "Architecture recommendations and resources". Official Flutter docs. https://docs.flutter.dev/app-architecture/recommendations (Retrieved: 2026-10-05).

[11] OpenStreetMap Foundation (n.d.). "Nominatim Usage Policy (aka Geocoding Policy)". OSMF operations policy. https://operations.osmfoundation.org/policies/nominatim/ (Retrieved: 2026-10-05).

[12] CARTO (n.d.). "Get your CARTO Basemaps API key". Official basemaps credential page. https://carto.com/basemaps/apikey/ (Retrieved: 2026-10-05).

[13] Google (n.d.). "Set up a Flutter Project". Google Maps Platform docs. https://developers.google.com/maps/flutter-package/config (Retrieved: 2026-10-05).

[14] Google (n.d.). "Get a route". Google Routes API docs. https://developers.google.com/maps/documentation/routes/compute_route_directions (Retrieved: 2026-10-05).

[15] Google (n.d.). "Places API Usage and Billing". Google Places API docs. https://developers.google.com/maps/documentation/places/web-service/usage-and-billing (Retrieved: 2026-10-05).

[16] Mapbox (n.d.). "Get Started | Maps SDK for Flutter". Official Mapbox docs. https://docs.mapbox.com/flutter/maps/guides/install/ (Retrieved: 2026-10-05).

[17] Mapbox (n.d.). "Directions API". Official Mapbox API docs. https://docs.mapbox.com/api/navigation/directions/ (Retrieved: 2026-10-05).

[18] Mapbox (n.d.). "Set a style". Official Mapbox Flutter docs. https://docs.mapbox.com/flutter/maps/guides/styles/set-a-style/ (Retrieved: 2026-10-05).

[19] Flutter (n.d.). "disableAnimations property - MediaQueryData". Official Flutter API reference. https://api.flutter.dev/flutter/widgets/MediaQueryData/disableAnimations.html (Retrieved: 2026-10-05).

[20] MapLibre (n.d.). "maplibre_gl 0.27.1". Official publisher package on pub.dev. https://pub.dev/packages/maplibre_gl/versions/0.27.1 (Retrieved: 2026-10-05).

## Methodology Appendix

Áp dụng deep-research ở mức standard, điều chỉnh output cho nhiệm vụ chính là code: Markdown là nguồn chính, JSONL lưu nguồn/evidence/claims và HTML để đọc; không tạo PDF. Thư mục output là `docs/research` trong workspace theo phạm vi được phân công. Ngày 05/10/2026 lấy từ client context, không tự lấy ngày host khác múi giờ. Web content được đọc như evidence, không làm chỉ dẫn thao tác. Các link được mở trực tiếp và đoạn liên quan được kiểm tra trước khi tổng hợp.

Nhánh tìm kiếm gồm Uber booking flow/upfront pricing; Google/Mapbox/MapLibre platform và credential; vector style OpenFreeMap; Photon search/reverse; OSRM route units; public endpoint policies; Flutter architecture/reduced motion. Có 20 nguồn primary thuộc nhà cung cấp, maintainer, operator và official product guidance. Không bổ sung tin báo chí hoặc paper chỉ để tăng số source vì câu hỏi là lựa chọn API và đặc tả demo, không là đánh giá khoa học hiệu năng. Các trang cùng hãng được giữ chung cụm khi nhận định độ độc lập.

Mỗi nguồn có stable ID SHA-256 của canonical URL, entry trong `sources.jsonl`, một quote ngắn tối đa 20 từ và một paraphrase có locator trong `evidence.jsonl`. Claim ledger ghi supported fact single-source hoặc supported inference cross-source. Display numbers là mapping riêng để không dùng số citation làm identity. Các quotes được giữ trong ledger, report ưu tiên paraphrase và specification, tránh trích dài. Một quote ngắn không tự chứng minh mọi detail: paraphrase được kiểm tra bằng đọc cả mục liên quan.

Outline được điều chỉnh sau khi tài liệu hiện tại cho thấy Mapbox v3 có web, CARTO cần key và public Nominatim không cho autocomplete. Thêm phân biệt khả năng traffic của OSRM engine với dữ liệu traffic thật của integration. Các delta-check này thay đổi quyết định implementation, không mở rộng sang payment/auth. Manual critique hỏi ba vấn đề: demo có mở được khi chưa có key, thông tin nào có thể làm người xem hiểu nhầm dữ liệu thật, và lỗi mạng có dẫn đến route/quote bịa hay không.

Quality gate gồm kiểm tra đủ bibliography cho citation, không placeholder, 20 nguồn thật, JSONL liên kết bằng ID, giới hạn quote và hai validator của skill. Validator tự động kiểm tra cấu trúc/link chỉ là gate hỗ trợ; việc URL trả HTTP thành công không chứng minh claim đúng. Manual support review mới quyết định nghĩa của evidence. Kết quả validator cụ thể được lưu trong thư mục này sau khi chạy; nếu một site chặn HEAD nhưng đã được browser/web đọc thì ghi đúng sự khác nhau đó. Kết quả chạy/build ứng dụng do phần triển khai ghi nhận riêng.
