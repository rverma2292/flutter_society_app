import 'package:flutter/material.dart';
import '../database/resident_vehicle_dao.dart';
import '../models/resident_vehicle_model.dart';
import 'resident_vehicle_form_page.dart';

class VehicleListPage extends StatefulWidget {
  const VehicleListPage({super.key});

  @override
  State<VehicleListPage> createState() => _VehicleListPageState();
}

class _VehicleListPageState extends State<VehicleListPage> {
  final ResidentVehicleDao _vehicleDao = ResidentVehicleDao();
  final ScrollController _scrollController = ScrollController();

  // State variables for pagination
  final List<Map<String, dynamic>> _vehicles = [];
  bool _isLoading = false;
  bool _hasMore = true;
  int _currentOffset = 0;
  final int _limit = 20;
  int _totalCount = 0;
  String _searchQuery = "";

  @override
  void initState() {
    super.initState();
    _loadMoreVehicles(isRefresh: true);
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200 &&
        !_isLoading &&
        _hasMore &&
        _searchQuery.isEmpty) {
      _loadMoreVehicles();
    }
  }

  Future<void> _loadMoreVehicles({bool isRefresh = false}) async {
    if (_isLoading) return;
    setState(() => _isLoading = true);

    if (isRefresh) {
      final count = await _vehicleDao.getTotalVehicleCount();
      setState(() {
        _totalCount = count;
        _currentOffset = 0;
        _vehicles.clear();
        _hasMore = true;
      });
    }

    final newItems = await _vehicleDao.getVehiclesPaginated(
      limit: _limit,
      offset: _currentOffset,
    );

    setState(() {
      _isLoading = false;
      if (newItems.length < _limit) _hasMore = false;
      _vehicles.addAll(newItems);
      _currentOffset += _limit;
    });
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query.toUpperCase();
    });
  }

  Color _getDisplayColor(String? colorName) {
    switch (colorName?.toLowerCase()) {
      case 'white': return Colors.white;
      case 'off white': return const Color(0xFFFAF9F6);
      case 'silver': return Colors.grey[400]!;
      case 'grey': return Colors.grey;
      case 'black': return Colors.black;
      case 'red': return Colors.red;
      case 'blue': return Colors.blue;
      case 'green': return Colors.green;
      case 'yellow': return Colors.yellow;
      default: return Colors.transparent;
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredList = _searchQuery.isEmpty
        ? _vehicles
        : _vehicles.where((v) => v['vehicle_number'].toString().contains(_searchQuery)).toList();

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("All Vehicles"),
            Text(
              _searchQuery.isEmpty
                  ? "Total: $_totalCount"
                  : "Found: ${filteredList.length}",
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.normal),
            ),
          ],
        ),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: "Search by vehicle number...",
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      FocusScope.of(context).unfocus();
                      setState(() => _searchQuery = "");
                    })
                    : null,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: Colors.grey[100],
              ),
              onChanged: _onSearchChanged,
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => _loadMoreVehicles(isRefresh: true),
              child: filteredList.isEmpty && !_isLoading
                  ? const Center(child: Text("No vehicles found"))
                  : ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemCount: filteredList.length + (_hasMore && _searchQuery.isEmpty ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == filteredList.length) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(8.0),
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }
                  final v = filteredList[index];
                  IconData vehicleIcon = (v['vehicle_type']?.toString().toLowerCase() == 'bike')
                      ? Icons.motorcycle
                      : Icons.directions_car;

                  return Card(
                    elevation: 1,
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.blue.withValues(alpha: 0.1),
                        child: Icon(vehicleIcon, color: Colors.blue),
                      ),
                      title: Text(v['vehicle_number'], style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text("Owner: ${v['resident_name']} (${v['house_num']})"),
                      trailing: _buildTrailing(v['vehicle_color']),
                      onTap: () async {
                        final refresh = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ResidentVehicleFormPage(
                              residentId: v['resident_id'],
                              vehicle: ResidentVehicle.fromMap(v),
                            ),
                          ),
                        );
                        if (refresh == true) _loadMoreVehicles(isRefresh: true);
                      },
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
      backgroundColor: Colors.blue,
      foregroundColor: Colors.white,
        onPressed: () async {
          // Now calling the form directly with residentId as null
          // The form will show the resident picker internally
          final refresh = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const ResidentVehicleFormPage(
                residentId: null,
              ),
            ),
          );

          if (refresh == true) {
            _loadMoreVehicles(isRefresh: true);
          }
        },

        child: const Icon(Icons.add),
    ),
    );
  }

  Widget _buildTrailing(String? colorName) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (colorName != null)
          Container(
            width: 14,
            height: 14,
            decoration: BoxDecoration(
              color: _getDisplayColor(colorName),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.grey.shade400),
            ),
          ),
        const Icon(Icons.chevron_right, color: Colors.grey),
      ],
    );
  }
}
