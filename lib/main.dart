import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

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

  void checkIfAlreadySelected() async {
    String? result = await storage.read(key: 'filepath');
    if (result != null) {
      setState(() {
        _filePath = result;
      });
    }
  }

  void pickPdfFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result != null) {
      setState(() {
        _filePath = result.files.single.path;
      });
      await storage.deleteAll();
      storage.write(key: 'filepath', value: _filePath);
    } else {
      print("No File Selected!");
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
