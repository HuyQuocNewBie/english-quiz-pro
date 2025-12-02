EnglishQuiz Pro – Ứng dụng Quiz Tiếng Anh đa nền tảng
Đồ án cuối kỳ – Lập trình di động (Flutter + Firebase)

Tính năng chính
Đăng nhập/Đăng ký bằng Email & Google
Làm quiz tiếng Anh (Ngữ pháp, Từ vựng, Thành ngữ...)
Xem kết quả + giải thích chi tiết từng câu
Lịch sử làm bài & điểm cao nhất
Người dùng bình thường có thể tự thêm câu hỏi
Quản trị viên toàn quyền: quản lý người dùng, câu hỏi, danh mục, xem thống kê
Loading đẹp (Lottie + SpinKit) khi mở app và khi thực hiện hành động
Giao diện hiện đại, chạy mượt trên Android & iOS
Công nghệ sử dụng
Flutter 3.24+
Firebase Authentication
Cloud Firestore
Provider (state management)
Lottie & Flutter Spinkit (loading)
Cấu trúc thư mục
lib/ ├── core/ → theme, constants, routes ├── models/ → User, Question, QuizResult, Category ├── services/ → Auth & Firestore ├── providers/ → Auth, Quiz, Admin ├── screens/ → auth, user, admin ├── widgets/ → loading, button, card... └── utils/

Cách chạy dự án
flutter pub get flutter run