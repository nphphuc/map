# Nghiệp vụ đặt xe Việt Nam cho demo bản đồ Flutter

Ngày đối chiếu: **06/10/2026 · Asia/Saigon**. Phạm vi: Grab, Be và Green SM/Xanh SM, tập trung điểm đón, điểm đến, khoảng cách, thời gian, cước và ngoại lệ. Các quy tắc thiết kế được ghi rõ là đề xuất cho demo.

## Executive Summary

Một demo có thể cho người dùng chọn địa điểm trên toàn Việt Nam, lấy đường đi và tính cước tham chiếu. Tuy nhiên, đường đi tồn tại không xác nhận rằng một hãng có xe tại điểm đón hoặc nhận hành trình đó. Chính sách công khai của Be, Grab và Green SM phân biệt loại dịch vụ, chiều đi, thời gian chờ và khu vực phục vụ. Vì vậy cần tách kết quả bản đồ, giá dự kiến và khả năng cung cấp chuyến thật.[4][6][7]

Nguồn Green SM tại TP.HCM hiện công bố bảng theo các mốc 2, 12 và 25 km. Có thể chọn bảng này làm cấu hình tham chiếu cố định, ghi ngày kiểm chứng và tính tiền rõ từng bậc. Áp dụng cấu hình ấy cho demo toàn quốc là quyết định thiết kế, không phải bảng giá toàn quốc của Green SM.[1] Grab công bố cấu phần giá theo khoảng cách và thời gian; thông tin dịch vụ còn mô tả phụ phí và điều chỉnh theo cung cầu, nên không thể sao chép một báo giá thực từ một bảng tĩnh.[5][10]

Đề xuất giữ luồng nhập đón/đến thống nhất, tự nhận diện đường dài từ 35 km; với tuyến từ 300 km hoặc 8 giờ, cho xem tuyến và giá rồi yêu cầu xác nhận mô phỏng chuyến đặc biệt. Mốc 35 km có tiền lệ trong thông báo Be năm 2023; hai mốc còn lại do demo đề xuất, không đại diện chính sách hãng.[2] Khi đổi điểm đón hoặc điểm đến, báo giá cũ phải mất hiệu lực. Khi không tìm được đường, thiếu vị trí hoặc dữ liệu không hợp lệ, màn hình phải cho sửa địa điểm và thử lại. Xe tài xế có thể mô phỏng, nhưng không được biến chúng thành bằng chứng về tài xế thật.

## Introduction

Nghiên cứu chuyển yêu cầu “đặt xe ở bất kỳ nơi nào” thành quy trình có thể kiểm tra. Demo không xác thực, thu tiền hay điều phối tài xế. Giá được giải thích từ route và cấu hình. Các đề xuất cần đối chiếu với mã và QA; báo cáo không tự xác nhận tính năng đã chạy.

Phương pháp dùng nguồn trực tiếp của ba doanh nghiệp, đối chiếu ngày bài viết với phần cập nhật và giới hạn dịch vụ. Bài cũ được giữ để giải thích sự thay đổi nghiệp vụ. Một thông báo của một hãng là chứng cứ cho chính thông báo đó, không đủ để suy rộng thành tiêu chuẩn thị trường. Các kết luận chung được đối chiếu ở cả ba nhóm doanh nghiệp; những mức giá riêng vẫn là thông tin một nguồn.

Không có quyền truy cập hệ thống báo giá, xe khả dụng, tốc độ giao thông hoặc điều phối nội bộ. Vì thế “giống cách đặt xe” được hiểu là thao tác và trạng thái rõ ràng, giá tính từ cấu hình công bố, cùng xử lý dữ liệu cũ và ngoại lệ. Không suy ra thuật toán độc quyền. Địa chỉ người dùng nêu để minh họa không trở thành điểm đón mặc định; mô hình nghiệp vụ phải nhận tọa độ của phiên hiện tại hoặc tọa độ người dùng chủ động chọn.

## Main Analysis

### 1. Một luồng đặt xe thống nhất, nhiều điều kiện dịch vụ

