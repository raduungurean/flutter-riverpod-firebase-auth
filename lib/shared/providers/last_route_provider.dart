import 'package:shared_preferences/shared_preferences.dart';

class LastRouteService {
  static const _lastAuthenticatedRouteKey = 'lastAuthenticatedRoute';

  Future<void> updateLastAuthenticatedRoute(String route) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_lastAuthenticatedRouteKey, route);
  }

  Future<String?> getLastAuthenticatedRoute() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_lastAuthenticatedRouteKey);
  }

  Future<void> clearLastAuthenticatedRoute() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.remove(_lastAuthenticatedRouteKey);
  }
}
