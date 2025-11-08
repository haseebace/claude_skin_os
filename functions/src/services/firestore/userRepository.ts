import {getFirestore} from "firebase-admin/firestore";

export interface UserProfile {
  uid: string;
  email?: string;
  displayName?: string;
  photoURL?: string;
  createdAt: number;
}

/**
 * Creates or updates a user profile in Firestore.
 * @param {UserProfile} profile The user profile to save.
 */
export async function createUserProfile(profile: UserProfile): Promise<void> {
  const db = getFirestore();
  const ref = db.collection("users").doc(profile.uid);
  await ref.set(profile, {"merge": true});
}

