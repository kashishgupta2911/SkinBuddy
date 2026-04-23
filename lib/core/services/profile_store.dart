class ProfileStore {
  ProfileStore._();
  static final ProfileStore instance = ProfileStore._();

  String fullName = 'Alice Williams';
  String email = 'alicewilliams@gmail.com';
  DateTime dateOfBirth = DateTime(1990, 6, 15);
  String skinType = 'Combination';
}
