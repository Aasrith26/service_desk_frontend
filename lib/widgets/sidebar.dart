import 'package:flutter/material.dart';

class Sidebar extends StatelessWidget {
  final bool collapsed;
  final ValueChanged<bool> onCollapsedChanged;

  const Sidebar({
    super.key,
    required this.collapsed,
    required this.onCollapsedChanged,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      width: collapsed ? 80 : 256,
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
                            color: Colors.blue.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.monitor_heart, color: Colors.blue),
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
                    label: "Main Screen",
                    collapsed: collapsed,
                    active: true,
                  ),
                  const SizedBox(height: 8),
                  _NavItem(
                    icon: Icons.people,
                    label: "Walk-ins",
                    collapsed: collapsed,
                    disabled: true,
                    badge: "Soon",
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

  const _NavItem({
    required this.icon,
    required this.label,
    required this.collapsed,
    this.active = false,
    this.disabled = false,
    this.badge,
  });

  @override
  Widget build(BuildContext context) {
    final color = active ? Colors.blue : (disabled ? Colors.grey.withOpacity(0.5) : Colors.grey[700]);
    final bgColor = active ? Colors.blue : Colors.transparent;
    final textColor = active ? Colors.white : (disabled ? Colors.grey.withOpacity(0.5) : Colors.grey[700]);

    return InkWell(
      onTap: disabled ? null : () {},
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
            Icon(icon, size: 20, color: active ? Colors.white : color),
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
