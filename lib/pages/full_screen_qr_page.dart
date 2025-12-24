import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:typed_data';
import 'dart:ui';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import '../models/resident.dart';

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
              "House Number: ${resident.house_num} | Type: ${resident.resident_type}",
              style: const TextStyle(fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }
}