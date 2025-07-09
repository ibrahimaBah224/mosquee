import 'package:shared_preferences/shared_preferences.dart';

class AdminAuthService {
  static const String _isLoggedInKey = 'admin_logged_in';
  static const String _adminPasswordKey = 'admin_password';

  // Mot de passe par défaut (peut être changé dans les paramètres)
  static const String _defaultPassword = 'MOMED2024';

  static AdminAuthService? _instance;
  static AdminAuthService get instance => _instance ??= AdminAuthService._();

  AdminAuthService._();

  /// Vérifie si l'admin est connecté
  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_isLoggedInKey) ?? false;
  }

  /// Connecte l'admin avec un mot de passe
  Future<bool> login(String password) async {
    final prefs = await SharedPreferences.getInstance();
    final savedPassword =
        prefs.getString(_adminPasswordKey) ?? _defaultPassword;

    if (password == savedPassword) {
      await prefs.setBool(_isLoggedInKey, true);
      return true;
    }
    return false;
  }

  /// Déconnecte l'admin
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_isLoggedInKey, false);
  }

  /// Change le mot de passe admin
  Future<void> changePassword(String newPassword) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_adminPasswordKey, newPassword);
  }

  /// Obtient le mot de passe actuel (pour l'affichage dans les paramètres)
  Future<String> getCurrentPassword() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_adminPasswordKey) ?? _defaultPassword;
  }

  /// Réinitialise le mot de passe au défaut
  Future<void> resetPassword() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_adminPasswordKey, _defaultPassword);
  }
}
