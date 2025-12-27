import 'package:flutter/material.dart';

class ResidentNotFoundPage extends StatelessWidget {
  final String scannedUuid;

  const ResidentNotFoundPage({super.key, required this.scannedUuid});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(30.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.person_off_rounded, size: 100, color: Colors.redAccent),
              const SizedBox(height: 20),
              const Text(
                "Access Denied",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.redAccent),
              ),
              const SizedBox(height: 10),
              const Text(
                "No resident record found for this QR code.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 30),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  "Scanned ID: $scannedUuid",
                  style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
                ),
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, foregroundColor: Colors.white),
                  onPressed: () => Navigator.pop(context),
                  child: const Text("TRY AGAIN"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
