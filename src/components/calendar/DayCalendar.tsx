import React, { useRef, useEffect } from 'react';
import { clsx } from 'clsx';
import { MoreHorizontal } from 'lucide-react';
import type { Appointment, Doctor } from '../../data/mockData';

interface DayCalendarProps {
    appointments: Appointment[];
    doctors: Doctor[];
    onAppointmentClick: (appointment: Appointment) => void;
}

const HOURS = Array.from({ length: 11 }, (_, i) => i + 8); // 8 AM to 6 PM

export const DayCalendar: React.FC<DayCalendarProps> = ({ appointments, doctors, onAppointmentClick }) => {
    const containerRef = useRef<HTMLDivElement>(null);

    // Scroll to 8 AM (start)
    useEffect(() => {
        if (containerRef.current) {
            containerRef.current.scrollTop = 0;
        }
    }, []);

    return (
        <div className="flex flex-col h-full bg-white rounded-2xl shadow-sm border border-secondary-light/20 overflow-hidden">
            {/* Calendar Header with Doctor Swimlane Headers */}
            <div className="flex border-b border-secondary-light/20 bg-background/50 backdrop-blur-sm sticky top-0 z-20">
                <div className="w-16 flex-shrink-0 border-r border-secondary-light/20 p-4 text-xs font-semibold text-text-muted text-center">
                    Time
                </div>
                <div className="flex flex-1">
                    {doctors.map(doc => (
                        <div key={doc.id} className="flex-1 p-4 flex items-center gap-3 border-r last:border-r-0 border-secondary-light/20 min-w-[200px]">
                            <div className="w-8 h-8 rounded-full bg-primary/10 text-primary flex items-center justify-center font-bold text-xs ring-2 ring-white">
                                {doc.avatar}
                            </div>
                            <div className="flex flex-col">
                                <span className="text-sm font-bold text-text-main truncate">{doc.name}</span>
                                <span className="text-xs text-text-muted truncate">{doc.specialty}</span>
                            </div>
                        </div>
                    ))}
                </div>
            </div>

            {/* Calendar Grid */}
            <div ref={containerRef} className="flex-1 overflow-y-auto relative bg-grid-pattern pb-10">
                {HOURS.map(hour => (
                    <div key={hour} className="flex min-h-[100px] border-b border-secondary-light/10 group">
                        {/* Time Column */}
                        <div className="w-16 flex-shrink-0 border-r border-secondary-light/20 py-2 text-xs font-medium text-text-muted text-center sticky left-0 bg-white/95 group-hover:bg-background transition-colors z-10">
                            {`${hour > 12 ? hour - 12 : hour} ${hour >= 12 ? 'PM' : 'AM'}`}
                        </div>

                        {/* Columns for each doctor */}
                        <div className="flex flex-1">
                            {doctors.map(doc => (
                                <div key={doc.id} className="flex-1 border-r last:border-r-0 border-secondary-light/10 relative hover:bg-background/40 transition-colors">
                                    {/* Map Appointments */}
                                    {appointments.filter(app => app.doctorId === doc.id).map(app => {
                                        // Simple logic to position based on time (parsing "09:00" etc)
                                        const [h, m] = app.time.split(':').map(Number);
                                        if (h === hour) {
                                            // Very basic positioning logic
                                            const topPct = (m / 60) * 100;
                                            const heightPct = (app.duration / 60) * 100; // Assuming cell is 60m height effectively

                                            return (
                                                <div
                                                    key={app.id}
                                                    onClick={() => onAppointmentClick(app)}
                                                    style={{ top: `${topPct}%`, height: `${heightPct}%` }}
                                                    className={clsx(
                                                        "absolute left-1 right-1 rounded-lg p-2 border-l-4 text-xs shadow-sm cursor-pointer hover:shadow-md transition-all z-10 animate-in fade-in zoom-in-95 duration-300",
                                                        app.status === 'in-progress' && "bg-green-50 border-green-500 text-green-900",
                                                        app.status === 'waiting' && "bg-amber-50 border-amber-500 text-amber-900",
                                                        app.status === 'scheduled' && "bg-blue-50 border-blue-500 text-blue-900",
                                                        app.status === 'checked-in' && "bg-teal-50 border-teal-500 text-teal-900",
                                                        app.type === 'walk-in' && "ring-2 ring-purple-100" // Highlight walk-ins
                                                    )}
                                                >
                                                    <div className="flex justify-between items-start">
                                                        <span className="font-bold truncate">{app.patientName}</span>
                                                        <MoreHorizontal size={14} className="opacity-50" />
                                                    </div>
                                                    <div className="mt-1 opacity-70 flex gap-1 items-center">
                                                        {app.type === 'walk-in' && <span className="bg-purple-100 text-purple-700 px-1 rounded-[4px] text-[9px] font-bold">WALK-IN</span>}
                                                        <span>{app.time}</span>
                                                    </div>
                                                </div>
                                            )
                                        }
                                        return null;
                                    })}
                                </div>
                            ))}
                        </div>
                    </div>
                ))}

                {/* Current Time Indicator (Mock) */}
                <div className="absolute left-16 right-0 top-[220px] h-0.5 bg-red-400 z-20 pointer-events-none flex items-center">
                    <div className="w-2 h-2 rounded-full bg-red-400 -ml-1"></div>
                    <div className="text-[10px] font-bold text-red-500 ml-1 bg-white/80 px-1 rounded">Current Time</div>
                </div>
            </div>
        </div>
    );
};
