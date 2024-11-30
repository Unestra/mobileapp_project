import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:myapp/student/borrow.dart';

class AllStudent extends StatefulWidget {
  const AllStudent({super.key});

  @override
  State<AllStudent> createState() => _AllStudentState();
}

class _AllStudentState extends State<AllStudent> {
  Uri uri = Uri.parse('http://192.168.1.6:3000/assets');
  final List<Map<String, dynamic>> items = [];

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
            if (assetId > 0) {
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
                                : Color(
                                    0xFFE7C413), // Default color if status is unrecognized
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
            const SizedBox(height: 20),
            Expanded(
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
                                  return const Center(
                                      child: Text('Image not found'));
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
                          SizedBox(
                            height: 40,
                            child: item["status"] == "Available"
                                ? ElevatedButton(
                                    onPressed: () {
                                      // ตรวจสอบค่าที่ส่งไป
                                      print('Asset ID: ${item['id']}');
                                      print(
                                          'Asset Name: ${item['asset_name']}');
                                      print(
                                          'Asset Image Path: ${item["imagePath"]}');
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
                                      );
                                      // Implement borrowing logic here
                                      print('Borrowing ${item["name"]}');
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
            ),
          ],
        ),
      ),
    );
  }
}