Be từng thông báo tích hợp “Đi tỉnh” vào màn hình đặt xe thông thường từ 29/04/2021. Nhập điểm đón và điểm đến sẽ làm giao diện hiện cước nội thành hoặc đi tỉnh tương ứng.[3] Thông báo đổi tên năm 2023 giải thích đường dài từ 35 km vẫn có thể nằm trong cùng một tỉnh/thành phố.[2] Hai tài liệu này ủng hộ cách phân loại theo hành trình, thay vì bắt người dùng đoán đúng một menu trước khi nhập địa điểm. Chúng không xác lập ngưỡng vận hành hiện tại cho tất cả hãng.

**Đề xuất demo:** mọi chuyến bắt đầu từ cùng ô điểm đón và điểm đến. Sau khi router trả kết quả hợp lệ, tính khoảng cách đường bộ, thời gian và loại hành trình. Không dùng tên thành phố trong chuỗi địa chỉ để tự quyết định giá. Tên do geocoder trả có thể có ngôn ngữ và cách ghi khác nhau; vùng phục vụ thật nếu sau này có cần dựa trên dữ liệu vùng của nhà cung cấp. Với bản hiện tại, cấu hình giá tham chiếu thống nhất giúp hai tọa độ giống nhau luôn tạo cùng phép tính.

Một vị trí GPS và một điểm đón xe thuận tiện có thể cần hai hành động riêng trong giao diện. Grab từng mô tả gợi ý cổng đón tại nơi đông người hoặc tòa nhà có nhiều lối vào.[13] **Đề xuất demo:** nhận vị trí của thiết bị để đặt camera và gợi ý điểm đón; cho người dùng điều chỉnh pin nếu muốn đón ở cổng khác. Tọa độ định vị không được thay bằng tâm một địa danh chỉ vì reverse geocoder trả tên địa danh ấy. Tên địa điểm là nhãn; tọa độ mới là dữ liệu cho routing.

**Đề xuất demo:** trước khi có vị trí, ứng dụng hiện trạng thái đang xác định điểm đón và vẫn cho tìm địa chỉ hoặc chọn pin. Nếu người dùng chọn thủ công trong khi GPS đang chờ, kết quả GPS đến sau không ghi đè lựa chọn đó. Nếu đang chọn điểm đến, nút vị trí hiện tại cần làm rõ đang điều chỉnh điểm nào. Mỗi thao tác đổi đón hoặc đến làm tăng phiên bản yêu cầu, để kết quả tìm đường trước đó không cập nhật nhầm chuyến mới.

Khả năng ghép xe không được suy ra từ khả năng geocode. FAQ Be nói tài xế có thể bật/tắt dịch vụ đi tỉnh và quyết định nhận từng yêu cầu.[4] **Đề xuất demo:** các xe hiển thị quanh điểm đón được ghi nhận là mô phỏng trong mô hình dữ liệu. Không hiển thị một thời gian “tài xế thật đến sau hai phút” từ tọa độ xe giả. Có thể mô phỏng đường xe tiến đến điểm đón sau khi người dùng chủ động bắt đầu, nhưng trạng thái đó là phát lại kịch bản.

### 2. Cước theo bậc, thời gian và phiên bản cấu hình

Trang Green SM TP.HCM ghi ngày bài 01/02/2025, nhưng bảng hiện đọc ngày 06/10/2026 có các dịch vụ Car, Premium và Limo với bốn cấu phần dưới đây. Trang yêu cầu xem app để biết giá chính xác vì thời điểm và ưu đãi có thể làm giá thay đổi.[1]

| Dịch vụ tham chiếu | Trọn 2 km đầu | Trên 2 đến 12 km, đ/km | Trên 12 đến 25 km, đ/km | Trên 25 km, đ/km |
|---|---:|---:|---:|---:|
| Car | 30.500 | 15.200 | 14.700 | 13.300 |
| Premium | 34.400 | 16.500 | 16.000 | 14.400 |
| Limo | 39.500 | 18.900 | 18.400 | 16.500 |

