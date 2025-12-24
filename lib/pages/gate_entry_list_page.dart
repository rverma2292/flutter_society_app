import 'package:flutter/material.dart';
import '../database/gate_entery_dao.dart';
import '../models/gate_entry_model.dart';
import 'gate_entry_details_page.dart';

class GateEntryListPage extends StatefulWidget {
  const GateEntryListPage({super.key});

  @override
  State<GateEntryListPage> createState() => _GateEntryListPageState();
}

class _GateEntryListPageState extends State<GateEntryListPage> {
  final GateEntryDao _gateEntryDao = GateEntryDao();
  List<GateEntry> _allEntries = [];
  List<GateEntry> _filteredEntries = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  void _fetchData() async {
    final data = await _gateEntryDao.getAllEntries();
    setState(() {
      _allEntries = data;
      _filteredEntries = data;
      _isLoading = false;
    });
  }

  void _onSearch(String query) {
    setState(() {
      _filteredEntries = _allEntries
          .where((e) =>
      e.personName.toLowerCase().contains(query.toLowerCase()) ||
          e.houseNum.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Gate Register History")),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              onChanged: _onSearch,
              decoration: InputDecoration(
                hintText: "Search by Name or House No...",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredEntries.isEmpty
                ? const Center(child: Text("No records found"))
                : ListView.builder(
              itemCount: _filteredEntries.length,
              itemBuilder: (context, index) {
                final entry = _filteredEntries[index];
                final bool isIncoming = entry.entryTime != null && entry.entryTime!.isNotEmpty;

                return Card(
                  margin: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 6),
                  child: ListTile(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              GateEntryDetailsPage(entry: entry),
                        ),
                      );
                    },
                    leading: CircleAvatar(
                      backgroundColor: isIncoming ? Colors.teal : Colors
                          .deepOrange,
                      child: Icon(isIncoming ? Icons.login : Icons.logout,
                          color: Colors.white),
                    ),
                    title: Text(entry.personName),
                    subtitle: Text("House: ${entry.houseNum}"),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
