import express from 'express';
import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';
import { createUserProfile, UserProfile } from '../services/firestore/userRepository.js';

admin.apps.length === 0 && admin.initializeApp();

const app = express();
app.use(express.json());

// Simple auth middleware: verifies Firebase ID token from Authorization: Bearer <token>
app.use(async (req, res, next) => {
  try {
    const auth = req.headers.authorization || '';
    const token = auth.startsWith('Bearer ') ? auth.substring(7) : '';
    if (!token) return res.status(401).json({ error: 'Missing token' });
    const decoded = await admin.auth().verifyIdToken(token);
    (req as any).uid = decoded.uid;
    next();
  } catch (e) {
    return res.status(401).json({ error: 'Invalid token' });
  }
});

app.post('/users', async (req, res) => {
  try {
    const uid = (req as any).uid as string;
    const { email, displayName, photoURL } = req.body || {};
    const profile: UserProfile = {
      uid,
      email,
      displayName,
      photoURL,
      createdAt: Date.now(),
    };
    await createUserProfile(profile);
    return res.status(201).json({ ok: true });
  } catch (e) {
    return res.status(500).json({ error: 'Failed to create user' });
  }
});

export const usersApi = functions.https.onRequest(app);

