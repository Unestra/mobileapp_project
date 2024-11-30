import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AllLender extends StatefulWidget {
  const AllLender({super.key});

  @override
  State<AllLender> createState() => _AllLenderState();
}

class _AllLenderState extends State<AllLender> {
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
                "color": item['status'] == 'Available'
                    ? Color(0xFF2EA64E)
                    : item['status'] == 'Disabled'
                        ? Color(0xFFFF0000)
                        : item['status'] == 'Pending'
                            ? Color(0xFF007AFF)
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
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'All Lenders',
          style: TextStyle(
            color: Color(0xFF78A3D4),
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Color(0xFF78A3D4)),
      ),
      backgroundColor: Colors.white,
      body: items.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(10.0),
              child: _buildGridView(),
            ),
    );
  }

  Widget _buildGridView() {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.65,
        crossAxisSpacing: 15,
        mainAxisSpacing: 15,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        var item = items[index];
        return _buildAssetCard(item);
      },
    );
  }

  Widget _buildAssetCard(Map<String, dynamic> item) {
    return Card(
      color: const Color(0xFFF2F2F2),
      margin: const EdgeInsets.all(5),
      child: SizedBox(
        //width: 160, // กำหนดความกว้างที่ต้องการ
        //height: 100, // กำหนดความสูงที่ต้องการ
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
                  fontSize: 18, // ปรับขนาดตัวอักษรให้เล็กลง
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10.0),
              Text(
                "Distinct ID :${item["id"]}", // ย่อข้อความให้กระชับขึ้น
                style: const TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
              SizedBox(
                height: 10,
              ),
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
              SizedBox(
                height: 20,
              )
            ],
          ),
        ),
      ),
    );
  }
}

















// import 'package:flutter/material.dart';

// class AllLender extends StatefulWidget {
//   const AllLender({super.key});

//   @override
//   State<AllLender> createState() => _AllLenderState();
// }

