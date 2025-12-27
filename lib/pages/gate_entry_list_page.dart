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

  // Filter states
  bool _showOnlyInside = false;
  bool _showOnlyCompleted = false;
  String _currentSearchQuery = "";

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  void _fetchData() async {
    final data = await _gateEntryDao.getAllEntries();
    setState(() {
      _allEntries = data;
      _applyFilters();
      _isLoading = false;
    });
  }

  void _applyFilters() {
    setState(() {
      _filteredEntries = _allEntries.where((e) {
        final matchesSearch = e.personName.toLowerCase().contains(_currentSearchQuery.toLowerCase()) ||
            e.houseNum.toLowerCase().contains(_currentSearchQuery.toLowerCase());

        final hasEntry = e.entryTime != null && e.entryTime!.isNotEmpty;
        final hasExit = e.exitTime != null && e.exitTime!.isNotEmpty;

        final isStillInside = hasEntry && !hasExit;
        final isCompleted = hasEntry && hasExit;

        if (_showOnlyInside) {
          return matchesSearch && isStillInside;
        } else if (_showOnlyCompleted) {
          return matchesSearch && isCompleted;
        }

        return matchesSearch;
      }).toList();
    });
  }

  void _resetFilters() {
    setState(() {
      _showOnlyInside = false;
      _showOnlyCompleted = false;
      _applyFilters();
    });
  }

  @override
  Widget build(BuildContext context) {
    bool isAnyFilterActive = _showOnlyInside || _showOnlyCompleted;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Gate Register History"),
        actions: [
          IconButton(onPressed: _fetchData, icon: const Icon(Icons.refresh))
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              onChanged: (value) {
                _currentSearchQuery = value;
                _applyFilters();
              },
              decoration: InputDecoration(
                hintText: "Search by Name or House No...",
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _currentSearchQuery.isNotEmpty
                    ? IconButton(icon: const Icon(Icons.clear), onPressed: () {
                  _currentSearchQuery = "";
                  _applyFilters();
                })
                    : null,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  FilterChip(
                    label: const Text("Currently Inside"),
                    selected: _showOnlyInside,
                    onSelected: (bool selected) {
                      setState(() {
                        _showOnlyInside = selected;
                        if (selected) _showOnlyCompleted = false;
                        _applyFilters();
                      });
                    },
                  ),
                  const SizedBox(width: 8),
                  FilterChip(
                    label: const Text("Exited/Completed"),
                    selected: _showOnlyCompleted,
                    onSelected: (bool selected) {
                      setState(() {
                        _showOnlyCompleted = selected;
                        if (selected) _showOnlyInside = false;
                        _applyFilters();
                      });
                    },
                  ),
                  if (isAnyFilterActive) ...[
                    const SizedBox(width: 12),
                    TextButton.icon(
                      onPressed: _resetFilters,
                      icon: const Icon(Icons.filter_alt_off, size: 18),
                      label: const Text("Clear"),
                    ),
                  ]
                ],
              ),
            ),
          ),

          const Divider(),

          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredEntries.isEmpty
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("No records match your filters"),
                  if (isAnyFilterActive)
                    TextButton(
                      onPressed: _resetFilters,
                      child: const Text("View All Records"),
                    )
                ],
              ),
            )
                : ListView.builder(
              itemCount: _filteredEntries.length,
              itemBuilder: (context, index) {
                final entry = _filteredEntries[index];
                final bool isCurrentlyInside = entry.exitTime == null || entry.exitTime!.isEmpty;

                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  elevation: 2,
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => GateEntryDetailsPage(entry: entry),
                        ),
                      );
                      _fetchData();
                    },
                    leading: CircleAvatar(
                      backgroundColor: isCurrentlyInside ? Colors.red.shade400 : Colors.green.shade400,
                      child: Icon(
                        isCurrentlyInside ? Icons.door_front_door : Icons.check_circle_outline,
                        color: Colors.white,
                      ),
                    ),
                    title: Text(
                      entry.personName,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isCurrentlyInside ? Colors.red.shade900 : Colors.black87,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("House: ${entry.houseNum}", style: const TextStyle(fontWeight: FontWeight.w500)),
                        const SizedBox(height: 4),
                        // FIXED: Using Wrap instead of Row to prevent 91px overflow
                        Wrap(
                          spacing: 10, // horizontal gap between items
                          runSpacing: 4, // vertical gap if items wrap to next line
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.login, size: 14, color: Colors.blueGrey),
                                const SizedBox(width: 4),
                                Text(entry.entryTime ?? "", style: const TextStyle(fontSize: 12)),
                              ],
                            ),
                            if (!isCurrentlyInside)
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.logout, size: 14, color: Colors.blueGrey),
                                  const SizedBox(width: 4),
                                  Text(entry.exitTime ?? "", style: const TextStyle(fontSize: 12)),
                                ],
                              ),
                          ],
                        ),
                      ],
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 14),
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
