import React from 'react';
import { X, Calendar, User, Phone, Mail, FileText, CheckCircle } from 'lucide-react';
import { DOCTORS } from '../../data/mockData';
import type { Appointment } from '../../data/mockData';

interface AppointmentDetailsModalProps {
    appointment: Appointment | null;
    onClose: () => void;
}

export const AppointmentDetailsModal: React.FC<AppointmentDetailsModalProps> = ({ appointment, onClose }) => {
    if (!appointment) return null;

    const doctor = DOCTORS.find(d => d.id === appointment.doctorId);

    return (
        <div className="fixed inset-0 z-50 flex justify-end">
            {/* Backdrop */}
            <div
                className="absolute inset-0 bg-black/20 backdrop-blur-[1px] animate-in fade-in duration-300"
                onClick={onClose}
            />

            {/* Slide-over Panel */}
            <div className="relative w-full max-w-md bg-background h-full shadow-2xl animate-in slide-in-from-right duration-300 border-l border-secondary-light/20 flex flex-col">

                {/* Header */}
                <div className="px-6 py-5 border-b border-secondary-light/20 flex justify-between items-start bg-white">
                    <div>
                        <h2 className="text-xl font-bold text-text-main">{appointment.patientName}</h2>
                        <p className="text-sm text-text-muted mt-0.5">Patient ID: #PAT-{Math.floor(Math.random() * 10000)}</p>
                    </div>
                    <button onClick={onClose} className="p-2 -mr-2 hover:bg-secondary-light/10 rounded-lg text-secondary transition-colors">
                        <X size={20} />
                    </button>
                </div>

                {/* Content */}
                <div className="flex-1 overflow-y-auto p-6 space-y-8">

                    {/* Status Badge */}
                    <div className="flex items-center gap-4">
                        <div className={`px-3 py-1 rounded-full text-sm font-bold uppercase tracking-wider ${appointment.status === 'in-progress' ? 'bg-green-100 text-green-700' :
                            appointment.status === 'checked-in' ? 'bg-teal-100 text-teal-700' :
                                appointment.status === 'waiting' ? 'bg-amber-100 text-amber-700' :
                                    'bg-blue-100 text-blue-700'
                            }`}>
                            {appointment.status.replace('-', ' ')}
                        </div>
                        <span className="text-sm text-text-muted">Last visit: 2 weeks ago</span>
                    </div>

                    {/* Appointment Info */}
                    <section>
                        <h3 className="text-sm font-bold text-text-muted uppercase tracking-wider mb-4 flex items-center gap-2">
                            <Calendar size={14} /> Appointment Details
                        </h3>
                        <div className="bg-white rounded-2xl border border-secondary-light/20 p-4 space-y-4 shadow-sm">
                            <div className="flex justify-between items-center border-b border-secondary-light/10 pb-3">
                                <span className="text-secondary">Time</span>
                                <span className="font-semibold text-text-main">{appointment.time} (30 min)</span>
                            </div>
                            <div className="flex justify-between items-center border-b border-secondary-light/10 pb-3">
                                <span className="text-secondary">Type</span>
                                <span className="font-semibold text-text-main capitalize">{appointment.type}</span>
                            </div>
                            <div className="flex justify-between items-center">
                                <span className="text-secondary">Doctor</span>
                                <div className="text-right">
                                    <div className="font-semibold text-text-main">{doctor?.name}</div>
                                    <div className="text-xs text-secondary">{doctor?.specialty}</div>
                                </div>
                            </div>
                        </div>
                    </section>

                    {/* Patient Info (Mock) */}
                    <section>
                        <h3 className="text-sm font-bold text-text-muted uppercase tracking-wider mb-4 flex items-center gap-2">
                            <User size={14} /> Patient Information
                        </h3>
                        <div className="bg-white rounded-2xl border border-secondary-light/20 p-4 space-y-4 shadow-sm">
                            <div className="flex items-center gap-3">
                                <div className="p-2 rounded-lg bg-blue-50 text-blue-600">
                                    <Phone size={18} />
                                </div>
                                <div>
                                    <div className="text-xs text-secondary">Phone Number</div>
                                    <div className="font-medium text-text-main">+1 (555) 012-3456</div>
                                </div>
                            </div>
                            <div className="flex items-center gap-3">
                                <div className="p-2 rounded-lg bg-purple-50 text-purple-600">
                                    <Mail size={18} />
                                </div>
                                <div>
                                    <div className="text-xs text-secondary">Email</div>
                                    <div className="font-medium text-text-main">patient@example.com</div>
                                </div>
                            </div>
                            <div className="flex items-center gap-3">
                                <div className="p-2 rounded-lg bg-amber-50 text-amber-600">
                                    <FileText size={18} />
                                </div>
                                <div>
                                    <div className="text-xs text-secondary">Medical History</div>
                                    <div className="font-medium text-text-main">Hypertension, Allergies (Penicillin)</div>
                                </div>
                            </div>
                        </div>
                    </section>

                    {/* Actions */}
                    <div className="flex flex-col gap-3">
                        <button className="w-full py-3 rounded-xl bg-primary text-white font-bold shadow-lg shadow-primary/20 hover:bg-primary-dark transition-colors flex items-center justify-center gap-2">
                            <CheckCircle size={20} />
                            Check In Patient
                        </button>
                        <button className="w-full py-3 rounded-xl border border-secondary-light/30 text-secondary font-semibold hover:bg-secondary-light/10 transition-colors">
                            Reschedule
                        </button>
                    </div>

                </div>
            </div>
        </div>
    );
};
