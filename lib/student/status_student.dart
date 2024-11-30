// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:myapp/Login.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
// import 'dart:convert';
// import 'dart:async';

// class StatusStudent extends StatefulWidget {
//   const StatusStudent({super.key});

//   @override
//   State<StatusStudent> createState() => _StatusStudentState();
// }

// class _StatusStudentState extends State<StatusStudent> {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       theme: ThemeData(
//         useMaterial3: true,
//         colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
//       ),
//       home: const StatusPage(),
//     );
//   }
// }

// class StatusPage extends StatefulWidget {
//   const StatusPage({super.key});

//   @override
//   State<StatusPage> createState() => _StatusPageState();
// }

// class _StatusPageState extends State<StatusPage> {
//   List<Map<String, dynamic>> sportRequests = [];
//   List<Map<String, dynamic>> assets = [];
//   String searchQuery = '';
//   String selectedStatus = 'All';

//   final String url = 'http://192.168.1.6:3000';
//   bool isWaiting = false;

//   void popDialog(String title, String message) {
//     showDialog(
//         context: context,
//         builder: (context) {
//           return AlertDialog(
//             title: Text(title),
//             content: Text(message),
//           );
//         });
//   }

//   void getAssets() async {
//     setState(() {
//       isWaiting = true;
//     });
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       String? token = prefs.getString('token');

//       if (token == null) {
//         if (!mounted) return;
//         Navigator.pushReplacement(
//           context,
//           MaterialPageRoute(builder: (context) => const Login()),
//         );
//       }

//       final jwt = JWT.decode(token!);

//       Uri uri = Uri.parse('$url/assets');
//       http.Response response = await http
//           .get(uri, headers: {'authorization': 'Bearer $token'}).timeout(
//         const Duration(seconds: 10),
//       );

//       if (response.statusCode == 200) {
//         setState(() {
//           final List<dynamic> data = json.decode(response.body);
//           assets = data.map((item) {
//             return {
//               'asset_id': item['asset_id'],
//               'asset_name': item['asset_name'],
//               'asset_image': item['asset_image'] ?? 'assets/default_image.png',
//               'assets_description': item['assets_description'],
//             };
//           }).toList();
//         });
//       } else {
//         popDialog('Error', 'Failed to load assets: ${response.body}');
//       }
//     } on TimeoutException catch (e) {
//       debugPrint(e.message);
//       popDialog('Error', 'Timeout error, try again!');
//     } catch (e) {
//       debugPrint(e.toString());
//       popDialog('Error', 'Unknown error, try again!');
//     } finally {
//       setState(() {
//         isWaiting = false;
//       });
//     }
//   }

//   void getBorrowRequest() async {
//     setState(() {
//       isWaiting = true;
//     });
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       String? token = prefs.getString('token');

//       if (token == null) {
//         if (!mounted) return;
//         Navigator.pushReplacement(
//           context,
//           MaterialPageRoute(builder: (context) => const Login()),
//         );
//       }

//       final jwt = JWT.decode(token!);

//       Uri uri = Uri.parse('$url/borrowrequests');
//       http.Response response = await http
//           .get(uri, headers: {'authorization': 'Bearer $token'}).timeout(
//         const Duration(seconds: 10),
//       );

//       if (response.statusCode == 200) {
//         final List<dynamic> data = json.decode(response.body);
//         setState(() {
//           sportRequests = data.map((item) {
//             DateTime borrowDate = DateTime.parse(item['borrow_date']);
//             DateTime returnDate = DateTime.parse(item['return_date']);

//             var asset = assets.firstWhere(
//               (asset) => asset['asset_id'] == item['asset_id'],
//               orElse: () => {
//                 'asset_name': 'Unknown',
//                 'asset_image': 'assets/default_image.png',
//                 'assets_description': ''
//               },
//             );