**Đề xuất phép tính của demo:** với khoảng cách đường bộ `d` tính bằng km, lấy giá 2 km đầu, cộng `min(max(d−2,0),10) × r1`, cộng `min(max(d−12,0),13) × r2`, rồi cộng `max(d−25,0) × r3`. Đây là diễn giải liên tục theo các bậc, dùng khoảng cách router trả về. Chọn riêng quy tắc làm tròn kết quả cuối để phép tính không nhảy theo mỗi km nguyên. Quy tắc làm tròn của demo phải có kiểm thử và được ghi như một quyết định cấu hình.

Ví dụ toán học tự tính cho cấu hình Car: 4,4 km tạo `30.500 + 2,4 × 15.200 = 66.980đ` trước làm tròn; 30 km tạo `30.500 + 10 × 15.200 + 13 × 14.700 + 5 × 13.300 = 440.100đ`. Những số này là kết quả của công thức demo, không phải giá đặt xe trực tiếp. Cần dùng cùng khoảng cách chính xác cho thẻ xe, trang xác nhận và màn hình kết thúc; số km đã rút gọn trên UI không được đưa ngược vào phép tính.

Grab công bố bảng GrabCar gồm giá tối thiểu 2 km, mỗi km tiếp theo và thời gian di chuyển sau 2 km; các hàng khác nhau theo khu vực và dịch vụ.[5] Thông tin dịch vụ Grab còn mô tả điều chỉnh theo cung cầu cùng phụ phí thời gian, thay đổi nhu cầu và phí nền tảng.[10] Vì vậy không nên ghép giá mở cửa của một hãng, giá km của hãng khác và tiền phút tự chọn rồi gọi là giá chuẩn của một thương hiệu.

**Đề xuất demo:** đặt tên cấu hình nội bộ rõ nguồn và ngày, chẳng hạn `reference_hcm_2026_10_06`. Giá chỉ gồm các bậc khoảng cách đã chọn; thời gian router dùng để hiển thị thời lượng dự kiến, không bị cộng tiền phút nếu cấu hình tham chiếu không có khoản ấy. Không tự cộng VAT lần nữa khi chưa xác lập nguồn đã gồm hay chưa gồm. Các khoản chưa tính như cầu đường, sân bay hoặc chờ cần ghi là chưa bao gồm, không hiển thị 0đ để tạo cảm giác đã được kiểm tra miễn phí.

**Đề xuất kiểm tra:** thử mốc 2, 12, 25 km và hai phía; từ chối khoảng cách âm, NaN, vô cực. Giá tăng liên tục, giữ mức mở cửa cho chuyến ngắn hợp lệ. Báo giá gắn với tọa độ, loại xe, route và cấu hình; thay thành phần nào cũng phải tính lại.

### 3. Đường dài và trường hợp TP.HCM–Hà Nội

Các dịch vụ đi xa không có một mô hình chung để sao chép nguyên xi. GrabCar 2 chiều hiện có gói 4/8 giờ gồm đi, về và chờ; điểm trả cuối thuộc tỉnh/thành phố đón ban đầu, với các giới hạn riêng về điểm dừng.[6] Green SM Liên Tỉnh hiện công bố các hành lang cụ thể, giá theo người hoặc bao xe và phụ thu khoảng cách ngoài vùng hub; chính sách ghi ngày 26/08/2026 thay thế trước đó.[7] Be từng mô tả đi tỉnh từ nơi hoạt động đến tỉnh lân cận.[11] Ba mô hình đều đặt điều kiện ngoài một đường nối hai tọa độ.

Danh sách Green SM Liên Tỉnh đang hiển thị không có tuyến TP.HCM–Hà Nội.[7] Phát hiện này chỉ nói về danh sách công khai đã đọc, không chứng minh doanh nghiệp tuyệt đối từ chối mọi yêu cầu riêng. Tài liệu Green SM đường dài năm 2023 có bảng theo thành phố, giảm chiều về và tiền chờ, nhưng tuổi tài liệu khiến các con số không phù hợp làm cam kết giá hiện tại.[8] Nghiên cứu không tìm thấy một báo giá công khai đủ để xác nhận rằng ba hãng đều nhận ngay chuyến một chiều xuyên Việt.

