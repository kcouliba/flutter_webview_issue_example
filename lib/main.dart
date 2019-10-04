import 'dart:async';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http_server/http_server.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:webview_flutter/webview_flutter.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WebView issue',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: Scaffold(
        appBar: AppBar(title: Text('Webview')),
        body: SafeArea(
          child: WebViewPage(),
        ),
      ),
    );
  }
}

class WebViewPage extends StatefulWidget {
  @override
  _WebViewPageState createState() => _WebViewPageState();
}

class _WebViewPageState extends State<WebViewPage> {
  HttpServer _server;
  String _initialUrl;
  Directory _httpDirectory;

  @override
  void initState() {
    super.initState();
    _startServer();
  }

  @override
  void dispose() {
    _cleanup();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_initialUrl == null) return CircularProgressIndicator();
    return Container(
      child: WebView(
        javascriptMode: JavascriptMode.unrestricted,
        initialUrl: _initialUrl,
      ),
    );
  }

  Future _startServer() async {
    final Directory appDir = await getApplicationDocumentsDirectory();
    final Directory httpDirectory =
        await Directory('${appDir.path}/www').create(recursive: true);
    final VirtualDirectory staticFiles = VirtualDirectory(httpDirectory.path)
      ..allowDirectoryListing = true;

    await _setupHttpFolder(httpDirectory);
    await runZoned(() async {
      final HttpServer server =
          await HttpServer.bind(InternetAddress.loopbackIPv4, 3000);
      final String initialUrl =
          'http://${server.address.host}:${server.port}/index.html';

      setState(() {
        _server = server;
        _httpDirectory = httpDirectory;
        _initialUrl = initialUrl;
      });
      server.listen(staticFiles.serveRequest);
    }, onError: (e, stackTrace) => print('Error occured : $e $stackTrace'));
  }

  /// preparing http assets
  Future _setupHttpFolder(Directory parentDir) async {
    Directory archiveDir = Directory('${parentDir.path}/archive');
    File indexFile = File('${parentDir.path}/index.html');
    ByteData data = await rootBundle.load('assets/archive.zip');
    String indexContent = await rootBundle.loadString('assets/index.txt');
    List<int> content = List<int>(data.lengthInBytes);
    Archive archive;

    await indexFile.writeAsString(indexContent);
    await archiveDir.create();
    for (var i = 0; i < data.lengthInBytes; i++) {
      content[i] = data.getUint8(i);
    }
    archive = ZipDecoder().decodeBytes(content);
    _uncompress(archive, archiveDir);
  }

  /// uncompressing the example archive to app directory
  Future<void> _uncompress(Archive archive, Directory dest) async {
    for (ArchiveFile file in archive) {
      if (file.isFile) {
        List<int> data = file.content;
        File('${dest.path}/${file.name}')
          ..createSync(recursive: true)
          ..writeAsBytesSync(data);
      } else {
        Directory('${dest.path}/${file.name}')..createSync(recursive: true);
      }
    }
  }

  /// stoping server and removing http assets
  Future _cleanup() async {
    await _server?.close();
    await _httpDirectory?.delete(recursive: true);
  }
}
