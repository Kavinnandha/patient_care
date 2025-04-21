const mongoose = require('mongoose');
require('dotenv').config();

async function testConnection() {
    try {
        // Print connection string (with password masked)
        const maskPassword = uri => {
            return uri.replace(/:([^@]+)@/, ':****@');
        };
        console.log('Attempting to connect with URI:', maskPassword(process.env.MONGODB_URI));
        
        await mongoose.connect(process.env.MONGODB_URI, {
            serverSelectionTimeoutMS: 5000
        });
        console.log('MongoDB connection successful!');
        
        // Test database operation
        const collections = await mongoose.connection.db.listCollections().toArray();
        console.log('Available collections:', collections.map(c => c.name));
        
    } catch (error) {
        console.error('Connection error details:', {
            name: error.name,
            message: error.message,
            code: error.code
        });
        
        if (error.reason) {
            console.error('Topology description:', {
                type: error.reason.type,
                setName: error.reason.setName,
                servers: Array.from(error.reason.servers.entries())
                    .map(([host, desc]) => ({
                        host,
                        type: desc.type,
                        state: desc.state
                    }))
            });
        }
    } finally {
        await mongoose.disconnect();
        process.exit();
    }
}

testConnection();