**Đề xuất demo:** vẫn cho chọn TP.HCM và Hà Nội, gọi router thật, hiển thị toàn tuyến và tính theo mô hình tham chiếu. Nếu route hợp lệ, không khóa mô phỏng chỉ vì chuyến xa. Từ 35 km có nhãn đường dài; từ 300 km hoặc thời lượng từ 8 giờ cần trang xác nhận chuyến đặc biệt nêu khoảng cách, thời lượng và giá tham chiếu. Mốc 300 km và 8 giờ do demo tự đặt để phân biệt tình huống cần suy xét, không phải trần nhận chuyến của Uber, Grab, Be hay Green SM.

**Đề xuất giao diện:** xác nhận chuyến đặc biệt nêu thời lượng chưa gồm nghỉ, chờ và phụ phí thiếu dữ liệu. Nút cuối bắt đầu mô phỏng. Không thông báo đã có tài xế thật từ xe mock. Cho sửa điểm đến hoặc phát lại đường bộ; đổi địa điểm thì tính lại điều kiện xác nhận.

**Đề xuất về toàn quốc:** mọi điểm do GPS, tìm kiếm hoặc pin tạo ra đều đi qua cùng pipeline. Không chỉ cho phép sáu địa danh mẫu, không dùng snapshot của chuyến ở TP.HCM cho một cặp tọa độ mới. Nếu tuyến đi qua phà hoặc router không có kết nối phù hợp, cần giữ nguyên dữ liệu đón/đến và cho người dùng chọn điểm khác. “Demo toàn Việt Nam” nên có nghĩa là nhận mọi đầu vào hợp lệ và xử lý cả thành công lẫn không có tuyến, không có nghĩa bịa một đường xe chạy cho mọi đảo hoặc mặt nước.

**Đề xuất mô phỏng:** xe chạy trên polyline theo chiều dài route. Phát lại nhanh không thay thế thời lượng router. Tuyến lớn cần giới hạn cập nhật camera, kiểm tra bộ nhớ và hủy/reset; km và giá trước/sau chuyến phải thống nhất.

### 4. Đổi địa điểm, chờ, phụ phí và dữ liệu không sẵn sàng

Grab mô tả đổi điểm đến bằng việc hiển thị cước mới rồi xác nhận; bài năm 2018 giải thích giá có tính đoạn đã đi và phần đến điểm mới cùng các cấu phần khác.[9] Hướng dẫn Be năm 2020 nói phần km tăng thêm được ứng dụng cộng vào số tiền cuối; tiền chờ chiều về chạy giữa kết thúc chiều đi và bắt đầu chiều về.[12] Đây là ví dụ cho nguyên tắc dữ liệu chuyến và báo giá phải cập nhật cùng nhau. Các giới hạn “một lần” trong bài lịch sử không được tự biến thành luật hiện tại cho mọi dịch vụ.

**Đề xuất demo trước khi bắt đầu:** cho đổi đón hoặc đến linh hoạt, nhưng ngay khi đổi phải ẩn hoặc vô hiệu giá cũ và nút xác nhận. Có phản hồi đang tìm tuyến và tính lại. Chỉ khi route mới đúng cặp tọa độ hiện hành thì cập nhật ba loại xe. Nếu request cũ về sau request mới, bỏ request cũ. Nếu route mới lỗi, không giữ giá cũ như vẫn áp dụng cho địa điểm vừa thay.

Một bài GrabBike năm 2020 nêu đổi điểm đón sau đặt bị giới hạn khi nhiều điểm dừng, điểm mới quá xa hoặc tài xế đã gần điểm ban đầu.[14] Đây là chính sách được ghi cho Bike, không phải bằng chứng về bán kính cụ thể của Car. **Đề xuất demo đang phát lại:** nút quay lại hoặc kết thúc mô phỏng phải hủy timer và route đang phát. Nếu chưa triển khai đổi đích giữa chuyến với tính tiền đoạn đã đi, lựa chọn đơn giản là dừng rồi bắt đầu kịch bản mới; không âm thầm reset tiền mà vẫn giữ trạng thái cùng chuyến.

