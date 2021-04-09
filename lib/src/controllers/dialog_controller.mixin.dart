import 'package:flutter/foundation.dart';
import 'package:one_context/src/components/one_basic_widget.dart';
import 'package:one_context/src/controllers/one_context.dart';
import 'package:flutter/material.dart';

typedef Widget DialogBuilder(BuildContext context);
mixin DialogController {
  /// Return dialog utility class `DialogController`
  DialogController get dialog => this;

  /// The current context
  BuildContext? get context => OneContext().context;

  List<OneBasicWidget> _dialogs = [];

  List<OneBasicWidget> get dialogList => _dialogs;

  /// Check if it has dialog visible
  bool get hasDialogVisible => _dialogs.length > 0;

  void _addDialogVisible(OneBasicWidget widget) {
    _dialogs.add(widget);
  }

  void _removeDialogVisible({OneBasicWidget? widget}) {
    if (widget != null) {
      _dialogs.remove(widget);
    } else
      _dialogs.removeLast();
  }

  Future<T?> Function<T>({
    bool? barrierDismissible,
    required Widget Function(BuildContext) builder,
    bool useRootNavigator,
    Color barrierColor,
  })? _showDialog;

  Future<T?> Function<T>(
      {required Widget Function(BuildContext) builder,
      Color? backgroundColor,
      double? elevation,
      ShapeBorder? shape,
      Clip? clipBehavior,
      bool isScrollControlled,
      bool useRootNavigator,
      bool isDismissible})? _showModalBottomSheet;

  ScaffoldFeatureController<SnackBar, SnackBarClosedReason> Function(
    SnackBar Function(BuildContext?) builder,
  )? _showSnackBar;

  PersistentBottomSheetController<T> Function<T>({
    Widget Function(BuildContext) builder,
    Color? backgroundColor,
    double? elevation,
    ShapeBorder? shape,
    Clip? clipBehavior,
  })? _showBottomSheet;

  /// Displays a Material dialog above the current contents of the app, with
  /// Material entrance and exit animations, modal barrier color, and modal
  /// barrier behavior (dialog is dismissible with a tap on the barrier).
  Future<T?> showDialog<T>(
      {required Widget Function(BuildContext) builder,
      Color barrierColor = Colors.transparent,
      bool barrierDismissible = false,
      bool useRootNavigator = true,
      bool isBackButtonDismissible = true,
      Function()? onClickBackButtonDismissCallback}) async {
    if (!(await _contextLoaded())) return null;

    OneBasicWidget dialog = OneBasicWidget(
      key: UniqueKey(),
      child: builder(context!),
      type: OneBasicWidgetTypes.dialog,
      isBackButtonDismissible: isBackButtonDismissible,
      onClickBackButtonDismissCallback: onClickBackButtonDismissCallback,
    );
    _addDialogVisible(dialog);
    return _showDialog!<T>(
      builder: (_) => dialog,
      barrierDismissible: barrierDismissible,
      useRootNavigator: useRootNavigator,
      barrierColor: barrierColor,
    ).whenComplete(() {
      _removeDialogVisible(widget: dialog);
    });
  }

  /// ## To be removed
  /// Dismiss a [SnackBar] at the bottom of the scaffold.
  /// Use `hideCurrentSnackBar` instead.
  @deprecated
  void dismissSnackBar({SnackBarClosedReason reason = SnackBarClosedReason.hide}) async {
    if (!(await _contextLoaded())) return;
    Scaffold.of(context!).hideCurrentSnackBar(reason: reason);
  }

  /// Removes the current [SnackBar] by running its normal exit animation.
  ///
  /// The closed completer is called after the animation is complete.
  void hideCurrentSnackBar({SnackBarClosedReason reason = SnackBarClosedReason.hide}) async {
    if (!(await _contextLoaded())) return;
    Scaffold.of(context!).hideCurrentSnackBar(reason: reason);
  }

  /// Removes the current [SnackBar] (if any) immediately.
  ///
  /// The removed snack bar does not run its normal exit animation. If there are
  /// any queued snack bars, they begin their entrance animation immediately.
  void removeCurrentSnackBar({SnackBarClosedReason reason = SnackBarClosedReason.hide}) async {
    if (!(await _contextLoaded())) return;
    Scaffold.of(context!).removeCurrentSnackBar(reason: reason);
  }

  /// Shows a [SnackBar] at the bottom of the scaffold.
  Future<ScaffoldFeatureController<SnackBar, SnackBarClosedReason>?> showSnackBar(
      {required SnackBar Function(BuildContext?) builder, bool isBackButtonDismissible = true}) async {
    if (!(await _contextLoaded())) return null;
    return _showSnackBar!(builder);
  }

  /// Shows a modal material design bottom sheet.
  ///
  /// A modal bottom sheet is an alternative to a menu or a dialog and prevents
  /// the user from interacting with the rest of the app.
  Future<T?> showModalBottomSheet<T>(
      {required Widget Function(BuildContext) builder,
      Color? backgroundColor,
      double? elevation,
      ShapeBorder? shape,
      Clip? clipBehavior,
      bool isScrollControlled = false,
      bool useRootNavigator = false,
      bool isDismissible = true,
      bool isBackButtonDismissible = true}) async {
    if (!(await _contextLoaded())) return null;

    OneBasicWidget dialog =
        OneBasicWidget(key: UniqueKey(), child: builder(context!), type: OneBasicWidgetTypes.modalBottomSheet, isBackButtonDismissible: isBackButtonDismissible);
    _addDialogVisible(dialog);
    return _showModalBottomSheet!<T>(
            builder: (_) => dialog,
            backgroundColor: backgroundColor,
            clipBehavior: clipBehavior,
            elevation: elevation,
            isDismissible: isDismissible,
            isScrollControlled: isScrollControlled,
            shape: shape,
            useRootNavigator: useRootNavigator)
        .whenComplete(() {
      _removeDialogVisible(widget: dialog);
    });
  }

  /// Shows a material design bottom sheet in the nearest [Scaffold] ancestor. If
  /// you wish to show a persistent bottom sheet, use [Scaffold.bottomSheet].
  ///
  /// Returns a controller that can be used to close and otherwise manipulate the
  /// bottom sheet.
  Future<PersistentBottomSheetController<T>?> showBottomSheet<T>(
      {required Widget Function(BuildContext) builder,
      Color? backgroundColor,
      double? elevation,
      ShapeBorder? shape,
      Clip? clipBehavior,
      bool isBackButtonDismissible = true}) async {
    if (!(await _contextLoaded())) return null;

    OneBasicWidget dialog =
        OneBasicWidget(key: UniqueKey(), child: builder(context!), type: OneBasicWidgetTypes.bottomSheet, isBackButtonDismissible: isBackButtonDismissible);
    _addDialogVisible(dialog);
    return _showBottomSheet!<T>(builder: builder, backgroundColor: backgroundColor, elevation: elevation, shape: shape, clipBehavior: clipBehavior)
      ..closed.whenComplete(() {
        _removeDialogVisible(widget: dialog);
      });
  }

  /// Shows a dialog containing a Material Design date picker.
  ///
  /// The returned [Future] resolves to the date selected by the user when the
  /// user confirms the dialog. If the user cancels the dialog, null is returned.
  ///
  /// When the date picker is first displayed, it will show the month of
  /// [initialDate], with [initialDate] selected.
  ///
  /// The [firstDate] is the earliest allowable date. The [lastDate] is the latest
  /// allowable date. [initialDate] must either fall between these dates,
  /// or be equal to one of them. For each of these [DateTime] parameters, only
  /// their dates are considered. Their time fields are ignored. They must all
  /// be non-null.
  ///
  /// The [currentDate] represents the current day (i.e. today). This
  /// date will be highlighted in the day grid. If null, the date of
  /// `DateTime.now()` will be used.
  ///
  /// An optional [initialEntryMode] argument can be used to display the date
  /// picker in the [DatePickerEntryMode.calendar] (a calendar month grid)
  /// or [DatePickerEntryMode.input] (a text input field) mode.
  /// It defaults to [DatePickerEntryMode.calendar] and must be non-null.
  ///
  /// An optional [selectableDayPredicate] function can be passed in to only allow
  /// certain days for selection. If provided, only the days that
  /// [selectableDayPredicate] returns true for will be selectable. For example,
  /// this can be used to only allow weekdays for selection. If provided, it must
  /// return true for [initialDate].
  ///
  /// The following optional string parameters allow you to override the default
  /// text used for various parts of the dialog:
  ///
  ///   * [helpText], label displayed at the top of the dialog.
  ///   * [cancelText], label on the cancel button.
  ///   * [confirmText], label on the ok button.
  ///   * [errorFormatText], message used when the input text isn't in a proper date format.
  ///   * [errorInvalidText], message used when the input text isn't a selectable date.
  ///   * [fieldHintText], text used to prompt the user when no text has been entered in the field.
  ///   * [fieldLabelText], label for the date text input field.
  ///
  /// An optional [locale] argument can be used to set the locale for the date
  /// picker. It defaults to the ambient locale provided by [Localizations].
  ///
  /// An optional [textDirection] argument can be used to set the text direction
  /// ([TextDirection.ltr] or [TextDirection.rtl]) for the date picker. It
  /// defaults to the ambient text direction provided by [Directionality]. If both
  /// [locale] and [textDirection] are non-null, [textDirection] overrides the
  /// direction chosen for the [locale].
  ///
  /// The [context], [useRootNavigator] and [routeSettings] arguments are passed to
  /// [showDialog], the documentation for which discusses how it is used. [context]
  /// and [useRootNavigator] must be non-null.
  ///
  /// The [builder] parameter can be used to wrap the dialog widget
  /// to add inherited widgets like [Theme].
  ///
  /// An optional [initialDatePickerMode] argument can be used to have the
  /// calendar date picker initially appear in the [DatePickerMode.year] or
  /// [DatePickerMode.day] mode. It defaults to [DatePickerMode.day], and
  /// must be non-null.
  ///
  /// See also:
  ///
  ///  * [showDateRangePicker], which shows a material design date range picker
  ///    used to select a range of dates.
  ///  * [CalendarDatePicker], which provides the calendar grid used by the date picker dialog.
  ///  * [InputDatePickerFormField], which provides a text input field for entering dates.

  /// Register callbacks
  void registerCallback({
    Future<T?> Function<T>({
      bool? barrierDismissible,
      required Widget Function(BuildContext) builder,
      bool useRootNavigator,
      Color barrierColor,
    })?
        showDialog,
    Future<T?> Function<T>(
            {required Widget Function(BuildContext) builder,
            Color? backgroundColor,
            double? elevation,
            ShapeBorder? shape,
            Clip? clipBehavior,
            bool? isScrollControlled,
            bool? useRootNavigator,
            bool? isDismissible})?
        showModalBottomSheet,
    ScaffoldFeatureController<SnackBar, SnackBarClosedReason> Function(SnackBar Function(BuildContext?) builder)? showSnackBar,
    PersistentBottomSheetController<T> Function<T>(
            {Widget Function(BuildContext)? builder, Color? backgroundColor, double? elevation, ShapeBorder? shape, Clip? clipBehavior})?
        showBottomSheet,
  }) {
    _showDialog = showDialog;
    _showSnackBar = showSnackBar;
    _showModalBottomSheet = showModalBottomSheet;
    _showBottomSheet = showBottomSheet;
  }

  /// Pop the top-most dialog off the OneContext.dialog.
  popDialog<T extends Object>([T? result]) async {
    if (!(await _contextLoaded())) return;
    return Navigator.of(context!).pop<T>(result);
  }

  Future<bool> _contextLoaded() async {
    await Future.delayed(Duration.zero);
    if (!OneContext.hasContext && !kReleaseMode) {
      throw NO_CONTEXT_ERROR;
    }
    return OneContext.hasContext;
  }
}
