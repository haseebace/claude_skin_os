import { getFirestore } from 'firebase-admin/firestore';

export interface UserProfile {
  uid: string;
  email?: string;
  displayName?: string;
  photoURL?: string;
  createdAt: number;
}

export async function createUserProfile(profile: UserProfile): Promise<void> {
  const db = getFirestore();
  const ref = db.collection('users').doc(profile.uid);
  await ref.set(profile, { merge: true });
}

