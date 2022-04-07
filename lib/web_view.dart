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
  String callBackFromButton = 'пусто пока';

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

    return SingleChildScrollView(
      child: SizedBox(
        width: size.width,
        height: size.height,
        child: Column(
          children: [
            SizedBox(
              width: size.width,
              height: size.height - 50 - 250,
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
              ),
            ),
            if (hasController)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    InkWell(
                      onTap: () {
                        webViewController.evaluateJavascript(
                            source: '''changeGraphType.funcChangeTimeframe(1)''').then((value) {
                          log(value.toString(), name: 'funcChangeTimeframe callback');
                          setState(() => callBackFromButton = value.toString());
                        });
                      },
                      child: const Text('Timeframe(1)'),
                    ),
                    InkWell(
                      onTap: () {
                        webViewController.evaluateJavascript(
                            source: '''changeGraphType.funcChangeTimeframe(30)''').then((value) {
                          setState(() => callBackFromButton = value.toString());
                          log(value.toString(), name: 'funcChangeTimeframe callback');
                        });
                      },
                      child: const Text('Timeframe(30)'),
                    ),
                    InkWell(
                      onTap: () {
                        webViewController.evaluateJavascript(
                            source: '''changeGraphType.funcChangeType(0)''').then((value) {
                          setState(() => callBackFromButton = value.toString());
                          log(value.toString(), name: 'funcChangeType callback');
                        });
                      },
                      child: const Text('funcChangeType(0)'),
                    ),
                    InkWell(
                      onTap: () {
                        webViewController.evaluateJavascript(
                            source: '''changeGraphType.funcChangeType(1)''').then((value) {
                          setState(() => callBackFromButton = value.toString());
                          log(value.toString(), name: 'funcChangeType callback');
                        });
                      },
                      child: const Text('funcChangeType(1)'),
                    ),
                    InkWell(
                      onTap: () {
                        webViewController.evaluateJavascript(
                            source: '''changeGraphType.funcCreateStudy(['Aroon'])''').then((value) {
                          setState(() => callBackFromButton = value.toString());
                          log(value.toString(), name: 'funcCreateStudy callback');
                        });
                      },
                      child: const Text('funcCreateStudy([Aroon])'),
                    ),
                    InkWell(
                      onTap: () {
                        webViewController.evaluateJavascript(
                            source:
                                '''changeGraphType.funcCreateStudy(['Chande Kroll Stop'])''').then(
                            (value) {
                          setState(() => callBackFromButton = value.toString());
                          log(value.toString(), name: 'funcCreateStudy callback');
                        });
                      },
                      child: const Text('funcCreateStudy([Chande Kroll Stop])'),
                    ),
                    InkWell(
                      onTap: () {
                        webViewController.evaluateJavascript(
                            source: '''changeGraphType.funcSaveIndicators()''').then((value) {
                          setState(() => callBackFromButton = value.toString());
                          log(value.toString(), name: 'funcSaveIndicators callback');
                        });
                      },
                      child: const Text('funcSaveIndicators()'),
                    ),
                  ],
                ),
              ),
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
                  Text('Строка из стрима readyStreamNew: $messageJavascriptChannelReadyStreamNew'),
                  Text('Строка из callBack от нажатия кнопки: $callBackFromButton'),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
