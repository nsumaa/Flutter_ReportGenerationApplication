import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share/share.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
// import 'login.dart';
// import 'register.dart';
// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   final cameras = await availableCameras();
//   runApp(CameraApp(cameras: cameras));
// }
// void main(){
//   runApp(MaterialApp(
//     debugShowCheckedModeBanner: false,
//     initialRoute:'login',
//      routes: {
//        'login':(context)=>MyLogin(),
//        'register':(context)=>MyRegister(),
//      },
//   ));
// }


// class MyApp extends StatelessWidget {
//   final List<CameraDescription> cameras;

//   MyApp({required this.cameras});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       initialRoute: 'login',
//       routes: {
//         'login': (context) => MyLogin(),
//         'register': (context) => MyRegister(),
//         'cameraApp': (context) => CameraApp(cameras: cameras), // Adding CameraApp as a route
//       },
//     );
//   }
// }

class CameraApp extends StatelessWidget {
  final List<CameraDescription> cameras;

  const CameraApp({Key? key, required this.cameras}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.light(),
      home: HomeScreen(cameras: cameras),
    );
  }
}

class HomeScreen extends StatelessWidget {
  final List<CameraDescription> cameras;

  const HomeScreen({Key? key, required this.cameras}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Report Generation App", 
        style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: const Color.fromARGB(255, 0, 59, 107),),
      ),
          backgroundColor: const Color.fromARGB(255, 166, 200, 228),
        ),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => ProjectOptionsScreen(cameras: cameras),
                    ),
                  );
                },
                child: Text('Create Project'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  elevation: 10, // Shadow elevation
                  shadowColor: const Color.fromARGB(255, 117, 123, 7),
                  minimumSize: Size(220, 50),
                  textStyle: TextStyle(fontSize: 25),
                ),
              ),
            ),
          ),
          Expanded(
            child: Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => ReportsScreen(),
                    ),
                  );
                },
                child: Text('Show Reports'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  elevation: 10, // Shadow elevation
                  shadowColor: const Color.fromARGB(255, 117, 123, 7),
                  minimumSize: Size(220, 50),
                  textStyle: TextStyle(fontSize: 25),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ProjectOptionsScreen extends StatelessWidget {
  final List<CameraDescription> cameras;

  const ProjectOptionsScreen({Key? key, required this.cameras}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Project Options'),
      ),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => CameraScreen(cameras: cameras),
                    ),
                  );
                },
                child: Text('Open Camera'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  elevation: 10, // Shadow elevation
                  shadowColor: const Color.fromARGB(255, 117, 123, 7),
                  minimumSize: Size(220, 50),
                  textStyle: TextStyle(fontSize: 25),
                ),
              ),
            ),
          ),
          Expanded(
            child: Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => SavedImagesScreen(),
                    ),
                  );
                },
                child: Text('Images to Report'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  minimumSize: Size(220, 50),
                  textStyle: TextStyle(fontSize: 25),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CameraScreen extends StatefulWidget {
  final List<CameraDescription> cameras;

  const CameraScreen({Key? key, required this.cameras}) : super(key: key);

  @override
  CameraScreenState createState() => CameraScreenState();
}

class CameraScreenState extends State<CameraScreen> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;

  @override
  void initState() {
    super.initState();
    _controller = CameraController(
      widget.cameras.first,
      ResolutionPreset.high,
    );
    _initializeControllerFuture = _controller.initialize();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<String> _getSavePath() async {
    final directory = await getApplicationDocumentsDirectory();
    final path = '${directory.path}/your_report';
    final directoryExists = await Directory(path).exists();
    if (!directoryExists) {
      await Directory(path).create(recursive: true);
    }
    return path;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Camera Preview'),
      ),
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return CameraPreview(_controller);
          } else {
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          try {
            await _initializeControllerFuture;
            final image = await _controller.takePicture();
            if (!mounted) return;

            final savePath = await _getSavePath();
            final imageFile = File(image.path);
            final newImagePath = '$savePath/${DateTime.now().millisecondsSinceEpoch}.jpg';
            await imageFile.copy(newImagePath);

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Image saved to $newImagePath')),
            );
          } catch (e) {
            print('Error capturing picture: $e');
          }
        },
        child: Icon(Icons.camera_alt),
      ),
    );
  }
}

class SavedImagesScreen extends StatefulWidget {
  @override
  _SavedImagesScreenState createState() => _SavedImagesScreenState();
}

class _SavedImagesScreenState extends State<SavedImagesScreen> {
  Future<List<File>> _getSavedImages() async {
    final directory = await getApplicationDocumentsDirectory();
    final path = '${directory.path}/your_report';
    final dir = Directory(path);

    if (await dir.exists()) {
      final List<FileSystemEntity> files = dir.listSync();
      return files.whereType<File>().toList();
    } else {
      return [];
    }
  }

  Future<void> _deleteImage(File image) async {
    try {
      await image.delete();
      print('Image deleted: ${image.path}');
    } catch (e) {
      print('Error deleting image: $e');
    }
  }

