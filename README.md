# EnglishQuiz Pro 🎓

Ứng dụng luyện tập tiếng Anh qua quiz với giao diện hiện đại, tích hợp đầy đủ hệ thống người dùng & admin, thống kê, lịch sử làm bài… xây dựng bằng **Flutter + Firebase**.

---

## 1. Tính năng chính

### 1.1. Người dùng (User)

- **Đăng nhập / Đăng ký**
  - Email + mật khẩu
  - Đăng nhập bằng Google
- **Làm quiz theo danh mục**
  - Ngữ pháp, Từ vựng, Thành ngữ, Điền từ, Nghe hiểu...
  - Mỗi câu có **đồng hồ đếm ngược**
  - Sau khi chọn đáp án:
    - Hiển thị đúng/sai ngay trên câu hỏi
    - Chỉ chuyển câu khi bấm **Next Question / Finish Quiz**
- **Kết quả bài làm**
  - Điểm (score) & phần trăm (%)
  - Hiển thị danh mục vừa hoàn thành
  - Nút:
    - **Trang chủ**
    - **Làm lại**
    - **Xem giải thích chi tiết**
- **Giải thích chi tiết**
  - Mỗi câu:
    - Câu hỏi
    - Đáp án đúng (highlight xanh)
    - Câu trả lời của bạn (highlight xanh hoặc đỏ, gạch ngang nếu sai)
    - Giải thích chi tiết
- **Lịch sử làm bài**
  - Danh sách tất cả quiz đã làm
  - Mỗi item:
    - Danh mục
    - Điểm / Tổng điểm
    - % đúng
    - Thời gian hoàn thành
  - **Lịch sử chi tiết**:
    - Thông tin bài quiz
    - Danh sách câu hỏi + đáp án + giải thích (giống màn giải thích)
- **Điểm cao nhất & tiến độ**
  - Ở màn Home:
    - **Điểm cao nhất tổng** (highScore)
    - Tiến độ từng danh mục dựa trên `categoryHighScores` và số câu hỏi

---

## 2. Tính năng Admin

Admin được xác định bằng trường `role: "admin"` trong collection `users`.

### 2.1. Trang chủ Admin

- Dashboard tổng quan:
  - Tổng người dùng
  - Tổng câu hỏi
  - Số lượt làm quiz
  - Số danh mục
- Khu vực **Quản lý**:
  - Quản lý Câu hỏi
  - Quản lý Người dùng
  - Quản lý Danh mục
  - Báo cáo & Thống kê
- Nút **Đăng xuất** riêng cho admin

### 2.2. Quản lý Câu hỏi

- Danh sách câu hỏi:
  - Nội dung câu hỏi
  - Danh mục
  - Nút **Sửa** / **Xóa**
- **Thêm / Sửa câu hỏi**:
  - Nhập:
    - Nội dung câu hỏi
    - Chọn danh mục
    - 4 đáp án A/B/C/D
    - Chọn đáp án đúng
    - Giải thích chi tiết (tuỳ chọn)
  - UI chuẩn form admin:
    - Header: “Thêm Câu Hỏi Mới” / “Sửa Câu Hỏi”
    - Nút “Lưu” ở trên cùng
- Xóa câu hỏi có **hộp thoại xác nhận**

### 2.3. Quản lý Danh mục

- Danh sách danh mục dạng card:
  - Icon khác nhau cho từng kiểu danh mục
  - Tên danh mục
  - Nút **Sửa** / **Xóa**
- **Thêm / Sửa danh mục**:
  - Nhập tên danh mục
  - UI đẹp với icon `title` bên trái, nút “Thêm Mới / Cập nhật” bo tròn phía dưới
- Xóa danh mục:
  - Cảnh báo: xóa luôn tất cả câu hỏi thuộc danh mục đó

### 2.4. Quản lý Người dùng