//             return {
//               'icon': asset['asset_image'],
//               'sport': asset['asset_name'],
//               'userId': item['request_id'].toString(),
//               'dateRange':
//                   '${borrowDate.toLocal().toString().split(' ')[0]} - ${returnDate.toLocal().toString().split(' ')[0]}',
//               'status': item['status'] ?? 'Pending',
//               'asset_description': asset['assets_description'],
//             };
//           }).toList();
//         });
//       } else {
//         popDialog('Error', 'Failed to load borrow requests: ${response.body}');
//       }
//     } on TimeoutException catch (e) {
//       debugPrint(e.message);
//       popDialog('Error', 'Timeout error, try again!');
//     } catch (e) {
//       debugPrint(e.toString());
//       popDialog('Error', 'Unknown error, try again!');
//     } finally {
//       setState(() {
//         isWaiting = false;
//       });
//     }
//   }

//   @override
//   void initState() {
//     super.initState();
//     getAssets();
//     getBorrowRequest();
//   }

//   void cancelRequest(int index) async {
//   final requestId = sportRequests[index]['userId'];

//   await showDialog(
//     context: context,
//     builder: (BuildContext context) {
//       return AlertDialog(
//         content: Text('Do you want to "Cancel" this item?'),
//         actions: [
//           TextButton(
//             onPressed: () async {
//               Navigator.of(context).pop();

//               final cancelurl = Uri.parse('$url/cancel/$requestId');
//               final response = await http.delete(cancelurl);

//               print('Response status: ${response.statusCode}');
//               print('Response body: ${response.body}');

//               if (response.statusCode == 200) {
//                 setState(() {
//                   sportRequests.removeAt(index);
//                 });
//                 ScaffoldMessenger.of(context).showSnackBar(
//                   SnackBar(content: Text('Request cancelled successfully!')),
//                 );
//               } else {
//                 ScaffoldMessenger.of(context).showSnackBar(
//                   SnackBar(content: Text('Failed to cancel the request')),
//                 );
//               }
//             },
//             child: Text('OK', style: TextStyle(color: Colors.green)),
//           ),
//           TextButton(
//             onPressed: () {
//               Navigator.of(context).pop();
//             },
//             child: Text('Cancel', style: TextStyle(color: Colors.red)),
//           ),
//         ],
//       );
//     },
//   );
// }


//   @override
//   Widget build(BuildContext context) {
//     final filteredRequests = sportRequests.where((request) {
//       bool matchesSearch =
//           request['sport']!.toLowerCase().contains(searchQuery.toLowerCase());
//       bool matchesStatus =
//           selectedStatus == 'All' || request['status'] == selectedStatus;
//       return matchesSearch && matchesStatus;
//     }).toList();

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('SPORT APP'),
//         centerTitle: true,
//       ),
//       body: SafeArea(
//         child: Padding(
//           padding: const EdgeInsets.all(16.0),
//           child: SingleChildScrollView(
//             // Wrap Column in SingleChildScrollView
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     const Text(
//                       'Status',
//                       style:
//                           TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
//                     ),
//                     DropdownButton<String>(
//                       value: selectedStatus,
//                       items: <String>[
//                         'All',
//                         'Approved',
//                         'Pending',
//                         'Disapprove'
//                       ].map<DropdownMenuItem<String>>((String value) {
//                         return DropdownMenuItem<String>(
//                           value: value,
//                           child: Text(value),
//                         );
//                       }).toList(),
//                       onChanged: (String? newValue) {
//                         setState(() {
//                           selectedStatus = newValue!;
//                         });
//                       },
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 16),
//                 TextField(
//                   onChanged: (query) {
//                     setState(() {
//                       searchQuery = query;
//                     });
//                   },
//                   decoration: const InputDecoration(
//                     labelText: 'Search',
//                     hintText: 'Search by asset name',
//                     prefixIcon: Icon(Icons.search),
//                     border: OutlineInputBorder(),
//                   ),
//                 ),
//                 const SizedBox(height: 16),
//                 if (isWaiting)
//                   const Center(child: CircularProgressIndicator())
//                 else if (filteredRequests.isEmpty)
//                   const Center(child: Text('No requests found'))
//                 else
//                   ListView.builder(
//                     shrinkWrap:
//                         true, // Ensure the list is constrained within its size
//                     itemCount: filteredRequests.length,
//                     itemBuilder: (context, index) {
//                       final request = filteredRequests[index];
//                       return Card(
//                         elevation: 4,
//                         margin: const EdgeInsets.symmetric(vertical: 8),
//                         child: ListTile(
//                           leading: Image.asset(request['icon']),
//                           title: Text(
//                             request['sport'],
//                             style: TextStyle(fontWeight: FontWeight.bold),
//                           ),
//                           subtitle: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               SizedBox(height: 10,),
//                               Text(
//                                 request['asset_description'],
//                                 style: TextStyle(fontSize: 10),
//                               ),
//                             ],
//                           ),
//                           trailing: SingleChildScrollView(
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.center,
//                               children: [
//                                 Row(
//                                   mainAxisSize: MainAxisSize.min,
//                                   children: [
//                                     Text(
//                                       request['status']!,
//                                       style: TextStyle(
//                                           color: request['status'] == 'Approved'
//                                               ? Colors.green
//                                               : request['status'] ==
//                                                       'Rejected'
//                                                   ? Colors.red
//                                                   : Colors.orange,
//                                           fontSize: 15),
//                                     ),
//                                     if (request['status'] == 'Pending')
//                                     IconButton(
//                                           icon: Icon(Icons.delete,
//                                               color: Colors.red,),
//                                           onPressed: () {
//                                             cancelRequest(index);
//                                           },
//                                         ),
//                                   ],
//                                 ),
//                                 Text(request['dateRange']),
//                               ],
//                             ),
//                           ),
//                         ),
//                       );
//                     },
//                   ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }



// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:myapp/Login.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
// import 'dart:async';

// import 'dart:convert';

// class StatusStudent extends StatefulWidget {
//   const StatusStudent({super.key});

//   @override
//   State<StatusStudent> createState() => _StatusStudentState();
// }

// class _StatusStudentState extends State<StatusStudent> {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       theme: ThemeData(
//         useMaterial3: true,
//         colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
//       ),
//       home: const StatusPage(),
//     );
//   }
// }

// class StatusPage extends StatefulWidget {
//   const StatusPage({super.key});

//   @override
//   State<StatusPage> createState() => _StatusPageState();
// }

// class _StatusPageState extends State<StatusPage> {
//   List<Map<String, dynamic>> sportRequests = [];
//   List<Map<String, dynamic>> assets = [];
//   String searchQuery = '';
//   String selectedStatus = 'All';

//   final String url = '192.168.2.154:3000';
//   bool isWaiting = false;

//   void popDialog(String title, String message) {
//     showDialog(
//         context: context,
//         builder: (context) {
//           return AlertDialog(
//             title: Text(title),
//             content: Text(message),
//           );
//         });
//   }

//   void getAssets() async {
//     setState(() {
//       isWaiting = true;
//     });
//     try {
//       // get JWT token from local storage
//       final prefs = await SharedPreferences.getInstance();
//       String? token = prefs.getString('token');

//       if (token == null) {
//         // no token, jump to login page
//         // check mounted to use 'context' for navigation in 'async' method
//         if (!mounted) return;
//         // Cannot use only pushReplacement() because the dialog is showing
//         Navigator.pushReplacement(
//           context,
//           MaterialPageRoute(builder: (context) => const Login()),
//         );
//       }

//       // token found
//       // decode JWT to get uername and role
//       final jwt = JWT.decode(token!);