  Future<String> _generatePdf(List<Map<String, dynamic>> imagesWithDescriptions) async {
    final pdf = pw.Document();

    for (var imageWithDescription in imagesWithDescriptions) {
      final imageFile = imageWithDescription['file'] as File;
      final description = imageWithDescription['description'] as String;

      final imageProvider = pw.MemoryImage(await imageFile.readAsBytes());

      pdf.addPage(pw.Page(
        margin: pw.EdgeInsets.all(16),
        build: (pw.Context context) {
          return pw.Column(
            children: [
              pw.Image(imageProvider, fit: pw.BoxFit.contain, height: 700),
              pw.SizedBox(height: 8),
              pw.Text(
                description.isNotEmpty ? description : 'No description provided.',
                style: pw.TextStyle(fontSize: 24),
                textAlign: pw.TextAlign.left,
              ),
            ],
          );
        },
      ));
    }

    final directory = await getApplicationDocumentsDirectory();
    final now = DateTime.now();
    final formattedDate = "${now.day.toString().padLeft(2, '0')}-"
        "${now.month.toString().padLeft(2, '0')}-"
        "${now.year}_"
        "${now.hour.toString().padLeft(2, '0')}-"
        "${now.minute.toString().padLeft(2, '0')}";
    final reportPath = '${directory.path}/report_$formattedDate.pdf';
    final file = File(reportPath);
    await file.writeAsBytes(await pdf.save());

    return reportPath;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Select Images'),
      ),
      body: FutureBuilder<List<File>>(
        future: _getSavedImages(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No images found.'));
          } else {
            final images = snapshot.data!;
            final imagesWithDescriptions = images.map((image) {
              return {'file': image, 'description': ''};
            }).toList();

            return Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: imagesWithDescriptions.length,
                    itemBuilder: (context, index) {
                      final imageWithDescription = imagesWithDescriptions[index];
                      final imageFile = imageWithDescription['file'] as File;
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            GestureDetector(
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => DisplayPictureScreen(imagePath: imageFile.path),
                                  ),
                                );
                              },
                              child: Image.file(
                                imageFile,
                                fit: BoxFit.cover,
                                height: 200,
                              ),
                            ),
                            TextField(
                              onChanged: (value) {
                                imageWithDescription['description'] = value;
                              },
                              decoration: InputDecoration(
                                labelText: 'Enter description',
                                border: OutlineInputBorder(),
                              ),
                            ),
                            IconButton(
                              icon: Icon(Icons.delete, color: Colors.red),
                              onPressed: () async {
                                await _deleteImage(imageFile);
                                setState(() {});
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final reportPath = await _generatePdf(imagesWithDescriptions);
                    for (var imageWithDescription in imagesWithDescriptions) {
                      await _deleteImage(imageWithDescription['file'] as File);
                    }
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Report generated. Go to "Show Reports" to view it.')),
                    );
                  },
                  child: Text('Generate PDF'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    minimumSize: Size(double.infinity, 50),
                    textStyle: TextStyle(fontSize: 18),
                  ),
                ),
              ],
            );
          }
        },
      ),
    );
  }
}

class DisplayPictureScreen extends StatelessWidget {
  final String imagePath;

  const DisplayPictureScreen({Key? key, required this.imagePath}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Captured Image')),
      body: Center(
        child: Image.file(File(imagePath)),
      ),
    );
  }
}

class PdfViewerScreen extends StatelessWidget {
  final String pdfPath;

  const PdfViewerScreen({Key? key, required this.pdfPath}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('PDF Viewer'),
      ),
      body: PDFView(
        filePath: pdfPath,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Share.shareFiles([pdfPath], text: 'Here is your report!');
        },
        child: Icon(Icons.share),
      ),
    );
  }
}

class ReportsScreen extends StatelessWidget {
  Future<List<File>> _getReports() async {
    final directory = await getApplicationDocumentsDirectory();
    final path = '${directory.path}';
    final dir = Directory(path);

    if (await dir.exists()) {
      final List<FileSystemEntity> files = dir.listSync();
      return files.whereType<File>().where((file) => file.path.endsWith('.pdf')).toList();
    } else {
      return [];
    }
  }
Future<void> _deleteReport(File report, BuildContext context) async {
    try {
      await report.delete();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Report deleted successfully.')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting report: $e')),
      );
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Generated Reports'),
      ),
      body: FutureBuilder<List<File>>(
        future: _getReports(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No reports found.'));
          } else {
            final reports = snapshot.data!;
            return ListView.builder(
              itemCount: reports.length,
              itemBuilder: (context, index) {
                final report = reports[index];
                return ListTile(
                  title: Text('Report ${index + 1}'),
                  subtitle: Text(report.path),
                  trailing: IconButton(
                    icon: Icon(Icons.delete, color: Colors.red),
                    onPressed: () async {
                      await _deleteReport(report, context);
                      // Rebuild the widget to update the list of reports.
                      (context as Element).reassemble();
                    },
                  ),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => PdfViewerScreen(pdfPath: report.path),
                      ),
                    );
                  },
                );
              },
            );
          }
        },
      ),
    );
  }
}