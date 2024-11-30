import 'package:flutter/material.dart'; 
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class Borrow extends StatefulWidget {
  final String assetId;
  final String assetName;
  final String assetImage;
  final String assetStatus;
  final String assetDescription;

  const Borrow({
    super.key,
    required this.assetId,
    required this.assetName,
    required this.assetImage,
    required this.assetStatus,
    required this.assetDescription,
  });

  @override
  State<Borrow> createState() => _BorrowState();
}

class _BorrowState extends State<Borrow> {
  String _startDate = '';
  String _endDate = '';
  bool _isBorrowed = false;

  // Format date from DD/MM/YYYY to YYYY-MM-DD
  String formatDate(String date) {
    List<String> parts = date.split('/');
    return '${parts[2]}-${parts[1].padLeft(2, '0')}-${parts[0].padLeft(2, '0')}';
  }

  void selectStartDate() async {
    DateTime? dt = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2024, 12, 31),
    );

    if (dt != null) {
      setState(() {
        _startDate = '${dt.day}/${dt.month}/${dt.year}';
        _endDate = ''; // Reset end date when start date changes
      });
    }
  }

  void selectEndDate() async {
    DateTime? startDate = DateTime.now();
    if (_startDate.isNotEmpty) {
      List<String> parts = _startDate.split('/');
      startDate = DateTime(int.parse(parts[2]), int.parse(parts[1]), int.parse(parts[0]));
    }

    DateTime? dt = await showDatePicker(
      context: context,
      initialDate: startDate,
      firstDate: startDate,
      lastDate: DateTime(2024, 12, 31),
    );

    if (dt != null) {
      setState(() {
        _endDate = '${dt.day}/${dt.month}/${dt.year}';
      });
    }
  }

  Future<String?> getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  void borrowAsset() async {
    if (_startDate.isEmpty || _endDate.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select both start and end dates.')),
      );
      return;
    }

    String? token = await getToken();
    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('User is not authenticated. Please log in again.')),
      );
      return;
    }

    final url = 'http://192.168.1.6:3000/borrow';
    final body = json.encode({
      "asset_id": widget.assetId,
      "borrow_date": formatDate(_startDate),
      "return_date": formatDate(_endDate),
    });

    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: body,
    );

    if (response.statusCode == 201) {
      setState(() {
        _isBorrowed = true; // Hide button by updating state
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Borrow request submitted successfully!')),
      );
      Navigator.pop(context); // Optionally, go back after submitting
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to submit borrow request. Please try again later.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Center(
          child: Text(
            'SPORT APP',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        backgroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(30.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                child: Image.asset(widget.assetImage),
                height: 250,
                width: 250,
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Text(
                    widget.assetName,
                    style: const TextStyle(
                        fontSize: 25, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  const Text(
                    'Equipment status: ',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    widget.assetStatus,
                    style: TextStyle(
                        color: widget.assetStatus == 'Available'
                            ? Colors.green
                            : Colors.red,
                        fontSize: 18,
                        fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Info: ',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: Text(
                        widget.assetDescription,
                        style: const TextStyle(fontSize: 15),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Start Date',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 5),
                      GestureDetector(
                        onTap: selectStartDate,
                        child: SizedBox(
                          width: 180,
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF2F2F2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Center(
                              child: Text(
                                _startDate.isEmpty ? 'Select Date' : _startDate,
                                style: const TextStyle(fontSize: 15),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'End Date',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 5),
                      GestureDetector(
                        onTap: selectEndDate,
                        child: SizedBox(
                          width: 180,
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF2F2F2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Center(
                              child: Text(
                                _endDate.isEmpty ? 'Select Date' : _endDate,
                                style: const TextStyle(fontSize: 15),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // Conditionally render the BORROW button
              if (!_isBorrowed)
                ElevatedButton(
                  onPressed: borrowAsset,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.lightBlue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  ),
                  child: const Text(
                    'BORROW',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
