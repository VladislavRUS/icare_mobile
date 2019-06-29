import 'package:flutter/material.dart';
import 'package:flutter_hack/constants/app_colors.dart';

class Loader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CircularProgressIndicator(
      valueColor: AlwaysStoppedAnimation<Color>(AppColors.MAIN_COLOR),
    );
  }
}
