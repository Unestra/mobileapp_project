import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

final Color primaryColor = Color(0xFF1A237E);
final TextStyle headingStyle =
    TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: primaryColor);
final ButtonStyle buttonStyle = ElevatedButton.styleFrom(
  foregroundColor: Colors.white,
  backgroundColor: primaryColor,
  textStyle: TextStyle(fontWeight: FontWeight.bold),
);

class HistoryStaffPage extends StatefulWidget {
  @override
  _HistoryStaffPageState createState() => _HistoryStaffPageState();
}

class _HistoryStaffPageState extends State<HistoryStaffPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String dropdownValue = 'All';
  String searchQuery = '';
  final ScrollController _historyScrollController = ScrollController();
  final ScrollController _returningAssetsScrollController = ScrollController();
  List<Map<String, dynamic>> historyData = [];
  List<Map<String, dynamic>> returningAssetsData = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    fetchStaffHistory();
    fetchReturningAssets();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _historyScrollController.dispose();
    _returningAssetsScrollController.dispose();
    super.dispose();
  }

  Future<void> fetchStaffHistory() async {
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
        Uri.parse('http://192.168.1.6:3000/api/history/staff/$token'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(Duration(seconds: 20));

      if (response.statusCode == 200) {
        setState(() {
          historyData =
              List<Map<String, dynamic>>.from(json.decode(response.body));
          isLoading = false;
        });
      } else {
        print('Failed to load history, status code: ${response.statusCode}');
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error fetching staff history: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> fetchReturningAssets() async {
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
        Uri.parse('http://192.168.1.6:3000/api/assets/returning'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(Duration(seconds: 20));

      if (response.statusCode == 200) {
        setState(() {
          returningAssetsData =
              List<Map<String, dynamic>>.from(json.decode(response.body));
          isLoading = false;
        });
      } else {
        print(
            'Failed to load returning assets, status code: ${response.statusCode}');
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error fetching returning assets: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredHistoryData = historyData.where((data) {
      bool matchesSearch = data['asset_name']
              ?.toString()
              .toLowerCase()
              .contains(searchQuery.toLowerCase()) ??
          false;
      bool matchesStatus = dropdownValue == 'All' ||
          (dropdownValue == 'Returned' && data['status'] == 'Approved') ||
          (dropdownValue == 'Disapproved' && data['status'] == 'Rejected') ||
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
                  fontSize: 28)),
        ),
        automaticallyImplyLeading: false,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                          'Borrowed',
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
                  TabBar(
                    controller: _tabController,
                    tabs: [
                      Tab(text: 'History'),
                      Tab(text: 'Returning Assets'),
                    ],
                  ),
                  SizedBox(height: 16),
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        _buildHistoryTab(filteredHistoryData),
                        _buildReturningAssetsTab(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildHistoryTab(List<Map<String, dynamic>> filteredHistoryData) {
    return Padding(
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
            return _buildStaffHistoryCard(
              data['asset_name']?.toString() ?? '',
              data['borrower']?.toString() ?? '',
              data['borrow_date']?.toString() ?? '',
              data['return_date']?.toString() ?? '',
              data['status']?.toString() ?? '',
              data['asset_image']?.toString() ?? '',
              data['approvedBy']?.toString() ?? '',
            );
          },
        ),
      ),
    );
  }

  Widget _buildReturningAssetsTab() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Scrollbar(
        controller: _returningAssetsScrollController,
        thumbVisibility: true,
        thickness: 6.0,
        radius: Radius.circular(12.0),
        child: ListView.builder(
          controller: _returningAssetsScrollController,
          padding: EdgeInsets.only(right: 8.0),
          itemCount: returningAssetsData.length,
          itemBuilder: (context, index) {
            final data = returningAssetsData[index];
            return _buildReturningAssetCard(
              data['asset_name']?.toString() ?? '',
              data['borrower']?.toString() ?? '',
              data['borrow_date']?.toString() ?? '',
              data['approvedBy']?.toString() ?? '',
              data['asset_image']?.toString() ?? '',
              data['asset_id']?.toString() ?? '',
              index,
            );
          },
        ),
      ),
    );
  }

  Widget _buildStaffHistoryCard(
      String name,
      String borrower,
      String borrowedDate,
      String returnedDate,
      String status,
      String imageUrl,
      String approvedBy) {
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
                                  Icon(Icons.image, size: 40),
                            )
                          : Icon(Icons.image, size: 40),
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
                  status == 'Approved' ? 'Returned' : status,
                  style: TextStyle(
                    color: status == 'Rejected'
                        ? Colors.red
                        : status == 'Pending'
                            ? Colors.blue
                            : (status == 'Borrowed'
                                ? Colors.orange
                                : Colors.green),
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
                Text('Borrower: $borrower',
                    style: TextStyle(color: Colors.black)),
                Text('Borrowed: $formattedBorrowedDate',
                    style: TextStyle(color: Colors.black)),
                if (formattedReturnedDate.isNotEmpty)
                  Text('Returned: $formattedReturnedDate',
                      style: TextStyle(color: Colors.black)),
                Text('Approved by: $approvedBy',
                    style: TextStyle(color: Colors.black)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReturningAssetCard(
      String name,
      String borrower,
      String borrowedDate,
      String approvedBy,
      String imageUrl,
      String assetId,
      int index) {
    final DateFormat formatter = DateFormat('dd/MM/yyyy');
    String formattedBorrowedDate = borrowedDate.isNotEmpty
        ? formatter.format(DateTime.parse(borrowedDate))
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
                                  Icon(Icons.image, size: 40),
                            )
                          : Icon(Icons.image, size: 40),
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
                  'Borrowed',
                  style: TextStyle(
                    color: Colors.orange,
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
                Text('Borrower: $borrower',
                    style: TextStyle(color: Colors.black)),
                Text('Borrowed: $formattedBorrowedDate',
                    style: TextStyle(color: Colors.black)),
                Text('Approved by: $approvedBy',
                    style: TextStyle(color: Colors.black)),
              ],
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: Padding(
              padding: const EdgeInsets.only(right: 16.0, bottom: 8.0),
              child: ElevatedButton(
                onPressed: () async {
                  SharedPreferences prefs =
                      await SharedPreferences.getInstance();
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        backgroundColor: Colors.grey[200],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        title: Text('Confirmation',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: primaryColor)),
                        content: Text(
                            'Do you want to mark this item as returned?',
                            style: TextStyle(color: Colors.black)),
                        actions: [
                          TextButton(
                            child: Text('Cancel',
                                style: TextStyle(color: primaryColor)),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                          TextButton(
                            child: Text('Yes',
                                style: TextStyle(color: primaryColor)),
                            onPressed: () async {
                              try {
                                final response = await http.put(
                                  Uri.parse(
                                      'http://192.168.1.6:3000/api/assets/return/$assetId'),
                                  headers: {
                                    'Content-Type': 'application/json',
                                    'Authorization':
                                        'Bearer ${prefs.getString('token')}',
                                  },
                                );

                                if (response.statusCode == 200) {
                                  Navigator.of(context).pop();
                                  await fetchReturningAssets();
                                  setState(() {});

                                  // Refresh the data instead of replacing the entire page
                                } else {
                                  print(
                                      'Failed to mark as returned, status code: ${response.statusCode}');
                                }
                              } catch (e) {
                                print('Error marking as returned: $e');
                              }
                            },
                          ),
                        ],
                      );
                    },
                  );
                },
                child: Text('Mark as returned'),
                style: buttonStyle,
              ),
            ),
          ),
        ],
      ),
    );
  }
}














