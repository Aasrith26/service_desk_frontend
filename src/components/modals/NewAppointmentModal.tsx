import React, { useState } from 'react';
import { X, Calendar, User, Clock, Stethoscope } from 'lucide-react';
import { DOCTORS } from '../../data/mockData';
import type { Appointment } from '../../data/mockData';

interface NewAppointmentModalProps {
    isOpen: boolean;
    onClose: () => void;
    onSubmit: (appointment: Omit<Appointment, 'id' | 'status'>) => void;
}

export const NewAppointmentModal: React.FC<NewAppointmentModalProps> = ({ isOpen, onClose, onSubmit }) => {
    const [patientName, setPatientName] = useState('');
    const [doctorId, setDoctorId] = useState(DOCTORS[0].id);
    const [time, setTime] = useState('09:00');
    const [type, setType] = useState<Appointment['type']>('consultation');
    const [notes, setNotes] = useState('');

    if (!isOpen) return null;

    const handleSubmit = (e: React.FormEvent) => {
        e.preventDefault();
        onSubmit({
            patientName,
            doctorId,
            time,
            duration: 30, // Default for now
            type,
        });
        onClose();
        // Reset form
        setPatientName('');
        setNotes('');
    };

    return (
        <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-black/40 backdrop-blur-sm animate-in fade-in duration-200">
            <div className="bg-white rounded-2xl shadow-2xl w-full max-w-lg overflow-hidden animate-in zoom-in-95 duration-200">
                <div className="px-6 py-4 border-b border-secondary-light/20 flex justify-between items-center bg-background/50">
                    <h2 className="text-xl font-bold text-text-main">New Appointment</h2>
                    <button onClick={onClose} className="p-2 hover:bg-secondary-light/10 rounded-lg text-secondary transition-colors">
                        <X size={20} />
                    </button>
                </div>

                <form onSubmit={handleSubmit} className="p-6 space-y-4">
                    {/* Patient Name */}
                    <div className="space-y-1.5">
                        <label className="text-sm font-semibold text-text-muted flex items-center gap-2">
                            <User size={16} /> Patient Name
                        </label>
                        <input
                            required
                            type="text"
                            value={patientName}
                            onChange={e => setPatientName(e.target.value)}
                            placeholder="e.g. John Doe"
                            className="w-full px-4 py-2.5 rounded-xl border border-secondary-light/30 focus:ring-2 focus:ring-primary/20 focus:border-primary focus:outline-none transition-all"
                        />
                    </div>

                    <div className="grid grid-cols-2 gap-4">
                        {/* Doctor Selection */}
                        <div className="space-y-1.5">
                            <label className="text-sm font-semibold text-text-muted flex items-center gap-2">
                                <Stethoscope size={16} /> Doctor
                            </label>
                            <select
                                value={doctorId}
                                onChange={e => setDoctorId(e.target.value)}
                                className="w-full px-4 py-2.5 rounded-xl border border-secondary-light/30 focus:ring-2 focus:ring-primary/20 focus:border-primary focus:outline-none bg-white transition-all"
                            >
                                {DOCTORS.map(doc => (
                                    <option key={doc.id} value={doc.id}>{doc.name}</option>
                                ))}
                            </select>
                        </div>

                        {/* Time Selection */}
                        <div className="space-y-1.5">
                            <label className="text-sm font-semibold text-text-muted flex items-center gap-2">
                                <Clock size={16} /> Time
                            </label>
                            <input
                                type="time"
                                value={time}
                                onChange={e => setTime(e.target.value)}
                                className="w-full px-4 py-2.5 rounded-xl border border-secondary-light/30 focus:ring-2 focus:ring-primary/20 focus:border-primary focus:outline-none transition-all"
                            />
                        </div>
                    </div>

                    {/* Type Selection */}
                    <div className="space-y-1.5">
                        <label className="text-sm font-semibold text-text-muted flex items-center gap-2">
                            <Calendar size={16} /> Appointment Type
                        </label>
                        <div className="grid grid-cols-3 gap-2">
                            {(['consultation', 'follow-up', 'check-up'] as const).map(t => (
                                <button
                                    key={t}
                                    type="button"
                                    onClick={() => setType(t as any)}
                                    className={`px-3 py-2 rounded-lg text-sm font-medium border transition-all ${type === t
                                        ? 'bg-primary/10 border-primary text-primary'
                                        : 'border-secondary-light/30 text-secondary hover:bg-secondary-light/5'
                                        }`}
                                >
                                    {t.charAt(0).toUpperCase() + t.slice(1)}
                                </button>
                            ))}
                        </div>
                    </div>

                    {/* Notes */}
                    <div className="space-y-1.5">
                        <label className="text-sm font-semibold text-text-muted">Notes (Optional)</label>
                        <textarea
                            value={notes}
                            onChange={e => setNotes(e.target.value)}
                            rows={3}
                            className="w-full px-4 py-2.5 rounded-xl border border-secondary-light/30 focus:ring-2 focus:ring-primary/20 focus:border-primary focus:outline-none transition-all resize-none"
                            placeholder="Reason for visit..."
                        />
                    </div>

                    {/* Actions */}
                    <div className="pt-4 flex gap-3">
                        <button
                            type="button"
                            onClick={onClose}
                            className="flex-1 py-2.5 rounded-xl border border-secondary-light/30 text-text-main font-medium hover:bg-secondary-light/5 transition-colors"
                        >
                            Cancel
                        </button>
                        <button
                            type="submit"
                            className="flex-1 py-2.5 rounded-xl bg-primary text-white font-medium hover:bg-primary-dark shadow-lg shadow-primary/20 transition-all active:scale-95"
                        >
                            Confirm Booking
                        </button>
                    </div>
                </form>
            </div>
        </div>
    );
};
