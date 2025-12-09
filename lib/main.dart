import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
// qr import
import 'package:qr_flutter/qr_flutter.dart';
// share import
import 'package:share_plus/share_plus.dart';
import 'dart:typed_data';
import 'dart:ui';
import 'package:flutter/rendering.dart';
// path provide to use in share
import 'package:path_provider/path_provider.dart';
import 'dart:io';
//mobile scanner
import 'package:mobile_scanner/mobile_scanner.dart';
// image picker added
import 'package:image_picker/image_picker.dart';
import 'package:hive/hive.dart'; // to save data with hive
import 'package:hive_flutter/hive_flutter.dart';
import 'resident.dart'; // Resident model import karo
import 'database_helper.dart';



void main() async {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Society App',
      debugShowCheckedModeBanner: false,
      home: MenuPage(),
    );
  }
}

/*
// Old Resident model
class Resident {
  final String id;
  final String name;
  final String flat;
  final String block;
  final String mobile;

  Resident({
    required this.id,
    required this.name,
    required this.flat,
    required this.block,
    required this.mobile,
  });

  factory Resident.fromJson(Map<String, dynamic> json) {
    return Resident(
      id: json['id'],
      name: json['name'],
      flat: json['flat'],
      block: json['block'],
      mobile: json['mobile'],
    );
  }
}
*/

// Initial Page with buttons
class MenuPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Society App")),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            MenuButton(
              title: "Resident List",
              color: Colors.blue,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => ResidentsPage()),
              ),
            ),
            MenuButton(
              title: "Show QR",
              color: Colors.green,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => ShowQRPage()),
              ),
            ),
            MenuButton(
              title: "Scan QR",
              color: Colors.orange,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => ScanQRPage()),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Reusable colorful button
class MenuButton extends StatelessWidget {
  final String title;
  final VoidCallback onTap;
  final Color color;

  MenuButton({required this.title, required this.onTap, required this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(vertical: 16),
          minimumSize: Size(double.infinity, 50),
          textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onPressed: onTap,
        child: Text(title, textAlign: TextAlign.center),
      ),
    );
  }
}

// Residents Page
class ResidentsPage extends StatefulWidget {
  @override
  _ResidentsPageState createState() => _ResidentsPageState();
}

class _ResidentsPageState extends State<ResidentsPage> {
  List<Resident> residents = [];

  @override
  void initState() {
    super.initState();
    loadResidents(); // Purana resident.json wala code commented
  }

  /*
  // Old code for loading from JSON (commented)
  Future<void> loadResidents() async {
    final String response = await rootBundle.loadString('assets/residents.json');
    final List<dynamic> data = json.decode(response);
    setState(() {
      residents = data.map((json) => Resident.fromJson(json)).toList();
    });
  }
  */

  Future<void> loadResidents() async {
    final rows = await DatabaseHelper.instance.getAllResidents();

    setState(() {
      residents = rows.map((data) => Resident.fromMap(data)).toList();
    });
  }


  /// ---------- Add Resident (Hive Save) ----------
  Future<void> addResident(BuildContext context) async {
    final nameController = TextEditingController();
    final flatController = TextEditingController();
    final blockController = TextEditingController();
    final mobileController = TextEditingController();

    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text("Add Resident"),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ID फ़ील्ड हटा दिया गया है, क्योंकि SQL इसे स्वचालित रूप से उत्पन्न करता है
              TextField(controller: nameController, decoration: InputDecoration(labelText: "Name")),
              TextField(controller: flatController, decoration: InputDecoration(labelText: "Flat")),
              TextField(controller: blockController, decoration: InputDecoration(labelText: "Block")),
              TextField(controller: mobileController, decoration: InputDecoration(labelText: "Mobile")),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              // यह सुनिश्चित करने के लिए जांचें कि कोई भी फ़ील्ड खाली न हो
              if (nameController.text.isEmpty ||
                  flatController.text.isEmpty ||
                  blockController.text.isEmpty ||
                  mobileController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Please fill all fields.")),
                );
                return;
              }

