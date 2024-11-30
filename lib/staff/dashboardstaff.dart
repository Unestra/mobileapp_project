import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:http/http.dart' as http;
import 'package:myapp/Login.dart';
import 'dart:convert';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';

class Dashboard1 extends StatelessWidget {
  const Dashboard1({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
      ),
      home: const DashboardPage(),
    );
  }
}

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _buildHeader(context),
              const SizedBox(height: 40),
              const Expanded(child: AssetStatusChart()),
              const SizedBox(height: 50),
              const AssetLegend(),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        const Expanded(
          child: Text(
            'SPORT APP',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(width: 48), // Balance the title
      ],
    );
  }
}

class AssetStatusChart extends StatelessWidget {
  const AssetStatusChart({super.key});

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: PieChart(
        PieChartData(
          sectionsSpace: 0,
          centerSpaceRadius: 80,
          sections: _buildPieChartSections(),
        ),
      ),
    );
  }

  List<PieChartSectionData> _buildPieChartSections() {
    return [
      PieChartSectionData(value: 10, color: Colors.green, showTitle: false),
      PieChartSectionData(value: 4, color: Colors.yellow, showTitle: false),
      PieChartSectionData(value: 5, color: Colors.blue, showTitle: false),
      PieChartSectionData(value: 2, color: Colors.red, showTitle: false),
    ];
  }
}

class AssetLegend extends StatefulWidget {
  const AssetLegend({super.key});

  @override
  State<AssetLegend> createState() => _AssetLegendState();
}

class _AssetLegendState extends State<AssetLegend> {
  final String url = 'http://192.168.1.6:3000';
  bool isWaiting = false;
  String username = '';
  List? items;

  // Store the asset counts from the API response
  int availableAssets = 0;
  int pendingAssets = 0;
  int borrowedAssets = 0;
  int disabledAssets = 0;

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

  void getItem() async {
    setState(() {
      isWaiting = true;
    });
    try {
      // get JWT token from local storage
      final prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');

      if (token == null) {
        // no token, jump to login page
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const Login()),
        );
      }

      // token found
      // decode JWT to get username and role
      final jwt = JWT.decode(token!);
      Map payload = jwt.payload;

      // get expenses
      // Uri uri = Uri.http(url, '/api/dashboard');
      // http.Response response =
      //     await http.get(uri, headers: {'authorization': token}).timeout(
      //   const Duration(seconds: 10),
      // );
       Uri uri = Uri.parse('http://192.168.1.6:3000/api/dashboard');
      http.Response response =
          await http.get(uri, headers: {'authorization': 'Bearer $token'}).timeout(
        const Duration(seconds: 10),
      );
      // check server's response
      if (response.statusCode == 200) {
        // update username and asset counts from the response
        setState(() {
          username = payload['username'];
          Map<String, dynamic> data = jsonDecode(response.body);
          availableAssets = int.parse(data['available_assets']);
          pendingAssets = int.parse(data['pending_assets']);
          borrowedAssets = int.parse(data['borrowed_assets']);
          disabledAssets = int.parse(data['disabled_assets']);
        });
      } else {
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
    getItem();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            isWaiting
                ? const CircularProgressIndicator()
                : Text(
                    'Item Borrow',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
            SizedBox(height: 16),
            LegendItem(
              color: Colors.blue,
              label: 'Borrow Assets',
              value: borrowedAssets.toString(),
            ),
            SizedBox(height: 8),
            LegendItem(
              color: Colors.green,
              label: 'Available Assets',
              value: availableAssets.toString(),
            ),
            SizedBox(height: 8),
            LegendItem(
              color: Colors.red,
              label: 'Disabled Assets',
              value: disabledAssets.toString(),
            ),
            SizedBox(height: 8),
            LegendItem(
              color: Colors.yellow,
              label: 'Pending Assets',
              value: pendingAssets.toString(),
            ),
          ],
        ),
      ),
    );
  }
}

class LegendItem extends StatelessWidget {
  final Color color;
  final String label;
  final String value;

  const LegendItem({
    super.key,
    required this.color,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          color: color,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(fontSize: 16),
          ),
        ),
        const Text(':', style: TextStyle(fontSize: 16)),
        const SizedBox(width: 8),
        Text(
          value,
          style: const TextStyle(fontSize: 16),
        ),
      ],
    );
  }
}


















// import 'package:flutter/material.dart';
// import 'package:fl_chart/fl_chart.dart';

// final Color primaryColor = Color(0xFF1A237E); // Dark blue color matching the theme
// final TextStyle headingStyle = TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: primaryColor);
// final ButtonStyle buttonStyle = ElevatedButton.styleFrom(backgroundColor: primaryColor, textStyle: TextStyle(fontWeight: FontWeight.bold));


