import 'package:flutter/material.dart';

class Sidebar extends StatelessWidget {
  final bool collapsed;
  final ValueChanged<bool> onCollapsedChanged;
  final int selectedIndex;
  final ValueChanged<int> onItemSelected;
  final bool isMobileDrawer;

  const Sidebar({
    super.key,
    required this.collapsed,
    required this.onCollapsedChanged,
    required this.selectedIndex,
    required this.onItemSelected,
    this.isMobileDrawer = false,
  });

  @override
  Widget build(BuildContext context) {
    // In mobile drawer mode, use full width and don't animate
    final sidebarWidth = isMobileDrawer ? 280.0 : (collapsed ? 80.0 : 256.0);
    
    return AnimatedContainer(
      duration: isMobileDrawer ? Duration.zero : const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      width: sidebarWidth,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          right: BorderSide(color: Colors.grey.withOpacity(0.3)),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 1,
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          SizedBox(
            height: 64,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: collapsed
                    ? MainAxisAlignment.center
                    : MainAxisAlignment.spaceBetween,
                children: [
                  Theme(
                    data: ThemeData(primaryColor: Colors.blue), // Placeholder for primary color
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFF00BFA5).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.monitor_heart, color: Color(0xFF00BFA5)),
                        ),
                        if (!collapsed) ...[
                          const SizedBox(width: 12),
                          const Text(
                            "MediCare",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (!collapsed)
                    IconButton(
                      icon: const Icon(Icons.chevron_left, color: Colors.grey),
                      onPressed: () => onCollapsedChanged(!collapsed),
                      splashRadius: 20,
                    ),
                ],
              ),
            ),
          ),
          if (collapsed)
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: IconButton(
                icon: const Icon(Icons.menu, color: Colors.grey),
                onPressed: () => onCollapsedChanged(!collapsed),
              ),
            ),

          const Divider(height: 1),
          const SizedBox(height: 16),

          // Navigation
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Column(
                children: [
                  _NavItem(
                    icon: Icons.dashboard,
                    label: "Dashboard",
                    collapsed: collapsed,
                    active: selectedIndex == 0,
                    onTap: () => onItemSelected(0),
                  ),
                  const SizedBox(height: 8),
                  _NavItem(
                    icon: Icons.call,
                    label: "Call Logs",
                    collapsed: collapsed,
                    active: selectedIndex == 1,
                    onTap: () => onItemSelected(1),
                  ),
                  const SizedBox(height: 8),
                  _NavItem(
                    icon: Icons.calendar_month,
                    label: "Calendar",
                    collapsed: collapsed,
                    active: selectedIndex == 2,
                    onTap: () => onItemSelected(2),
                  ),
                  const SizedBox(height: 8),
                  _NavItem(
                    icon: Icons.queue_music,
                    label: "Queue",
                    collapsed: collapsed,
                    active: selectedIndex == 3,
                    onTap: () => onItemSelected(3),
                  ),
                ],
              ),
            ),
          ),

          // Footer
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(12),
            child: _NavItem(
              icon: Icons.settings,
              label: "Settings",
              collapsed: collapsed,
              active: selectedIndex == 4,
              onTap: () => onItemSelected(4),
            ),
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool collapsed;
  final bool active;
  final bool disabled;
  final String? badge;
  final VoidCallback? onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.collapsed,
    this.active = false,
    this.disabled = false,
    this.badge,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = active ? const Color(0xFF00BFA5) : (disabled ? Colors.grey.withOpacity(0.5) : Colors.grey[700]);
    final bgColor = active ? const Color(0xFF00BFA5).withOpacity(0.1) : Colors.transparent;
    final textColor = active ? const Color(0xFF00BFA5) : (disabled ? Colors.grey.withOpacity(0.5) : Colors.grey[700]);

    return InkWell(
      onTap: disabled ? null : onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
        decoration: BoxDecoration(
          color: active ? bgColor : null,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: collapsed ? MainAxisAlignment.center : MainAxisAlignment.start,
          children: [
            Icon(icon, size: 20, color: color),
            if (!collapsed) ...[
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    color: textColor,
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
              ),
              if (badge != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    badge!,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[900],
                    ),
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }
}