FAQ Be phân biệt cước ban đầu với cước cuối theo thời gian chờ, khoảng cách và thời gian thực tế, đồng thời loại phí cầu đường/bến bãi/đỗ xe khỏi cước đi tỉnh.[4] GrabCar 2 chiều cũng tách cầu đường, sân bay và đỗ xe khỏi giá hiển thị.[6] **Đề xuất demo:** không tạo tiền chờ từ thời gian người dùng đọc màn hình. Đó là thời gian tương tác, không phải tài xế đã chờ. Không nhân thêm hệ số chuyến một chiều đã được áp dụng trong cấu hình. Hướng dẫn Be cũ cũng nhắc tài xế không được tự thu lại khoản điều chỉnh một chiều đã nằm trong app.[12]

**Đề xuất lỗi dữ liệu:** phân biệt không có kết quả tìm địa điểm với lỗi mạng; phân biệt không tìm được đường với router hết thời gian. Điểm đón trùng hoặc gần điểm đến cần yêu cầu chọn điểm khác thay vì nhận một chuyến 0 m có giá mở cửa. Tọa độ ngoài phạm vi demo cần báo rõ phạm vi. Tọa độ hợp lệ nhưng nằm quá xa đường xe chạy cần cho điều chỉnh pin. Không có kết quả không làm mất hai điểm đã chọn, để thao tác khôi phục ngắn và rõ.

Grab từng mô tả hủy khi còn tìm tài xế và tự tìm tài xế khác sau khi tài xế đầu hủy.[13] Tài liệu giá hiện tại còn có phí hủy riêng cho đặt trước, nên không thể mang một quy tắc phí hủy sang mọi flow.[10] **Đề xuất demo:** hủy/reset không thu tiền và trả về điểm đón của phiên hiện tại hoặc lựa chọn thủ công đã xác nhận. Không tự quay về tọa độ mẫu. Nếu bổ sung một kịch bản “không có xe”, ghi đó là trạng thái mô phỏng có chủ đích và vẫn cho sửa tuyến hoặc thử lại.

## Synthesis & Insights

Kết luận đối chiếu là khả năng demo bản đồ cần được kiểm tra độc lập với năng lực nhận chuyến của một hãng. Một router trả tuyến, một cấu hình tính tiền và một hệ thống ghép tài xế trả xe là ba kết quả khác nhau. Việc tách chúng giúp bản demo mở rộng địa điểm mà vẫn thể hiện đúng trạng thái. Đây là suy luận từ điều kiện đi tỉnh, đi hai chiều và tuyến định sẵn, không phải thông tin về kiến trúc nội bộ của ba hãng.[4][6][7]

Mô hình tham chiếu giúp người xem tính lại tiền. Đề xuất báo giá lưu nguồn cấu hình, route và dấu thời gian; UI hiện dữ liệu cần quyết định, phép tính chi tiết ở thông tin cước. Không trình bày giá bỏ phí/điều kiện như báo giá thương mại.

Tuyến rất xa làm rõ ranh giới giữa mô phỏng và đặt xe. Với SG–HN, vẫn nên cho người dùng quan sát đường và tiền theo mô hình đã chọn. Một bước xác nhận chuyến đặc biệt giúp người xem hiểu chưa có điều phối thực. Đề xuất không tăng số bước cho chuyến ngắn, chỉ yêu cầu xác nhận thêm khi hành trình đạt điều kiện cấu hình.

## Limitations & Caveats

