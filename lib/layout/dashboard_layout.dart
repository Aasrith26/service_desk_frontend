import 'package:flutter/material.dart';
import '../widgets/sidebar.dart';

class DashboardLayout extends StatefulWidget {
  final Widget child;
  final int selectedIndex;
  final ValueChanged<int> onItemSelected;

  const DashboardLayout({
    super.key, 
    required this.child,
    this.selectedIndex = 0,
    required this.onItemSelected,
  });

  @override
  State<DashboardLayout> createState() => _DashboardLayoutState();
}

class _DashboardLayoutState extends State<DashboardLayout> {
  bool _sidebarCollapsed = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50], // background color
      body: Row(
        children: [
          Sidebar(
            collapsed: _sidebarCollapsed,
            onCollapsedChanged: (collapsed) {
              setState(() {
                _sidebarCollapsed = collapsed;
              });
            },
            selectedIndex: widget.selectedIndex,
            onItemSelected: widget.onItemSelected,
          ),
          Expanded(
            child: widget.child,
          ),
        ],
      ),
    );
  }
}
