import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:myapp/Login.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'dart:convert';
import 'dart:async';

class StatusLender extends StatefulWidget {
  const StatusLender({super.key});

  @override
  State<StatusLender> createState() => _StatusLenderState();
}

class _StatusLenderState extends State<StatusLender> {
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

  final String url = 'http://192.168.1.6:3000';
  bool isWaiting = false;

  void popDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
        );
      },
    );
  }

  void getAssets() async {
    setState(() {
      isWaiting = true;
    });
    try {
      final prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');

      if (token == null) {
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const Login()),
        );
      }

      final jwt = JWT.decode(token!);

      Uri uri = Uri.parse('$url/assets');
      http.Response response = await http
          .get(uri, headers: {'authorization': 'Bearer $token'}).timeout(
        const Duration(seconds: 10),
      );

      if (response.statusCode == 200) {
        setState(() {
          final List<dynamic> data = json.decode(response.body);
          assets = data.map((item) {
            return {
              'asset_id': item['asset_id'],
              'asset_name': item['asset_name'],
              'asset_image': item['asset_image'] ?? 'assets/default_image.png',
              'assets_description': item['assets_description'],
            };
          }).toList();
        });
      } else {
        popDialog('Error', 'Failed to load assets: ${response.body}');
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
      final prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');

      if (token == null) {
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const Login()),
        );
      }

      final jwt = JWT.decode(token!);

      Uri uri = Uri.parse('$url/borrowrequests');
      http.Response response = await http
          .get(uri, headers: {'authorization': 'Bearer $token'}).timeout(
        const Duration(seconds: 10),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          sportRequests = data.map((item) {
            DateTime borrowDate = DateTime.parse(item['borrow_date']);
            DateTime returnDate = DateTime.parse(item['return_date']);

            var asset = assets.firstWhere(
              (asset) => asset['asset_id'] == item['asset_id'],
              orElse: () => {
                'asset_name': 'Unknown',
                'asset_image': 'assets/default_image.png',
                'assets_description': ''
              },
            );

            return {
              'icon': asset['asset_image'],
              'sport': asset['asset_name'],
              'userId': item['request_id'].toString(),
              'dateRange':
                  '${borrowDate.toLocal().toString().split(' ')[0]} - ${returnDate.toLocal().toString().split(' ')[0]}',
              'status': item['status'] ?? 'Pending',
              'asset_description': asset['assets_description'],
            };
          }).toList();
        });
      } else {
        popDialog('Error', 'Failed to load borrow requests: ${response.body}');
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
void approveRequest(int index) async {
  try {
    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Authorization token is missing!')),
      );
      return;
    }

    final requestId = sportRequests[index]['userId'];
    final approveUrl = Uri.parse('$url/approve/$requestId');

    // ส่งค่า status = 'Approved' ไปใน body ของ request
    final response = await http.post(
      approveUrl,
      headers: {
        'authorization': 'Bearer $token',
        'Content-Type': 'application/json' // ต้องบอกว่าข้อมูลที่ส่งเป็น JSON
      },
      body: json.encode({
        'status': 'Approved', // ส่ง status ไปด้วย
      }),
    );

    if (response.statusCode == 200) {
      setState(() {
        sportRequests[index]['status'] = 'Approved';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Request approved successfully!')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to approve the request: ${response.body}')),
      );
    }
  } catch (e) {
    debugPrint('Error approving request: $e');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('An error occurred while approving the request.')),
    );
  }
}

void disapproveRequest(int index) async {
  try {
    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Authorization token is missing!')),
      );
      return;
    }

    final requestId = sportRequests[index]['userId'];
    final disapproveUrl = Uri.parse('$url/approve/$requestId'); // ใช้ URL ที่ถูกต้อง

    // ส่งค่า status = 'Disapproved' ไปใน body ของ request
    final response = await http.post(
      disapproveUrl,
      headers: {
        'authorization': 'Bearer $token',
        'Content-Type': 'application/json' // ต้องบอกว่าข้อมูลที่ส่งเป็น JSON
      },
      body: json.encode({
        'status': 'Rejected', // ส่ง status ไปด้วย
      }),
    );

    if (response.statusCode == 200) {
      setState(() {
        sportRequests[index]['status'] = 'Disapproved';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Request disapproved successfully!')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to disapprove the request: ${response.body}')),
      );
    }
  } catch (e) {
    debugPrint('Error disapproving request: $e');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('An error occurred while disapproving the request.')),
    );
  }
}

  void showConfirmationDialog({
    required String title,
    required String content,
    required VoidCallback onConfirm,
  }) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('No', style: TextStyle(color: Colors.red)),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                onConfirm();
              },
              child: const Text('Yes', style: TextStyle(color: Colors.green)),
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    getAssets();
    getBorrowRequest();
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
        title: const Text('SPORT APP'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Status',
                      style:
                          TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                    ),
                    DropdownButton<String>(
                      value: selectedStatus,
                      items: <String>[
                        'All',
                        'Approved',
                        'Pending',
                        'Disapproved'
                      ].map<DropdownMenuItem<String>>((String value) {
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
                  onChanged: (query) {
                    setState(() {
                      searchQuery = query;
                    });
                  },
                  decoration: const InputDecoration(
                    labelText: 'Search',
                    hintText: 'Search by asset name',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                if (isWaiting)
                  const Center(child: CircularProgressIndicator())
                else if (filteredRequests.isEmpty)
                  const Center(child: Text('No requests found.'))
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: filteredRequests.length,
                    itemBuilder: (context, index) {
                      final request = filteredRequests[index];
                      return Card(
                        child: ListTile(
                          leading: Image.asset(
                            request['icon'],
                            width: 40,
                            height: 40,
                          ),
                          title: Text(request['sport']),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Date Range: ${request['dateRange']}'),
                              Text('Status: ${request['status']}'),
                            ],
                          ),
                          trailing: request['status'] == 'Pending'
                              ? Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.check,
                                          color: Colors.green),
                                      onPressed: () {
                                        showConfirmationDialog(
                                          title: 'Approve Request',
                                          content:
                                              'You want to approve this item?',
                                          onConfirm: () =>
                                              approveRequest(index),
                                        );
                                      },
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.close,
                                          color: Colors.red),
                                      onPressed: () {
                                        showConfirmationDialog(
                                          title: 'Disapprove Request',
                                          content:
                                              'You want to disapprove this item?',
                                          onConfirm: () =>
                                              disapproveRequest(index),
                                        );
                                      },
                                    ),
                                  ],
                                )
                              : Text(request['dateRange']),
                        ),
                      );
                    },
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
  