// // Student History Page (history_staff.dart)
// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import 'package:intl/intl.dart';

// final Color primaryColor = Color(0xFF1A237E); // Dark blue color matching the theme
// final TextStyle headingStyle = TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: primaryColor);
// final ButtonStyle buttonStyle = ElevatedButton.styleFrom(
//   foregroundColor: Colors.white,
//   backgroundColor: primaryColor,
//   textStyle: TextStyle(fontWeight: FontWeight.bold),
// );

// class HistoryStaffPage extends StatefulWidget {
//   @override
//   _HistoryStaffPageState createState() => _HistoryStaffPageState();
// }

// class _HistoryStaffPageState extends State<HistoryStaffPage> with SingleTickerProviderStateMixin {
//   late TabController _tabController;
//   String dropdownValue = 'All';
//   String searchQuery = '';
//   final ScrollController _historyScrollController = ScrollController();
//   final ScrollController _returningAssetsScrollController = ScrollController();
//   List<Map<String, dynamic>> historyData = [];
//   List<Map<String, dynamic>> returningAssetsData = [];
//   bool isLoading = true;

//   @override
//   void initState() {
//     super.initState();
//     _tabController = TabController(length: 2, vsync: this);
//     fetchStaffHistory();
//     fetchReturningAssets();
//   }

//   @override
//   void dispose() {
//     _tabController.dispose();
//     _historyScrollController.dispose();
//     _returningAssetsScrollController.dispose();
//     super.dispose();
//   }

//   Future<void> fetchStaffHistory() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     String? userId = prefs.getString('userId');
//     print('User ID from SharedPreferences: $userId');

//     if (userId == null) {
//       setState(() {
//         isLoading = false;
//       });
//       return;
//     }

