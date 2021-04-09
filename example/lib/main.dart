import 'dart:math';
import 'package:flutter/services.dart';
import 'package:one_context/one_context.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

bool debugShowCheckedModeBanner = false;
const localeEnglish = [Locale('en', '')];

void main() => OnePlatform.app = () => MyApp();

class MyApp extends StatelessWidget {
  MyApp() {
    print('MyApp loaded!');

    debugShowCheckedModeBanner = true;

    // Reseting light theme
    if (OneContext.hasContext) OneContext().oneTheme.changeThemeData(ThemeData(primarySwatch: Colors.green, brightness: Brightness.light));
  }

  @override
  Widget build(BuildContext context) {
    /// important: Use [OneContext().builder] in MaterialApp builder, in order to show dialogs, overlays and change the app theme.
    /// important: Use [OneContext().key] in MaterialApp navigatorKey, in order to navigate.

    return OneNotification<List<Locale>>(
      onVisited: (_, __) {
        print('Root widget visited!');
      },
      // This widget rebuild the Material app to update theme, supportedLocales, etc...
      stopBubbling: true,
      // avoid the data bubbling to ancestors widgets
      initialData: localeEnglish,
      // [data] is null during boot of the application, but you can set initialData ;)
      rebuildOnNull: true,
      // Allow other entities reload this widget without messing up currenty data (Data is cached on first event)

      builder: (context, dataLocale) {
        if (dataLocale != null && dataLocale != localeEnglish) print('Set Locale: $dataLocale');

        return OneNotification<OneThemeChangerEvent>(
            onVisited: (_, __) {
              print('Theme Changer widget visited!');
            },
            stopBubbling: true,
            builder: (context, data) {
              return MaterialApp(
                debugShowCheckedModeBanner: debugShowCheckedModeBanner,
                // Configure reactive theme mode and theme data (needs OneNotification above in the widget tree)
                themeMode: OneThemeController.initThemeMode(ThemeMode.light),
                theme: OneThemeController.initThemeData(ThemeData(primarySwatch: Colors.green, primaryColor: Colors.green, brightness: Brightness.light)),
                darkTheme: OneThemeController.initDarkThemeData(ThemeData(brightness: Brightness.dark, primaryColor: Colors.blue)),

                // Configure [OneContext] to dialogs, overlays, snackbars, and ThemeMode
                builder: OneContext().builder,
                // builder: (context, widget) => OneContext().builder(context, widget, mediaQueryData: MediaQuery.of(context).copyWith(textScaleFactor: 1.0)),

                // Set navigator key in order to navigate
                navigatorKey: OneContext().key,

                // [data] it comes through events
                supportedLocales: dataLocale ?? [const Locale('en', '')],

                title: 'OneContext Demo',
                home: MyHomePage(
                  title: 'OneContext Demo',
                ),
                routes: {'/second': (context) => SecondPage()},
                // onGenerateRoute: (settings) {
                // if (settings.name == SecondPage.routeName) {
                //   return MaterialPageRoute(
                //     builder: (context) {
                //       return SecondPage();
                //       },
                //   );
                // }
                // },
              );
            });
      },
    );
  }
}

class MyApp2 extends StatelessWidget {
  MyApp2() {
    print('MyApp2 loaded!');
    OneContext().key = GlobalKey<NavigatorState>();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        theme: ThemeData(primarySwatch: Colors.pink),
        title: 'OneContext Demo',
        home: MyHomePage2(title: 'A NEW APPLICATION'),
        routes: {'/second': (context) => SecondPage()},
        builder: OneContext().builder,
        navigatorKey: OneContext().key);
  }
}

class MyHomePage2 extends StatefulWidget {
  MyHomePage2({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePage2State createState() => _MyHomePage2State();
}

class _MyHomePage2State extends State<MyHomePage2> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Container(
        color: Colors.pink,
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            RaisedButton(
                child: Text('COME BACK TO THE OLD APP'),
                onPressed: () {
                  OnePlatform.reboot(
                    setUp: () {
                      OneContext().key = GlobalKey<NavigatorState>();
                    },
                    builder: () => MyApp(),
                  );
                }),
            RaisedButton(
                child: Text('Navigate to Second Page'),
                onPressed: () {
                  OneContext().pushNamed('/second');
                })
          ],
        ),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  final String reloadAppButtonLabel;

