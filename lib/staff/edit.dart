import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart'; // สำหรับจัดการ path




class EditStaffPage extends StatefulWidget {
  final Map<String, dynamic>? item; // Optional item for editing

  const EditStaffPage({super.key, required this.item});

  @override
  _EditStaffPageState createState() => _EditStaffPageState();
}

class _EditStaffPageState extends State<EditStaffPage> {
  // Controllers for text fields
  late TextEditingController _nameController;
  late TextEditingController _infoController;
  late String _imagePath;  
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    // Initialize controllers with existing item data if available
    _nameController = TextEditingController(text: widget.item?["name"] ?? "");
    _infoController = TextEditingController(text: widget.item?["info"] ?? "");
    _imagePath = widget.item?["imagePath"] ?? 'assets/images/default.png';  // Default image
  }
  
  void extractFileName(String fullPath) {
  String fileName = basename(fullPath);
  print('file name: $fileName'); // ผลลัพธ์: football.png
}

Future<void> _pickFile() async {
  FilePickerResult? result = await FilePicker.platform.pickFiles(
    type: FileType.custom,
    allowedExtensions: ['jpg', 'jpeg', 'png','webp'],
  );

  if (result != null) {
    String? filePath = result.files.single.path;

    if (filePath != null) {
      // ดึงเฉพาะชื่อไฟล์
      String fileName = basename(filePath);
      print('select file: $fileName'); // football.png

      setState(() {
        _imagePath = 'assets/images/$fileName'; // ตั้ง path ใหม่
      });
    }
  }
  }

  // Function to delete the image
  Future<void> _deleteImage() async {
    setState(() {
      _imagePath = 'assets/images/default.png';  // Reset to default image
    });
  }

  @override
  void dispose() {
    // Clean up the controllers when the widget is disposed
    _nameController.dispose();
    _infoController.dispose();
    super.dispose();
  }

  // Function to update asset via API
  Future<void> updateAsset(BuildContext context) async {
    final assetId = widget.item?["id"];

    // Check if assetId is valid
    if (assetId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid Asset ID')),
      );
      return;
    }

    final extractedId = assetId.split(': ')[1]; // Extract the ID
    final url = Uri.parse('http://192.168.1.6:3000/edit/assets/${extractedId}');
    final body = json.encode({
      "asset_id": extractedId,
      "asset_name": _nameController.text,
      "asset_image": _imagePath,
      "assets_description": _infoController.text,
      
        // Updated image path
    });

    try {
      final response = await http.put(
        url,
        headers: {"Content-Type": "application/json"},
        body: body,
      );

      if (response.statusCode == 200) {
        final result = json.decode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['message'] ?? 'Update successful')),
        );
        Navigator.pop(context, {"success": true});
      } else {
        final error = json.decode(response.body);
        String errorMessage = error['message'] ?? 'Unknown error occurred';
        if (response.statusCode == 400) {
          errorMessage = error['message'] ?? 'Bad Request';
        } else if (response.statusCode == 404) {
          errorMessage = error['message'] ?? 'Asset not found';
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage)),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'SPORT APP',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context); // Navigate back
          },
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        titleTextStyle: const TextStyle(color: Colors.black, fontSize: 18),
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image Placeholder with Upload and Bin Icons Below
                Center(
                  child: Column(
                    children: [
                      Container(
                        height: 250,
                        width: 250,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Colors.grey[300],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: _imagePath.startsWith('assets/images')
                              ? Image.asset(
                                  _imagePath,  // Using the selected or default image
                                  fit: BoxFit.cover,
                                )
                              : Image.file(
                                  File(_imagePath),  // Load image from file system
                                  fit: BoxFit.cover,
                                ),
                        ),
                      ),
                      SizedBox(height: 8),
                      // Placeholder for Upload and Delete Icons
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            icon: Image.asset(
                              'assets/images/upload.png', // Path for upload icon
                              width: 30,
                              height: 30,
                            ),
                            onPressed: () {
                              _pickFile(); // Open the file picker
                            },
                          ),
                          SizedBox(width: 16),
                          IconButton(
                            icon: Image.asset(
                              'assets/images/bin.png', // Path for bin icon
                              width: 24,
                              height: 24,
                            ),
                            onPressed: () {
                              _deleteImage(); // Delete the selected image
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20),
                // Name Field Row
                _buildTextFieldRow("Name  :", _nameController, false),
                SizedBox(height: 20),
                // Info Field Row
                _buildTextFieldRow("Info      :", _infoController, true),
                SizedBox(height: 20),
              ],
            ),
          ),
          // Positioned "Edit" button in the bottom right corner
          Positioned(
            bottom: 20,
            right: 16,
            child: ElevatedButton(
              onPressed: () {
                _showConfirmationDialog(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                padding:
                    const EdgeInsets.symmetric(horizontal: 30, vertical: 16),
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(20)),
                ),
              ),
              child: const Text(
                'Edit',
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextFieldRow(
      String label, TextEditingController controller, bool isInfo) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 1,
          child: Text(label),
        ),
        Expanded(
          flex: 6,
          child: TextField(
            controller: controller,
            maxLines: isInfo ? 5 : 1,
            minLines: isInfo ? 3 : 1,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
            ),
          ),
        ),
      ],
    );
  }

  void _showConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Center(
            child: Text(
              'Do you want to edit this item?',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () {
                      Navigator.of(context).pop(); // Close dialog
                    },
                    child: const Text(
                      'Cancel',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ),
                Expanded(
                  child: TextButton(
                    onPressed: () {
                      updateAsset(context);
                      Navigator.of(context).pop();
                    },
                    child: const Text(
                      'Edit',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ),
              ],
            )
          ],
        );
      },
    );
  }
}