//     try {
//       final response = await http.get(
//         Uri.parse('http://192.168.1.134:3000/api/history/staff/$userId'),
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
//         print('Failed to load history, status code: ${response.statusCode}');
//         setState(() {
//           isLoading = false;
//         });
//       }
//     } catch (e) {
//       print('Error fetching staff history: $e');
//       setState(() {
//         isLoading = false;
//       });
//     }
//   }

//   Future<void> fetchReturningAssets() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     String? userId = prefs.getString('userId');
//     print('User ID from SharedPreferences: $userId');

//     if (userId == null) {
//       setState(() {
//         isLoading = false;
//       });
//       return;
//     }

//     try {
//       final response = await http.get(
//         Uri.parse('http://192.168.1.134:3000/api/assets/returning/staff/$userId'),
//         headers: {
//           'Content-Type': 'application/json',
//         },
//       ).timeout(Duration(seconds: 20));

//       if (response.statusCode == 200) {
//         setState(() {
//           returningAssetsData = List<Map<String, dynamic>>.from(json.decode(response.body));
//           isLoading = false;
//         });
//       } else {
//         print('Failed to load returning assets, status code: ${response.statusCode}');
//         setState(() {
//           isLoading = false;
//         });
//       }
//     } catch (e) {
//       print('Error fetching returning assets: $e');
//       setState(() {
//         isLoading = false;
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final filteredHistoryData = historyData.where((data) {
//       bool matchesSearch = data['asset_name']?.toString().toLowerCase().contains(searchQuery.toLowerCase()) ?? false;
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
//           : Padding(
//               padding: const EdgeInsets.all(16.0),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       Expanded(
//                         child: TextField(
//                           decoration: InputDecoration(
//                             hintText: 'Search',
//                             prefixIcon: Icon(Icons.search),
//                             filled: true,
//                             fillColor: Colors.grey[200],
//                             border: OutlineInputBorder(
//                               borderRadius: BorderRadius.all(Radius.circular(12.0)),
//                               borderSide: BorderSide.none,
//                             ),
//                             contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 16.0),
//                           ),
//                           onChanged: (value) {
//                             setState(() {
//                               searchQuery = value;
//                             });
//                           },
//                         ),
//                       ),
//                       SizedBox(width: 8),
//                       DropdownButton<String>(
//                         value: dropdownValue,
//                         icon: Icon(Icons.arrow_drop_down),
//                         underline: SizedBox(),
//                         items: <String>['All', 'Borrowed', 'Returned', 'Disapproved']
//                             .map<DropdownMenuItem<String>>((String value) {
//                           return DropdownMenuItem<String>(
//                             value: value,
//                             child: Text(value),
//                           );
//                         }).toList(),
//                         onChanged: (String? value) {
//                           setState(() {
//                             dropdownValue = value!;
//                           });
//                         },
//                       ),
//                     ],
//                   ),
//                   SizedBox(height: 16),
//                   TabBar(
//                     controller: _tabController,
//                     tabs: [
//                       Tab(text: 'History'),
//                       Tab(text: 'Returning Assets'),
//                     ],
//                   ),
//                   SizedBox(height: 16),
//                   Expanded(
//                     child: TabBarView(
//                       controller: _tabController,
//                       children: [
//                         _buildHistoryTab(filteredHistoryData),
//                         _buildReturningAssetsTab(),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//     );
//   }

//   Widget _buildHistoryTab(List<Map<String, dynamic>> filteredHistoryData) {
//     return Padding(
//       padding: const EdgeInsets.all(16.0),
//       child: Scrollbar(
//         controller: _historyScrollController,
//         thumbVisibility: true,
//         thickness: 6.0,
//         radius: Radius.circular(12.0),
//         child: ListView.builder(
//           controller: _historyScrollController,
//           padding: EdgeInsets.only(right: 8.0),
//           itemCount: filteredHistoryData.length,
//           itemBuilder: (context, index) {
//             final data = filteredHistoryData[index];
//             return _buildStaffHistoryCard(
//               data['asset_name']?.toString() ?? '',
//               data['borrower']?.toString() ?? '',
//               data['borrow_date']?.toString() ?? '',
//               data['return_date']?.toString() ?? '',
//               data['status']?.toString() ?? '',
//               data['asset_image']?.toString() ?? '',
//               data['approvedBy']?.toString() ?? '',
//             );
//           },
//         ),
//       ),
//     );
//   }

//   Widget _buildReturningAssetsTab() {
//     return Padding(
//       padding: const EdgeInsets.all(16.0),
//       child: Scrollbar(
//         controller: _returningAssetsScrollController,
//         thumbVisibility: true,
//         thickness: 6.0,
//         radius: Radius.circular(12.0),
//         child: ListView.builder(
//           controller: _returningAssetsScrollController,
//           padding: EdgeInsets.only(right: 8.0),
//           itemCount: returningAssetsData.length,
//           itemBuilder: (context, index) {
//             final data = returningAssetsData[index];
//             return _buildReturningAssetCard(
//               data['asset_name']?.toString() ?? '',
//               data['borrower']?.toString() ?? '',
//               data['borrow_date']?.toString() ?? '',
//               data['approvedBy']?.toString() ?? '',
//               data['asset_image']?.toString() ?? '',
//               data['asset_id']?.toString() ?? '',
//               index,
//             );
//           },
//         ),
//       ),
//     );
//   }

//   Widget _buildStaffHistoryCard(String name, String borrower, String borrowedDate, String returnedDate, String status, String imageUrl, String approvedBy) {
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
//                               errorBuilder: (context, error, stackTrace) =>
//                                   Icon(Icons.image, size: 40),
//                             )
//                           : Icon(Icons.image, size: 40),
//                     ),
//                     SizedBox(width: 8),
//                     Text(
//                       name,
//                       style: TextStyle(
//                           fontWeight: FontWeight.bold, color: primaryColor),
//                     ),
//                   ],
//                 ),
//                 Text(
//                   status == 'Approved' ? 'Returned' : status,
//                   style: TextStyle(
//                     color: status == 'Disapproved'
//                         ? Colors.red
//                         : (status == 'Borrowed' ? Colors.orange : Colors.green),
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
//                 if (formattedReturnedDate.isNotEmpty)
//                   Text('Returned: $formattedReturnedDate', style: TextStyle(color: Colors.black)),
//                 Text('Approved by: $approvedBy', style: TextStyle(color: Colors.black)),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildReturningAssetCard(String name, String borrower, String borrowedDate, String approvedBy, String imageUrl, String assetId, int index) {
//     final DateFormat formatter = DateFormat('dd/MM/yyyy');
//     String formattedBorrowedDate = borrowedDate.isNotEmpty ? formatter.format(DateTime.parse(borrowedDate)) : '';

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
//                               errorBuilder: (context, error, stackTrace) =>
//                                   Icon(Icons.image, size: 40),
//                             )
//                           : Icon(Icons.image, size: 40),
//                     ),
//                     SizedBox(width: 8),
//                     Text(
//                       name,
//                       style: TextStyle(
//                           fontWeight: FontWeight.bold, color: primaryColor),
//                     ),
//                   ],
//                 ),
//                 Text(
//                   'Borrowed',
//                   style: TextStyle(
//                     color: Colors.orange,
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
//                 Text('Approved by: $approvedBy', style: TextStyle(color: Colors.black)),
//               ],
//             ),
//           ),
//           Align(
//             alignment: Alignment.centerRight,
//             child: Padding(
//               padding: const EdgeInsets.only(right: 16.0, bottom: 8.0),
//               child: ElevatedButton(
//                 onPressed: () {
//                   showDialog(
//                     context: context,
//                     builder: (BuildContext context) {
//                       return AlertDialog(
//                         backgroundColor: Colors.grey[200],
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(12.0),
//                         ),
//                         title: Text('Confirmation',
//                             style: TextStyle(
//                                 fontWeight: FontWeight.bold,
//                                 color: primaryColor)),
//                         content: Text('Do you want to mark this item as returned?',
//                             style: TextStyle(color: Colors.black)),
//                         actions: [
//                           TextButton(
//                             child: Text('Cancel',
//                                 style: TextStyle(color: primaryColor)),
//                             onPressed: () {
//                               Navigator.of(context).pop();
//                             },
//                           ),
//                           TextButton(
//                             child: Text('Yes',
//                                 style: TextStyle(color: primaryColor)),
//                             onPressed: () async {
//                               try {
//                                 final response = await http.put(
//                                   Uri.parse('http://192.168.1.134:3000/api/assets/return/$assetId'),
//                                   headers: {
//                                     'Content-Type': 'application/json',
//                                   },
//                                 );

//                                 if (response.statusCode == 200) {
//                                   setState(() {
//                                     returningAssetsData.removeAt(index);
//                                   });
//                                   Navigator.of(context).pop();
//                                 } else {
//                                   print('Failed to mark as returned, status code: ${response.statusCode}');
//                                 }
//                               } catch (e) {
//                                 print('Error marking as returned: $e');
//                               }
//                             },
//                           ),
//                         ],
//                       );
//                     },
//                   );
//                 },
//                 child: Text('Mark as returned'),
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: primaryColor,
//                   foregroundColor: Colors.white,
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(8.0),
//                   ),
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