Không nghiên cứu này hoặc bảng tĩnh nào chứng minh giá có hiệu lực tại phút người dùng bấm đặt xe. Ngày truy cập khác ngày xuất bản và có trang được cập nhật nhiều lần. Tài liệu 2018–2023 chỉ được dùng với giới hạn thời gian. Một số trang Grab dùng ảnh cho chi tiết; bài trợ giúp hiện tại về mức phụ phí đổi đích không mở được bằng công cụ web, nên báo cáo không khẳng định một mức phí đổi đích mới.

Nghiên cứu giới hạn ở nội dung chính thức, không đăng nhập app ba hãng hoặc gửi yêu cầu chuyến thật. Không có kiểm thử tài xế nhận SG–HN, vùng hoạt động từng phút, thời tiết, ùn tắc, phà, trạm thu phí hoặc quyền nhận cuốc của từng xe. Không đủ chứng cứ cho một giới hạn đường dài chung. Phần không tìm đường và chất lượng định vị là đề xuất xử lý dữ liệu; cần QA riêng với SDK và thiết bị thực.

Nguồn tự công bố có độ tin cậy cao về điều khoản riêng của tác giả nhưng không độc lập về chất lượng hay độ phủ. Các nguồn thuộc cùng công ty không được đếm như nhiều xác nhận độc lập. Những tổng hợp cả thị trường dùng cả ba công ty; các mức giá riêng vẫn được đánh dấu chứng cứ một nguồn trong ledger.

## Recommendations

Trước hết triển khai điểm đón động, thao tác lấy vị trí hiện tại và hủy kết quả cũ khi người dùng chọn thủ công. Kế tiếp dùng một pipeline tìm tuyến cho mọi cặp đón/đến hợp lệ, không phụ thuộc danh sách mẫu. Sau đó đưa bảng tham chiếu theo bậc vào lớp domain, cùng những mốc và quy tắc làm tròn có kiểm thử. Giao diện không còn tên Uber hay tên hãng trên nút lựa chọn xe nếu không dùng dịch vụ của hãng.

Với tuyến đường dài, đề xuất phân loại 35 km; tuyến đặc biệt từ 300 km hoặc 8 giờ cần người dùng xác nhận mô phỏng. Kiểm tra các chuyến ngắn ở Hà Nội, TP.HCM, Đà Nẵng, khu vực ngoài đô thị, liên tỉnh và SG–HN. Tình huống lỗi cần gồm mất mạng, hết thời gian, không route, ngoài phạm vi, hai điểm trùng, pin xa đường và thay đổi địa điểm khi API đang xử lý. Các đề xuất này không chứng minh bản app đã vượt qua QA.

Nếu sau này phát triển đặt xe thương mại, cần API báo giá/điều phối cùng dữ liệu vùng dịch vụ, thu phí và giao thông phù hợp. Khi đó cấu hình tham chiếu được thay bằng báo giá có hạn dùng. Không tái sử dụng giá minh họa làm số tiền phải thanh toán.

## Bibliography

