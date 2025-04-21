require('dotenv').config();
const mongoose = require('mongoose');

const MAX_RETRIES = 5;
const RETRY_DELAY = 5000; // 5 seconds

const connectWithRetry = async (retryCount = 0) => {
    try {
        await mongoose.connect(process.env.MONGODB_URI, {
            useNewUrlParser: true,
            useUnifiedTopology: true,
            serverSelectionTimeoutMS: 10000,
            socketTimeoutMS: 45000,
            maxPoolSize: 10,
            family: 4 // Use IPv4, skip trying IPv6
        });
        console.log('Successfully connected to MongoDB Atlas');
        process.exit(0);
    } catch (err) {
        console.error(`MongoDB Atlas connection error (attempt ${retryCount + 1}/${MAX_RETRIES}):`, err);
        
        if (retryCount < MAX_RETRIES - 1) {
            console.log(`Retrying in ${RETRY_DELAY/1000} seconds...`);
            await new Promise(resolve => setTimeout(resolve, RETRY_DELAY));
            return connectWithRetry(retryCount + 1);
        } else {
            console.error('Max retry attempts reached. Exiting...');
            process.exit(1);
        }
    }
};

// Handle process termination
process.on('SIGINT', () => {
    mongoose.connection.close(() => {
        console.log('MongoDB connection closed through app termination');
        process.exit(0);
    });
});

connectWithRetry();
