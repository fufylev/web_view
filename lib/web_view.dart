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

    void onSend() async {
      webViewController.evaluateJavascript(source: """changeGraphType.funcChangeTimeframe('{
        'ask': 1811.25,
        'bid': 1810.45,
        'change': -0.01,
        'digits': 2,
        'lasttime': 1652862998,
        'symbol': "GOLD",
      }')""");
    }

    return SingleChildScrollView(
      child: SizedBox(
        width: size.width,
        height: size.height,
        child: Column(
          children: [
            SizedBox(
              width: size.width,
              height: size.height - 50 - 320,
              child: InAppWebView(
                initialUrlRequest: URLRequest(
                  url: Uri.parse(
                      'https://appcharts.ifxdb.com/index.html?symbol=GOLD&lang=en&timeframe=1&type=1&theme=light&server_type=4&showname=0&socket=1&ready_stream_new=1'),
                ),
                /*initialData: InAppWebViewInitialData(data: """
                          <!DOCTYPE html>
                          <html lang="en">
                              <head>
                                  <meta charset="UTF-8">
                                  <meta name="viewport" content="width=device-width, user-scalable=no, initial-scale=1.0, maximum-scale=1.0, minimum-scale=1.0">
                              </head>
                              <body>
                                  <h1>JavaScript Handlers</h1>
                                  <script>
                                      window.addEventListener("flutterInAppWebViewPlatformReady", function(event) {
                                          window.flutter_inappwebview.callHandler('socketChannel')
                                            .then(function(result) {
                                              console.log(JSON.stringify(result));
                                              return result;

                                              window.flutter_inappwebview
                                                .callHandler('socketChannel1', {'event': '', result: result});
                                          });
                                      });
                                  </script>
                              </body>
                          </html>
                      """),*/
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
                    handlerName: 'socketChannel1',
                    callback: (args) {
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
                      onTap: () => onSend(),
                      child: const Text('send socket'),
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
