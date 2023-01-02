import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:pdfx/pdfx.dart';
import 'package:r_scan/r_scan.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:home_widget/home_widget.dart';

AndroidOptions _getAndroidOptions() => const AndroidOptions(
      encryptedSharedPreferences: true,
    );
final storage = FlutterSecureStorage(aOptions: _getAndroidOptions());

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'id widget creator',
      debugShowCheckedModeBanner: false,
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
  bool fileAdded = false;
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
    _qrMessage = result.message;
    storage.write(key: 'qrMessage', value: _qrMessage);
  }

  Future<void> checkIfAlreadySelected() async {
    String? filePathResult = await storage.read(key: 'filepath');
    String? qrMessageResult = await storage.read(key: 'qrMessage');
    if (filePathResult != null) {
      _filePath = filePathResult;
      _qrMessage = qrMessageResult;
      updateAppWidget();
      setState(() {
        fileAdded = true;
      });
    }
    setState(() {
      showLoadingIndicator = false;
    });
  }

  Future<void> pickPdfFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result != null) {
      await storage.deleteAll();
      _filePath = result.files.single.path;
      storage.write(key: 'filepath', value: _filePath);
      getQrDetails();
      updateAppWidget();
      setState(() {
        fileAdded = true;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    checkIfAlreadySelected();
  }

  Future<void> updateAppWidget() async {
    await HomeWidget.saveWidgetData('_qrMessage', _qrMessage);
    await HomeWidget.updateWidget(name: 'AppWidgetProvider');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.pink,
        title: const Text('Id Widget Creator'),
        centerTitle: true,
      ),
      body: showLoadingIndicator == true
          ? const Center(
              child: SizedBox(
                height: 30,
                width: 30,
                child: LoadingIndicator(
                  indicatorType: Indicator.ballPulse,
                  strokeWidth: 2,
                ),
              ),
            )
          : fileAdded != true
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
