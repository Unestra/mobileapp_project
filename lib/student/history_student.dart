// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import 'package:intl/intl.dart';

// final Color primaryColor =
//     Color(0xFF1A237E); // Dark blue color matching the theme
// final TextStyle headingStyle =
//     TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: primaryColor);

// class HistoryStudentPage extends StatefulWidget {
//   @override
//   _HistoryStudentPageState createState() => _HistoryStudentPageState();
// }

// class _HistoryStudentPageState extends State<HistoryStudentPage> {
//   String dropdownValue = 'All';
//   String searchQuery = '';
//   final ScrollController _historyScrollController = ScrollController();
//   List<Map<String, dynamic>> historyData = [];
//   bool isLoading = true;

//   @override
//   void initState() {
//     super.initState();
//     fetchStudentHistory();
//   }

//   @override
//   void dispose() {
//     _historyScrollController.dispose();
//     super.dispose();
//   }

//   Future<void> fetchStudentHistory() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     String? token = prefs.getString('token'); // Assuming token is used as userId

//     if (token == null) {
//       setState(() {
//         isLoading = false;
//       });
//       return;
//     }

//     try {
//       final response = await http.get(
//         Uri.parse('http://192.168.1.6:3000/api/history/student/$token'),
//         headers: {
//           'Content-Type': 'application/json',
//           'Authorization': 'Bearer $token', // Pass the token in the header for authentication
//         },
//       ).timeout(Duration(seconds: 20));

