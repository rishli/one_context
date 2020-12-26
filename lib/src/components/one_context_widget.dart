import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'package:flutter/material.dart';
import 'package:one_context/src/components/one_basic_widget.dart';
import 'package:one_context/src/controllers/one_context.dart';

class OneContextWidget extends StatefulWidget {
  final Widget child;
  OneContextWidget({Key key, this.child}) : super(key: key);
  _OneContextWidgetState createState() => _OneContextWidgetState();
}

class _OneContextWidgetState extends State<OneContextWidget> {
  @override
  void initState() {
    super.initState();
    OneContext().registerDialogCallback(
        showDialog: _showDialog,
        showSnackBar: _showSnackBar,
        showModalBottomSheet: _showModalBottomSheet,
        showBottomSheet: _showBottomSheet,
        showDatePicker: _showDatePicker);
    BackButtonInterceptor.add(backButtonInterceptor);
  }

  @override
  void dispose() {
    BackButtonInterceptor.remove(backButtonInterceptor);
    super.dispose();
  }

  bool backButtonInterceptor(bool stopDefaultButtonEvent, RouteInfo info) {
    try {
      if (OneContext().hasDialogVisible) {
        OneBasicWidget lastDialog = OneContext().dialogList.last;
        if (lastDialog.isBackButtonDismissible) {
          if (lastDialog.type == OneBasicWidgetTypes.snackbar) {
            OneContext().hideCurrentSnackBar();
          } else {
            OneContext().popDialog();
          }
        }
        return true;
      } else
        return false;
    } catch (e) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Builder(
        builder: (innerContext) {
          OneContext().context = innerContext;
          return widget.child;
        },
      ),
    );
  }

  Future<T> _showDialog<T>(
          {bool barrierDismissible = true,
          Widget Function(BuildContext) builder,
          bool useRootNavigator = true}) =>
      showDialog<T>(
        context: context,
        builder: (context) => builder(context),
        barrierDismissible: barrierDismissible,
        useRootNavigator: useRootNavigator,
      );

  ScaffoldFeatureController<SnackBar, SnackBarClosedReason> _showSnackBar(
          SnackBar Function(BuildContext) builder) =>
      Scaffold.of(OneContext().context)
          .showSnackBar(builder(OneContext().context));

  Future<T> _showModalBottomSheet<T>(
      {Widget Function(BuildContext) builder,
      Color backgroundColor,
      double elevation,
      ShapeBorder shape,
      Clip clipBehavior,
      bool isScrollControlled = false,
      bool useRootNavigator = false,
      bool isDismissible = true}) {
    return showModalBottomSheet<T>(
      context: context,
      builder: builder,
      backgroundColor: backgroundColor,
      clipBehavior: clipBehavior,
      elevation: elevation,
      isDismissible: isDismissible,
      isScrollControlled: isScrollControlled,
      shape: shape,
      useRootNavigator: useRootNavigator,
    );
  }

  PersistentBottomSheetController<T> _showBottomSheet<T>(
      {@required Widget Function(BuildContext) builder,
      Color backgroundColor,
      double elevation,
      ShapeBorder shape,
      Clip clipBehavior}) {
    return showBottomSheet<T>(
        context: OneContext().context,
        builder: builder,
        backgroundColor: backgroundColor,
        elevation: elevation,
        shape: shape,
        clipBehavior: clipBehavior);
  }

  Future<DateTime> _showDatePicker({
    @required DateTime initialDate,
    @required DateTime firstDate,
    @required DateTime lastDate,
    DateTime currentDate,
    DatePickerEntryMode initialEntryMode,
    SelectableDayPredicate selectableDayPredicate,
    String helpText,
    String cancelText,
    String confirmText,
    Locale locale,
    bool useRootNavigator,
    RouteSettings routeSettings,
    TextDirection textDirection,
    TransitionBuilder builder,
    DatePickerMode initialDatePickerMode,
    String errorFormatText,
    String errorInvalidText,
    String fieldHintText,
    String fieldLabelText,
  }) =>
      showDatePicker(
        context: OneContext().context,
        initialDate: initialDate,
        firstDate: firstDate,
        lastDate: lastDate,
        currentDate: currentDate,
        initialEntryMode: initialEntryMode,
        selectableDayPredicate: selectableDayPredicate,
        helpText: helpText,
        cancelText: cancelText,
        confirmText: confirmText,
        locale: locale,
        useRootNavigator: useRootNavigator,
        routeSettings: routeSettings,
        textDirection: textDirection,
        builder: builder,
        initialDatePickerMode: initialDatePickerMode,
        errorFormatText: errorFormatText,
        errorInvalidText: errorInvalidText,
        fieldHintText: fieldHintText,
        fieldLabelText: fieldLabelText,
      );
}
