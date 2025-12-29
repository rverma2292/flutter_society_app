import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import '../models/resident.dart';
import '../database/database_helper.dart';
import 'resident_form_page.dart';
import 'dart:io';
import 'resident_detail_page.dart';

class ResidentsPage extends StatefulWidget {
  final bool isSelectionMode;
  const ResidentsPage({
    super.key,
    this.isSelectionMode = false
  });
  @override
  _ResidentsPageState createState() => _ResidentsPageState();
}

class _ResidentsPageState extends State<ResidentsPage> {
  List<Resident> residents = [];
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";

  int page = 0;
  int totalCount = 0;
  final int limit = 15;
  bool isLoadingMore = false;
  bool hasMore = true;

  @override
  void initState() {
    super.initState();
    loadResidentsPage();
  }

  Future<void> loadResidentsPage() async {
    if (isLoadingMore || !hasMore) return;

    setState(() => isLoadingMore = true);
    final total = await DatabaseHelper.instance.getTotalResidentsCount();
    // Pass the search query to your DatabaseHelper
    final result = await DatabaseHelper.instance
        .getResidentsPage(limit, page * limit, query: _searchQuery);

    if (result.isEmpty && page == 0) {
      setState(() {
        residents = [];
        hasMore = false;
        isLoadingMore = false;
      });
      return;
    }

    setState(() {
      if (page == 0) residents.clear();
      residents.addAll(result.map((x) => Resident.fromMap(x)).toList());
      totalCount = total;
      page++;
      hasMore = result.length >= limit;
      isLoadingMore = false;
    });
  }

  void _onSearchChanged(String value) {
    setState(() {
      _searchQuery = value;
      residents.clear();
      page = 0;
      hasMore = true;
    });
    loadResidentsPage();
  }

  void _refreshList() {
    setState(() {
      residents.clear();
      page = 0;
      hasMore = true;
    });
    loadResidentsPage();
  }

  Future<void> addResident(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ResidentFormPage()),
    );
    if (result == true) _refreshList();
  }

  Future<void> editResident(BuildContext context, Resident r) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ResidentFormPage(resident: r)),
    );
    if (result == true) _refreshList();
  }

  Future<void> _confirmDelete(BuildContext context, Resident r) async {
    final bool? confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Resident"),
        content: Text("Are you sure you want to delete ${r.name}?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("CANCEL"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("DELETE", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      // Ensure your DatabaseHelper has a deleteResident method taking an ID
      await DatabaseHelper.instance.deleteResident(r.id.toString());
      _refreshList();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Matching your MenuButton blue
    const Color themeBlue = Colors.blue;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: themeBlue,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _searchController,
              style: const TextStyle(color: Colors.white, fontSize: 18),
              decoration: const InputDecoration(
                hintText: "Search Residents...",
                hintStyle: TextStyle(color: Colors.white70),
                border: InputBorder.none,
                isDense: true,
              ),
              onChanged: _onSearchChanged,
            ),
            // TOTAL COUNT SUBTITLE
            Text(
              "Showing: ${residents.length} of $totalCount residents",
              style: const TextStyle(fontSize: 12, color: Colors.white70),
            ),
          ],
        ),
      ),

      body: NotificationListener<ScrollNotification>(
        onNotification: (scrollInfo) {
          if (!isLoadingMore &&
              hasMore &&
              scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent) {
            loadResidentsPage();
          }
          return false;
        },
        child: residents.isEmpty && !isLoadingMore
            ? const Center(child: Text("No Residents Found"))
            : ListView.builder(
          itemCount: residents.length + (hasMore ? 1 : 0),
          itemBuilder: (context, index) {
            if (index == residents.length) {
              return const Padding(
                padding: EdgeInsets.all(20),
                child: Center(
                    child: CircularProgressIndicator(color: themeBlue)),
              );
            }

            final r = residents[index];

            return Column(
              children: [
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 8),
                  // BLUE & WHITE AVATAR
                  leading: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.blueAccent.withOpacity(
                          0.3), width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: CircleAvatar(
                      backgroundColor: themeBlue, // Attractive primary color
                      backgroundImage: r.image_path != null
                          ? FileImage(File(r.image_path!))
                          : null,
                      child: r.image_path == null
                          ? Text(
                        r.house_num,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12, // Small font to fit house numbers like "102-A"
                        ),
                      )
                          : null,
                    ),
                  ),
                  title: Text(
                    r.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.black87,
                    ),
                  ),
                  subtitle: Text(
                    "Flat: ${r.house_num} • ${r.resident_type
                        .toUpperCase()}\nMob: ${r.mobile}",
                    style: TextStyle(color: Colors.grey[600], height: 1.3),
                  ),
                  isThreeLine: true,
                  // Added Delete Icon alongside the Chevron
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors
                            .redAccent),
                        onPressed: () => _confirmDelete(context, r),
                      ),
                      const Icon(Icons.chevron_right, color: themeBlue),
                    ],
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            ResidentDetailsPage(resident: r.toMap()),
                      ),
                    );
                  },
                  onLongPress: () => editResident(context, r),
                ),
                const Divider(height: 1, indent: 80, endIndent: 20),
              ],
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: themeBlue,
        onPressed: () => addResident(context),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
