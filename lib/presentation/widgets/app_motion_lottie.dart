import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class AppMotionLottie extends StatelessWidget {
  const AppMotionLottie(
    this.assetName, {
    super.key,
    this.width,
    this.height,
    this.fit = BoxFit.contain,
    this.repeat = true,
  });

  final String assetName;
  final double? width;
  final double? height;
  final BoxFit fit;
  final bool repeat;

  @override
  Widget build(BuildContext context) {
    return Lottie.asset(
      assetName,
      width: width,
      height: height,
      fit: fit,
      repeat: repeat,
    );
  }
}
