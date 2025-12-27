import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import '../models/resident.dart';
import '../database/database_helper.dart';

class ResidentsPage extends StatefulWidget {
  const ResidentsPage({super.key});
  @override
  _ResidentsPageState createState() => _ResidentsPageState();
}

class _ResidentsPageState extends State<ResidentsPage> {
  List<Resident> residents = [];

  int page = 0;
  int totalCount = 0;
  final int limit = 8; // per page
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

    final count = await DatabaseHelper.instance.getTotalResidentsCount();
    final result = await DatabaseHelper.instance
        .getResidentsPage(limit, page * limit);

    if (result.isEmpty  && page == 0) {
      setState(() {
        totalCount = 0;
        hasMore = false;
        isLoadingMore = false;
      });
      return;
    }

    setState(() {
      totalCount = count;
      residents.addAll(result.map((x) => Resident.fromMap(x)).toList());
      page++;
      isLoadingMore = result.length < limit ? false : isLoadingMore;
      hasMore = result.length >= limit;
      isLoadingMore = false;
    });
  }

  Future<void> addResident(BuildContext context) async {
    final nameController = TextEditingController();
    final flatController = TextEditingController();
    final mobileController = TextEditingController();

    // Controller ki jagah variable use karein aur default value set karein
    String selectedType = 'owner';

    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder( // StatefulBuilder zaroori hai dropdown update dikhane ke liye
        builder: (context, setState) => AlertDialog(
          title: Text("Add Resident"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: nameController, decoration: InputDecoration(labelText: "Name")),
                TextField(controller: flatController, decoration: InputDecoration(labelText: "House Number")),

                // Dropdown yahan add karein
                DropdownButtonFormField<String>(
                  value: selectedType,
                  decoration: InputDecoration(labelText: "Type"),
                  items: [
                    DropdownMenuItem(value: 'owner', child: Text("Owner")),
                    DropdownMenuItem(value: 'tenant', child: Text("Tenant")),
                  ],
                  onChanged: (value) {
                    setState(() {
                      selectedType = value!;
                    });
                  },
                ),

                TextField(controller: mobileController, decoration: InputDecoration(labelText: "Mobile")),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: Text("Cancel")),
            ElevatedButton(
              onPressed: () async {
                if (nameController.text.isEmpty || flatController.text.isEmpty || mobileController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Please fill all fields.")));
                  return;
                }

                final now = DateTime.now().toIso8601String();
                // TO THIS:
                final newResident = Resident(
                  name: nameController.text,
                  house_num: flatController.text,
                  resident_type: selectedType,
                  mobile: mobileController.text,
                );

                // toMap() will now automatically include the generated UUID
                await DatabaseHelper.instance.insertResident(newResident.toMap());

                residents.clear();
                page = 0;
                hasMore = true;
                await loadResidentsPage();
                Navigator.pop(ctx);
              },
              child: Text("Save"),
            ),
          ],
        ),
      ),
    );
  }


  Future<void> editResident(BuildContext context, Resident r) async {
  final nameController = TextEditingController(text: r.name);
  final flatController = TextEditingController(text: r.house_num);
  final mobileController = TextEditingController(text: r.mobile);

  // Existing value ko initialize karein (ensure lowerCase matching)
  String selectedType = r.resident_type.toLowerCase() == 'tenant' ? 'tenant' : 'owner';

  await showDialog(
    context: context,
    builder: (ctx) => StatefulBuilder(
      builder: (context, setState) => AlertDialog(
        title: Text("Edit Resident"),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: TextEditingController(text: r.id.toString()), decoration: InputDecoration(labelText: "ID"), readOnly: true),
              TextField(controller: nameController, decoration: InputDecoration(labelText: "Name")),
              TextField(controller: flatController, decoration: InputDecoration(labelText: "House Number")),

              // Dropdown for Edit
              DropdownButtonFormField<String>(
                value: selectedType,
                decoration: InputDecoration(labelText: "Type"),
                items: [
                  DropdownMenuItem(value: 'owner', child: Text("Owner")),
                  DropdownMenuItem(value: 'tenant', child: Text("Tenant")),
                ],
                onChanged: (value) {
                  setState(() {
                    selectedType = value!;
                  });
                },
              ),

              TextField(controller: mobileController, decoration: InputDecoration(labelText: "Mobile")),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text("Cancel")),
          ElevatedButton(
            onPressed: () async {
              final now = DateTime.now().toIso8601String();
              // TO THIS:
              final updatedResident = r.copyWith(
                name: nameController.text,
                house_num: flatController.text,
                resident_type: selectedType,
                mobile: mobileController.text,
              );

              await DatabaseHelper.instance.updateResident(updatedResident.toMap());


              residents.clear();
              page = 0;
              hasMore = true;
              await loadResidentsPage();

              Navigator.pop(ctx);
            },
            child: Text("Save"),
          ),
        ],
      ),
    ),
  );
}


  Future<void> deleteResident(BuildContext context, Resident r) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Delete Resident?'),
        content: Text('Are you sure you want to delete ${r.name}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text('Cancel')),
          ElevatedButton(onPressed: () => Navigator.pop(ctx, true), child: Text('Delete')),
        ],
      ),
    );

    if (confirm == true) {
      await DatabaseHelper.instance.deleteResident(r.id.toString());

      residents.clear();
      page = 0;
      hasMore = true;
      await loadResidentsPage();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${r.name} deleted successfully!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Resident List ($totalCount)")),
      body: NotificationListener<ScrollNotification>(
        onNotification: (scrollInfo) {
          if (!isLoadingMore &&
              hasMore &&
              scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent) {
            SchedulerBinding.instance.addPostFrameCallback((_) {
              loadResidentsPage();
            });
          }
          return false;
        },
        child: ListView.builder(
          itemCount: residents.length + (hasMore ? 1 : 0),
          itemBuilder: (context, index) {
            if (index == residents.length) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                loadResidentsPage();
              });
              return Padding(
                padding: const EdgeInsets.all(20),
                child: Center(child: CircularProgressIndicator()),
              );
            }

            final r = residents[index];

            return ListTile(
              leading: CircleAvatar(child: Text(r.house_num)),
              title: Text(r.name),
              subtitle: Text(
                // Capitalize the first letter of resident_type for display
                  "Type: ${r.resident_type[0].toUpperCase()}${r.resident_type.substring(1)}\n"
                      "Mobile: ${r.mobile}"
              ),
              isThreeLine: true,
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(icon: Icon(Icons.edit), onPressed: () => editResident(context, r)),
                  IconButton(icon: Icon(Icons.delete, color: Colors.red), onPressed: () => deleteResident(context, r)),
                ],
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => addResident(context),
        child: Icon(Icons.add),
        tooltip: "Add Resident",
      ),
    );
  }
}