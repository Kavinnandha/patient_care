const jwt = require('jsonwebtoken');
const rateLimit = require('express-rate-limit');
const { TokenBlacklist } = require('../schemas/TokenBlacklist');

// Rate limiting for login attempts
const loginLimiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 5, // 5 attempts per window
  message: {
    status: 'error',
    message: 'Too many login attempts, please try again after 15 minutes'
  }
});

// Rate limiting for registration
const registrationLimiter = rateLimit({
  windowMs: 60 * 60 * 1000, // 1 hour
  max: 3, // 3 attempts per window
  message: {
    status: 'error',
    message: 'Too many registration attempts, please try again after 1 hour'
  }
});

// Verify JWT token
const authenticateToken = async (req, res, next) => {
  try {
    const authHeader = req.header('Authorization');
    if (!authHeader) {
      return res.status(401).json({
        status: 'error',
        message: 'Access denied. No token provided.'
      });
    }

    const token = authHeader.replace('Bearer ', '');

    // Check if token is blacklisted
    const isBlacklisted = await TokenBlacklist.exists({ token });
    if (isBlacklisted) {
      return res.status(401).json({
        status: 'error',
        message: 'Token has been invalidated'
      });
    }

    // Verify token
    const decoded = jwt.verify(token, process.env.JWT_SECRET);
    req.user = decoded;
    next();
  } catch (error) {
    if (error.name === 'TokenExpiredError') {
      return res.status(401).json({
        status: 'error',
        message: 'Token expired'
      });
    }
    return res.status(401).json({
      status: 'error',
      message: 'Invalid token'
    });
  }
};

// Generate tokens
const generateTokens = (userData) => {
  const accessToken = jwt.sign(
    userData,
    process.env.JWT_SECRET,
    { expiresIn: '1h' }
  );

  const refreshToken = jwt.sign(
    userData,
    process.env.REFRESH_TOKEN_SECRET,
    { expiresIn: '7d' }
  );

  return { accessToken, refreshToken };
};

// Refresh token middleware
const refreshToken = async (req, res, next) => {
  try {
    const refreshToken = req.body.refreshToken;
    if (!refreshToken) {
      return res.status(401).json({
        status: 'error',
        message: 'Refresh token required'
      });
    }

    // Verify refresh token
    const decoded = jwt.verify(refreshToken, process.env.REFRESH_TOKEN_SECRET);
    
    // Generate new tokens
    const { accessToken, refreshToken: newRefreshToken } = generateTokens({
      userId: decoded.userId,
      username: decoded.username,
      profileId: decoded.profileId
    });

    res.json({
      status: 'success',
      accessToken,
      refreshToken: newRefreshToken
    });
  } catch (error) {
    return res.status(401).json({
      status: 'error',
      message: 'Invalid refresh token'
    });
  }
};

module.exports = {
  loginLimiter,
  registrationLimiter,
  authenticateToken,
  generateTokens,
  refreshToken
};
