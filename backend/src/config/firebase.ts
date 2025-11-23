import admin from 'firebase-admin';
import { config } from './index';
import * as fs from 'fs';

let firebaseInitialized = false;

export const initializeFirebase = (): void => {
  try {
    if (firebaseInitialized) {
      console.log('⚠️ Firebase already initialized.');
      return;
    }

    const serviceAccountPath = config.firebase.serviceAccountPath;
    
    if (!fs.existsSync(serviceAccountPath)) {
      console.warn('⚠️ Firebase service account file not found. FCM features will be disabled.');
      console.warn(`   Please add your firebase-service-account.json file to: ${serviceAccountPath}`);
      return;
    }

    const serviceAccount = JSON.parse(fs.readFileSync(serviceAccountPath, 'utf8'));

    admin.initializeApp({
      credential: admin.credential.cert(serviceAccount),
    });

    firebaseInitialized = true;
    console.log('✅ Firebase Admin SDK initialized successfully.');
  } catch (error) {
    console.error('❌ Failed to initialize Firebase Admin SDK:', error);
    console.warn('⚠️ FCM features will be disabled.');
  }
};

export const getFirebaseMessaging = () => {
  if (!firebaseInitialized) {
    throw new Error('Firebase is not initialized. FCM features are disabled.');
  }
  return admin.messaging();
};

export const isFirebaseInitialized = (): boolean => {
  return firebaseInitialized;
};
