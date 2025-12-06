import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
// qr import
import 'package:qr_flutter/qr_flutter.dart';
// share import
import 'package:share_plus/share_plus.dart';
import 'dart:typed_data';
import 'dart:ui';
import 'dart:ui';
import 'package:flutter/rendering.dart';
// path provide to use in share
import 'package:path_provider/path_provider.dart';
import 'dart:io';

void main() {
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

// Resident Model
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
                MaterialPageRoute(builder: (_) => PlaceholderPage(title: "Scan QR")),
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
    loadResidents();
  }

  Future<void> loadResidents() async {
    final String response = await rootBundle.loadString('assets/residents.json');
    final List<dynamic> data = json.decode(response);
    setState(() {
      residents = data.map((json) => Resident.fromJson(json)).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Resident List")),
      body: residents.isEmpty
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: residents.length,
              itemBuilder: (context, index) {
                final r = residents[index];
                return ListTile(
                  leading: CircleAvatar(child: Text(r.flat)),
                  title: Text(r.name),
                  subtitle: Text("Block: ${r.block}\nMobile: ${r.mobile}"),
                  isThreeLine: true,
                );
              },
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

  Future<void> loadResidents() async {
    final String response = await rootBundle.loadString('assets/residents.json');
    final List<dynamic> data = json.decode(response);
    setState(() {
      residents = data.map((json) => Resident.fromJson(json)).toList();
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
                        data: r.id,
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
    // Use QrPainter directly
    final qrValidationResult = QrValidator.validate(
      data: resident.id,
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

      // Convert to image bytes
      final picData = await painter.toImageData(200, format: ImageByteFormat.png);
      final bytes = picData!.buffer.asUint8List();

      // Save to temporary file
      final tempDir = await getTemporaryDirectory();
      final file = await File('${tempDir.path}/${resident.name}_QR.png').create();
      await file.writeAsBytes(bytes);

      // Share file
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
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            RepaintBoundary(
              key: qrKey,
              child: QrImageView(
                data: resident.id,
                version: QrVersions.auto,
                size: 300, // <- BADA QR
              ),
            ),
            SizedBox(height: 20),
            Text(
              resident.name,
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            Text(
              "Flat: ${resident.flat} | Block: ${resident.block}",
              style: TextStyle(fontSize: 18),
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
