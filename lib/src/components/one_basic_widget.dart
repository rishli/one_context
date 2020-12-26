import 'package:flutter/material.dart';

class OneBasicWidget extends StatelessWidget {

  final Widget child;
  final OneBasicWidgetTypes type;
  final bool isBackButtonDismissible;

  const OneBasicWidget({Key key, @required this.child, this.type = OneBasicWidgetTypes.unknown, this.isBackButtonDismissible})
      : assert(child != null), super(key: key);
  @override
  Widget build(BuildContext context) {
    return child;
  }
}

enum OneBasicWidgetTypes {
  snackbar,
  modalBottomSheet,
  bottomSheet,
  dialog,
  datePicker,
  unknown
}
