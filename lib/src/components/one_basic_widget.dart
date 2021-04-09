import 'package:flutter/material.dart';

class OneBasicWidget extends StatelessWidget {
  final Widget? child;
  final OneBasicWidgetTypes type;

  ///点击返回按钮是否能关闭弹窗
  final bool? isBackButtonDismissible;

  ///2021年3月10日
  ///点击返回按钮关闭弹窗时回调该方法：仅showDialog方法使用该字段
  final Function()? onClickBackButtonDismissCallback;

  const OneBasicWidget({required Key key, this.child, this.type = OneBasicWidgetTypes.unknown, this.isBackButtonDismissible, this.onClickBackButtonDismissCallback})
      : assert(child != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return child!;
  }
}

enum OneBasicWidgetTypes { snackbar, modalBottomSheet, bottomSheet, dialog, datePicker, unknown }
