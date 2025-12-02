import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:lottie/lottie.dart';

/// Loading toàn cục – dùng cho mọi nơi trong app
class LoadingWidget extends StatelessWidget {
  final bool useLottie; // true = Lottie, false = SpinKit
  final double size;

  const LoadingWidget({
    super.key,
    this.useLottie = false,
    this.size = 80,
  });

  @override
  Widget build(BuildContext context) {
    if (useLottie) {
      return Lottie.asset(
        'assets/lottie/loading.json',
        width: size + 40,
        height: size + 40,
        fit: BoxFit.contain,
      );
    }

    return SpinKitFadingCircle(
      color: Theme.of(context).primaryColor,
      size: size,
    );
  }
}

/// Loading overlay che toàn màn hình (dùng khi gọi API, đăng nhập, v.v.)
class FullScreenLoader extends StatelessWidget {
  const FullScreenLoader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black54,
      child: const Center(
        child: LoadingWidget(useLottie: true, size: 100),
      ),
    );
  }
}