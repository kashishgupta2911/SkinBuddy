class ProfileStore {
  ProfileStore._();
  static final ProfileStore instance = ProfileStore._();

  String firstName = 'Alice';
  String lastName = 'Williams';
  String email = 'alicewilliams@gmail.com';
  DateTime dateOfBirth = DateTime(1990, 6, 15);
  String skinType = 'Combination';

  bool scanReminders = true;
  bool resultsReady = true;
  bool weeklyTips = false;
  bool productUpdates = false;

  bool shareAnonymousData = true;
  bool localStorageOnly = true;
  bool biometricLock = false;
}
