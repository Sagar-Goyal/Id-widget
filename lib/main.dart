import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:pdfx/pdfx.dart';
import 'package:r_scan/r_scan.dart';

AndroidOptions _getAndroidOptions() => const AndroidOptions(
      encryptedSharedPreferences: true,
    );
final storage = FlutterSecureStorage(aOptions: _getAndroidOptions());

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'id widget creator',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? _filePath;
  String? _qrMessage;
  bool showLoadingIndicator = true;

  Future<void> getQrDetails() async {
    String path = _filePath!;
    final document = await PdfDocument.openFile(path);
    final page = await document.getPage(1);
    final pageImage = await page.render(
      width: page.width,
      height: page.height,
      format: PdfPageImageFormat.jpeg,
    );
    final result = await RScan.scanImageMemory(pageImage!.bytes);
    setState(() {
      _qrMessage = result.message;
    });
    storage.write(key: 'qrMessage', value: _qrMessage);
  }

  Future<void> checkIfAlreadySelected() async {
    String? filePathResult = await storage.read(key: 'filepath');
    String? qrMessageResult = await storage.read(key: 'qrMessage');
    if (filePathResult != null) {
      setState(() {
        _filePath = filePathResult;
        _qrMessage = qrMessageResult;
      });
    }
  }

  Future<void> pickPdfFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result != null) {
      setState(() {
        _filePath = result.files.single.path;
      });
      await storage.deleteAll();
      getQrDetails();
      storage.write(key: 'filepath', value: _filePath);
    }
  }

  @override
  void initState() {
    super.initState();
    checkIfAlreadySelected();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.pink,
        title: const Text('Id Widget Creator'),
        centerTitle: true,
      ),
      body: _filePath == null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 20.0),
                    child: IconButton(
                      onPressed: pickPdfFile,
                      icon: const Icon(
                        Icons.add_box_outlined,
                        size: 40.0,
                      ),
                    ),
                  ),
                  const Text(
                    'Add ID Card PDF file.',
                    style: TextStyle(
                      fontSize: 20.0,
                    ),
                  ),
                ],
              ),
            )
          : Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(bottom: 10.0),
                    child: Text(
                      'ID card already selected.',
                      style: TextStyle(
                        fontSize: 20.0,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: pickPdfFile,
                    child: const Text(
                      'Add New',
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