//       if (response.statusCode == 200) {
//         if (mounted) {
//           setState(() {
//             historyData = List<Map<String, dynamic>>.from(json.decode(response.body));
//             isLoading = false;
//           });
//         }
//       } else {
//         print('Failed to load history, status code: ${response.statusCode}');
//         if (mounted) {
//           setState(() {
//             isLoading = false;
//           });
//         }
//       }
//     } catch (e) {
//       print('Error fetching student history: $e');
//       if (mounted) {
//         setState(() {
//           isLoading = false;
//         });
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final filteredHistoryData = historyData.where((data) {
//       bool matchesSearch = data['asset_name']
//               ?.toLowerCase()
//               .contains(searchQuery.toLowerCase()) ?? false;
//       bool matchesStatus = dropdownValue == 'All' ||
//           (dropdownValue == 'Returned' && data['status'] == 'Approved') ||
//           data['status'] == dropdownValue;
//       return matchesSearch && matchesStatus;
//     }).toList();

//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: primaryColor,
//         title: Center(
//             child: Text('SPORT APP',
//                 style: TextStyle(
//                     fontWeight: FontWeight.bold,
//                     color: Colors.white,
//                     fontFamily: 'Arial',
//                     fontSize: 28))),
//         automaticallyImplyLeading: false,
//       ),
//       body: isLoading
//           ? Center(child: CircularProgressIndicator())
//           : historyData.isEmpty
//               ? Center(child: Text('No history data available'))
//               : Padding(
//                   padding: const EdgeInsets.all(16.0),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text('History', style: headingStyle),
//                       SizedBox(height: 16),
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           Expanded(
//                             child: TextField(
//                               decoration: InputDecoration(
//                                 hintText: 'Search',
//                                 prefixIcon: Icon(Icons.search),
//                                 filled: true,
//                                 fillColor: Colors.grey[200],
//                                 border: OutlineInputBorder(
//                                   borderRadius:
//                                       BorderRadius.all(Radius.circular(12.0)),
//                                   borderSide: BorderSide.none,
//                                 ),
//                                 contentPadding: EdgeInsets.symmetric(
//                                     vertical: 0, horizontal: 16.0),
//                               ),
//                               onChanged: (value) {
//                                 setState(() {
//                                   searchQuery = value;
//                                 });
//                               },
//                             ),
//                           ),
//                           SizedBox(width: 8),
//                           DropdownButton<String>(
//                             value: dropdownValue,
//                             icon: Icon(Icons.arrow_drop_down),
//                             underline: SizedBox(),
//                             items: <String>[
//                               'All',
//                               'Borrowed',
//                               'Returned',
//                               'Disapproved'
//                             ].map<DropdownMenuItem<String>>((String value) {
//                               return DropdownMenuItem<String>(
//                                 value: value,
//                                 child: Text(value),
//                               );
//                             }).toList(),
//                             onChanged: (String? value) {
//                               setState(() {
//                                 dropdownValue = value!;
//                               });
//                             },
//                           ),
//                         ],
//                       ),
//                       SizedBox(height: 16),
//                       Expanded(
//                         child: Padding(
//                           padding: const EdgeInsets.all(16.0),
//                           child: Scrollbar(
//                             controller: _historyScrollController,
//                             thumbVisibility: true,
//                             thickness: 6.0,
//                             radius: Radius.circular(12.0),
//                             child: ListView.builder(
//                               controller: _historyScrollController,
//                               padding: EdgeInsets.only(right: 8.0),
//                               itemCount: filteredHistoryData.length,
//                               itemBuilder: (context, index) {
//                                 final data = filteredHistoryData[index];
//                                 return _buildHistoryCard(
//                                   data['asset_name'] ?? '',
//                                   data['borrow_date'] ?? '',
//                                   data['return_date'] ?? '',
//                                   data['status'] ?? '',
//                                   data['asset_image'] ?? '',
//                                   data['approver'] ?? '',
//                                 );
//                               },
//                             ),
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//     );
//   }

// Widget _buildHistoryCard(String name, String borrowedDate,
//     String returnedDate, String status, String imageUrl, String approver) {
//   final DateFormat formatter = DateFormat('dd/MM/yyyy');
//   String formattedBorrowedDate = borrowedDate.isNotEmpty
//       ? formatter.format(DateTime.parse(borrowedDate))
//       : '';
//   String formattedReturnedDate = returnedDate.isNotEmpty
//       ? formatter.format(DateTime.parse(returnedDate))
//       : '';

//   return Card(
//     color: Colors.grey[200],
//     shape: RoundedRectangleBorder(
//       borderRadius: BorderRadius.circular(12.0),
//     ),
//     child: Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Container(
//           color: Colors.grey[300],
//           padding: const EdgeInsets.all(8.0),
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Row(
//                 children: [
//                   SizedBox(
//                     width: 40,
//                     height: 40,
//                     child: imageUrl.isNotEmpty
//                         ? Image.asset(
//                             '$imageUrl',
//                             fit: BoxFit.contain,
//                             errorBuilder: (context, error, stackTrace) =>
//                                 Icon(Icons.image, size: 40, color: Colors.grey), // แสดงไอคอนแทนที่หากมีข้อผิดพลาด
//                           )
//                         : Icon(Icons.image, size: 40, color: Colors.grey), // ถ้าไม่มี URL รูปภาพจะใช้ไอคอนแทน
//                   ),
//                   SizedBox(width: 8),
//                   Text(
//                     name,
//                     style: TextStyle(
//                         fontWeight: FontWeight.bold, color: primaryColor),
//                   ),
//                 ],
//               ),
//               Text(
//                 status == 'Approved' ? 'Returned' : status,
//                 style: TextStyle(
//                   color: status == 'Disapproved'
//                       ? Colors.red
//                       : (status == 'Borrowed' ? Colors.orange : Colors.green),
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//             ],
//           ),
//         ),
//         Padding(
//           padding: const EdgeInsets.all(8.0),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               if (approver.isNotEmpty)
//                 Text('Coach: $approver',
//                     style: TextStyle(color: Colors.black)),
//               SizedBox(height: 8),
//               if (formattedBorrowedDate.isNotEmpty)
//                 Text('Borrowed Date: $formattedBorrowedDate'),
//               if (formattedReturnedDate.isNotEmpty)
//                 Text('Returned Date: $formattedReturnedDate'),
//             ],
//           ),
//         ),
//       ],
//     ),
//   );
// }
// }



import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

final Color primaryColor =
    Color(0xFF1A237E); // Dark blue color matching the theme
final TextStyle headingStyle =
    TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: primaryColor);

class HistoryStudentPage extends StatefulWidget {
  @override
  _HistoryStudentPageState createState() => _HistoryStudentPageState();
}

class _HistoryStudentPageState extends State<HistoryStudentPage> {
  String dropdownValue = 'All';
  String searchQuery = '';
  final ScrollController _historyScrollController = ScrollController();
  List<Map<String, dynamic>> historyData = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchStudentHistory();
  }

  @override
  void dispose() {
    _historyScrollController.dispose();
    super.dispose();
  }

  Future<void> fetchStudentHistory() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token =
        prefs.getString('token'); // Assuming token is used as userId

    if (token == null) {
      setState(() {
        isLoading = false;
      });
      return;
    }

    try {
      final response = await http.get(
        Uri.parse('http://192.168.1.6:3000/api/history/student/$token'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization':
              'Bearer $token', // Pass the token in the header for authentication
        },
      ).timeout(Duration(seconds: 20));

      if (response.statusCode == 200) {
        if (mounted) {
          setState(() {
            historyData =
                List<Map<String, dynamic>>.from(json.decode(response.body));
            isLoading = false;
          });
        }
      } else {
        print('Failed to load history, status code: ${response.statusCode}');
        if (mounted) {
          setState(() {
            isLoading = false;
          });
        }
      }
    } catch (e) {
      print('Error fetching student history: $e');
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredHistoryData = historyData.where((data) {
      bool matchesSearch = data['asset_name']
              ?.toLowerCase()
              .contains(searchQuery.toLowerCase()) ??
          false;
      bool matchesStatus = dropdownValue == 'All' ||
          (dropdownValue == 'Returned' && data['status'] == 'Approved') ||
          (dropdownValue == 'Disapproved' && data['status'] == 'Rejected') ||
          (dropdownValue == 'Pending' && data['status'] == 'Pending') ||
          data['status'] == dropdownValue;
      return matchesSearch && matchesStatus;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: Center(
            child: Text('SPORT APP',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontFamily: 'Arial',
                    fontSize: 28))),
        automaticallyImplyLeading: false,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : historyData.isEmpty
              ? Center(child: Text('No history data available'))
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('History', style: headingStyle),
                      SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: TextField(
                              decoration: InputDecoration(
                                hintText: 'Search',
                                prefixIcon: Icon(Icons.search),
                                filled: true,
                                fillColor: Colors.grey[200],
                                border: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(12.0)),
                                  borderSide: BorderSide.none,
                                ),
                                contentPadding: EdgeInsets.symmetric(
                                    vertical: 0, horizontal: 16.0),
                              ),
                              onChanged: (value) {
                                setState(() {
                                  searchQuery = value;
                                });
                              },
                            ),
                          ),
                          SizedBox(width: 8),
                          DropdownButton<String>(
                            value: dropdownValue,
                            icon: Icon(Icons.arrow_drop_down),
                            underline: SizedBox(),
                            items: <String>[
                              'All',
                              'Pending',
                              'Returned',
                              'Disapproved'
                            ].map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                            onChanged: (String? value) {
                              setState(() {
                                dropdownValue = value!;
                              });
                            },
                          ),
                        ],
                      ),
                      SizedBox(height: 16),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Scrollbar(
                            controller: _historyScrollController,
                            thumbVisibility: true,
                            thickness: 6.0,
                            radius: Radius.circular(12.0),
                            child: ListView.builder(
                              controller: _historyScrollController,
                              padding: EdgeInsets.only(right: 8.0),
                              itemCount: filteredHistoryData.length,
                              itemBuilder: (context, index) {
                                final data = filteredHistoryData[index];
                                return _buildHistoryCard(
                                  data['asset_name'] ?? '',
                                  data['borrow_date'] ?? '',
                                  data['return_date'] ?? '',
                                  data['status'] ?? '',
                                  data['asset_image'] ?? '',
                                  data['approver_name'] ?? '',
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }

  Widget _buildHistoryCard(String name, String borrowedDate, String returnedDate, String status, String imageUrl, String approver) {
    final DateFormat formatter = DateFormat('dd/MM/yyyy');
    String formattedBorrowedDate = borrowedDate.isNotEmpty
        ? formatter.format(DateTime.parse(borrowedDate))
        : '';
    String formattedReturnedDate = returnedDate.isNotEmpty
        ? formatter.format(DateTime.parse(returnedDate))
        : '';

    return Card(
      color: Colors.grey[200],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            color: Colors.grey[300],
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    SizedBox(
                      width: 40,
                      height: 40,
                      child: imageUrl.isNotEmpty
                          ? Image.asset(
                              '$imageUrl',
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) =>
                                  Icon(Icons.image, size: 40, color: Colors.grey), // Display an icon if image fails
                            )
                          : Icon(Icons.image, size: 40, color: Colors.grey), // Use icon if no URL
                    ),
                    SizedBox(width: 8),
                    Text(
                      name,
                      style: TextStyle(
                          fontWeight: FontWeight.bold, color: primaryColor),
                    ),
                  ],
                ),
                Text(
                  status,
                  style: TextStyle(
                    color: status == 'Disapproved' || status == 'Rejected'
                        ? Colors.red
                        : (status == 'Borrowed'
                            ? Colors.orange
                            : (status == 'Pending'
                                ? Color(0xFF007AFF)
                                : Colors.green)), // Adjust color for Borrowed status
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (approver.isNotEmpty)
                  Text('Coach: $approver', style: TextStyle(color: Colors.black)),
                SizedBox(height: 8),
                if (formattedBorrowedDate.isNotEmpty)
                  Text('Borrowed Date: $formattedBorrowedDate'),
                if (formattedReturnedDate.isNotEmpty)
                  Text('Returned Date: $formattedReturnedDate'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