- Danh sách người dùng:
  - Avatar, tên, email
  - Chip “Admin” cho tài khoản admin
  - Nút:
    - **Edit**: toggle quyền admin (cấp / bỏ admin)
    - **Delete**: xóa tài khoản (có xác nhận)
- Thanh **search** + filter:
  - Tìm theo tên / email
  - Lọc: Tất cả / Admin / User

### 2.5. Báo cáo & Thống kê

- **Thống kê tổng quan**:
  - Tổng người dùng
  - Quiz đã hoàn thành
  - Tổng câu hỏi
- **Hiệu suất**:
  - Tỷ lệ **Đúng / Sai** (biểu đồ tròn)
- **Người dùng hàng đầu**:
  - Tính từ `quiz_results` → map vào `_users` với trường `score`
  - Hiển thị top N user có `score` cao nhất (sắp xếp giảm dần)

> Lưu ý: để top user hiển thị đúng, bạn cần đảm bảo logic cập nhật điểm tổng (`totalScore` hoặc `score` per user) đã được implement trong `QuizProvider` / Firestore.

---

## 3. Kiến trúc & Công nghệ

- **Flutter**: 3.24+
- **State management**: `provider`
- **Backend**: Firebase
  - Authentication (Email/Password, Google)
  - Cloud Firestore
- **UI/UX**
  - Material 3 style
  - Nhiều màn hình được thiết kế theo prototype Tailwind/HTML
  - Lottie & SpinKit cho loading (Splash + action)

**Cấu trúc thư mục:**

lib/
  core/
    app_routes.dart      # Định nghĩa route + map route
    theme.dart           # Theme chung
    constants.dart       # Hằng số (tên collection, v.v.)
  models/
    user_model.dart
    question_model.dart
    quiz_result_model.dart
    category_model.dart
  services/
    auth_service.dart    # Đăng nhập, đăng ký, Google SignIn, lấy UserModel
  providers/
    auth_provider.dart   # Quản lý trạng thái đăng nhập
    quiz_provider.dart   # Quản lý quiz, điểm, kết quả
    admin_provider.dart  # Quản lý dữ liệu admin (users, categories, stats)
  screens/
    auth/
      login_screen.dart
    user/
      home_screen.dart
      quiz_screen.dart
      result_screen.dart
      explanation_screen.dart
      history_screen.dart
      history_detail_screen.dart
      settings_screen.dart
    admin/
      admin_dashboard_screen.dart
      manage_questions_screen.dart
      add_edit_question_screen.dart
      manage_categories_screen.dart
      add_edit_category_screen.dart
      manage_users_screen.dart
      statistics_screen.dart
  widgets/
    custom_button.dart
    bottom_nav_bar.dart
    question_card.dart

## 4. Chuẩn bị Firebase

### 4.1. Tạo Project Firebase

1. Vào `https://console.firebase.google.com`
2. **Add project** → đặt tên (ví dụ: `english_quiz_pro`)
3. Bật **Google Analytics** nếu muốn (không bắt buộc)

### 4.2. Thêm app Flutter

1. Trong project Firebase, thêm app **Android** (và iOS nếu cần)
2. Điền:
   - Android package name: trùng với `applicationId` trong `android/app/build.gradle`
3. Tải file `google-services.json` đặt vào: `android/app/`

### 4.3. Bật Authentication

1. Menu **Authentication → Sign-in method**
2. Bật:
   - Email/Password
   - Google (nhập SHA-1 nếu cần)

### 4.4. Tạo Firestore & Collections

Tạo Cloud Firestore (mode Production). Các collection chính:

- `users`
  - `email: string`
  - `displayName: string`
  - `photoURL: string?`
  - `role: "user" | "admin"`
  - `highScore: number`
  - `categoryHighScores: { [categoryName]: number }`
  - (tuỳ chọn) `totalScore: number` để thống kê top user

- `categories`
  - `name: string`

- `questions`
  - `question: string`
  - `answers: string[] (4 phần tử)`
  - `correctIndex: number`
  - `explanation: string`
  - `category: string` (trùng với `categories.name`)

