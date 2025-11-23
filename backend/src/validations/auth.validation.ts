import Joi from 'joi';

/**
 * Validation schema for user registration
 */
export const registerSchema = Joi.object({
  name: Joi.string().min(2).max(100).required().messages({
    'string.empty': 'Name is required',
    'string.min': 'Name must be at least 2 characters long',
    'string.max': 'Name must not exceed 100 characters',
    'any.required': 'Name is required',
  }),
  email: Joi.string().email().required().messages({
    'string.empty': 'Email is required',
    'string.email': 'Email must be a valid email address',
    'any.required': 'Email is required',
  }),
  password: Joi.string().min(6).required().messages({
    'string.empty': 'Password is required',
    'string.min': 'Password must be at least 6 characters long',
    'any.required': 'Password is required',
  }),
});

/**
 * Validation schema for user login
 */
export const loginSchema = Joi.object({
  email: Joi.string().email().required().messages({
    'string.empty': 'Email is required',
    'string.email': 'Email must be a valid email address',
    'any.required': 'Email is required',
  }),
  password: Joi.string().required().messages({
    'string.empty': 'Password is required',
    'any.required': 'Password is required',
  }),
  fcmToken: Joi.string().optional().allow(null, ''),
  platform: Joi.string().valid('android', 'ios', 'web').optional().allow(null, ''),
});

/**
 * Validation schema for refresh token
 */
export const refreshTokenSchema = Joi.object({
  refreshToken: Joi.string().required().messages({
    'string.empty': 'Refresh token is required',
    'any.required': 'Refresh token is required',
  }),
});

/**
 * Validation schema for FCM token
 */
export const fcmTokenSchema = Joi.object({
  token: Joi.string().required().messages({
    'string.empty': 'FCM token is required',
    'any.required': 'FCM token is required',
  }),
  platform: Joi.string().valid('android', 'ios', 'web').required().messages({
    'string.empty': 'Platform is required',
    'any.required': 'Platform is required',
    'any.only': 'Platform must be one of: android, ios, web',
  }),
});
