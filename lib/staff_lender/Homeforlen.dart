
import 'package:flutter/material.dart';
import 'package:myapp/staff_lender/acclender.dart';
import 'package:myapp/staff_lender/dashboard.dart';
import 'package:myapp/staff_lender/history_lender.dart';
import 'package:myapp/staff_lender/list_lender.dart';
import 'package:myapp/staff_lender/status_lender.dart';

class LenderPage extends StatefulWidget {
  @override
  LenderPageState createState() => LenderPageState();
}

class LenderPageState extends State<LenderPage> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildScreen(_selectedIndex),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Color(0xFF01082D),
          borderRadius: BorderRadius.circular(16),
          
        ),
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            NavBarItem(
              icon: Icons.home,
              label: 'Home',
              isSelected: _selectedIndex == 0,
              onTap: () => _onItemTapped(0),
            ),
            NavBarItem(
              icon: Icons.approval,
              label: 'Aprove',
              isSelected: _selectedIndex == 1,
              onTap: () => _onItemTapped(1),
            ),
            NavBarItem(
              icon: Icons.history,
              label: 'History',
              isSelected: _selectedIndex == 2,
              onTap: () => _onItemTapped(2),
            ),
            NavBarItem(
              icon: Icons.pie_chart,
              label: 'Dashboard',
              isSelected: _selectedIndex == 3,
              onTap: () => _onItemTapped(3),
            ),
            NavBarItem(
              icon: Icons.person_outline,
              label: 'Account',
              isSelected: _selectedIndex == 4,
              onTap: () => _onItemTapped(4),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScreen(int index) {
    switch (index) {
      case 0:
        return ListLender();
      case 1:
        return StatusLender();
      case 2:
        return HistoryLenderPage();
      case 3:
        return Dashboard();
      case 4:
        return AccountLender();
      default:
        return Center(
          child: Text('Selected Index: $index'),
        );
    }
  }
}

class NavBarItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const NavBarItem({
    super.key,
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isSelected ? Colors.blue : Colors.grey,
            size: 28, // ขนาดของไอคอน
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.blue : Colors.grey,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