- `quiz_results`
  - `userId: string`
  - `category: string`
  - `score: number`
  - `total: number`
  - `completedAt: Timestamp`
  - `answers: { [questionId]: userAnswerIndex }`

> Sau khi tạo xong, có thể dùng màn admin để thêm danh mục + câu hỏi.

---

## 5. Cài đặt & Chạy dự án

### 5.1. Yêu cầu

- Flutter 3.24+ (`flutter --version`)
- Dart 3.x
- Android Studio / VSCode + plugin Flutter
- Đã cài đặt `firebase_core` và `flutterfire` (đã có trong `pubspec.yaml`)

### 5.2. Cài dependencies

flutter pub get### 5.3. Chạy app

flutter runNếu có nhiều thiết bị, chọn thiết bị từ `flutter devices` hoặc IDE.

---

## 6. Logic điểm & tiến độ

### 6.1. Trong Quiz

- Mỗi câu đúng: **+10 điểm**
- `QuizProvider`:
  - `score` = tổng điểm
  - `userAnswers` = danh sách index người dùng chọn
  - Sau khi kết thúc quiz:
    - Gọi `saveResult(userId, category)`
    - Lưu vào `quiz_results`
    - Cập nhật:
      - `users/<uid>/highScore`
      - `users/<uid>/categoryHighScores[category]`
      - (tuỳ chọn) `users/<uid>/totalScore` để thống kê top user

### 6.2. Ở Home (User)

Tiến độ từng danh mục được tính:

final maxScore = questionCount * 10;
final userCategoryScore =
    user?.categoryHighScores[catName]?.toDouble() ?? 0.0;

final progress = (maxScore > 0)
    ? (userCategoryScore / maxScore).clamp(0.0, 1.0)
    : 0.0;- `progress` dùng cho text “Hoàn thành X%” và progress bar.

### 6.3. Ở Statistics (Admin)

- `AdminProvider.loadStatistics()`:
  - Đọc `quiz_results`:
    - `_totalResults` = số document
    - `_categoryAverages[category]` = điểm trung bình theo danh mục
    - `scoresByUser[userId] += score` → map sang `_users` với trường `score`
- `StatisticsScreen`:
  - Hiển thị `_totalUsers`, `_totalQuestions`, `_totalResults`
  - Biểu đồ tròn đúng/sai (có thể tính % đúng nếu có dữ liệu chi tiết)
  - Top users: sort `_users` theo `score` giảm dần, lấy 3 user đầu.

---

## 7. Phân quyền & bảo mật

### 7.1. Phân quyền trong app

- **User**:
  - Mặc định `role: "user"`
  - Chỉ truy cập được các màn hình:
    - Home, Quiz, Result, Explanation, History, Settings
- **Admin**:
  - `role: "admin"` → được chuyển sang `AdminDashboardScreen` khi login
  - Có quyền truy cập tất cả màn hình admin:
    - Manage Questions/Users/Categories
    - Statistics

### 7.2. Gợi ý Firestore Rules (cần tinh chỉnh thêm)

rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {

    match /users/{userId} {
      allow read, update: if request.auth != null && request.auth.uid == userId;
      allow create: if request.auth != null;
      allow read: if resource.data.role == 'admin' && request.auth != null; // tuỳ chỉnh
    }

    match /quiz_results/{docId} {
      allow create: if request.auth != null;
      allow read: if request.auth != null && request.auth.uid == resource.data.userId;
    }

    // Các collection khác tuỳ nhu cầu
  }
}---

## 8. Hướng phát triển tiếp

- Thêm **dark mode** switch trong Settings.
- Hỗ trợ **đa ngôn ngữ** (vi / en) bằng `flutter_localizations`.
- Thêm loại câu hỏi khác (drag & drop, listening audio).
- Export kết quả thống kê admin dưới dạng CSV / Excel.
- Push notification: nhắc người dùng luyện quiz hàng ngày.

---