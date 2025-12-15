import React from 'react';
import { clsx } from 'clsx';
import type { LucideIcon } from 'lucide-react';

interface StatCardProps {
    label: string;
    value: string | number;
    icon: LucideIcon;
    isActive: boolean;
    onClick: () => void;
    trend?: string;
    colorClass?: string; // e.g., "text-blue-600"
}

export const StatCard: React.FC<StatCardProps> = ({
    label,
    value,
    icon: Icon,
    isActive,
    onClick,
    trend,
    colorClass = "text-primary"
}) => {
    return (
        <button
            onClick={onClick}
            className={clsx(
                "relative flex flex-col items-start p-5 rounded-2xl w-full transition-all duration-300 border text-left",
                isActive
                    ? "bg-white border-primary shadow-lg shadow-primary/10 ring-1 ring-primary"
                    : "bg-white/60 border-secondary-light/20 hover:bg-white hover:border-secondary-light/50 hover:shadow-md"
            )}
        >
            <div className="flex w-full justify-between items-start mb-2">
                <div className={clsx("p-2 rounded-xl bg-background", colorClass)}>
                    <Icon size={20} />
                </div>
                {isActive && (
                    <span className="flex h-2 w-2 rounded-full bg-primary animate-pulse" />
                )}
            </div>

            <div className="mt-1">
                <span className="text-3xl font-bold text-text-main tracking-tight block">
                    {value}
                </span>
                <span className="text-sm font-medium text-text-muted mt-1 block">
                    {label}
                </span>
            </div>

            {trend && (
                <div className="absolute top-5 right-5 text-xs font-semibold bg-green-100 text-green-700 px-2 py-0.5 rounded-full">
                    {trend}
                </div>
            )}
        </button>
    );
};
