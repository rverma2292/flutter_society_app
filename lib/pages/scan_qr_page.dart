import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:ui';
import 'package:flutter/rendering.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:image_picker/image_picker.dart';
import '../database/database_helper.dart';
import 'resident_detail_page.dart';

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

  bool isProcessing = false;

  /// ---------- PROCESS SCAN (DIRECT SQL) ----------
  void processScan(Barcode barcode) async {
    // 1. Lock the scanner so it doesn't fire multiple times
    if (isProcessing) return;
    setState(() => isProcessing = true);

    // 2. Clean the scanned value
    final scannedValue = (barcode.rawValue ?? "")
        .trim()
        .replaceAll(RegExp(r'[\n\r]'), '')
        .toLowerCase();

    if (scannedValue.isEmpty) {
      setState(() => isProcessing = false);
      return;
    }

    try {
      // 3. Query the database
      final db = await DatabaseHelper.instance.database;
      final List<Map<String, dynamic>> results = await db.query(
        'residents',
        where: 'uuid = ?',
        whereArgs: [scannedValue],
        limit: 1,
      );

      if (mounted) {
        if (results.isNotEmpty) {
          // A. STOP CAMERA to save battery and prevent background scans
          controller.stop();

          // B. NAVIGATE to the new separate page
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ResidentDetailsPage(resident: results.first),
            ),
          );

          // C. RESUME once the user returns
          setState(() {
            scannedCode = null;
            scannedResident = null;
            isProcessing = false;
          });
          controller.start();
        } else {
          // No match found - update UI to show error
          setState(() {
            scannedCode = barcode;
            scannedResident = null;
            isProcessing = false;
          });
        }
      }
    } catch (e) {
      debugPrint("Error during SQL scan: $e");
      if (mounted) setState(() => isProcessing = false);
    }
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
                    "House Number: ${scannedResident!['house_num']}",
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                  ),
                  Text(
                    "Type: ${scannedResident!['resident_type']}",
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