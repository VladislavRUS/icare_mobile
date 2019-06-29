import 'package:flutter/material.dart';
import 'package:flutter_hack/constants/app_colors.dart';

class BigButton extends StatelessWidget {
  final String text;
  final Function onTap;
  bool isLoading;
  bool isDisabled;

  BigButton({this.text, this.onTap, this.isLoading, this.isDisabled = false});

  onButtonTap() {
    if (isLoading) {
      return;
    }

    onTap();
  }

  @override
  Widget build(BuildContext context) {
    return RaisedButton(
      padding: EdgeInsets.only(top: 12, bottom: 12, left: 50, right: 50),
      onPressed: isDisabled ? null : onButtonTap,
      disabledColor: Colors.grey,
      color: AppColors.MAIN_COLOR,
      child: Stack(
        children: <Widget>[
          Positioned(
            left: 0,
            right: 0,
            child: Center(
              child: Opacity(
                  opacity: isLoading ? 1 : 0,
                  child: Container(
                      width: 15,
                      height: 15,
                      child: FittedBox(
                          fit: BoxFit.contain,
                          child: CircularProgressIndicator(
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          )))),
            ),
          ),
          Opacity(
              opacity: isLoading ? 0 : 1,
              child: Text(this.text,
                  style: TextStyle(color: Colors.white, fontSize: 16)))
        ],
      ),
    );
  }
}
