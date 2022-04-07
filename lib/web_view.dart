import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class WebViewWidget extends StatefulWidget {
  const WebViewWidget({Key? key, required this.isServerListening}) : super(key: key);

  final bool isServerListening;

  @override
  _WebViewWidgetState createState() => _WebViewWidgetState();
}

class _WebViewWidgetState extends State<WebViewWidget> {
  bool hasController = false;
  late InAppWebViewController webViewController;
  String tickingMessage = 'пусто пока';
  String messageJavascriptConsoleMessage = 'пусто пока';
  String messageJavascriptChannelReadyStreamNew = 'пусто пока';

  @override
  void initState() {
    init();
    super.initState();
  }

  void init() async {
    if (Platform.isAndroid) {
      await AndroidInAppWebViewController.setWebContentsDebuggingEnabled(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return SizedBox(
      width: size.width,
      height: size.height,
      child: Column(
        children: [
          SizedBox(
              width: size.width,
              height: size.height - 50 - 100,
              child: InAppWebView(
                initialUrlRequest: URLRequest(
                  url: Uri.parse(
                      'https://appcharts.ifxdb.com/index.html?symbol=GOLD&lang=en&timeframe=1&type=1&theme=light&server_type=4&showname=0&socket=1&ready_stream_new=1'),
                ),
                initialOptions: InAppWebViewGroupOptions(
                  crossPlatform: InAppWebViewOptions(
                    useShouldOverrideUrlLoading: true,
                    mediaPlaybackRequiresUserGesture: false,
                  ),
                  android: AndroidInAppWebViewOptions(
                    useHybridComposition: true,
                  ),
                  ios: IOSInAppWebViewOptions(
                    allowsInlineMediaPlayback: true,
                  ),
                ),
                onWebViewCreated: (InAppWebViewController controller) {
                  setState(() {
                    hasController = true;
                    webViewController = controller;
                  });
                  controller.addJavaScriptHandler(
                    handlerName: 'readyStreamNew',
                    callback: (args) {
                      /**
                       !!!!!!!!!!!!!!!! Вот тут должен быть стрим от графика
                       */
                      log(args.toString(), name: 'Аргументы из функции readyStreamNew');
                      setState(() => messageJavascriptChannelReadyStreamNew = args.toString());
                    },
                  );
                },
                androidOnPermissionRequest: (controller, origin, resources) async {
                  return PermissionRequestResponse(
                      resources: resources, action: PermissionRequestResponseAction.GRANT);
                },
                onLoadStart: (controller, url) {},
                onLoadStop: (controller, url) async {},
                onLoadError: (controller, url, code, message) {},
                onConsoleMessage: (
                  InAppWebViewController controller,
                  ConsoleMessage consoleMessage,
                ) {
                  log("console message: ${consoleMessage.message}", name: 'ConsoleMessage');
                  setState(() => messageJavascriptConsoleMessage = consoleMessage.message);
                },
              )
              // InAppWebView(
              //   initialFile: 'assets/index.html',
              //   initialOptions: InAppWebViewGroupOptions(
              //     crossPlatform: InAppWebViewOptions(
              //       useShouldOverrideUrlLoading: true,
              //       mediaPlaybackRequiresUserGesture: false,
              //     ),
              //     android: AndroidInAppWebViewOptions(
              //       useHybridComposition: true,
              //     ),
              //     ios: IOSInAppWebViewOptions(
              //       allowsInlineMediaPlayback: true,
              //     ),
              //   ),
              //   onLoadStart: (controller, url) async {},
              //   onLoadStop: (controller, url) async {},
              //   onConsoleMessage: (
              //     InAppWebViewController controller,
              //     ConsoleMessage consoleMessage,
              //   ) {
              //     log("console message: ${consoleMessage.message}", name: 'ConsoleMessage');
              //     setState(() => messageJavascriptChannel = consoleMessage.message);
              //   },
              //   onWebViewCreated: (InAppWebViewController controller) {
              //     setState(() {
              //       hasController = true;
              //       webViewController = controller;
              //     });
              //
              //     // пример 1  [mySum]
              //     /**
              //         тут мы получаем на вход от JS аргументы в формате [12, 2, 50]
              //         и отправляем в JS обратно результат действий над аргументами
              //         далее мы получил лог результатов нижу в методе [onConsoleMessage]
              //      */
              //     controller.addJavaScriptHandler(
              //       handlerName: "mySum",
              //       callback: (args) {
              //         // Here you receive all the arguments from the JavaScript side  that is a List<dynamic>
              //         log(args.toString(), name: 'Аргументы из функции mySum');
              //         return args.reduce((curr, next) => curr + next);
              //       },
              //     );
              //
              //     // пример 2 [handlerFoo]
              //     /**
              //      в данном примере мы делаем два действия
              //         * в контроллере "handlerFoo":
              //         1. Сначала получаем аргументы от JS в виде [{'bar': 'bar_value', 'baz': 'baz_value'}]
              //         2. Их же возвращаем обратно в JS
              //         * в контроллере "handlerFooWithArgs":
              //         3. Получаем ответ обработки результата от JS
              //      */
              //     controller.addJavaScriptHandler(
              //       handlerName: "handlerFoo",
              //       callback: (args) {
              //         // Here you receive all the arguments from the JavaScript side  that is a List<dynamic>
              //         log(args.toString(), name: 'Аргументы из функции handlerFoo');
              //         return {'bar': 'bar_value', 'baz': 'baz_value'};
              //       },
              //     );
              //     controller.addJavaScriptHandler(
              //       handlerName: 'handlerFooWithArgs',
              //       callback: (args) {
              //         log(args.toString(), name: 'Аргументы из функции handlerFooWithArgs');
              //         // it will print: [1, true, [bar, 5], {foo: baz}, {bar: bar_value, baz: baz_value}]
              //       },
              //     );
              //
              //     // пример 3 [customStream]
              //     /**
              //         В данном контроллере мы отлавливаем стрим от результата нажатия на кнопку на
              //         экране телефона
              //      */
              //     controller.addJavaScriptHandler(
              //       handlerName: "customStream",
              //       callback: (args) {
              //         // Here you receive all the arguments from the JavaScript side that is a List<dynamic>
              //         log(args.toString(), name: 'Аргументы из функции customStream');
              //         setState(() => messageJavascriptChannelCustomStream = args.toString());
              //         return [];
              //       },
              //     );
              //
              //     // пример 4 [tickingStream]
              //     /**
              //      * тут мы получаем данные от стрима 'tickingStream'] и уже обрабатываем как нам надо
              //      */
              //     controller.addJavaScriptHandler(
              //       handlerName: "tickingStream",
              //       callback: (args) {
              //         // Here you receive all the arguments from the JavaScript side  that is a List<dynamic>
              //         log(args.toString(), name: 'Аргументы из стрима tickingStream');
              //         setState(() => tickingMessage = args.toString());
              //         return {};
              //       },
              //     );
              //   },
              // ),

              ),
          // if (hasController)
          //   Column(
          //     children: [
          //       // кнопка без колбека
          //       ElevatedButton(
          //         onPressed: () {
          //           webViewController.evaluateJavascript(source: '''onMessage("My message")''');
          //         },
          //         child: const Text('Send "My message"'),
          //       ),
          //       // кнопка с колбеком
          //       ElevatedButton(
          //         onPressed: () {
          //           webViewController.evaluateJavascript(
          //               source: '''onMessage("Hello InstaForex")''').then((value) {
          //             log(value.toString(), name: 'Callback ');
          //           });
          //         },
          //         child: const Text('Send "Hello InstaForex"'),
          //       ),
          //       ElevatedButton(
          //         onPressed: () {
          //           webViewController.evaluateJavascript(
          //               source:
          //                   '''changeGraphType.funcSaveIndicators("Hello InstaForex")''').then(
          //               (value) {
          //             log(value.toString(), name: 'Callback ');
          //           });
          //         },
          //         child: const Text('Send "funcSaveIndicators"'),
          //       ),
          //     ],
          //   ),
          Container(
            padding: const EdgeInsets.all(6.0),
            color: Colors.black.withOpacity(0.1),
            // height: 100,
            width: size.height,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Text('Строка из консоли стрима tickingStream: $tickingMessage'),
                // const SizedBox(height: 20),
                Text('Строка из консоли: $messageJavascriptConsoleMessage'),
                const SizedBox(height: 20),
                Text('Строка из стрима readyStreamNew: $messageJavascriptChannelReadyStreamNew'),
              ],
            ),
          )
        ],
      ),
    );
  }
}
