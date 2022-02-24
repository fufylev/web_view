import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebViewWidget extends StatefulWidget {
  const WebViewWidget({Key? key, required this.isServerListening})
      : super(key: key);

  final bool isServerListening;

  @override
  _WebViewWidgetState createState() => _WebViewWidgetState();
}

class _WebViewWidgetState extends State<WebViewWidget> {
  bool hasController = false;
  late WebViewController controller;
  String messageJavascriptChannel = 'пусто пока';

  JavascriptChannel _toasterJavascriptChannel(BuildContext context) {
    return JavascriptChannel(
        name: 'OHLCstream',
        onMessageReceived: (JavascriptMessage message) {
          log(message.message, name: 'OHLCstream');
          setState(() => messageJavascriptChannel = message.message);
        });
  }

  void setInitialChartData() async {
    await Future.delayed(const Duration(milliseconds: 2500));
    controller
        .runJavascriptReturningResult(
            "changeGraphType.funcChangeTimeframe('15')")
        .then(
            (value) => log(value.toString(), name: 'funcChangeType callback'));
    controller
        .runJavascriptReturningResult("changeGraphType.funcChangeType('3')")
        .then(
            (value) => log(value.toString(), name: 'funcChangeType callback'));
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return SizedBox(
      width: size.width,
      height: size.height,
      child: Column(
        children: [
          if (widget.isServerListening == true)
            SizedBox(
              width: size.width,
              height: size.height - 130,
              child: WebView(
                initialUrl:
                    'http://localhost:58888/index.html?symbol=EURUSD&lang=en&timeframe=60&type=1&theme=light&server_type=5&showname=0',
                javascriptMode: JavascriptMode.unrestricted,
                onWebViewCreated: (WebViewController webViewController) {
                  controller = webViewController;
                  setState(() {
                    hasController = true;
                  });
                  setInitialChartData();
                },
                onProgress: (int progress) {},
                javascriptChannels: <JavascriptChannel>{
                  _toasterJavascriptChannel(context),
                },
                onPageStarted: (String url) {
                  log(url, name: 'адрес страницы которую загружаем:');
                },
                onPageFinished: (String url) {
                  log(url, name: 'адрес страницы которую ЗАГРУЗИЛИ:');
                },
                onWebResourceError: (_) {},
                gestureNavigationEnabled: true,
                backgroundColor: Colors.white,
                zoomEnabled: true,
              ),
            ),
          Container(
            padding: const EdgeInsets.all(6.0),
            color: Colors.black.withOpacity(0.1),
            height: 100,
            width: size.height,
            child: Text('Строка из стрима: $messageJavascriptChannel'),
          )
        ],
      ),
    );
  }
}
