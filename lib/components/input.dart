import 'package:flutter/material.dart';
import 'package:flutter_hack/constants/app_colors.dart';

class Input extends StatelessWidget {
  final TextEditingController controller;
  final Widget icon;
  final String hintText;
  final TextInputType inputType;
  final int maxLines;
  final bool obscureText;
  final bool isEnabled;
  final Function onChanged;

  Input(
      {this.controller,
      this.onChanged,
      this.icon,
      this.hintText,
      this.inputType,
      this.obscureText = false,
      this.isEnabled = true,
      this.maxLines = 1});

  List<Widget> getChildren() {
    List<Widget> children = List();

    if (icon != null) {
      children.add(Container(
          margin: EdgeInsets.only(left: 8),
          padding: EdgeInsets.only(right: 8),
          child: Opacity(child: icon, opacity: 0.7),
          decoration: BoxDecoration(
              border: Border(
                  right:
                      BorderSide(color: AppColors.BORDER_COLOR, width: 1)))));
    }

    children.add(Expanded(
      child: TextField(
          enabled: isEnabled,
          maxLines: maxLines,
          controller: controller,
          onChanged: onChanged,
          keyboardType: inputType != null ? inputType : TextInputType.text,
          obscureText: obscureText,
          decoration: InputDecoration(
              hintText: this.hintText,
              disabledBorder: InputBorder.none,
              border: InputBorder.none,
              contentPadding: EdgeInsets.all(12)),
          style: TextStyle(fontSize: 14, color: AppColors.INPUT_TEXT_COLOR)),
    ));

    return children;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: AppColors.BORDER_COLOR),
            borderRadius: BorderRadius.all(Radius.circular(0))),
        child: Row(children: getChildren()));
  }
}