              final now = DateTime.now().toIso8601String();

              // सुनिश्चित करें कि कॉलम नाम ('created_at') आपके DatabaseHelper से मेल खाते हैं
              final newResident = {
                "name": nameController.text,
                "flat": flatController.text,
                "block": blockController.text,
                "mobile": mobileController.text,
                "created_at": now,
                "updated_at": now,
              };

              await DatabaseHelper.instance.insertResident(newResident);
              await loadResidents(); // सूची को रीफ़्रेश करें
              Navigator.pop(ctx);
            },
            child: Text("Save"),
          ),
        ],
      ),
    );
  }


  // ----------------- Edit Resident Dialog -----------------
  Future<void> editResident(BuildContext context, Resident resident) async {
    final nameController = TextEditingController(text: resident.name);
    final flatController = TextEditingController(text: resident.flat);
    final blockController = TextEditingController(text: resident.block);
    final mobileController = TextEditingController(text: resident.mobile);
    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text("Edit Resident"),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: TextEditingController(text: resident.id.toString()),
                decoration: InputDecoration(labelText: "ID (cannot be changed)"),
                readOnly: true,
              ),
              TextField(controller: nameController, decoration: InputDecoration(labelText: "Name")),
              TextField(controller: flatController, decoration: InputDecoration(labelText: "Flat")),
              TextField(controller: blockController, decoration: InputDecoration(labelText: "Block")),
              TextField(controller: mobileController, decoration: InputDecoration(labelText: "Mobile")),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              final now = DateTime.now().toIso8601String();

              final updatedData = {
                "id": resident.id,
                "name": nameController.text,
                "flat": flatController.text,
                "block": blockController.text,
                "mobile": mobileController.text,
                "created_at": resident.created_at,
                "updated_at": now,
              };

              await DatabaseHelper.instance.updateResident(updatedData);
              await loadResidents();
              Navigator.pop(ctx);
            },
            child: Text("Save"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text("Resident List")),
      body: residents.isEmpty
          ? Center(child: Text("No Residents Found"))
          : ListView.builder(
        itemCount: residents.length,
        itemBuilder: (context, index) {
          final r = residents[index];
          return ListTile(
            leading: CircleAvatar(child: Text(r.flat)),
            title: Text(r.name),
            subtitle: Text("Block: ${r.block}\nMobile: ${r.mobile}"),
            isThreeLine: true,
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(Icons.edit),
                  onPressed: () => editResident(context, r),
                ),
                IconButton(
                  icon: Icon(Icons.delete, color: Colors.red),
                  onPressed: () async {
                    // Confirm dialog before deleting
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: Text('Delete Resident?'),
                        content: Text('Are you sure you want to delete ${r.name}?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx, false),
                            child: Text('Cancel'),
                          ),
                          ElevatedButton(
                            onPressed: () => Navigator.pop(ctx, true),
                            child: Text('Delete'),
                          ),
                        ],
                      ),
                    );

                    if (confirm == true) {
                      await DatabaseHelper.instance.deleteResident(r.id.toString());
                      await loadResidents(); // Refresh list
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('${r.name} deleted successfully!')),
                      );
                    }
                  },
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => addResident(context),
        child: Icon(Icons.add),
        tooltip: "Add Resident",
      ),
    );
  }
}


// Show QR Page with filter
class ShowQRPage extends StatefulWidget {
  @override
  _ShowQRPageState createState() => _ShowQRPageState();
}

class _ShowQRPageState extends State<ShowQRPage> {
  List<Resident> residents = [];
  List<Resident> filtered = [];
  String query = '';

