import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

final Color primaryColor = Color(0xFF1A237E);
final TextStyle headingStyle = TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: primaryColor);

class HistoryLenderPage extends StatefulWidget {
  @override
  _HistoryLenderPageState createState() => _HistoryLenderPageState();
}

class _HistoryLenderPageState extends State<HistoryLenderPage> {
  String searchQuery = '';
  String selectedStatus = 'All';
  final ScrollController _historyScrollController = ScrollController();
  List<Map<String, dynamic>> historyData = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchLenderHistory();
  }

  @override
  void dispose() {
    _historyScrollController.dispose();
    super.dispose();
  }

  Future<void> fetchLenderHistory() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    if (token == null) {
      setState(() {
        isLoading = false;
      });
      return;
    }

    try {
      final response = await http.get(
        Uri.parse('http://192.168.1.6:3000/api/history/lender/$token'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(Duration(seconds: 20));

      if (response.statusCode == 200) {
        setState(() {
          historyData = List<Map<String, dynamic>>.from(json.decode(response.body));
          isLoading = false;
        });
      } else {
        print('Failed to load history, status code: ${response.statusCode}');
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error fetching lender history: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredHistoryData = historyData.where((data) {
      bool matchesSearch = data['asset_name']?.toLowerCase().contains(searchQuery.toLowerCase()) ?? false;
      bool matchesStatus = selectedStatus == 'All' ||
          (selectedStatus == 'Approved' && data['status'] == 'Approved') ||
          (selectedStatus == 'Disapproved'  && data['status'] ==  'Rejected' );
      return matchesSearch && matchesStatus;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        automaticallyImplyLeading: false,
        title: Center(
          child: Text(
            'SPORT APP',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontFamily: 'Arial', fontSize: 28),
          ),
        ),
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
                                  borderRadius: BorderRadius.all(Radius.circular(12.0)),
                                  borderSide: BorderSide.none,
                                ),
                                contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 16.0),
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
                            value: selectedStatus,
                            icon: Icon(Icons.arrow_drop_down),
                            underline: SizedBox(),
                            items: <String>['All', 'Approved', 'Disapproved']
                                .map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                            onChanged: (String? newValue) {
                              setState(() {
                                selectedStatus = newValue!;
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
                                return _buildLenderHistoryCard(
                                  data['asset_name'] ?? '',
                                  data['borrower'] ?? '',
                                  data['borrow_date'] ?? '',
                                  data['return_date'] ?? '',
                                  data['status'] ?? '',
                                  data['asset_image'] ?? '',
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

  Widget _buildLenderHistoryCard(String name, String borrower, String borrowedDate, String returnedDate, String status, String imageUrl) {
    final DateFormat formatter = DateFormat('dd/MM/yyyy');
    String formattedBorrowedDate = borrowedDate.isNotEmpty ? formatter.format(DateTime.parse(borrowedDate)) : '';
    String formattedReturnedDate = returnedDate.isNotEmpty ? formatter.format(DateTime.parse(returnedDate)) : '';

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
                                Icon(Icons.image, size: 40, color: Colors.grey), // แสดงไอคอนแทนที่หากมีข้อผิดพลาด
                          )
                        : Icon(Icons.image, size: 40, color: Colors.grey),
                    ),
                    SizedBox(width: 8),
                    Text(
                      name,
                      style: TextStyle(fontWeight: FontWeight.bold, color: primaryColor),
                    ),
                  ],
                ),
                Text(
                  status,
                  style: TextStyle(
                    color: status == 'Disapproved' || status == 'Rejected' ? Colors.red : Colors.green,
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
                Text('Borrower: $borrower', style: TextStyle(color: Colors.black)),
                Text('Borrowed: $formattedBorrowedDate', style: TextStyle(color: Colors.black)),
                if (status == 'Approved' && formattedReturnedDate.isNotEmpty)
                  Text('Returned: $formattedReturnedDate', style: TextStyle(color: Colors.black)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}



// // Lender History Page (history_lender.dart)
// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import 'package:intl/intl.dart';

// final Color primaryColor = Color(0xFF1A237E);
// final TextStyle headingStyle = TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: primaryColor);

// class HistoryLenderPage extends StatefulWidget {
//   @override
//   _HistoryLenderPageState createState() => _HistoryLenderPageState();
// }

// class _HistoryLenderPageState extends State<HistoryLenderPage> {
//   String searchQuery = '';
//   String selectedStatus = 'All';
//   final ScrollController _historyScrollController = ScrollController();
//   List<Map<String, dynamic>> historyData = [];
//   bool isLoading = true;

//   @override
//   void initState() {
//     super.initState();
//     fetchLenderHistory();
//   }

//   @override
//   void dispose() {
//     _historyScrollController.dispose();
//     super.dispose();
//   }

//   Future<void> fetchLenderHistory() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     String? userId = prefs.getString('userId');
//     print('User ID from SharedPreferences: $userId');

//     if (userId == null) {
//       // Handle user not logged in
//       setState(() {
//         isLoading = false;
//       });
//       return;
//     }

//     try {
//       final response = await http.get(
//         Uri.parse('http://192.168.1.6:3000/api/history/lender/$userId'),
//         headers: {
//           'Content-Type': 'application/json',
//         },
//       ).timeout(Duration(seconds: 20));

//       if (response.statusCode == 200) {
//         setState(() {
//           historyData = List<Map<String, dynamic>>.from(json.decode(response.body));
//           isLoading = false;
//         });
//       } else {
//         // Handle error
//         print('Failed to load history, status code: ${response.statusCode}');
//         setState(() {
//           isLoading = false;
//         });
//       }
//     } catch (e) {
//       // Handle exception
//       print('Error fetching lender history: $e');
//       setState(() {
//         isLoading = false;
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final filteredHistoryData = historyData.where((data) {
//       bool matchesSearch = data['asset_name']?.toLowerCase().contains(searchQuery.toLowerCase()) ?? false;
//       bool matchesStatus = selectedStatus == 'All' ||
//           (selectedStatus == 'Approved' && data['status'] == 'Approved') ||
//           (selectedStatus == 'Disapproved' && data['status'] == 'Disapproved');
//       return matchesSearch && matchesStatus;
//     }).toList();

//     return Scaffold(
//       appBar: AppBar(
//         automaticallyImplyLeading: false,
//         backgroundColor: primaryColor,
//         title: Center(
//           child: Text(
//             'SPORT APP',
//             style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontFamily: 'Arial', fontSize: 28),
//           ),
//         ),
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
//                                   borderRadius: BorderRadius.all(Radius.circular(12.0)),
//                                   borderSide: BorderSide.none,
//                                 ),
//                                 contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 16.0),
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
//                             value: selectedStatus,
//                             icon: Icon(Icons.arrow_drop_down),
//                             underline: SizedBox(),
//                             items: <String>['All', 'Approved', 'Disapproved']
//                                 .map<DropdownMenuItem<String>>((String value) {
//                               return DropdownMenuItem<String>(
//                                 value: value,
//                                 child: Text(value),
//                               );
//                             }).toList(),
//                             onChanged: (String? newValue) {
//                               setState(() {
//                                 selectedStatus = newValue!;
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
//                                 return _buildLenderHistoryCard(
//                                   data['asset_name'] ?? '',
//                                   data['borrower'] ?? '',
//                                   data['borrow_date'] ?? '',
//                                   data['return_date'] ?? '',
//                                   data['status'] ?? '',
//                                   data['asset_image'] ?? '',
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

//   Widget _buildLenderHistoryCard(String name, String borrower, String borrowedDate, String returnedDate, String status, String imageUrl) {
//     final DateFormat formatter = DateFormat('dd/MM/yyyy');
//     String formattedBorrowedDate = borrowedDate.isNotEmpty ? formatter.format(DateTime.parse(borrowedDate)) : '';
//     String formattedReturnedDate = returnedDate.isNotEmpty ? formatter.format(DateTime.parse(returnedDate)) : '';

//     return Card(
//       color: Colors.grey[200],
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(12.0),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Container(
//             color: Colors.grey[300],
//             padding: const EdgeInsets.all(8.0),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Row(
//                   children: [
//                     SizedBox(
//                       width: 40,
//                       height: 40,
//                       child: imageUrl.isNotEmpty
//                           ? Image.network(
//                               'http://192.168.1.134:3000/images/$imageUrl',
//                               fit: BoxFit.contain,
//                               errorBuilder: (context, error, stackTrace) => Icon(Icons.image, size: 40),
//                             )
//                           : Icon(Icons.image, size: 40),
//                     ),
//                     SizedBox(width: 8),
//                     Text(
//                       name,
//                       style: TextStyle(fontWeight: FontWeight.bold, color: primaryColor),
//                     ),
//                   ],
//                 ),
//                 Text(
//                   status == 'Approved' ? 'Approved' : status,
//                   style: TextStyle(
//                     color: status == 'Disapproved' ? Colors.red : Colors.green,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           Padding(
//             padding: const EdgeInsets.all(8.0),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text('Borrower: $borrower', style: TextStyle(color: Colors.black)),
//                 Text('Borrowed: $formattedBorrowedDate', style: TextStyle(color: Colors.black)),
//                 if (status == 'Approved' && formattedReturnedDate.isNotEmpty)
//                   Text('Approved: $formattedReturnedDate', style: TextStyle(color: Colors.black)),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