// class _AllLenderState extends State<AllLender> {
//   final List<Map<String, dynamic>> items = [
//     {
//       "id": "Distinct ID : 001",
//       "name": "Football",
//       "imagePath": 'assets/images/football.png',
//       "status": "Available",
//       "color": Color(0xFF2EA64E),
//     },
//     {
//       "id": "Distinct ID : 002",
//       "name": "Volleyball",
//       "imagePath": 'assets/images/ball2.jpg',
//       "status": "Disable",
//       "color": Color(0xFFFF0000),
//     },
//     {
//       "id": "Distinct ID : 003",
//       "name": "Basketball",
//       "imagePath": 'assets/images/ball3.jpg',
//       "status": "Borrowed",
//       "color": Color(0xFFE7C413),
//     },
//     {
//       "id": "Distinct ID : 004",
//       "name": "Badminton",
//       "imagePath": 'assets/images/dd.jpg',
//       "status": "Pending",
//       "color": Color(0xFF007AFF),
//     },
//     {
//       "id": "Distinct ID : 005",
//       "name": "Tennis",
//       "imagePath": 'assets/images/ball5.jpeg',
//       "status": "Available",
//       "color": Color(0xFF2EA64E),
//     },
//     {
//       "id": "Distinct ID : 006",
//       "name": "Rattan ball",
//       "imagePath": 'assets/images/ball6.jpg',
//       "status": "Disable",
//       "color": Color(0xFFFF0000),
//     },
//     {
//       "id": "Distinct ID : 007",
//       "name": "Ping pong",
//       "imagePath": 'assets/images/ball7.jpg',
//       "status": "Borrowed",
//       "color": Color(0xFFE7C413),
//     },
//     {
//       "id": "Distinct ID : 008",
//       "name": "Futsal ball",
//       "imagePath": 'assets/images/ball8.jpg',
//       "status": "Pending",
//       "color": Color(0xFF007AFF),
//     },
//   ];

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         automaticallyImplyLeading: false,
//         title: const Text(
//           'Sports Equipment',
//           style: TextStyle(
//             color: Color(0xFF78A3D4),
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//         leading: IconButton(
//           icon: Icon(Icons.arrow_back),
//           onPressed: () {
//          Navigator.pop(context);
//             // Navigate back
//           },
//         ),
//         backgroundColor: Colors.white,
//         iconTheme: const IconThemeData(color: Color(0xFF78A3D4)),
//       ),
//       backgroundColor: Colors.white,
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: GridView.builder(
//           gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//             crossAxisCount: 2, // Number of cards per row
//             childAspectRatio: 0.6, // Aspect ratio for the cards
//             crossAxisSpacing: 10, // Space between cards in a row
//             mainAxisSpacing: 10, // Space between rows
//           ),
//           itemCount: items.length,
//           itemBuilder: (context, index) {
//             var item = items[index];

//             return Card(
//               color: const Color(0xFFF2F2F2),
//               margin: EdgeInsets.all(5),
//               child: Container(
//                 padding: const EdgeInsets.all(10.0),
//                 constraints: BoxConstraints(
//                   maxHeight: 300, // Set max height for the card
//                 ),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.center,
//                   children: [
//                     Expanded(
//                       child: ClipRRect(
//                         borderRadius: BorderRadius.circular(10.0),
//                         child: Image.asset(
//                           item["imagePath"],
//                           fit: BoxFit.cover,
//                           errorBuilder: (context, error, stackTrace) {
//                             return const Center(child: Text('Image not found'));
//                           },
//                         ),
//                       ),
//                     ),
//                     const SizedBox(height: 8.0),
//                     Text(
//                       item["name"],
//                       style: const TextStyle(
//                         fontSize: 18,
//                         fontWeight: FontWeight.bold,
//                       ),
//                       textAlign: TextAlign.center,
//                     ),
//                     const SizedBox(height: 4.0),
//                     Text(
//                       item["id"],
//                       style: const TextStyle(
//                         fontSize: 14,
//                       ),
//                       textAlign: TextAlign.center,
//                     ),
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         const Text(
//                           'Status: ',
//                           style: TextStyle(color: Colors.black),
//                         ),
//                         Text(
//                           item["status"],
//                           style: TextStyle(color: item["color"]),
//                         ),
//                       ],
//                     ),
//                     const SizedBox(height: 60),
//                     // Row(
//                     //   mainAxisAlignment: MainAxisAlignment.center,
//                     //   children: [
//                     //     ElevatedButton(
//                     //       onPressed: () {
//                     //         print('Edit pressed for ${item["name"]}');
//                     //       },
//                     //       style: ElevatedButton.styleFrom(
//                     //         backgroundColor: const Color(0xFF1B305B),
//                     //         minimumSize: const Size(80, 40),
//                     //       ),
//                     //       child: const Text(
//                     //         'Edit',
//                     //         style: TextStyle(color: Colors.white),
//                     //       ),
//                     //     ),
//                     //     const SizedBox(width: 5),
//                     //     ElevatedButton(
//                     //       onPressed: (item["status"] == "Pending" ||
//                     //               item["status"] == "Borrowed")
//                     //           ? null
//                     //           : () {
//                     //               setState(() {
//                     //                 if (item["status"] == "Available") {
//                     //                   item["status"] = "Disable";
//                     //                   item["color"] = Color(0xFFFF0000);
//                     //                 } else {
//                     //                   item["status"] = "Available";
//                     //                   item["color"] = Color(0xFF2EA64E);
//                     //                 }
//                     //               });
//                     //             },
//                     //       style: ElevatedButton.styleFrom(
//                     //         backgroundColor: item["status"] == "Disable"
//                     //             ? Colors.yellow
//                     //             : Colors.red,
//                     //         padding: const EdgeInsets.symmetric(
//                     //             horizontal: 12, vertical: 8),
//                     //         minimumSize: const Size(80, 40),
//                     //       ),
//                     //       child: Text(
//                     //         item["status"] == "Disable"
//                     //             ? 'Activate'
//                     //             : 'Disable',
//                     //         style: const TextStyle(color: Colors.white),
//                     //       ),
//                     //     ),
//                     //   ],
//                     // ),
//                   ],
//                 ),
//               ),
//             );
//           },
//         ),
//       ),
//     );
//   }
// }
