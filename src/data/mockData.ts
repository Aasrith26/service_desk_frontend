export interface Doctor {
    id: string;
    name: string;
    specialty: string;
    avatar: string;
}

export interface Appointment {
    id: string;
    patientName: string;
    time: string; // "10:00"
    duration: number; // minutes
    type: 'consultation' | 'surgery' | 'follow-up' | 'walk-in';
    doctorId: string;
    status: 'checked-in' | 'waiting' | 'in-progress' | 'scheduled';
}

export const DOCTORS: Doctor[] = [
    { id: 'dr-1', name: 'Dr. Sarah Smith', specialty: 'Cardiology', avatar: 'SS' },
    { id: 'dr-2', name: 'Dr. James Chen', specialty: 'Pediatrics', avatar: 'JC' },
    { id: 'dr-3', name: 'Dr. Emily White', specialty: 'General', avatar: 'EW' },
];

export const INITIAL_APPOINTMENTS: Appointment[] = [
    { id: '1', patientName: 'Alice Johnson', time: '09:00', duration: 45, type: 'consultation', doctorId: 'dr-1', status: 'in-progress' },
    { id: '2', patientName: 'Bob Brown', time: '10:00', duration: 30, type: 'walk-in', doctorId: 'dr-3', status: 'waiting' },
    { id: '3', patientName: 'Charlie Davis', time: '11:30', duration: 60, type: 'surgery', doctorId: 'dr-1', status: 'scheduled' },
    { id: '4', patientName: 'Diana Prince', time: '09:30', duration: 30, type: 'follow-up', doctorId: 'dr-2', status: 'checked-in' },
    { id: '5', patientName: 'Evan Wright', time: '14:00', duration: 45, type: 'consultation', doctorId: 'dr-3', status: 'scheduled' },
];

export const PATIENT_NAMES = [
    "Frank Miller", "Grace Ho", "Henry Ford", "Ivy Tang", "Jack Ryan",
    "Kelly Clarkson", "Liam Neeson", "Mia Hamm", "Noah Centineo", "Olivia Wilde"
];

export const getRandomPatient = () => PATIENT_NAMES[Math.floor(Math.random() * PATIENT_NAMES.length)];
