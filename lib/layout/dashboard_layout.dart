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
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // Breakpoints
  static const double mobileBreakpoint = 600;
  static const double tabletBreakpoint = 900;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.maxWidth;
        final isMobile = screenWidth < mobileBreakpoint;
        final isTablet = screenWidth >= mobileBreakpoint && screenWidth < tabletBreakpoint;

        // Auto-collapse sidebar on tablet
        if (isTablet && !_sidebarCollapsed) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) setState(() => _sidebarCollapsed = true);
          });
        }

        // Mobile: Use Drawer for sidebar
        if (isMobile) {
          return Scaffold(
            key: _scaffoldKey,
            backgroundColor: Colors.grey[50],
            appBar: AppBar(
              backgroundColor: Colors.white,
              elevation: 1,
              leading: IconButton(
                icon: const Icon(Icons.menu, color: Colors.blueGrey),
                onPressed: () => _scaffoldKey.currentState?.openDrawer(),
              ),
              title: const Text(
                'MediCare',
                style: TextStyle(
                  color: Colors.blueGrey,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
              centerTitle: true,
            ),
            drawer: Drawer(
              child: Sidebar(
                collapsed: false,
                onCollapsedChanged: (_) {},
                selectedIndex: widget.selectedIndex,
                onItemSelected: (index) {
                  widget.onItemSelected(index);
                  Navigator.of(context).pop(); // Close drawer after selection
                },
                isMobileDrawer: true,
              ),
            ),
            body: widget.child,
          );
        }

        // Tablet/Desktop: Use Row with sidebar
        return Scaffold(
          backgroundColor: Colors.grey[50],
          body: Row(
            children: [
              Sidebar(
                collapsed: _sidebarCollapsed,
                onCollapsedChanged: (collapsed) {
                  setState(() => _sidebarCollapsed = collapsed);
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
      },
    );
  }
}
