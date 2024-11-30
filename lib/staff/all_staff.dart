import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
//import 'package:myapp/project/staff/all_staff.dart'; // Ensure this import is correct

class AllStaff extends StatefulWidget {
  const AllStaff({super.key});

  @override
  State<AllStaff> createState() => _ListStaffState();
}

class _ListStaffState extends State<AllStaff> {
  Uri uri = Uri.parse('http://192.168.1.6:3000/assets');
  final List<Map<String, dynamic>> items = [];
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    fetchAssets(); // Fetch data when initializing
  }

  // Function to fetch assets
  Future<void> fetchAssets() async {
    try {
      final response = await http.get(uri);

      // Check if the response is successful
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          items.clear(); // Clear previous items

          for (var item in data) {
            // Ensure the necessary fields are available in the response
            int assetId = int.tryParse(item['asset_id'].toString()) ?? 0;
            String assetName = item['asset_name'] ?? 'Unknown Asset';
            String imagePath = item['asset_image'] ?? '';
            String status = item['status'] ?? 'Unknown';

            // Add the item to the list with a proper filter if necessary
            items.add({
              "id": assetId,
              "name": assetName,
              "imagePath": imagePath,
              "status": status,
              "color": status == 'Available'
                  ? Color(0xFF2EA64E)
                  : (status == 'Disabled'
                      ? Color(0xFFFF0000)
                      : Color(0xFFE7C413)),
            });
          }
        });
      } else {
        // Handle unsuccessful response
        print('Error fetching assets: ${response.statusCode}');
      }
    } catch (e) {
      // Handle error during the request
      print('Error: $e');
    }
  }

  // Function to handle search input
  void _onSearchChanged(String value) {
    setState(() {
      searchQuery = value.toLowerCase();
    });
  }

  // Function to filter assets based on search query
  List<Map<String, dynamic>> get filteredItems {
    if (searchQuery.isEmpty) {
      return items;
    } else {
      return items
          .where((item) => item['name'].toLowerCase().contains(searchQuery))
          .toList();
    }
  }

  @override
  Widget build(BuildContext context) {
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
            _buildGridView(),
          ],
        ),
      ),
    );
  }

  // Build Grid View
  Widget _buildGridView() {
    return Expanded(
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.6,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
        ),
        itemCount: filteredItems.length,
        itemBuilder: (context, index) {
          var item = filteredItems[index];
          return _buildAssetCard(item);
        },
      ),
    );
  }

  // Build Individual Asset Card
  Widget _buildAssetCard(Map<String, dynamic> item) {
    return Card(
      color: const Color(0xFFF2F2F2),
      margin: EdgeInsets.all(5),
      child: Container(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10.0),
                child: Image.asset(
                  item["imagePath"],
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return const Center(child: Text('Image not found'));
                  },
                ),
              ),
            ),
            const SizedBox(height: 8.0),
            Text(
              item["name"],
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4.0),
            Text(
              "Distinct ID : ${item["id"]}", // Show formatted ID for clarity
              style: const TextStyle(fontSize: 14),
              textAlign: TextAlign.center,
            ),
            _buildStatusRow(item),
            const SizedBox(height: 5),
            _buildActionButtons(item),
          ],
        ),
      ),
    );
  }

  // Build Status Row
  Widget _buildStatusRow(Map<String, dynamic> item) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text('Status: ', style: TextStyle(color: Colors.black)),
        Text(
          item["status"],
          style: TextStyle(color: item["color"]),
        ),
      ],
    );
  }

  // Build Action Buttons (Edit and Disable/Activate)
  Widget _buildActionButtons(Map<String, dynamic> item) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton(
          onPressed: () {
            print('Edit pressed for ${item["name"]}');
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
  onPressed: (item["status"] == "Pending" || item["status"] == "Borrowed")
      ? null
      : () async {
          // แสดง AlertDialog
          bool? confirm = await showDialog<bool>(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text('Confirm Status Change'),
                content: Text(
                  'Are you sure you want to ${item["status"] == "Available" ? "Disable" : "Activate"} this item?',
                ),
                actions: <Widget>[
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop(false); // ไม่ยืนยัน
                    },
                    child: Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop(true); // ยืนยัน
                    },
                    child: Text('Yes'),
                  ),
                ],
              );
            },
          );

          // ถ้าผู้ใช้กดยืนยัน
          if (confirm == true) {
            String newStatus = (item["status"] == "Available")
                ? "Disabled"
                : "Available";
            Color newColor = (newStatus == "Disabled")
                ? Color(0xFFFF0000)
                : Color(0xFF2EA64E);

            setState(() {
              item["status"] = newStatus;
              item["color"] = newColor;
            });

            try {
              final response = await http.put(
                Uri.parse('http://192.168.1.6:3000/assets/${item["id"]}'),
                headers: {'Content-Type': 'application/json'},
                body: json.encode({'status': newStatus}),
              );

              if (response.statusCode == 200) {
                print('Status updated successfully: ${response.body}');
              } else {
                print('Failed to update status: ${response.body}');
                setState(() {
                  item["status"] = (newStatus == "Disabled")
                      ? "Available"
                      : "Disabled";
                  item["color"] = (item["status"] == "Disabled")
                      ? Color(0xFFFF0000)
                      : Color(0xFF2EA64E);
                });
              }
            } catch (e) {
              print('Error occurred: $e');
              setState(() {
                item["status"] =
                    (newStatus == "Disabled") ? "Available" : "Disabled";
                item["color"] = (item["status"] == "Disabled")
                    ? Color(0xFFFF0000)
                    : Color(0xFF2EA64E);
              });
            }
          }
        },
  style: ElevatedButton.styleFrom(
    backgroundColor: item["status"] == "Disabled" ? Color(0xFF2EA64E) : Colors.red,
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    minimumSize: const Size(80, 40),
  ),
  child: Text(
    item["status"] == "Disabled" ? 'Activate' : 'Disable',
    style: const TextStyle(color: Colors.white),
  ),
),

      ],
    );
  }
}
