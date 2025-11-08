class AppConfig {
  // Placeholder for environment-specific config. In real app, inject via flavors.
  // Default to us-central1 for Firebase Functions when no region specified in code.
  // Project detected from .firebaserc: skin-agent-e82e1
  static const String apiBaseUrl = 'https://us-central1-skin-agent-e82e1.cloudfunctions.net';
}
