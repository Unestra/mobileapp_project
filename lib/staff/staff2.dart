import 'package:flutter/material.dart';
import 'package:myapp/staff/add.dart';
import 'package:myapp/staff/all_staff.dart';
import 'package:myapp/staff/edit.dart';
import 'package:http/http.dart' as http;
import 'dart:convert'; // For handling JSON

class AllStafff extends StatefulWidget {
  const AllStafff({super.key});

  @override
  State<AllStafff> createState() => _AllStafffState();
}

class _AllStafffState extends State<AllStafff> {
  Uri uri = Uri.parse('http://192.168.1.6:3000/assets');
  final List<Map<String, dynamic>> items = [];
  List<Map<String, dynamic>> initialItems = [];
  String searchQuery = '';
  bool showAll = false;

  @override
  void initState() {
    super.initState();
    fetchAssets();
  }

  Future<void> fetchAssets() async {
    try {
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          items.clear();
          initialItems.clear();
          for (var item in data) {
            final asset = {
              "id": "Distinct ID : ${item['asset_id']}",
              "name": item['asset_name'] ?? 'Unknown',
              "imagePath": item['asset_image'] ?? '',
              "status": item['status'] ?? 'Unknown',
              "info":item['assets_description'],
              "color": item['status'] == 'Available'
                  ? Color(0xFF2EA64E)
                  : item['status'] == 'Disabled'
                      ? Color(0xFFFF0000)
                      : item['status'] == 'Pending'
                          ? Color(0xFF007AFF)
                          : item['status'] == 'Borrowed'
                              ? Color(0xFFE7C413)
                              : Color(0xFFE7C413),
            };
            items.add(asset);
          }
          // Keep only the first 4 items in initialItems
          initialItems = items.take(4).toList();
        });
      } else {
        print('Error fetching assets: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  int nextId = 9; // Next ID for new items

  void _addNewStaff(Map<String, dynamic> newItem) {
    setState(() {
      newItem["id"] = "Distinct ID : ${nextId.toString().padLeft(3, '0')}";
      items.add(newItem);
      nextId++; // Increment the ID counter
    });
  }

  @override
  Widget build(BuildContext context) {
    final displayedItems = showAll
        ? items.where((item) {
            final nameMatch = item["name"]
                .toString()
                .toLowerCase()
                .contains(searchQuery.toLowerCase());
            final statusMatch = item["status"]
                .toString()
                .toLowerCase()
                .contains(searchQuery.toLowerCase());
            return nameMatch || statusMatch;
          }).toList()
        : initialItems;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Sports Equipment',
          style: TextStyle(
            color: Color(0xFF78A3D4),
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Color(0xFF78A3D4)),
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildSearchBar(),
            const SizedBox(height: 20),
            _buildSeeAllButton(),
            const SizedBox(height: 20),
            _buildGridView(displayedItems),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Row(
      children: [
        Flexible(
          child: TextField(
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.search, color: Color(0xFF8F8F8F)),
              hintText: 'Search...',
              hintStyle: TextStyle(color: Color(0xFF8F8F8F)),
              filled: true,
              fillColor: Color(0xFFECECEC),
              border: OutlineInputBorder(borderSide: BorderSide.none),
            ),
            onChanged: (value) {
              setState(() {
                searchQuery = value;
                showAll = value.isNotEmpty; // Show all items when typing
              });
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSeeAllButton() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
         // Add button
                ElevatedButton(
                  onPressed: () async {
                    final newItem = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AddStaffPage(),
                      ),
                    );
                    if (newItem != null) {
                      _addNewStaff(newItem);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    "Add",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                Spacer(),
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const AllStaff(),
              ),
            );
            setState(() {
              showAll = true; // Show all items when "See All" is tapped
            });
          },
          child: const Text(
            'See All',
            style: TextStyle(
              color: Color(0xFFD01D1D),
              fontWeight: FontWeight.w900,
              fontSize: 17,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGridView(List<Map<String, dynamic>> displayedItems) {
    return Expanded(
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.6,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
        ),
        itemCount: displayedItems.length,
        itemBuilder: (context, index) {
          var item = displayedItems[index];
          return _buildAssetCard(item, index);
        },
      ),
    );
  }

  Widget _buildAssetCard(Map<String, dynamic> item, int index) {
    return Card(
      color: const Color(0xFFF2F2F2),
      margin: const EdgeInsets.all(5),
      child: SizedBox(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20.0),
                  child: item["imagePath"] != null &&
                          item["imagePath"].isNotEmpty
                      ? Image.asset(
                          item["imagePath"],
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) {
                            return const Center(child: Text('Image not found'));
                          },
                        )
                      : const Center(child: Text('No image provided')),
                ),
              ),
              const SizedBox(height: 20.0),
              Text(
                item["name"],
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10.0),
              Text(
                item["id"],
                style: const TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Status: ', style: TextStyle(color: Colors.black)),
                  Text(
                    item["status"],
                    style: TextStyle(color: item["color"]),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () async {
                      final updatedItem = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EditStaffPage(item: item),
                        ),
                      );
                      if (updatedItem != null) {
                        setState(() {
                          items[index] = updatedItem;
                        });
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1B305B),
                      minimumSize: const Size(80, 40),
                    ),
                    child: const Text(
                      'Edit',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  const SizedBox(width: 5),
                  ElevatedButton(
                    onPressed: (item["status"] == "Pending" ||
                            item["status"] == "Borrowed")
                        ? null
                        : () async {
                            bool? shouldUpdate = await showDialog<bool>(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: Text('Change Status'),
                                  content: Text(
                                    'Are you sure you want to ${item["status"] == "Available" ? "Disable" : "Activate"} this item?',
                                  ),
                                  actions: <Widget>[
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop(false);
                                      },
                                      child: Text('Cancel'),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop(true);
                                      },
                                      child: Text('Yes'),
                                    ),
                                  ],
                                );
                              },
                            );

                            if (shouldUpdate == true) {
                              final url =
                                  'http://192.168.1.6:3000/assets/disable/${item["id"].split(': ')[1]}';
                              final response = await http.put(Uri.parse(url));
                              if (response.statusCode == 200) {
                                fetchAssets();
                              }
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: item["status"] == "Disabled"
                          ? Color(0xFF2EA64E)
                          : Colors.red,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      minimumSize: const Size(80, 40),
                    ),
                    child: Text(
                      item["status"] == "Available" ? 'Disable' : 'Activate',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