//       // get expenses
//       Uri uri = Uri.http(url, '/assets');
//       http.Response response =
//           await http.get(uri, headers: {'authorization': 'Bearer $token'}).timeout(
//         const Duration(seconds: 10),
//       );
//       // check server's response
//       if (response.statusCode == 200) {
//         // // show expenses in ListView
//         final List<dynamic> data = json.decode(response.body);
//         setState(() {
//           assets = data.map((item) {
//             return {
//               'asset_id': item['asset_id'],
//               'asset_name': item['asset_name'],
//               'asset_image': item['asset_image'],
//               'assets_description': item['assets_description'],
//             };
//           }).toList();
//         });
//       } else {
//         // wrong username or password
//         popDialog('Error', response.body);
//       }
//     } on TimeoutException catch (e) {
//       debugPrint(e.message);
//       popDialog('Error', 'Timeout error, try again!');
//     } catch (e) {
//       debugPrint(e.toString());
//       popDialog('Error', 'Unknown error, try again!');
//     } finally {
//       setState(() {
//         isWaiting = false;
//       });
//     }
//   }

//   void getBorrowRequest() async {
//     setState(() {
//       isWaiting = true;
//     });
//     try {
//       // get JWT token from local storage
//       final prefs = await SharedPreferences.getInstance();
//       String? token = prefs.getString('token');

//       if (token == null) {
//         // no token, jump to login page
//         // check mounted to use 'context' for navigation in 'async' method
//         if (!mounted) return;
//         // Cannot use only pushReplacement() because the dialog is showing
//         Navigator.pushReplacement(
//           context,
//           MaterialPageRoute(builder: (context) => const Login()),
//         );
//       }

//       // token found
//       // decode JWT to get uername and role
//       final jwt = JWT.decode(token!);

//       // get expenses
//       Uri uri = Uri.http(url, '/borrowrequestsforstu');
//       http.Response response =
//           await http.get(uri, headers: {'authorization': 'Bearer $token'}).timeout(
//         const Duration(seconds: 10),
//       );
//       // check server's response
//       if (response.statusCode == 200) {
//         final List<dynamic> data = json.decode(response.body);
//         setState(() {
//           sportRequests = data.map((item) {
//             DateTime borrowDate = DateTime.parse(item['borrow_date']);
//             DateTime returnDate = DateTime.parse(item['return_date']);
//             print('assets: $assets');
//             var asset = assets.firstWhere(
//               (asset) => asset['asset_id'] == item['asset_id'],
//               orElse: () => {
//                 'asset_name': 'Unknown',
//                 'asset_image': '',
//                 'assets_description': ''
//               },
//             );

//             return {
//               'icon': asset['asset_image'],
//               'sport': asset['asset_name'],
//               'userId':
//                   item['request_id'].toString(), // Assuming request_id here
//               'userName': 'User #${item['borrower_id']}',
//               'dateRange':
//                   '${borrowDate.toLocal().toString().split(' ')[0]} - ${returnDate.toLocal().toString().split(' ')[0]}',
//               'status': item['status'] ?? 'Pending',
//               'asset_description': asset['assets_description'],
//             };
//           }).toList();
//         });
//       } else {
//         // wrong username or password
//         popDialog('Error', response.body);
//       }
//     } on TimeoutException catch (e) {
//       debugPrint(e.message);
//       popDialog('Error', 'Timeout error, try again!');
//     } catch (e) {
//       debugPrint(e.toString());
//       popDialog('Error', 'Unknown error, try again!');
//     } finally {
//       setState(() {
//         isWaiting = false;
//       });
//     }
//   }

//   @override
//   void initState() {
//     super.initState();
//     // fetchAssets();
//     // fetchSportRequests();
//        getAssets(); 
//        getBorrowRequest();

//   }

//   // Future<void> fetchAssets() async {
//   //   try {
//   //     final response =
//   //         await http.get(Uri.parse('http://192.168.1.6:3000/assets'));

//   //     if (response.statusCode == 200) {
//   //       final List<dynamic> data = json.decode(response.body);
//   //       setState(() {
//   //         assets = data.map((item) {
//   //           return {
//   //             'asset_id': item['asset_id'],
//   //             'asset_name': item['asset_name'],
//   //             'asset_image': item['asset_image'],
//   //             'assets_description': item['assets_description'],
//   //           };
//   //         }).toList();
//   //       });
//   //     } else {
//   //       throw Exception('Failed to load assets');
//   //     }
//   //   } catch (e) {
//   //     print('Error fetching assets: $e');
//   //   }
//   // }