  MyHomePage({Key key, this.title, this.reloadAppButtonLabel}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with SingleTickerProviderStateMixin {
  Map<String, Offset> randomOffset = Map<String, Offset>();
  AnimationController _controller;
  Animation<Offset> _offsetAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _offsetAnimation = Tween<Offset>(
      begin: Offset(0, -1),
      end: const Offset(0, 0),
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOutCubic,
    ));
  }

  _showDialog1() async {
    Future.delayed(Duration(seconds: 3), () {
      print("定时关闭弹窗");

      ///TODO 调用该方法关闭弹窗时，关闭的是相同页面下，最后使用OneContext.showDialog()显示的dialog
      ///TODO 关闭弹窗前，先检查是否有dialog显示，否则会关闭当前页面
      ///TODO 即使先调用OneContext.showDialog()显示的dialog，再调用Flutter showDialog（）显示dialog，使用Flutter showDialog（）的dialog显示在最下面
      OneContext().popDialog();
    });

    OneContext().showDialog<String>(
      builder: (context) => AlertDialog(
        backgroundColor: Colors.blue,
        title: new Text("第一个弹窗1"),
        content: new Text("The Body"),
        actions: <Widget>[
          new FlatButton(child: new Text("OK"), onPressed: () => OneContext().popDialog('ok')),
          new FlatButton(child: new Text("CANCEL"), onPressed: () => OneContext().popDialog('cancel')),
        ],
      ),
      isBackButtonDismissible: true,
      onClickBackButtonDismissCallback: () {
        print('rishli 关闭了弹窗111');
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title + ' - ' + debugShowCheckedModeBanner.toString()),
        actions: <Widget>[
          Switch(
              activeColor: Colors.blue,
              value: debugShowCheckedModeBanner,
              onChanged: (_) {
                debugShowCheckedModeBanner = !debugShowCheckedModeBanner;
              })
        ],
      ),
      body: SingleChildScrollView(
        child: Container(
          alignment: Alignment.center,
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              RaisedButton(
                child: Text(' Hard Reload'),
                onPressed: () {
                  OneNotification.hardReloadRoot(context);
                },
              ),
              RaisedButton(
                child: Text('Soft Reeboot the app'),
                onPressed: () {
                  OnePlatform.reboot(setUp: () => print('Reboot the app!'));
                },
              ),
              RaisedButton(
                child: Text('Hard Reeboot'),
                onPressed: () {
                  OnePlatform.reboot(
                      builder: () => MyApp(),
                      setUp: () {
                        print('\n\nSetting debugShowCheckedModeBanner = true, so the debug banner should appear on the app right now.'
                            '\n\n That is useful for load environment variables and project configuration before boot the app!'
                            '\n And if you just need run some stuffs and reload the app without change it.');
                        debugShowCheckedModeBanner = true;
                      });
                },
              ),
              RaisedButton(
                child: Text('Load another app'),
                onPressed: () {
                  OnePlatform.reboot(
                      setUp: () {
                        OneContext().key = GlobalKey<NavigatorState>();
                      },
                      builder: () => MyApp2());
                },
              ),
              RaisedButton(
                child: Text('Change ThemeData Light'),
                onPressed: () {
                  OneContext().oneTheme.changeThemeData(ThemeData(primarySwatch: Colors.purple, brightness: Brightness.light));
                },
              ),
              RaisedButton(
                child: Text('Change ThemeData Dark'),
                onPressed: () {
                  OneContext().oneTheme.changeDarkThemeData(ThemeData(primarySwatch: Colors.amber, brightness: Brightness.dark));
                },
              ),
              RaisedButton(
                child: Text('Toggle ThemeMode (Dark/Light)'),
                onPressed: () {
                  OneContext().oneTheme.toggleMode();
                },
              ),
              RaisedButton(
                child: Text('Change to english locale support'),
                onPressed: () {
                  OneNotification.notify<List<Locale>>(context,
                      payload: NotificationPayload(data: [
                        Locale('en', ''), // English
                      ]));
                },
              ),
              RaisedButton(
                child: Text('Show SnackBar'),
                onPressed: () {
                  showTipsOnScreen('OneContext().showSnackBar()');
                  OneContext().hideCurrentSnackBar(); // Dismiss snackbar before show another ;)
                  OneContext().showSnackBar(
                      builder: (context) => SnackBar(
                            content: Text(
                              'My awesome snackBar!',
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.title.copyWith(color: Colors.white),
                            ),
                            action: SnackBarAction(label: 'DISMISS', onPressed: () {}),
                          ));
                },
              ),
              RaisedButton(
                child: Text('Show Dialog显示弹窗'),
                onPressed: () async {
                  showTipsOnScreen('OneContext().showDialog<String>()');
                  //TODO 测试弹窗显示
                  print("OneContext中的context与当前page的context是否是同一个：${context == OneContext().context}");

                  await _showDialog1();

                  print("第一个dialog已经显示");

                  OneContext().showDialog<String>(
                    builder: (context) => AlertDialog(
                      title: new Text("The Title2"),
                      content: new Text("The Body"),
                      actions: <Widget>[
                        new FlatButton(child: new Text("OK"), onPressed: () => OneContext().popDialog('ok')),
                        new FlatButton(child: new Text("CANCEL"), onPressed: () => OneContext().popDialog('cancel')),
                      ],
                    ),
                    isBackButtonDismissible: true,
                    onClickBackButtonDismissCallback: () {
                      print('rishli 关闭了弹窗2');
                    },
                  );

                  print("第2个dialog已经显示");

                  ///print("弹窗2 result：" + (result ?? "null"));
                  ///
                  ///TODO 使用flutter API显示dialog
                  showDialog(
                      context: context,
                      builder: (_) {
                        return AlertDialog(
                          backgroundColor: Colors.red,
                          title: new Text("使用flutter API显示dialog"),
                          content: new Text("The Body2"),
                          actions: <Widget>[
                            new FlatButton(child: new Text("OK2"), onPressed: () => OneContext().popDialog('ok')),
                            new FlatButton(child: new Text("CANCEL2"), onPressed: () => OneContext().popDialog('cancel')),
                          ],
                        );
                      });
                },
              ),
              RaisedButton(
                child: Text('Show DatePicker'),
                onPressed: () async {
                  showTipsOnScreen('OneContext().showDatePicker()');
                  DateTime selectedDate = DateTime.now();
                  OneContext()
                      .showDatePicker(initialDate: selectedDate, firstDate: DateTime(2015, 8), lastDate: DateTime(2101))
                      .then((picked) => {if (picked != null && picked != selectedDate) print(picked)});
                },
              ),
              RaisedButton(
                child: Text('Show modalBottomSheet'),
                onPressed: () async {
                  showTipsOnScreen('OneContext().showModalBottomSheet<String>()');
                  var result = await OneContext().showModalBottomSheet<String>(
                      builder: (context) => Container(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                ListTile(leading: Icon(Icons.music_note), title: Text('Music'), onTap: () => OneContext().popDialog('Music')),
                                ListTile(leading: Icon(Icons.videocam), title: Text('Video'), onTap: () => OneContext().popDialog('Video')),
                                SizedBox(height: 45)
                              ],
                            ),
                          ));
                  print(result);
                },
              ),
              RaisedButton(
                child: Text('Show bottomSheet'),
                onPressed: () {
                  showTipsOnScreen('OneContext().showBottomSheet()');
                  OneContext().showBottomSheet(
                    builder: (context) => Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                        color: Colors.red,
                      ),
                      margin: EdgeInsets.all(16),
                      alignment: Alignment.topCenter,
                      height: 200,
                      child: IconButton(icon: Icon(Icons.arrow_drop_down), iconSize: 50, color: Colors.white, onPressed: () => OneContext().popDialog()),
                    ),
                  );
                },
              ),
              RaisedButton(
                  child: Text('Show and block till input'),
                  onPressed: () async {
                    showTipsOnScreen('OneContext().showDialog<int>()');
                    switch (await OneContext().showDialog<int>(
                        barrierDismissible: false,
                        builder: (BuildContext context) {
                          return SimpleDialog(
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10))),
                            title: const Text('Select assignment'),
                            children: <Widget>[
                              SimpleDialogOption(
                                onPressed: () {
                                  OneContext().popDialog(1);
                                },
                                child: const Text('Number 1'),
                              ),
                              SimpleDialogOption(
                                onPressed: () {
                                  OneContext().popDialog(2);
                                },
                                child: const Text('Number 2'),
                              ),
                            ],
                          );
                        })) {
                      case 1:
                        print('number one');
                        break;
                      case 2:
                        print('number two');
                        break;
                    }
                  }),
              RaisedButton(
                child: Text('Show default progress indicator'),
                onPressed: () {
                  showTipsOnScreen('OneContext().showProgressIndicator()');

                  OneContext().showProgressIndicator();
                  Future.delayed(Duration(seconds: 2), () => OneContext().hideProgressIndicator());
                },
              ),
              RaisedButton(
                child: Text('Show progress indicator colored'),
                onPressed: () {
                  showTipsOnScreen('OneContext().showProgressIndicator(backgroundColor, circularProgressIndicatorColor)');
                  OneContext().showProgressIndicator(backgroundColor: Colors.blue.withOpacity(.3), circularProgressIndicatorColor: Colors.red);
                  Future.delayed(Duration(seconds: 2), () => OneContext().hideProgressIndicator());
                },
              ),
              RaisedButton(
                child: Text('Show custom progress indicator'),
                onPressed: () {
                  showTipsOnScreen('OneContext().showProgressIndicator(backgroundColor, circularProgressIndicatorColor)');
                  OneContext().showProgressIndicator(
                    builder: (_) => Container(
                        color: Colors.black38,
                        alignment: Alignment.center,
                        child: SizedBox(
                          height: 80,
                          width: 80,
                          child: Card(
                            color: Colors.white,
                            elevation: 0,
                            // shape: RoundedRectangleBorder(),
                            child: Center(child: CircularProgressIndicator()),
                          ),
                        )),
                  );
                  Future.delayed(Duration(seconds: 2), () => OneContext().hideProgressIndicator());
                },
              ),
              RaisedButton(
                child: Text('Show custom animated indicator'),
                onPressed: () {
                  showTipsOnScreen('OneContext().showProgressIndicator(builder)');
                  OneContext().showProgressIndicator(
                      builder: (_) => SlideTransition(
                            position: _offsetAnimation,
                            child: Container(
                              padding: EdgeInsets.only(top: 120),
                              alignment: Alignment.topCenter,
                              child: Container(
                                  alignment: Alignment.center,
                                  height: 60,
                                  width: 60,
                                  decoration: BoxDecoration(
                                    color: Colors.yellow,
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                  child: CircularProgressIndicator()),
                            ),
                          ),
                      backgroundColor: Colors.transparent);
                  _controller.reset();
                  _controller.forward();
                  Future.delayed(Duration(seconds: 3), () {
                    _controller.reverse().whenComplete(() => OneContext().hideProgressIndicator());
                  });
                },
              ),
              RaisedButton(
                child: Text('Add a generic overlay测试'),
                onPressed: () {
                  // showTipsOnScreen('OneContext().addOverlay(builder)测试');
                  // String overId = UniqueKey().toString();
                  // double getY() => Random().nextInt((MediaQuery.of(context).size.height - 50).toInt()).toDouble();
                  // double getX() => Random().nextInt((MediaQuery.of(context).size.width - 50).toInt()).toDouble();
                  // randomOffset.putIfAbsent(overId, () => Offset(getX(), getY()));
                  // Widget w = RaisedButton(
                  //     child: Text(
                  //       'CLOSE OR DRAG',
                  //       style: TextStyle(color: Colors.white),
                  //     ),
                  //     color: Colors.blue,
                  //     onPressed: () {
                  //       OneContext().removeOverlay(overId);
                  //     });
                  //
                  // OneContext().addOverlay(
                  //     builder: (_) => Positioned(
                  //         top: randomOffset[overId].dy,
                  //         left: randomOffset[overId].dx,
                  //         child: Draggable(
                  //           onDragEnd: (DraggableDetails detail) => randomOffset[overId] = detail.offset,
                  //           childWhenDragging: Container(),
                  //           child: w,
                  //           feedback: w,
                  //         )),
                  //     overlayId: overId);

                  ///TODO 显示overlay测试
                  OneContext().addOverlay(
                      builder: (_) {
                        return WillPopScope(
                          child: AbsorbPointer(
                            child: AlertDialog(
                              backgroundColor: Colors.cyan,
                              title: new Text("显示overlay测试"),
                              content: new Text("The Body2"),
                              actions: <Widget>[
                                new FlatButton(child: new Text("OK2"), onPressed: () {}),
                                new FlatButton(child: new Text("CANCEL2"), onPressed: () {}),
                              ],
                            ),
                          ),
                          onWillPop: () async {
                            print("点击返回");
                            OneContext().removeOverlay("rishli777");

                            ///TODO overlay不能拦截物理返回按钮，所以不适合加载dialog使用
                            return false;
                          },
                        );
                      },
                      overlayId: "rishli777");

                  Future.delayed(Duration(seconds: 3), () {
                    print("定时关闭Overlay");

                    OneContext().removeOverlay("rishli777");
                  });
                },
              ),
              RaisedButton(
                child: Text('Push a second page (push)'),
                onPressed: () async {
                  showTipsOnScreen('OneContext().push()');
                  String result = await OneContext().push<String>(MaterialPageRoute(builder: (_) => SecondPage()));
                  print('$result from OneContext().push()');
                },
              ),
              RaisedButton(
                child: Text('Push a second page (pushNamed)'),
                onPressed: () async {
                  showTipsOnScreen('OneContext().pushNamed()');
                  Object result = await OneContext().pushNamed('/second');
                  print('$result from OneContext().pushNamed()');
                },
              ),
              RaisedButton(
                child: Text('Show MediaQuery info'),
                onPressed: () async {
                  MediaQueryData mediaQuery = OneContext().mediaQuery;
                  String info = 'orientation: ${mediaQuery.orientation.toString()}\n'
                      'devicePixelRatio: ${mediaQuery.devicePixelRatio}\n'
                      'platformBrightness: ${mediaQuery.platformBrightness.toString()}\n'
                      'width: ${mediaQuery.size.width}\n'
                      'height: ${mediaQuery.size.height}\n'
                      'textScaleFactor: ${mediaQuery.textScaleFactor}';
                  print(info);
                  showTipsOnScreen(info, size: 200, seconds: 5);
                },
              ),
              RaisedButton(
                child: Text('Show Theme info'),
                onPressed: () async {
                  ThemeData theme = OneContext().theme;
                  String info = 'platform: ${theme.platform}\n'
                      'primaryColor: ${theme.primaryColor}\n'
                      'accentColor: ${theme.accentColor}\n'
                      'title.color: ${theme.textTheme.title.color}';
                  print(info);
                  showTipsOnScreen(info, size: 200, seconds: 5);
                },
              ),
              SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class SecondPage extends StatelessWidget {
  SecondPage() {
    OneContext()
        .showDialog(
            builder: (_) => AlertDialog(
                  content: Text('Dialog opened from constructor of StatelessWidget SecondPage!'),
                  actions: [
                    RaisedButton(
                        color: OneContext().theme.primaryColor,
                        child: Text('Close'),
                        onPressed: () {
                          OneContext().popDialog("Nice!");
                        })
                  ],
                ))
        .then((result) => print(result));
  }

  static String routeName = "SecondPage";

  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(),
      body: Center(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text('Second Page'),
          RaisedButton(
            child: Text('Go Back - pop("success")'),
            onPressed: () {
              // showTipsOnScreen('OneContext().pop("success")');
              OneContext().pop('success');
            },
          ),
        ],
      )));
}

// Dont need context, so features can be create in any place ;)
void showTipsOnScreen(String text, {double size, int seconds}) {
  String id = UniqueKey().toString();
  OneContext().addOverlay(
    overlayId: id,
    builder: (_) => Align(
      alignment: Alignment.topCenter,
      child: Container(
          alignment: Alignment.bottomCenter,
          padding: EdgeInsets.symmetric(horizontal: kFloatingActionButtonMargin, vertical: 8),
          child: FlatButton(
            onPressed: null,
            child: Text(
              text,
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
          color: Colors.red,
          height: size ?? 100,
          width: double.infinity),
    ),
  );
  Future.delayed(Duration(seconds: seconds ?? 2), () => OneContext().removeOverlay(id));
}
