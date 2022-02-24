import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_archive/flutter_archive.dart';
import 'package:instaforex_web_view/web_view.dart';
import 'package:local_assets_server/local_assets_server.dart';
import 'package:path_provider/path_provider.dart' as path_provider;

class HighOrderWidget extends StatefulWidget {
  const HighOrderWidget({Key? key}) : super(key: key);

  @override
  State<HighOrderWidget> createState() => _HighOrderWidgetState();
}

class _HighOrderWidgetState extends State<HighOrderWidget> {
  late Directory destinationDir;
  LocalAssetsServer? server;
  bool isServerListening = false;

  Future<String> get _localPath async {
    final directory = await path_provider.getApplicationSupportDirectory();
    return directory.path;
  }

  void _setDestination() async {
    final localPath = await _localPath;
    final _destinationDir = Directory('$localPath/www');
    setState(() {
      destinationDir = _destinationDir;
    });
    _initServer();
  }

  @override
  void initState() {
    super.initState();
    _setDestination();
  }

  @override
  void dispose() {
    server?.stop();
    super.dispose();
  }

  Future<bool> _gerFilesFromArchive() async {
    final localPath = await _localPath;

    final zipFile = File('$localPath/trading.zip');
    final isExist = await zipFile.exists();
    log(isExist.toString(), name: 'isExist');
    final _destinationDir = Directory('$localPath/www');

    final byteData = await rootBundle.load('assets/charts/trading.zip');
    await zipFile.writeAsBytes(byteData.buffer
        .asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));

    final isUnZipped = await ZipFile.extractToDirectory(
      zipFile: zipFile,
      destinationDir: _destinationDir,
    ).then((_) => true);

    if (isUnZipped) {
      return true;
    } else {
      return false;
    }
  }

  void _starServer() async {
    server = LocalAssetsServer(
      address: InternetAddress.loopbackIPv4,
      rootDir: destinationDir,
      assetsBasePath: destinationDir.path,
      logger: const DebugLogger(),
      port: 58888,
    );

    final _address = await server?.serve();
    log(_address?.address.toString() ?? '',
        name:
            'LocalAssetsServer _address_address_address_address_address_address_address');
    setState(() {
      isServerListening = true;
    });
  }

  _initServer() async {
    final isUnZipped = await _gerFilesFromArchive();
    log(isUnZipped.toString(), name: 'Is script unzipped - ');
    if (isUnZipped) {
      _starServer();
    }
  }

  @override
  Widget build(BuildContext context) {
    return WebViewWidget(isServerListening: isServerListening);
  }
}