//   // Future<void> fetchSportRequests() async {
//   //   try {
//   //     final response =
//   //         await http.get(Uri.parse('http://192.168.1.6:3000/borrowrequests'));

//   //     if (response.statusCode == 200) {
//   //       final List<dynamic> data = json.decode(response.body);
//   //       setState(() {
//   //         sportRequests = data.map((item) {
//   //           DateTime borrowDate = DateTime.parse(item['borrow_date']);
//   //           DateTime returnDate = DateTime.parse(item['return_date']);

//   //           var asset = assets.firstWhere(
//   //             (asset) => asset['asset_id'] == item['asset_id'],
//   //             orElse: () => {
//   //               'asset_name': 'Unknown',
//   //               'asset_image': '',
//   //               'assets_description': ''
//   //             },
//   //           );

//   //           return {
//   //             'icon': asset['asset_image'],
//   //             'sport': asset['asset_name'],
//   //             'userId':
//   //                 item['request_id'].toString(), // Assuming request_id here
//   //             'userName': 'User #${item['borrower_id']}',
//   //             'dateRange':
//   //                 '${borrowDate.toLocal().toString().split(' ')[0]} - ${returnDate.toLocal().toString().split(' ')[0]}',
//   //             'status': item['status'] ?? 'Pending',
//   //             'asset_description': asset['assets_description'],
//   //           };
//   //         }).toList();
//   //       });
//   //     } else {
//   //       throw Exception('Failed to load requests');
//   //     }
//   //   } catch (e) {
//   //     print('Error fetching requests: $e');
//   //   }
//   // }

//   // Cancel the request (delete it)
//   void cancelRequest(int index) async {
//     final requestId =
//         sportRequests[index]['userId']; // Use 'userId' as 'request_id'

//     await showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           content: Text('Do you want to "Cancel" this item?'),
//           actions: [
//             TextButton(
//               onPressed: () async {
//                 Navigator.of(context).pop();

//                 // Send the DELETE request to backend
//                 final url =
//                     Uri.parse('http://192.168.1.6:3000/cancle/$requestId');
//                 final response = await http.delete(url);

