import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../models/resident.dart';
import '../database/resident_dao.dart';
import 'full_screen_qr_page.dart';

class ShowQRPage extends StatefulWidget {
  const ShowQRPage({super.key});
  @override
  _ShowQRPageState createState() => _ShowQRPageState();
}

class _ShowQRPageState extends State<ShowQRPage> {
List<Resident> residents = [];
List<Resident> filtered = [];

String query = '';

int page = 0;
final int limit = 8; // per page 8 items
bool isLoading = false;
bool hasMore = true;

final ScrollController _scrollController = ScrollController();

@override
void initState() {
  super.initState();
  // Initial load
  WidgetsBinding.instance.addPostFrameCallback((_) {
    loadMoreResidents();
  });
  _scrollController.addListener(_scrollListener);
}

@override
void dispose() {
  _scrollController.dispose();
  super.dispose();
}

void _scrollListener() {
  if (_scrollController.position.pixels >=
      _scrollController.position.maxScrollExtent - 100) {
    // thoda early trigger
    loadMoreResidents();
  }
}

Future<void> loadMoreResidents() async {
  if (isLoading || !hasMore) return;

  setState(() => isLoading = true);

  final rows = await ResidentDao().getResidentsPage(limit, page * limit);

  if (rows.isEmpty) {
    setState(() => hasMore = false);
  } else {
    final newList = rows.map((data) => Resident.fromMap(data)).toList();

    setState(() {
      residents.addAll(newList);
      filtered = residents;
      page++;
    });
  }

  setState(() => isLoading = false);
}

void filterResidents(String q) {
  setState(() {
    query = q;
    filtered = residents.where((r) {
      final nameLower = r.name.toLowerCase();
      final flatLower = r.house_num.toLowerCase();
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
              labelText: "Search by Name or House Number",
              border: OutlineInputBorder(),
            ),
            onChanged: filterResidents,
          ),
          SizedBox(height: 16),
          Expanded(
            child: filtered.isEmpty
                ? Center(child: Text("No residents found"))
                : ListView.builder(
              controller: _scrollController,
              itemCount: filtered.length + (hasMore ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == filtered.length) {
                  return Center(
                    child: Padding(
                      padding: EdgeInsets.all(12),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }

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
                      data: r.uuid,
                      version: QrVersions.auto,
                      size: 60,
                      // Adding gapless and error correction makes scanning more reliable
                      gapless: true,
                      errorCorrectionLevel: QrErrorCorrectLevel.M,
                    ),
                    title: Text(r.name),
                    subtitle: Text(
                      "House Number: ${r.house_num} | Type: ${r.resident_type[0].toUpperCase()}${r.resident_type.substring(1)}"
                    ),
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