  @override
  void initState() {
    super.initState();
    loadResidents();
  }
  /*
  // Resident List with Json File
  Future<void> loadResidents() async {
    final String response = await rootBundle.loadString('assets/residents.json');
    final List<dynamic> data = json.decode(response);
    setState(() {
      residents = data.map((json) => Resident.fromJson(json)).toList();
      filtered = residents;
    });
  }
  */

  Future<void> loadResidents() async {
    final rows = await DatabaseHelper.instance.getAllResidents();

    setState(() {
      residents = rows.map((data) => Resident.fromMap(data)).toList();
      filtered = residents;
    });
  }

  void filterResidents(String q) {
    setState(() {
      query = q;
      filtered = residents.where((r) {
        final nameLower = r.name.toLowerCase();
        final flatLower = r.flat.toLowerCase();
        final qLower = q.toLowerCase();
        return nameLower.contains(qLower) || flatLower.contains(qLower);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Show QR")),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              decoration: InputDecoration(
                labelText: "Search by Name or Flat",
                border: OutlineInputBorder(),
              ),
              onChanged: filterResidents,
            ),
            SizedBox(height: 16),
            Expanded(
              child: filtered.isEmpty
                  ? Center(child: Text("No residents found"))
                  : ListView.builder(
                itemCount: filtered.length,
                itemBuilder: (context, index) {
                  final r = filtered[index];
                  return Card(
                    margin: EdgeInsets.symmetric(vertical: 6),
                    child: ListTile(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => FullScreenQR(resident: r),
                          ),
                        );
                      },
                      leading: QrImageView(
                        data: r.id.toString(),
                        version: QrVersions.auto,
                        size: 60,
                      ),
                      title: Text(r.name),
                      subtitle: Text("Flat: ${r.flat} | Block: ${r.block}"),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class FullScreenQR extends StatelessWidget {
  final Resident resident;
  final GlobalKey qrKey = GlobalKey();

  FullScreenQR({required this.resident});

  Future<void> shareQR() async {
    try {
      final qrValidationResult = QrValidator.validate(
        data: resident.id.toString(),
        version: QrVersions.auto,
        errorCorrectionLevel: QrErrorCorrectLevel.Q,
      );
      if (qrValidationResult.status == QrValidationStatus.valid) {
        final qrCode = qrValidationResult.qrCode!;
        final painter = QrPainter.withQr(
          qr: qrCode,
          color: Colors.black,
          gapless: true,
          emptyColor: Colors.white,
        );

        // Create image with padding (margin) all around
        final picData = await painter.toImageData(400, format: ImageByteFormat.png); // base size
        final Uint8List bytes = picData!.buffer.asUint8List();

        // Wrap image in a white container with padding for top/bottom/left/right
        final recorder = PictureRecorder();
        final canvas = Canvas(recorder);
        final paint = Paint()..color = Colors.white;
        final double margin = 60; // top/bottom/left/right margin

        // White background
        canvas.drawRect(
          Rect.fromLTWH(0, 0, 400 + margin * 2, 400 + margin * 2),
          paint,
        );

        // Draw QR in center
        final codec = await instantiateImageCodec(bytes);
        final frame = await codec.getNextFrame();
        canvas.drawImage(frame.image, Offset(margin, margin), Paint());

        final picture = recorder.endRecording();
        final img = await picture.toImage(
          (400 + margin * 2).toInt(),
          (400 + margin * 2).toInt(),
        );
        final finalBytes = await img.toByteData(format: ImageByteFormat.png);

        // Save to file and share
        final tempDir = await getTemporaryDirectory();
        final file = await File('${tempDir.path}/${resident.name}_QR.png').create();
        await file.writeAsBytes(finalBytes!.buffer.asUint8List());

        await Share.shareXFiles([XFile(file.path)], text: 'QR Code for ${resident.name}');
      }
    } catch (e) {
      print("Error sharing QR: $e");
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(resident.name),
        actions: [
          IconButton(
            icon: Icon(Icons.share),
            onPressed: shareQR,
          ),
        ],
      ),
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            RepaintBoundary(
              key: qrKey,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 40), // left-right margin
                color: Colors.white,
                child: QrImageView(
                  data: resident.id.toString(),
                  version: QrVersions.auto,
                  size: MediaQuery.of(context).size.width - 80, // screen width - margins
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              resident.name,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            Text(
              "Flat: ${resident.flat} | Block: ${resident.block}",
              style: const TextStyle(fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }
}



// Placeholder for Scan QR
class PlaceholderPage extends StatelessWidget {
  final String title;

  PlaceholderPage({required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Text("$title feature coming soon!", style: TextStyle(fontSize: 18)),
      ),
    );
  }
}

class ScanQRPage extends StatefulWidget {
  const ScanQRPage({super.key});

  @override
  State<ScanQRPage> createState() => _ScanQRPageState();
}

class _ScanQRPageState extends State<ScanQRPage> {
  final MobileScannerController controller = MobileScannerController(
    torchEnabled: false,
    detectionSpeed: DetectionSpeed.normal,
    facing: CameraFacing.back,
    returnImage: false,
  );

  Barcode? scannedCode;
  Map<String, dynamic>? scannedResident;
  List<dynamic> residents = [];

  @override
  void initState() {
    super.initState();
    loadResidents();
  }

  Future<void> loadResidents() async {
    final data = await DatabaseHelper.instance.getAllResidents();
    if (mounted) {
      setState(() {
        residents = data;
      });
    }
  }


  /// ---------- CAMERA SCAN CALLBACK ----------
  void _onDetect(BarcodeCapture capture) {
    final barcode = capture.barcodes.firstOrNull;
    if (barcode != null) {
      processScan(barcode);
    }
  }

  /// ---------- GALLERY PICK + SCAN ----------
  Future<void> pickImageAndScan() async {
    try {
      final picker = ImagePicker();
      final XFile? file = await picker.pickImage(source: ImageSource.gallery);
      if (file == null) return;

      // Analyze image by path
      final BarcodeCapture? result = await controller.analyzeImage(file.path);

      if (result != null && result.barcodes.isNotEmpty) {
        processScan(result.barcodes.first);
      } else {
        setState(() {
          scannedCode = null;
          scannedResident = null;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("No QR code found in image")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error scanning image: $e")),
      );
    }
  }

  /// ---------- PROCESS SCAN ----------
  void processScan(Barcode barcode) {
    final idString = barcode.rawValue ?? "";
    final id = int.tryParse(idString);

    dynamic matched;
    if (id != null) {
      try {
        matched = residents.firstWhere((r) => r["id"] == id);
      } catch (e) {
        matched = null;
      }
    }

    setState(() {
      scannedCode = barcode;
      scannedResident = matched;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Scan QR"),
        actions: [
          IconButton(
            icon: const Icon(Icons.image),
            onPressed: pickImageAndScan, // Gallery scan
          ),
          IconButton(
            icon: const Icon(Icons.flash_on),
            onPressed: () => controller.toggleTorch(),
          ),
        ],
      ),
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          /// CAMERA VIEW
          MobileScanner(
            controller: controller,
            onDetect: _onDetect,
          ),

          /// Result Preview
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              padding: const EdgeInsets.all(12),
              color: Colors.black54,
              child: scannedResident == null
                  ? Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    scannedCode?.rawValue ?? "Scan something!",
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                  ),
                  if (scannedCode != null)
                    const Text(
                      "Resident not found!",
                      style: TextStyle(color: Colors.red, fontSize: 16),
                    ),
                ],
              )
                  : Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "Resident Found!",
                    style: TextStyle(color: Colors.green, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Name: ${scannedResident!['name']}",
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                  ),
                  Text(
                    "Flat: ${scannedResident!['flat']}",
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                  ),
                  Text(
                    "Block: ${scannedResident!['block']}",
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}