//                 if (response.statusCode == 200) {
//                   setState(() {
//                     sportRequests
//                         .removeAt(index); // Remove the request from the list
//                   });
//                   ScaffoldMessenger.of(context).showSnackBar(
//                     SnackBar(content: Text('Request cancelled successfully!')),
//                   );
//                 } else {
//                   ScaffoldMessenger.of(context).showSnackBar(
//                     SnackBar(content: Text('Failed to cancel the request')),
//                   );
//                 }
//               },
//               child: Text(
//                 'OK',
//                 style: TextStyle(color: Colors.green),
//               ),
//             ),
//             TextButton(
//               onPressed: () {
//                 Navigator.of(context).pop();
//               },
//               child: Text(
//                 'Cancel',
//                 style: TextStyle(color: Colors.red),
//               ),
//             ),
//           ],
//         );
//       },
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final filteredRequests = sportRequests.where((request) {
//       bool matchesSearch =
//           request['sport']!.toLowerCase().contains(searchQuery.toLowerCase());
//       bool matchesStatus =
//           selectedStatus == 'All' || request['status'] == selectedStatus;
//       return matchesSearch && matchesStatus;
//     }).toList();

//     return Scaffold(
//       appBar: AppBar(
//         title: Text('SPORT APP'),
//         centerTitle: true,
//       ),
//       body: SafeArea(
//         child: Padding(
//           padding: const EdgeInsets.all(16.0),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   const Text(
//                     'Status',
//                     style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
//                   ),
//                   DropdownButton<String>(
//                     value: selectedStatus,
//                     items: <String>['All', 'Approved', 'Pending', 'Disapprove']
//                         .map<DropdownMenuItem<String>>((String value) {
//                       return DropdownMenuItem<String>(
//                         value: value,
//                         child: Text(value),
//                       );
//                     }).toList(),
//                     onChanged: (String? newValue) {
//                       setState(() {
//                         selectedStatus = newValue!;
//                       });
//                     },
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 16),
//               TextField(
//                 decoration: InputDecoration(
//                   labelText: 'Search',
//                   prefixIcon: Icon(Icons.search),
//                   border: OutlineInputBorder(),
//                 ),
//                 onChanged: (value) {
//                   setState(() {
//                     searchQuery = value; // Update search query
//                   });
//                 },
//               ),
//               const SizedBox(height: 16),
//               Expanded(
//                 child: ListView.builder(
//                   itemCount: filteredRequests.length,
//                   itemBuilder: (context, index) {
//                     final request = filteredRequests[index];
//                     return SportRequestCard(
//                       icon: request['icon']!,
//                       sport: request['sport']!,
//                       dateRange: request['dateRange']!,
//                       status: request['status']!,
//                       assetDescription: request['asset_description']!,
//                       onCancel: () =>
//                           cancelRequest(index), // Pass the index here
//                     );
//                   },
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// class SportRequestCard extends StatelessWidget {
//   final String icon;
//   final String sport;
//   final String dateRange;
//   final String status;
//   final String assetDescription;
//   final VoidCallback onCancel;

//   const SportRequestCard({
//     super.key,
//     required this.icon,
//     required this.sport,
//     required this.dateRange,
//     required this.status,
//     required this.assetDescription,
//     required this.onCancel,
//   });

//   @override
//   Widget build(BuildContext context) {
//     Color statusColor;

//     if (status == 'Approved') {
//       statusColor = Colors.green;
//     } else if (status == 'Pending') {
//       statusColor = Colors.orange;
//     } else if (status == 'Disapprove') {
//       statusColor = Colors.red;
//     } else {
//       statusColor = Colors.black; // Default color
//     }

//     return Card(
//       elevation: 4,
//       margin: const EdgeInsets.only(bottom: 12),
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Row(
//           children: [
//             const SizedBox(width: 16),
//             Expanded(
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Image.asset(
//                     icon,
//                     height: 50,
//                   ),
//                   Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         sport,
//                         style: const TextStyle(
//                           fontSize: 18,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                       const SizedBox(height: 4),
//                       Text(
//                         dateRange,
//                         style: const TextStyle(fontSize: 14),
//                       ),
//                     ],
//                   ),
//                   Row(
//                     children: [
//                       Text(
//                         status,
//                         style: TextStyle(
//                           color: statusColor,
//                           fontWeight: FontWeight.w500,
//                         ),
//                       ),
//                       if (status == 'Pending') ...[
//                         IconButton(
//                           icon: Icon(Icons.delete_outline),
//                           color: Colors.red,
//                           onPressed: onCancel,
//                         ),
//                       ],
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:myapp/Login.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'dart:async';
import 'dart:convert';

class StatusStudent extends StatefulWidget {
  const StatusStudent({super.key});

  @override
  State<StatusStudent> createState() => _StatusStudentState();
}

class _StatusStudentState extends State<StatusStudent> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
      ),
      home: const StatusPage(),
    );
  }
}

class StatusPage extends StatefulWidget {
  const StatusPage({super.key});

  @override
  State<StatusPage> createState() => _StatusPageState();
}

class _StatusPageState extends State<StatusPage> {
  List<Map<String, dynamic>> sportRequests = [];
  List<Map<String, dynamic>> assets = [];
  String searchQuery = '';
  String selectedStatus = 'All';

  final String url = '192.168.1.6:3000';
  bool isWaiting = false;

