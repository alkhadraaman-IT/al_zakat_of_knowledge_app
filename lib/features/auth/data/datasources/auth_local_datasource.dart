import 'package:hive_ce/hive_ce.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/constants/app_keys.dart';
import '../models/profile_model.dart';
import '../models/user_model.dart';

/// Abstract local data source for authentication caching.
abstract class AuthLocalDataSource {
  /// Caches the authenticated user.
  Future<void> cacheUser(UserModel user);

  /// Retrieves the cached user.
  Future<UserModel?> getCachedUser();

  /// Clears the cached user.
  Future<void> clearCachedUser();

  /// Caches the user's profile row from the `profiles` table.
  Future<void> cacheProfile(ProfileModel profile);

  /// Retrieves the cached profile row.
  Future<ProfileModel?> getCachedProfile();

  /// Clears the cached profile row.
  Future<void> clearCachedProfile();

  /// Checks if onboarding is completed.
  Future<bool> isOnboardingCompleted();

  /// Sets onboarding completed flag.
  Future<void> setOnboardingCompleted(bool value);

  /// Checks if user is logged in.
  Future<bool> isLoggedIn();

  /// Sets logged in flag.
  Future<void> setLoggedIn(bool value);
}

/// Hive + SharedPreferences implementation of [AuthLocalDataSource].
class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final Box authBox;
  final Box userBox;
  final SharedPreferences sharedPreferences;

  AuthLocalDataSourceImpl({
    required this.authBox,
    required this.userBox,
    required this.sharedPreferences,
  });

  @override
  Future<void> cacheUser(UserModel user) async {
    print('<<<<<<<<<<<[cacheUser]>>>>>>>>>>>>>');
    await userBox.put(AppKeys.CURRENT_USER, user.toHive());
    await authBox.put(AppKeys.IS_LOGGED_IN, true);
  }

  @override
  Future<UserModel?> getCachedUser() async {
    print('<<<<<<<<<<<[getCachedUser]>>>>>>>>>>>>>');
    final userData = userBox.get(AppKeys.CURRENT_USER);
    if (userData == null) return null;
    return UserModel.fromHive(Map<dynamic, dynamic>.from(userData));
  }

  @override
  Future<void> clearCachedUser() async {
    print('<<<<<<<<<<<[clearCachedUser]>>>>>>>>>>>>>');
    await userBox.delete(AppKeys.CURRENT_USER);
    await authBox.put(AppKeys.IS_LOGGED_IN, false);
  }

  @override
  Future<void> cacheProfile(ProfileModel profile) async {
    print('<<<<<<<<<<<[cacheProfile]>>>>>>>>>>>>>');
    await userBox.put(AppKeys.CURRENT_PROFILE, profile.toHive());
  }

  @override
  Future<ProfileModel?> getCachedProfile() async {
    print('<<<<<<<<<<<[getCachedProfile]>>>>>>>>>>>>>');
    final profileData = userBox.get(AppKeys.CURRENT_PROFILE);
    if (profileData == null) return null;
    return ProfileModel.fromHive(Map<dynamic, dynamic>.from(profileData));
  }

  @override
  Future<void> clearCachedProfile() async {
    print('<<<<<<<<<<<[clearCachedProfile]>>>>>>>>>>>>>');
    await userBox.delete(AppKeys.CURRENT_PROFILE);
  }

  @override
  Future<bool> isOnboardingCompleted() async {
    print('<<<<<<<<<<<[isOnboardingCompleted]>>>>>>>>>>>>>');
    return sharedPreferences.getBool(AppKeys.ONBOARDING_COMPLETED) ?? false;
  }

  @override
  Future<void> setOnboardingCompleted(bool value) async {
    print('<<<<<<<<<<<[setOnboardingCompleted]>>>>>>>>>>>>>');
    await sharedPreferences.setBool(AppKeys.ONBOARDING_COMPLETED, value);
  }

  @override
  Future<bool> isLoggedIn() async {
    print('<<<<<<<<<<<[isLoggedIn]>>>>>>>>>>>>>');
    return authBox.get(AppKeys.IS_LOGGED_IN) ?? false;
  }

  @override
  Future<void> setLoggedIn(bool value) async {
    print('<<<<<<<<<<<[setLoggedIn]>>>>>>>>>>>>>');
    await authBox.put(AppKeys.IS_LOGGED_IN, value);
  }
}