[1] Green SM (2025). “Bảng giá dịch vụ Taxi Green SM tại TP. Hồ Chí Minh cập nhật”. [Nguồn chính thức](https://www.greensm.com/vn-vi/news/bang-gia-xe-taxi-sai-gon). Truy cập: 06/10/2026.

[2] Be (2023). “Thông báo về việc thay đổi tên gọi dịch vụ be Đi Tỉnh”. [Nguồn chính thức](https://be.com.vn/tin-tuc/thong-bao-ve-viec-thay-doi-ten-goi-dich-vu-be-di-tinh/). Truy cập: 06/10/2026.

[3] Be (2021). “Tích hợp tính năng Đi Tỉnh theo lựa chọn điểm đến”. [Nguồn chính thức](https://be.com.vn/tin-tuc/tich-hop-tinh-nang-di-tinh-theo-lua-chon-diem-den-thong-minh-va-tien-loi-hon/). Truy cập: 06/10/2026.

[4] Be (không ghi ngày). “Câu hỏi thường gặp”. [Nguồn chính thức](https://be.com.vn/ho-tro/cau-hoi-thuong-gap/). Truy cập: 06/10/2026.

[5] Grab (2026). “Bảng dịch vụ cập nhật Thuế suất VAT 8%”. [Nguồn chính thức](https://www.grab.com/vn/blog/driver/thongtindichvu/). Truy cập: 06/10/2026.

[6] Grab (2025; cập nhật 2026). “Cập nhật thông tin dịch vụ GrabCar 2 chiều”. [Nguồn chính thức](https://www.grab.com/vn/en/blog/driver/grabcar2chieu/). Truy cập: 06/10/2026.

[7] Green SM (chính sách 26/08/2026). “Green SM Liên Tỉnh”. [Nguồn chính thức](https://www.greensm.com/vn-vi/green-lien-tinh). Truy cập: 06/10/2026.

[8] Green SM (2023). “Bảng giá xe taxi đường dài một số tuyến phổ biến”. [Nguồn chính thức](https://www.greensm.com/vn-vi/news/taxi-duong-dai). Truy cập: 06/10/2026.

[9] Grab (2018). “Cách để thay đổi Điểm Đến trên hành trình đã đặt trước”. [Nguồn chính thức](https://www.grab.com/vn/blog/changedestination/). Truy cập: 06/10/2026.

[10] Grab (2023; cập nhật 08/07/2026). “Bảng thông tin các dịch vụ trên ứng dụng Grab”. [Nguồn chính thức](https://www.grab.com/vn/en/blog/bang-thong-tin-cac-dich-vu-tren-ung-dung-grab/). Truy cập: 06/10/2026.

[11] Be (2019). “Giới thiệu dịch vụ gọi xe be Đi Tỉnh”. [Nguồn chính thức](https://be.com.vn/be-news/gioi-thieu-dich-vu-goi-xe-be-di-tinh/). Truy cập: 06/10/2026.

[12] Be (2020). “Hướng dẫn be đi tỉnh – Dịch vụ Gọi xe đi tỉnh”. [Nguồn chính thức](https://be.com.vn/be-rider-blog/bebike-becar-huong-dan-be-di-tinh-dich-vu-goi-xe-di-tinh/). Truy cập: 06/10/2026.

[13] Grab (2018). “BetterEveryday – Seamless Rides for Passengers”. [Nguồn chính thức](https://www.grab.com/vn/better-everyday-2018/passenger/seamless-rides/). Truy cập: 06/10/2026.

[14] Grab (2020). “GrabBike & GrabBike Premium – Thay Đổi Điểm Đón”. [Nguồn chính thức](https://www.grab.com/vn/en/blog/driver/thay-doi-diem-don-2w/). Truy cập: 06/10/2026.

## Methodology Appendix

Nghiên cứu nhanh, tra cứu song song giá, đi tỉnh, hai chiều, phụ phí và đổi điểm ở tên miền chính thức. Lưu 14 nguồn có ID băm URL,14 đoạn diễn giải có locator và 18 claim kiểm tra nghĩa. Đề xuất có loại `inference` riêng trong ledger.

Đề cương ban đầu tập trung bảng taxi đường dài năm 2023. Sau khi tìm được trang Green SM Liên Tỉnh với chính sách 26/08/2026 và các cập nhật Grab 2026, chuyển trọng tâm sang phân biệt sản phẩm theo tuyến, hai chiều và khả năng vận hành. Điều chỉnh này ngăn dùng bảng cũ cho báo giá hiện tại. Cũng loại mức phí đổi đích chỉ xuất hiện trong kết quả tìm kiếm của trang trợ giúp không mở được.

Kiểm tra cấu trúc, bibliography và claim support bằng các script của skill deep-research. Đối chiếu nghĩa thủ công vẫn là điều kiện quyết định vì kiểm tra chuỗi ký tự không xác nhận phạm vi thời gian hoặc sản phẩm. Báo cáo chủ yếu là phân tích và thiết kế đề xuất; không trích dài nguyên văn, không khẳng định thuật toán riêng, không xác nhận độ chính xác định vị hay điều phối thật. Log kiểm tra và giới hạn truy cập nguồn được lưu cạnh báo cáo.
