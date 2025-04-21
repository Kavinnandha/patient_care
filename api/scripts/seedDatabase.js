const mongoose = require('mongoose');
const bcrypt = require('bcryptjs');
const path = require('path');
require('dotenv').config({ path: path.resolve(__dirname, '../.env') });

// Import models
const User = require('../schemas/User');
const Profile = require('../schemas/UserProfile');
const GlucoseReading = require('../schemas/GlucoseReading');
const MedicalRecord = require('../schemas/MedicalRecord');
const Medication = require('../schemas/Medication');

async function seedDatabase() {
    try {
        await mongoose.connect(process.env.MONGODB_URI);
        console.log('Connected to MongoDB');

        // Clear existing data
        console.log('Clearing existing data...');
        await Promise.all([
            User.deleteMany({}),
            Profile.deleteMany({}),
            GlucoseReading.deleteMany({}),
            MedicalRecord.deleteMany({}),
            Medication.deleteMany({})
        ]);
        console.log('Data cleared successfully');

        // Create sample users
        console.log('Creating sample users...');
        const users = await User.create([
            {
                username: 'john.doe',
                email: 'john@example.com',
                password: 'password123' // Password will be hashed by pre-save hook
            },
            {
                username: 'jane.smith',
                email: 'jane@example.com',
                password: 'password123' // Password will be hashed by pre-save hook
            }
        ]);
        console.log('Created users:', users.map(u => ({ id: u._id, username: u.username, email: u.email })));

        // Create profiles for users
        console.log('Creating user profiles...');
        const profiles = await Profile.create([
            {
                user: users[0]._id,
                firstName: 'John',
                lastName: 'Doe',
                dateOfBirth: new Date('1990-05-15'),
                gender: 'male',
                height: 175,
                weight: 75,
                bloodType: 'O+',
                medicalConditions: ['Type 2 Diabetes', 'Hypertension'],
                allergies: ['Penicillin'],
                currentMedications: ['Metformin', 'Lisinopril'],
                emergencyContact: {
                    name: 'Mary Doe',
                    relationship: 'Wife',
                    phone: '555-0123'
                }
            },
            {
                user: users[1]._id,
                firstName: 'Jane',
                lastName: 'Smith',
                dateOfBirth: new Date('1985-08-22'),
                gender: 'female',
                height: 165,
                weight: 62,
                bloodType: 'A+',
                medicalConditions: ['Asthma'],
                allergies: ['Dust', 'Pollen'],
                currentMedications: ['Albuterol'],
                emergencyContact: {
                    name: 'Bob Smith',
                    relationship: 'Husband',
                    phone: '555-0124'
                }
            }
        ]);
        console.log('Created profiles:', profiles.map(p => ({ id: p._id, name: `${p.firstName} ${p.lastName}`, userId: p.user })));

        // Create glucose readings for John
        console.log('Creating glucose readings...');
        const today = new Date();
        const glucoseReadings = [];
        for (let i = 0; i < 7; i++) {
            const date = new Date(today);
            date.setDate(date.getDate() - i);
            
            glucoseReadings.push({
                patient: profiles[0]._id,
                glucoseLevel: Math.floor(Math.random() * (180 - 70) + 70),
                readingType: 'fasting',
                notes: 'Morning reading',
                createdAt: new Date(date.setHours(8, 0, 0))
            });

            glucoseReadings.push({
                patient: profiles[0]._id,
                glucoseLevel: Math.floor(Math.random() * (200 - 100) + 100),
                readingType: 'post_meal',
                notes: 'After lunch',
                createdAt: new Date(date.setHours(14, 0, 0))
            });
        }

        await GlucoseReading.create(glucoseReadings);
        console.log(`Created ${glucoseReadings.length} glucose readings`);

        // Create medications
        console.log('Creating medications...');
        const medications = await Medication.create([
            {
                profileId: profiles[0]._id,
                name: 'Metformin',
                dosage: '500mg',
                frequency: 'Twice daily',
                startDate: new Date('2023-01-01'),
                prescribedBy: 'Dr. Smith',
                purpose: 'Diabetes management',
                sideEffects: ['Nausea', 'Diarrhea'],
                notes: 'Take with meals'
            },
            {
                profileId: profiles[1]._id,
                name: 'Albuterol',
                dosage: '90mcg',
                frequency: 'As needed',
                startDate: new Date('2023-03-15'),
                prescribedBy: 'Dr. Johnson',
                purpose: 'Asthma relief',
                sideEffects: ['Tremors', 'Rapid heartbeat'],
                notes: 'Use inhaler when experiencing asthma symptoms'
            }
        ]);
        console.log('Created medications:', medications.map(m => ({ id: m._id, name: m.name, profileId: m.profileId })));

        // Verify passwords can be checked
        console.log('\nVerifying password functionality...');
        const testUser = await User.findOne({ username: 'john.doe' });
        const passwordMatch = await testUser.comparePassword('password123');
        console.log('Password verification test:', passwordMatch ? 'PASSED' : 'FAILED');

        console.log('\nDatabase seeded successfully!');
        await mongoose.connection.close();

    } catch (error) {
        console.error('Error seeding database:', error);
        await mongoose.connection.close();
        process.exit(1);
    }
}

seedDatabase();