  void popDialog(String title, String message) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(title),
            content: Text(message),
          );
        });
  }

  void getAssets() async {
    setState(() {
      isWaiting = true;
    });
    try {
      // get JWT token from local storage
      final prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');

      if (token == null) {
        // no token, jump to login page
        // check mounted to use 'context' for navigation in 'async' method
        if (!mounted) return;
        // Cannot use only pushReplacement() because the dialog is showing
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const Login()),
        );
      }

      // token found
      // decode JWT to get uername and role
      final jwt = JWT.decode(token!);

      // get expenses
      Uri uri = Uri.http(url, '/assets');
      http.Response response =
          await http.get(uri, headers: {'authorization': token}).timeout(
        const Duration(seconds: 10),
      );
      // check server's response
      if (response.statusCode == 200) {
        // // show expenses in ListView
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          assets = data.map((item) {
            return {
              'asset_id': item['asset_id'],
              'asset_name': item['asset_name'],
              'asset_image': item['asset_image'],
              'assets_description': item['assets_description'],
            };
          }).toList();
        });
      } else {
        // wrong username or password
        popDialog('Error', response.body);
      }
    } on TimeoutException catch (e) {
      debugPrint(e.message);
      popDialog('Error', 'Timeout error, try again!');
    } catch (e) {
      debugPrint(e.toString());
      popDialog('Error', 'Unknown error, try again!');
    } finally {
      setState(() {
        isWaiting = false;
      });
    }
  }

  void getBorrowRequest() async {
    setState(() {
      isWaiting = true;
    });
    try {
      // get JWT token from local storage
      final prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');

      if (token == null) {
        // no token, jump to login page
        // check mounted to use 'context' for navigation in 'async' method
        if (!mounted) return;
        // Cannot use only pushReplacement() because the dialog is showing
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const Login()),
        );
      }

      // token found
      // decode JWT to get uername and role
      final jwt = JWT.decode(token!);

      // get expenses
      Uri uri = Uri.http(url, '/borrowrequestsforstu');
      http.Response response =
          await http.get(uri, headers: {'authorization': token}).timeout(
        const Duration(seconds: 10),
      );
      // check server's response
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          sportRequests = data.map((item) {
            DateTime borrowDate = DateTime.parse(item['borrow_date']);
            DateTime returnDate = DateTime.parse(item['return_date']);
            print('assets: $assets');
            var asset = assets.firstWhere(
              (asset) => asset['asset_id'] == item['asset_id'],
              orElse: () => {
                'asset_name': 'Unknown',
                'asset_image': '',
                'assets_description': ''
              },
            );

            return {
              'icon': asset['asset_image'],
              'sport': asset['asset_name'],
              'userId':
                  item['request_id'].toString(), // Assuming request_id here
              'userName': 'User #${item['borrower_id']}',
              'dateRange':
                  '${borrowDate.toLocal().toString().split(' ')[0]} - ${returnDate.toLocal().toString().split(' ')[0]}',
              'status': item['status'] ?? 'Pending',
              'asset_description': asset['assets_description'],
            };
          }).toList();
        });
      } else {
        // wrong username or password
        popDialog('Error', response.body);
      }
    } on TimeoutException catch (e) {
      debugPrint(e.message);
      popDialog('Error', 'Timeout error, try again!');
    } catch (e) {
      debugPrint(e.toString());
      popDialog('Error', 'Unknown error, try again!');
    } finally {
      setState(() {
        isWaiting = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    // fetchAssets();
    // fetchSportRequests();
     getAssets(); 
    getBorrowRequest();
  
  }

  // Future<void> fetchAssets() async {
  //   try {
  //     final response =
  //         await http.get(Uri.parse('http://192.168.1.6:3000/assets'));

  //     if (response.statusCode == 200) {
  //       final List<dynamic> data = json.decode(response.body);
  //       setState(() {
  //         assets = data.map((item) {
  //           return {
  //             'asset_id': item['asset_id'],
  //             'asset_name': item['asset_name'],
  //             'asset_image': item['asset_image'],
  //             'assets_description': item['assets_description'],
  //           };
  //         }).toList();
  //       });
  //     } else {
  //       throw Exception('Failed to load assets');
  //     }
  //   } catch (e) {
  //     print('Error fetching assets: $e');
  //   }
  // }

  // Future<void> fetchSportRequests() async {
  //   try {
  //     final response =
  //         await http.get(Uri.parse('http://192.168.1.6:3000/borrowrequests'));

  //     if (response.statusCode == 200) {
  //       final List<dynamic> data = json.decode(response.body);
  //       setState(() {
  //         sportRequests = data.map((item) {
  //           DateTime borrowDate = DateTime.parse(item['borrow_date']);
  //           DateTime returnDate = DateTime.parse(item['return_date']);

  //           var asset = assets.firstWhere(
  //             (asset) => asset['asset_id'] == item['asset_id'],
  //             orElse: () => {
  //               'asset_name': 'Unknown',
  //               'asset_image': '',
  //               'assets_description': ''
  //             },
  //           );

  //           return {
  //             'icon': asset['asset_image'],
  //             'sport': asset['asset_name'],
  //             'userId':
  //                 item['request_id'].toString(), // Assuming request_id here
  //             'userName': 'User #${item['borrower_id']}',
  //             'dateRange':
  //                 '${borrowDate.toLocal().toString().split(' ')[0]} - ${returnDate.toLocal().toString().split(' ')[0]}',
  //             'status': item['status'] ?? 'Pending',
  //             'asset_description': asset['assets_description'],
  //           };
  //         }).toList();
  //       });
  //     } else {
  //       throw Exception('Failed to load requests');
  //     }
  //   } catch (e) {
  //     print('Error fetching requests: $e');
  //   }
  // }

  // Cancel the request (delete it)
  void cancelRequest(int index) async {
    final requestId =
        sportRequests[index]['userId']; // Use 'userId' as 'request_id'

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Text('Do you want to "Cancel" this item?'),
          actions: [
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();

                // Send the DELETE request to backend
                final url =
                    Uri.parse('http://192.168.1.6:3000/cancle/$requestId');
                final response = await http.delete(url);

                if (response.statusCode == 200) {
                  setState(() {
                    sportRequests
                        .removeAt(index); // Remove the request from the list
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Request cancelled successfully!')),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to cancel the request')),
                  );
                }
              },
              child: Text(
                'OK',
                style: TextStyle(color: Colors.green),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'Cancel',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredRequests = sportRequests.where((request) {
      bool matchesSearch =
          request['sport']!.toLowerCase().contains(searchQuery.toLowerCase());
      bool matchesStatus =
          selectedStatus == 'All' || request['status'] == selectedStatus;
      return matchesSearch && matchesStatus;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text('SPORT APP'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Status',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                  DropdownButton<String>(
                    value: selectedStatus,
                    items: <String>['All', 'Approved', 'Pending', 'Disapprove']
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
              const SizedBox(height: 16),
              TextField(
                decoration: InputDecoration(
                  labelText: 'Search',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  setState(() {
                    searchQuery = value; // Update search query
                  });
                },
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  itemCount: filteredRequests.length,
                  itemBuilder: (context, index) {
                    final request = filteredRequests[index];
                    return SportRequestCard(
                      icon: request['icon']!,
                      sport: request['sport']!,
                      dateRange: request['dateRange']!,
                      status: request['status']!,
                      assetDescription: request['asset_description']!,
                      onCancel: () =>
                          cancelRequest(index), // Pass the index here
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SportRequestCard extends StatelessWidget {
  final String icon;
  final String sport;
  final String dateRange;
  final String status;
  final String assetDescription;
  final VoidCallback onCancel;

  const SportRequestCard({
    super.key,
    required this.icon,
    required this.sport,
    required this.dateRange,
    required this.status,
    required this.assetDescription,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    Color statusColor;

    if (status == 'Approved') {
      statusColor = Colors.green;
    } else if (status == 'Pending') {
      statusColor = Colors.orange;
    } else if (status == 'Disapprove') {
      statusColor = Colors.red;
    } else {
      statusColor = Colors.black; // Default color
    }

    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const SizedBox(width: 16),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Image.asset(
                    icon,
                    height: 50,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        sport,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        dateRange,
                        style: const TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Text(
                        status,
                        style: TextStyle(
                          color: statusColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      if (status == 'Pending') ...[
                        IconButton(
                          icon: Icon(Icons.delete_outline),
                          color: Colors.red,
                          onPressed: onCancel,
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}