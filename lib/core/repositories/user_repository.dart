import '../models/user_profile.dart';
import '../services/firestore_service.dart';
import '../di/dependency_injection.dart';

class UserRepository {
  final FirestoreService _firestoreService = getIt<FirestoreService>();

  Future<void> createProfile(UserProfile profile) async {
    await _firestoreService.createUserProfile(profile);
  }

  Future<UserProfile?> getProfile(String userId) async {
    return await _firestoreService.getUserProfile(userId);
  }

  Future<void> updateProfile(UserProfile profile) async {
    await _firestoreService.updateUserProfile(profile);
  }

  Stream<UserProfile?> watchProfile(String userId) {
    return _firestoreService.watchUserProfile(userId);
  }

  Future<void> updateUserPreferences(
      String userId, Map<String, dynamic> preferences) async {
    final currentProfile = await getProfile(userId);
    if (currentProfile != null) {
      final updatedProfile = currentProfile.copyWith(
        preferences: preferences,
        updatedAt: DateTime.now(),
      );
      await updateProfile(updatedProfile);
    }
  }

  Future<void> setUserRole(String userId, UserRole role) async {
    final currentProfile = await getProfile(userId);
    if (currentProfile != null) {
      final updatedProfile = currentProfile.copyWith(
        role: role,
        updatedAt: DateTime.now(),
      );
      await updateProfile(updatedProfile);
    }
  }
}
