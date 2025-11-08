import express from "express";
import * as functions from "firebase-functions";
import * as admin from "firebase-admin";
import {
  createUserProfile,
  UserProfile,
} from "../services/firestore/userRepository.js";

admin.apps.length === 0 && admin.initializeApp();

const app = express();
app.use(express.json());

// Simple auth middleware: verifies Firebase ID token
app.use(async (req: any, res, next) => {
  try {
    const auth = req.headers.authorization || "";
    const token = auth.startsWith("Bearer ") ? auth.substring(7) : "";
    if (!token) {
      console.log("Auth: Missing token in Authorization header");
      return res.status(401).json({"error": "Missing token"});
    }
    console.log("Auth: Verifying token");
    const decoded = await admin.auth().verifyIdToken(token);
    console.log("Auth: Token verified successfully for UID:", decoded.uid);
    req.uid = decoded.uid;
    return next();
  } catch (e) {
    console.error("Auth: Token verification failed:", e);
    const errorMessage = e instanceof Error ? e.message : String(e);
    return res.status(401).json({
      "error": "Invalid token",
      "details": errorMessage,
    });
  }
});

app.post("/users", async (req: any, res) => {
  try {
    const uid = req.uid;
    const {email, displayName, photoURL} = req.body || {};
    console.log("Creating user profile:", {uid, email, displayName, photoURL});

    const profile: UserProfile = {
      uid,
      email,
      displayName,
      photoURL,
      createdAt: Date.now(),
    };

    await createUserProfile(profile);
    console.log("User profile created successfully");
    return res.status(201).json({"ok": true});
  } catch (e) {
    console.error("Error creating user profile:", e);
    const errorMessage = e instanceof Error ? e.message : String(e);
    return res.status(500).json({
      "error": "Failed to create user",
      "details": errorMessage,
    });
  }
});

export const usersApi = functions.https.onRequest(app);

