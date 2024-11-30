import 'package:flutter/material.dart';
// Ensure this import is correct
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:myapp/student/all_student.dart';
import 'package:myapp/student/borrow.dart';

class ListStudent extends StatefulWidget {
  const ListStudent({super.key});

  @override
  State<ListStudent> createState() => _ListStudentState();
}

class _ListStudentState extends State<ListStudent> {
  Uri uri = Uri.parse('http://192.168.1.6:3000/assets');
  final List<Map<String, dynamic>> items = [];
  String searchQuery = ''; // Variable to hold the search text

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
          for (var item in data) {
            int assetId = int.tryParse(item['asset_id'].toString()) ?? 0;
            if (assetId >= 1 && assetId <= 4) {
              items.add({
                "id": assetId,
                "name": item['asset_name'],
                "imagePath": item['asset_image'],
                "status": item['status'],
                "info": item['assets_description'],
                "color": item['status'] == 'Available'
                    ? Color(0xFF2EA64E)
                    : item['status'] == 'Disabled'
                        ? Color(0xFFFF0000)
                        : item['status'] == 'Pending'
                            ? Color(0xFF007AFF)
                            : item['status'] == 'Borrowed'
                                ? Color(0xFFE7C413)
                                : Color(0xFFE7C413),
              });
            }
          }
        });
      } else {
        print('Error fetching assets: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredItems = items.where((item) {
      return item["name"].toLowerCase().contains(searchQuery.toLowerCase());
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: const Text(
            'Sports Equipment',
            style: TextStyle(
              color: Color(0xFF78A3D4),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        automaticallyImplyLeading: false,
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
            _buildGridView(filteredItems),
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
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                      const AllStudent()), // Ensure this page exists
            );
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

  Widget _buildGridView(List<Map<String, dynamic>> items) {
    return Expanded(
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.6,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
        ),
        itemCount: items.length,
        itemBuilder: (context, index) {
          var item = items[index];

          return Card(
            color: const Color(0xFFF2F2F2),
            margin: const EdgeInsets.all(5),
            child: Container(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10.0),
                      child: item["imagePath"] != null &&
                              item["imagePath"].isNotEmpty
                          ? Image.asset(
                              item["imagePath"],
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return const Center(
                                    child: Text('Image not found'));
                              },
                            )
                          : const Center(child: Text('No image provided')),
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
                    "Distinct ID : ${item["id"]}",
                    style: const TextStyle(fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Status: ',
                          style: TextStyle(color: Colors.black)),
                      Text(
                        item["status"],
                        style: TextStyle(color: item["color"]),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  // Borrow Button
                  SizedBox(
                    height: 40,
                    child: item["status"] == "Available"
                        ? ElevatedButton(
                            onPressed: () {
                              // ตรวจสอบค่าที่ส่งไป
                              print('Asset ID: ${item['id']}');
                              print('Asset Name: ${item['asset_name']}');
                              print('Asset Image Path: ${item["imagePath"]}');
                              print('Asset Status: ${item["status"]}');
                              print(
                                  'Asset Description: ${item['assets_description']}');

                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => Borrow(
                                    assetId: item['id'].toString(),
                                    assetName: item['name'],
                                    assetImage: item["imagePath"],
                                    assetStatus: item["status"],
                                    assetDescription: item['info'],
                                  ),
                                ),
                              ).then((value) {
                                // เรียก fetchAssets() อีกครั้งเพื่อรีเฟรชข้อมูลเมื่อกลับมาหน้าเดิม
                                fetchAssets();
                              });
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  const Color.fromRGBO(46, 166, 78, 1),
                            ),
                            child: const Text(
                              'Borrow',
                              style: TextStyle(color: Colors.white),
                            ),
                          )
                        : const SizedBox.shrink(),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
