import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class LoadingWidget {
  // Full screen loading (dùng khi đổi màn hình, đăng nhập, v.v.)
  static Widget fullScreen() {
    return const Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SpinKitFadingCircle(
              color: Color(0xFF2E8B57),
              size: 60,
            ),
            SizedBox(height: 24),
            Text(
              'Đang tải...',
              style: TextStyle(fontSize: 18, color: Color(0xFF2E8B57)),
            ),
          ],
        ),
      ),
    );
  }

  // Inline loading nhỏ (dùng trong button, list, v.v.)
  static Widget inline({Color color = const Color(0xFF2E8B57)}) {
    return SpinKitThreeBounce(
      color: color,
      size: 24,
    );
  }

  // Loading cho button (khi bấm sẽ hiện loading bên trong nút)
  static Widget button() {
    return const SizedBox(
      width: 20,
      height: 20,
      child: CircularProgressIndicator(
        color: Colors.white,
        strokeWidth: 2.5,
      ),
    );
  }
}