// class Dashboard1 extends StatelessWidget {
//   const Dashboard1({super.key});
  

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       theme: ThemeData(
//         useMaterial3: true,
//         colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
//       ),
//       home: const DashboardPage(),
//     );
//   }
// }

// class DashboardPage extends StatelessWidget {
//   const DashboardPage({super.key});
  

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: primaryColor,
//         title: Center(child: Text('SPORT APP', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontFamily: 'Arial', fontSize: 28))),
//         // leading: IconButton(
//         //   icon: Icon(Icons.arrow_back),
//         //   onPressed: () => Navigator.of(context).pop(),
//         // ),
//         automaticallyImplyLeading: false,
//       ),
//       body: SafeArea(
        
//         child: Padding(
//           padding: const EdgeInsets.all(16.0),
//           child: Column(
            
//             crossAxisAlignment: CrossAxisAlignment.center,
//             children: [
              
//               Row(
//                 children: [
//                   // IconButton(
//                   //   icon: const Icon(Icons.arrow_back),
//                   //   onPressed: () {
//                   //     Navigator.pop(context);
//                   //   },
//                   // ),
                  
//                   const SizedBox(width: 48), // Balance the title
//                 ],
//               ),
//               const SizedBox(height: 100),
//               const Expanded(
//                 child: AssetStatusChart(),
//               ),
//               const SizedBox(height: 100),
//                Text('Dashboard', style: headingStyle),
//               const AssetLegend(),
//               const Spacer(),
//               // Container(
//               //   decoration: BoxDecoration(
//               //     color: Colors.grey[100],
//               //     borderRadius: BorderRadius.circular(16),
//               //   ),
//               //   padding: const EdgeInsets.all(16),
//               //   child: Row(
//               //     mainAxisAlignment: MainAxisAlignment.spaceAround,
//               //     children: [
//               //       const NavBarItem(
//               //         icon: Icons.home,
//               //         label: 'Home',
//               //         isSelected: false,
//               //       ),
//               //       const NavBarItem(
//               //         icon: Icons.edit_note,
//               //         label: 'Edit',
//               //         isSelected: false,
//               //       ),
//               //       const NavBarItem(
//               //         icon: Icons.history,
//               //         label: 'History',
//               //         isSelected: false,
//               //       ),
//               //       NavBarItem(
//               //         icon: Icons.pie_chart,
//               //         label: 'Dashboard',
//               //         isSelected: true,
//               //         selectedColor: Colors.blue[300]!,
//               //       ),
//               //       const NavBarItem(
//               //         icon: Icons.person_outline,
//               //         label: 'Account',
//               //         isSelected: false,
//               //       ),
//               //     ],
//               //   ),
//               // ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// class AssetStatusChart extends StatelessWidget {
//   const AssetStatusChart({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return AspectRatio(
//       aspectRatio: 1,
//       child: PieChart(
//         PieChartData(
//           sectionsSpace: 0,
//           centerSpaceRadius: 80,
//           sections: [
//             PieChartSectionData(
//               value: 10, // Available Assets
//               color: Colors.green,
//               showTitle: false,
//             ),
//             PieChartSectionData(
//               value: 4, // Pending Assets
//               color: Colors.yellow,
//               showTitle: false,
//             ),
//             PieChartSectionData(
//               value: 5, // Borrow Assets
//               color: Colors.blue,
//               showTitle: false,
//             ),
//             PieChartSectionData(
//               value: 2, // Disabled Assets
//               color: Colors.red,
//               showTitle: false,
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// class AssetLegend extends StatelessWidget {
//   const AssetLegend({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Card(
//       child: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             const Text(
//               'Item Borrow',
//               style: TextStyle(
//                 fontSize: 18,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//             const SizedBox(height: 16),
//             LegendItem(
//               color: Colors.blue,
//               label: 'Borrow Assets',
//               value: '5',
//             ),
//             const SizedBox(height: 8),
//             LegendItem(
//               color: Colors.green,
//               label: 'Available Assets',
//               value: '10',
//             ),
//             const SizedBox(height: 8),
//             LegendItem(
//               color: Colors.red,
//               label: 'Disabled Assets',
//               value: '2',
//             ),
//             const SizedBox(height: 8),
//             LegendItem(
//               color: Colors.yellow,
//               label: 'Pending Assets',
//               value: '4',
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// class LegendItem extends StatelessWidget {
//   final Color color;
//   final String label;
//   final String value;

//   const LegendItem({
//     super.key,
//     required this.color,
//     required this.label,
//     required this.value,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Row(
//       children: [
//         Container(
//           width: 16,
//           height: 16,
//           color: color,
//         ),
//         const SizedBox(width: 8),
//         Expanded(
//           child: Text(
//             label,
//             style: const TextStyle(
//               fontSize: 16,
//             ),
//           ),
//         ),
//         const Text(
//           ':',
//           style: TextStyle(
//             fontSize: 16,
//           ),
//         ),
//         const SizedBox(width: 8),
//         Text(
//           value,
//           style: const TextStyle(
//             fontSize: 16,
//           ),
//         ),
//       ],
//     );
//   }
// }

// // class NavBarItem extends StatelessWidget {
// //   final IconData icon;
// //   final String label;
// //   final bool isSelected;
// //   final Color selectedColor;

// //   const NavBarItem({
// //     super.key,
// //     required this.icon,
// //     required this.label,
// //     required this.isSelected,
// //     this.selectedColor = Colors.blue,
// //   });

// //   @override
// //   Widget build(BuildContext context) {
// //     return Column(
// //       mainAxisSize: MainAxisSize.min,
// //       children: [
// //         Icon(
// //           icon,
// //           color: isSelected ? selectedColor : Colors.grey,
// //         ),
// //         const SizedBox(height: 4),
// //         Text(
// //           label,
// //           style: TextStyle(
// //             color: isSelected ? selectedColor : Colors.grey,
// //             fontSize: 12,
// //           ),
// //         ),
// //       ],
// //     );
// //   }
// // }
