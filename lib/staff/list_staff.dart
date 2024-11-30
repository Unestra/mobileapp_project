import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:myapp/staff_lender/all_lender.dart';

class ListStaff extends StatefulWidget {
  const ListStaff({super.key});

  @override

  State<ListStaff> createState() => _ListStaffState();
}

class _ListStaffState extends State<ListStaff> {
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
              "id": int.tryParse(item['asset_id'].toString()) ?? 0,
              "name": item['asset_name'] ?? 'Unknown',
              "imagePath": item['asset_image'] ?? '',
              "status": item['status'] ?? 'Unknown',
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
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                      const AllLender()), // Ensure this page exists
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
          return _buildAssetCard(item);
        },
      ),
    );
  }

  Widget _buildAssetCard(Map<String, dynamic> item) {
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
                "Distinct ID :${item["id"]}",
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
            ],
          ),
        ),
      ),
    );
  }
}














// import 'package:flutter/material.dart';
// import 'package:myapp/staff_lender/all_lender.dart';


// class ListLender extends StatefulWidget {
//   const ListLender({super.key});

//   @override
//   State<ListLender> createState() => _ListLenderState();
// }

// class _ListLenderState extends State<ListLender> {
//   // Combined list of items
//   final List<Map<String, dynamic>> items = [
//     {
//       "id": "Distinct ID : 001",
//       "name": "Football",
//       "imagePath": '',
//       "status": "assets/images/football.png",
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
//   ];

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Center(
//           child: const Text(
//             'Sports Equipment',
//             style: TextStyle(
//               color: Color(0xFF78A3D4),
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//         ),
//          automaticallyImplyLeading: false,
//         backgroundColor: Colors.white,
//         iconTheme: const IconThemeData(color: Color(0xFF78A3D4)),
//       ),
//       backgroundColor: Colors.white,
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           children: [
//             Row(
//               children: [
//                 Flexible(
//                   child: TextField(
//                     decoration: const InputDecoration(
//                       prefixIcon: Icon(Icons.search, color: Color(0xFF8F8F8F)),
//                       hintText: 'Search...',
//                       hintStyle: TextStyle(color: Color(0xFF8F8F8F)),
//                       filled: true,
//                       fillColor: Color(0xFFECECEC),
//                       border: OutlineInputBorder(borderSide: BorderSide.none),
//                     ),
//                     onChanged: (value) {
//                       // handle search logic here
//                     },
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 20),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.end,
//               children: [
//                 // ElevatedButton(
//                 //   onPressed: () {},
//                 //   style: ElevatedButton.styleFrom(
//                 //     backgroundColor: Colors.green,
//                 //   ),
//                 //   child: Text('Add', style: TextStyle(color: Colors.white)),
//                 // ),
//                 GestureDetector(
//                   onTap: () {
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(builder: (context) => AllLender()),
//                     );
//                   },
//                   child: const Text(
//                     'See All',
//                     style: TextStyle(
//                       color: Color(0xFFD01D1D),
//                       fontWeight: FontWeight.w900,
//                       fontSize: 17,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 20),
//             Expanded(
//               child: GridView.builder(
//                 gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//                   crossAxisCount: 2,
//                   childAspectRatio: 0.6,
//                   crossAxisSpacing: 10,
//                   mainAxisSpacing: 10,
//                 ),
//                 itemCount: items.length,
//                 itemBuilder: (context, index) {
//                   var item = items[index];

//                   return Card(
//                     color: const Color(0xFFF2F2F2),
//                     margin: const EdgeInsets.all(5),
//                     child: Container(
//                       padding: const EdgeInsets.all(10.0),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.center,
//                         children: [
//                           Expanded(
//                             child: ClipRRect(
//                               borderRadius: BorderRadius.circular(10.0),
//                               child: Image.asset(
//                                 item["imagePath"],
//                                 fit: BoxFit.cover,
//                                 errorBuilder: (context, error, stackTrace) {
//                                   return const Center(
//                                       child: Text('Image not found'));
//                                 },
//                               ),
//                             ),
//                           ),
//                           const SizedBox(height: 8.0),
//                           Text(
//                             item["name"],
//                             style: const TextStyle(
//                               fontSize: 18,
//                               fontWeight: FontWeight.bold,
//                             ),
//                             textAlign: TextAlign.center,
//                           ),
//                           const SizedBox(height: 4.0),
//                           Text(
//                             item["id"],
//                             style: const TextStyle(
//                               fontSize: 14,
//                             ),
//                             textAlign: TextAlign.center,
//                           ),
//                           Row(
//                             mainAxisAlignment: MainAxisAlignment.center,
//                             children: [
//                               const Text('Status: ',
//                                   style: TextStyle(color: Colors.black)),
//                               Text(
//                                 item["status"],
//                                 style: TextStyle(color: item["color"]),
//                               ),
//                             ],
//                           ),
//                           const SizedBox(height: 60),
//                           // Row(
//                           //   mainAxisAlignment: MainAxisAlignment.center,
//                           //   children: [
//                           //     ElevatedButton(
//                           //       onPressed: () {
//                           //         print('Edit pressed for ${item["name"]}');
//                           //       },
//                           //       style: ElevatedButton.styleFrom(
//                           //         backgroundColor: const Color(0xFF1B305B),
//                           //         minimumSize: const Size(80, 40),
//                           //       ),
//                           //       child: const Text(
//                           //         'Edit',
//                           //         style: TextStyle(color: Colors.white),
//                           //       ),
//                           //     ),
//                           //     const SizedBox(width: 5),
//                           //     ElevatedButton(
//                           //       onPressed: (item["status"] == "Pending" ||
//                           //               item["status"] == "Borrowed")
//                           //           ? null
//                           //           : () {
//                           //               setState(() {
//                           //                 if (item["status"] == "Available") {
//                           //                   item["status"] = "Disable";
//                           //                   item["color"] = Color(0xFFFF0000);
//                           //                 } else {
//                           //                   item["status"] = "Available";
//                           //                   item["color"] = Color(0xFF2EA64E);
//                           //                 }
//                           //               });
//                           //             },
//                           //       style: ElevatedButton.styleFrom(
//                           //         backgroundColor: item["status"] == "Disable"
//                           //             ? Colors.yellow
//                           //             : Colors.red,
//                           //         padding: const EdgeInsets.symmetric(
//                           //             horizontal: 12, vertical: 8),
//                           //         minimumSize: const Size(80, 40),
//                           //       ),
//                           //       child: Text(
//                           //         item["status"] == "Disable"
//                           //             ? 'Activate'
//                           //             : 'Disable',
//                           //         style: const TextStyle(color: Colors.white),
//                           //       ),
//                           //     ),
//                           //   ],
//                           // ),
//                         ],
//                       ),
//                     ),
//                   );
//                 },
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }









// import 'package:flutter/material.dart';
// import 'package:myapp/staff/add.dart';
// import 'package:myapp/staff/all_staff.dart';
// import 'package:myapp/staff/edit.dart';

// class ListStaff extends StatefulWidget {
//   const ListStaff({super.key});

//   @override
//   State<ListStaff> createState() => _ListStaffState();
// }

// class _ListStaffState extends State<ListStaff> {
//   // Combined list of items
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
//   ];

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Center(
//           child: const Text(
//             'Sports Equipment',
//             style: TextStyle(
//               color: Color(0xFF78A3D4),
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//         ),
//         automaticallyImplyLeading: false,
//         backgroundColor: Colors.white,
//         iconTheme: const IconThemeData(color: Color(0xFF78A3D4)),
//       ),
//       backgroundColor: Colors.white,
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           children: [
//             Row(
//               children: [
//                 Flexible(
//                   child: TextField(
//                     decoration: const InputDecoration(
//                       prefixIcon: Icon(Icons.search, color: Color(0xFF8F8F8F)),
//                       hintText: 'Search...',
//                       hintStyle: TextStyle(color: Color(0xFF8F8F8F)),
//                       filled: true,
//                       fillColor: Color(0xFFECECEC),
//                       border: OutlineInputBorder(borderSide: BorderSide.none),
//                     ),
//                     onChanged: (value) {
//                       // handle search logic here
//                     },
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 20),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.end,
//               children: [
//                 ElevatedButton(
//                   onPressed: () {
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(builder: (context) => AddStaffPage()),
//                     );
//                   },
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.green,
//                   ),
//                   child: Text('Add', style: TextStyle(color: Colors.white)),
//                 ),
//                 Spacer(),
//                 GestureDetector(
//                   onTap: () {
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(builder: (context) => AllStaff()),
//                     );
//                   },
//                   child: const Text(
//                     'See All',
//                     style: TextStyle(
//                       color: Color(0xFFD01D1D),
//                       fontWeight: FontWeight.w900,
//                       fontSize: 17,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 20),
//             Expanded(
//               child: GridView.builder(
//                 gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//                   crossAxisCount: 2,
//                   childAspectRatio: 0.6,
//                   crossAxisSpacing: 10,
//                   mainAxisSpacing: 10,
//                 ),
//                 itemCount: items.length,
//                 itemBuilder: (context, index) {
//                   var item = items[index];

//                   return Card(
//                     color: const Color(0xFFF2F2F2),
//                     margin: EdgeInsets.all(5),
//                     child: Container(
//                       padding: const EdgeInsets.all(10.0),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.center,
//                         children: [
//                           Expanded(
//                             child: ClipRRect(
//                               borderRadius: BorderRadius.circular(10.0),
//                               child: Image.asset(
//                                 item["imagePath"],
//                                 fit: BoxFit.cover,
//                                 errorBuilder: (context, error, stackTrace) {
//                                   return const Center(
//                                       child: Text('Image not found'));
//                                 },
//                               ),
//                             ),
//                           ),
//                           const SizedBox(height: 8.0),
//                           Text(
//                             item["name"],
//                             style: const TextStyle(
//                               fontSize: 18,
//                               fontWeight: FontWeight.bold,
//                             ),
//                             textAlign: TextAlign.center,
//                           ),
//                           const SizedBox(height: 4.0),
//                           Text(
//                             item["id"],
//                             style: const TextStyle(
//                               fontSize: 14,
//                             ),
//                             textAlign: TextAlign.center,
//                           ),
//                           Row(
//                             mainAxisAlignment: MainAxisAlignment.center,
//                             children: [
//                               const Text('Status: ',
//                                   style: TextStyle(color: Colors.black)),
//                               Text(
//                                 item["status"],
//                                 style: TextStyle(color: item["color"]),
//                               ),
//                             ],
//                           ),
//                           const SizedBox(height: 5),
//                           Row(
//                             mainAxisAlignment: MainAxisAlignment.center,
//                             children: [
//                               ElevatedButton(
//                                 onPressed: () {
//                                   Navigator.push(
//                                     context,
//                                     MaterialPageRoute(
//                                       builder: (context) => EditStaffPage(item: item,),
//                                     ),
//                                   );
//                                 },
//                                 style: ElevatedButton.styleFrom(
//                                   backgroundColor: const Color(0xFF1B305B),
//                                   minimumSize: const Size(80, 40),
//                                 ),
//                                 child: const Text(
//                                   'Edit',
//                                   style: TextStyle(color: Colors.white),
//                                 ),
//                               ),
//                               const SizedBox(width: 5),
//                               ElevatedButton(
//                                 onPressed: (item["status"] == "Pending" ||
//                                         item["status"] == "Borrowed")
//                                     ? null
//                                     : () {
//                                         setState(() {
//                                           if (item["status"] == "Available") {
//                                             item["status"] = "Disable";
//                                             item["color"] = Color(0xFFFF0000);
//                                           } else {
//                                             item["status"] = "Available";
//                                             item["color"] = Color(0xFF2EA64E);
//                                           }
//                                         });
//                                       },
//                                 style: ElevatedButton.styleFrom(
//                                   backgroundColor: item["status"] == "Disable"
//                                       ? Colors.yellow
//                                       : Colors.red,
//                                   padding: const EdgeInsets.symmetric(
//                                       horizontal: 12, vertical: 8),
//                                   minimumSize: const Size(80, 40),
//                                 ),
//                                 child: Text(
//                                   item["status"] == "Disable"
//                                       ? 'Activate'
//                                       : 'Disable',
//                                   style: const TextStyle(color: Colors.white),
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ],
//                       ),
//                     ),
//                   );
//                 },
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
