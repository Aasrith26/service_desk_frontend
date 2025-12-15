import React from 'react';
import { LayoutDashboard, Users, Settings, Menu, ChevronLeft, Activity } from 'lucide-react';
import { clsx } from 'clsx';

interface SidebarProps {
    collapsed: boolean;
    setCollapsed: (collapsed: boolean) => void;
}

export const Sidebar: React.FC<SidebarProps> = ({ collapsed, setCollapsed }) => {
    return (
        <div
            className={clsx(
                "h-screen bg-white border-r border-secondary-light/30 flex flex-col transition-all duration-300 ease-in-out shadow-sm z-10",
                collapsed ? "w-20" : "w-64"
            )}
        >
            {/* Header / Logo */}
            <div className="h-16 flex items-center justify-between px-4 border-b border-secondary-light/30">
                <div className="flex items-center gap-3 overflow-hidden">
                    <div className="bg-primary/10 p-2 rounded-lg text-primary">
                        <Activity size={24} />
                    </div>
                    {!collapsed && (
                        <span className="font-bold text-lg text-text-main whitespace-nowrap">
                            MediCare
                        </span>
                    )}
                </div>
                <button
                    onClick={() => setCollapsed(!collapsed)}
                    className="p-1.5 hover:bg-secondary-light/10 rounded-md text-secondary transition-colors"
                >
                    {collapsed ? <Menu size={20} /> : <ChevronLeft size={20} />}
                </button>
            </div>

            {/* Navigation */}
            <nav className="flex-1 py-6 px-3 flex flex-col gap-2">
                <NavItem
                    icon={<LayoutDashboard size={20} />}
                    label="Main Screen"
                    collapsed={collapsed}
                    active
                />
                <NavItem
                    icon={<Users size={20} />}
                    label="Walk-ins"
                    collapsed={collapsed}
                    disabled
                    badge="Soon"
                />
            </nav>

            {/* Footer */}
            <div className="p-3 border-t border-secondary-light/30">
                <NavItem
                    icon={<Settings size={20} />}
                    label="Settings"
                    collapsed={collapsed}
                />
            </div>
        </div>
    );
};

interface NavItemProps {
    icon: React.ReactNode;
    label: string;
    collapsed: boolean;
    active?: boolean;
    disabled?: boolean;
    badge?: string;
}

const NavItem: React.FC<NavItemProps> = ({ icon, label, collapsed, active, disabled, badge }) => {
    return (
        <button
            disabled={disabled}
            className={clsx(
                "flex items-center gap-3 px-3 py-3 rounded-xl transition-all duration-200 group relative",
                active
                    ? "bg-primary text-white shadow-md shadow-primary/20"
                    : "text-secondary hover:bg-secondary-light/10 hover:text-primary-dark",
                disabled && "opacity-50 cursor-not-allowed hover:bg-transparent"
            )}
        >
            <span className={clsx("transition-transform duration-200", active && "scale-105")}>
                {icon}
            </span>

            {!collapsed && (
                <span className="font-medium text-sm flex-1 text-left">
                    {label}
                </span>
            )}

            {/* Tooltip for collapsed state */}
            {collapsed && (
                <div className="absolute left-full ml-4 px-2 py-1 bg-text-main text-white text-xs rounded opacity-0 group-hover:opacity-100 transition-opacity whitespace-nowrap pointer-events-none z-50">
                    {label}
                </div>
            )}

            {!collapsed && badge && (
                <span className="text-[10px] uppercase font-bold bg-secondary-light/20 text-secondary-dark px-2 py-0.5 rounded-full">
                    {badge}
                </span>
            )}
        </button>
    );
};
