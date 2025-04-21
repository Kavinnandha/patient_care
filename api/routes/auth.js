const express = require('express');
const jwt = require('jsonwebtoken');
const { validationResult } = require('express-validator');
const User = require('../schemas/User');
const Profile = require('../schemas/UserProfile');
const { TokenBlacklist } = require('../schemas/TokenBlacklist');
const { validateRegistration, validateLogin } = require('../middleware/validation');
const { 
  loginLimiter, 
  registrationLimiter, 
  authenticateToken, 
  generateTokens 
} = require('../middleware/auth');
const router = express.Router();

// Register new user
router.post('/register', registrationLimiter, validateRegistration, async (req, res) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({ errors: errors.array() });
    }

    const { 
      username, 
      email, 
      password,
      firstName,
      lastName,
      dateOfBirth,
      gender,
      height,
      weight,
      bloodType,
      medicalConditions,
      allergies,
      currentMedications,
      emergencyContact
    } = req.body;

    // Check if user already exists
    const existingUser = await User.findOne({ 
      $or: [{ username }, { email }] 
    });
    
    if (existingUser) {
      return res.status(400).json({ 
        error: 'Username or email already exists' 
      });
    }

    // Create new user
    const user = new User({
      username,
      email,
      password
    });

    await user.save();

    // Create user profile
    const profile = new Profile({
      user: user._id,
      firstName,
      lastName,
      dateOfBirth,
      gender,
      height,
      weight,
      bloodType,
      medicalConditions,
      allergies,
      currentMedications,
      emergencyContact
    });

    await profile.save();

    // Generate tokens
    const tokens = generateTokens({
      userId: user._id,
      username: user.username,
      profileId: profile._id
    });

    res.status(201).json({
      status: 'success',
      message: 'Registration successful',
      data: {
        tokens,
        user: {
          id: user._id,
          username: user.username,
          email: user.email
        },
        profile
      }
    });
  } catch (error) {
    if (error.code === 11000) {
      return res.status(409).json({
        status: 'error',
        message: 'Username or email already exists'
      });
    }
    res.status(500).json({
      status: 'error',
      message: 'Registration failed',
      details: error.message
    });
  }
});

// Refresh token
router.post('/refresh', async (req, res) => {
  try {
    const { refreshToken } = req.body;
    if (!refreshToken) {
      return res.status(401).json({
        status: 'error',
        message: 'Refresh token required'
      });
    }

    // Verify refresh token
    const decoded = jwt.verify(refreshToken, process.env.REFRESH_TOKEN_SECRET);
    
    // Generate new tokens
    const tokens = generateTokens({
      userId: decoded.userId,
      username: decoded.username,
      profileId: decoded.profileId
    });

    res.json({
      status: 'success',
      data: {
        token: tokens.accessToken,
        refreshToken: tokens.refreshToken
      }
    });
  } catch (error) {
    res.status(401).json({
      status: 'error',
      message: 'Invalid refresh token'
    });
  }
});

// Login user
router.post('/login', loginLimiter, validateLogin, async (req, res) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({ errors: errors.array() });
    }

    const { username, password } = req.body;

    // Find user
    const user = await User.findOne({ username });
    if (!user) {
      return res.status(401).json({ 
        status: 'error',
        message: 'Invalid credentials'
      });
    }

    // Check password
    const isMatch = await user.comparePassword(password);
    if (!isMatch) {
      return res.status(401).json({ 
        status: 'error',
        message: 'Invalid credentials'
      });
    }

    // Get user without password
    const userWithoutPassword = await User.findOne({ username }).select('-password');

    // Get user profile
    const profile = await Profile.findOne({ user: userWithoutPassword._id });

    // Generate tokens
    const tokens = generateTokens({
      userId: userWithoutPassword._id,
      username: userWithoutPassword.username,
      profileId: profile._id
    });

    res.json({
      status: 'success',
      message: 'Login successful',
      data: {
        tokens,
        user: {
          id: userWithoutPassword._id,
          username: userWithoutPassword.username,
          email: userWithoutPassword.email
        },
        profile
      }
    });
  } catch (error) {
    res.status(500).json({
      status: 'error',
      message: 'Login failed',
      details: error.message
    });
  }
});

// Get current user
router.get('/me', authenticateToken, async (req, res) => {
  try {
    const user = await User.findById(req.user.userId).select('-password');
    const profile = await Profile.findOne({ user: user._id });

    if (!user) {
      return res.status(404).json({ 
        status: 'error',
        message: 'User not found'
      });
    }

    res.json({
      status: 'success',
      data: {
        user: {
          id: user._id,
          username: user.username,
          email: user.email
        },
        profile
      }
    });
  } catch (error) {
    res.status(500).json({
      status: 'error',
      message: 'Failed to fetch user data',
      details: error.message
    });
  }
});

// Logout user
router.post('/logout', authenticateToken, async (req, res) => {
  try {
    const token = req.header('Authorization').replace('Bearer ', '');
    
    // Add token to blacklist
    await TokenBlacklist.create({ token });

    res.json({
      status: 'success',
      message: 'Logged out successfully'
    });
  } catch (error) {
    res.status(500).json({
      status: 'error',
      message: 'Logout failed',
      details: error.message
    });
  }
});

module.exports = router;
