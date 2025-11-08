import {
  createUserProfile,
  UserProfile,
} from "../src/services/firestore/userRepository";

jest.mock("firebase-admin/firestore", () => ({
  getFirestore: () => ({
    collection: () => ({
      doc: () => ({
        set: jest.fn().mockResolvedValue(undefined),
      }),
    }),
  }),
}));

describe("userRepository", () => {
  it("creates or merges user profile document", async () => {
    const profile: UserProfile = {
      uid: "abc",
      email: "test@example.com",
      displayName: "Tester",
      photoURL: "http://example.com/x.png",
      createdAt: Date.now(),
    };
    await expect(createUserProfile(profile)).resolves.toBeUndefined();
  });
});

