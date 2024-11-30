import 'package:flutter/material.dart';

class ShowAll extends StatefulWidget {
  const ShowAll({super.key});

  @override
  State<ShowAll> createState() => _ShowAllState();
}

class _ShowAllState extends State<ShowAll> {
  final List<Map<String, dynamic>> items = [
    {
      "id": "Distinct ID : 001",
      "name": "Football",
      "imagePath": 'assets/images/football.png',
      "status": "Available",
      "color": Color(0xFF2EA64E),
    },
    {
      "id": "Distinct ID : 002",
      "name": "Volleyball",
      "imagePath": 'assets/images/ball2.jpg',
      "status": "Disable",
      "color": Color(0xFFFF0000),
    },
    {
      "id": "Distinct ID : 003",
      "name": "Basketball",
      "imagePath": 'assets/images/ball3.jpg',
      "status": "Borrowed",
      "color": Color(0xFFE7C413),
    },
    {
      "id": "Distinct ID : 004",
      "name": "Badminton",
      "imagePath": 'assets/images/dd.jpg',
      "status": "Pending",
      "color": Color(0xFF007AFF),
    },
    {
      "id": "Distinct ID : 005",
      "name": "Tennis",
      "imagePath": 'assets/images/ball5.jpeg',
      "status": "Available",
      "color": Color(0xFF2EA64E),
    },
    {
      "id": "Distinct ID : 006",
      "name": "Rattan ball",
      "imagePath": 'assets/images/ball6.jpg',
      "status": "Disable",
      "color": Color(0xFFFF0000),
    },
    {
      "id": "Distinct ID : 007",
      "name": "Ping pong",
      "imagePath": 'assets/images/ball7.jpg',
      "status": "Borrowed",
      "color": Color(0xFFE7C413),
    },
    {
      "id": "Distinct ID : 008",
      "name": "Futsal ball",
      "imagePath": 'assets/images/ball8.jpg',
      "status": "Pending",
      "color": Color(0xFF007AFF),
    },
  ];

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
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, // Number of cards per row
            childAspectRatio: 0.6, // Aspect ratio for the cards
            crossAxisSpacing: 10, // Space between cards in a row
            mainAxisSpacing: 10, // Space between rows
          ),
          itemCount: items.length,
          itemBuilder: (context, index) {
            var item = items[index];

            return Card(
              color: const Color(0xFFF2F2F2),
              margin: EdgeInsets.all(5),
              child: Container(
                padding: const EdgeInsets.all(10.0),
                constraints: BoxConstraints(
                  maxHeight: 300, // Set max height for the card
                ),
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
                            return const Center(child: Text('Image not found'));
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
                      item["id"],
                      style: const TextStyle(
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Status: ',
                          style: TextStyle(color: Colors.black),
                        ),
                        Text(
                          item["status"],
                          style: TextStyle(color: item["color"]),
                        ),
                      ],
                    ),
                    const SizedBox(height: 60),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
