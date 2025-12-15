import React, { useState, useEffect } from 'react';
import { StatCard } from '../components/dashboard/StatCard';
import { DayCalendar } from '../components/calendar/DayCalendar';
import { PhoneIncoming, CalendarCheck, Search, Bell, Plus } from 'lucide-react';
import { INITIAL_APPOINTMENTS, DOCTORS } from '../data/mockData';
import type { Appointment } from '../data/mockData';
import { NewAppointmentModal } from '../components/modals/NewAppointmentModal';
import { AppointmentDetailsModal } from '../components/modals/AppointmentDetailsModal';

export const MainScreen: React.FC = () => {
    const [activeFilter, setActiveFilter] = useState<'all' | 'calls' | 'appointments'>('all');
    const [appointments, setAppointments] = useState<Appointment[]>(INITIAL_APPOINTMENTS);
    const [searchQuery, setSearchQuery] = useState('');
    const [incomingCalls, setIncomingCalls] = useState(24);
    const [isCalling, setIsCalling] = useState(true);

    // Modal States
    const [isNewAppointmentModalOpen, setIsNewAppointmentModalOpen] = useState(false);
    const [selectedAppointment, setSelectedAppointment] = useState<Appointment | null>(null);

    // Simulate Incoming Calls
    useEffect(() => {
        const interval = setInterval(() => {
            // 30% chance to get a new call every 5 seconds
            if (Math.random() > 0.7) {
                setIncomingCalls(prev => prev + 1);
                setIsCalling(true);
                setTimeout(() => setIsCalling(false), 3000); // Pulse effect for 3s
            }
        }, 5000);
        return () => clearInterval(interval);
    }, []);

    // Search Filtering
    const filteredAppointments = appointments.filter(app => {
        if (searchQuery) {
            const query = searchQuery.toLowerCase();
            return app.patientName.toLowerCase().includes(query) ||
                DOCTORS.find(d => d.id === app.doctorId)?.name.toLowerCase().includes(query);
        }
        return true;
    });

    // Handle New Appointment Submission
    const handleNewAppointmentSubmit = (data: Omit<Appointment, 'id' | 'status'>) => {
        const newAppointment: Appointment = {
            id: Math.random().toString(),
            ...data,
            status: 'scheduled'
        };
        setAppointments(prev => [...prev, newAppointment]);
    };

    return (
        <div className="flex flex-col h-full bg-background p-6 gap-6">
            {/* Top Header */}
            <div className="flex justify-between items-center">
                <div>
                    <h1 className="text-2xl font-bold text-text-main">Command Center</h1>
                    <p className="text-sm text-text-muted">Monday, Dec 15 • Good Morning, Sarah</p>
                </div>

                <div className="flex items-center gap-4">
                    <div className="relative group">
                        <Search className="absolute left-3 top-1/2 -translate-y-1/2 text-secondary-light group-focus-within:text-primary transition-colors" size={18} />
                        <input
                            type="text"
                            placeholder="Search patients, doctors..."
                            value={searchQuery}
                            onChange={(e) => setSearchQuery(e.target.value)}
                            className="pl-10 pr-4 py-2.5 rounded-xl border border-secondary-light/30 bg-white focus:outline-none focus:ring-2 focus:ring-primary/20 focus:border-primary w-64 transition-all"
                        />
                        <div className="absolute right-3 top-1/2 -translate-y-1/2 bg-secondary-light/10 text-secondary border border-secondary-light/20 text-[10px] px-1.5 py-0.5 rounded">
                            ⌘K
                        </div>
                    </div>

                    <button className="relative p-2.5 rounded-xl bg-white border border-secondary-light/30 hover:bg-secondary-light/5 text-secondary hover:text-primary transition-colors">
                        <Bell size={20} />
                        <span className="absolute top-2 right-2.5 w-2 h-2 bg-red-500 rounded-full ring-2 ring-white"></span>
                    </button>

                    <button
                        onClick={() => setIsNewAppointmentModalOpen(true)}
                        className="flex items-center gap-2 bg-primary hover:bg-primary-dark text-white px-5 py-2.5 rounded-xl font-medium shadow-lg shadow-primary/20 hover:shadow-primary/40 transition-all active:scale-95"
                    >
                        <Plus size={18} />
                        <span>New Appointment</span>
                    </button>
                </div>
            </div>

            {/* KPI / Filters Section */}
            <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
                <StatCard
                    label="Incoming Calls"
                    value={incomingCalls}
                    icon={PhoneIncoming}
                    isActive={activeFilter === 'calls'}
                    onClick={() => setActiveFilter(activeFilter === 'calls' ? 'all' : 'calls')}
                    trend="+12% vs last hr"
                    colorClass={isCalling ? "text-blue-600 bg-blue-50 animate-pulse" : "text-blue-600 bg-blue-50"}
                />
                <StatCard
                    label="Appointments"
                    value={filteredAppointments.length}
                    icon={CalendarCheck}
                    isActive={activeFilter === 'appointments'}
                    onClick={() => setActiveFilter(activeFilter === 'appointments' ? 'all' : 'appointments')}
                    trend={`${80 - filteredAppointments.length} slots remaining`}
                    colorClass="text-teal-600 bg-teal-50"
                />
                {/* Mock AI Agent Status */}
                <div className="p-5 rounded-2xl bg-gradient-to-br from-primary to-primary-dark text-white shadow-xl shadow-primary/20 flex flex-col justify-between relative overflow-hidden group cursor-pointer hover:shadow-primary/30 transition-all">
                    <div className="absolute top-0 right-0 p-4 opacity-10 transform translate-x-4 -translate-y-4 group-hover:scale-110 transition-transform">
                        <PhoneIncoming size={100} />
                    </div>
                    <div className="relative z-10">
                        <div className="flex items-center gap-2 mb-1">
                            <span className="relative flex h-3 w-3">
                                <span className="animate-ping absolute inline-flex h-full w-full rounded-full bg-white opacity-75"></span>
                                <span className="relative inline-flex rounded-full h-3 w-3 bg-teal-200"></span>
                            </span>
                            <h3 className="font-bold text-white tracking-wide">AI Receptionist Live</h3>
                        </div>
                        <p className="text-sm opacity-90 max-w-[80%]">Handling <span className="font-bold text-white">3 calls</span> and <span className="font-bold text-white">2 chats</span>.</p>
                    </div>
                    <div className="mt-4 flex gap-2">
                        <div className="h-1 flex-1 bg-white/20 rounded-full overflow-hidden">
                            <div className="h-full bg-white animate-[progress_2s_ease-in-out_infinite] w-[70%]"></div>
                        </div>
                    </div>
                </div>
            </div>

            {/* Main Calendar View */}
            <div className="flex-1 min-h-0">
                <DayCalendar
                    appointments={filteredAppointments}
                    doctors={DOCTORS}
                    onAppointmentClick={setSelectedAppointment}
                />
            </div>

            <NewAppointmentModal
                isOpen={isNewAppointmentModalOpen}
                onClose={() => setIsNewAppointmentModalOpen(false)}
                onSubmit={handleNewAppointmentSubmit}
            />

            <AppointmentDetailsModal
                appointment={selectedAppointment}
                onClose={() => setSelectedAppointment(null)}
            />
        </div>
    );
};
