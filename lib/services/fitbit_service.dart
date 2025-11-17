import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_web_auth_2/flutter_web_auth_2.dart';

class FitbitService {
  // Fitbit OAuth Credentials
  // SECURITY NOTE: In production, the client secret should be handled by a backend proxy server
  // to prevent exposure in the mobile app code. For MVP/prototype purposes, this is acceptable.
  static const String clientId = '23TQK4';
  static const String clientSecret = 'f7cd25a75d12571fc486a915458feae9';
  static const String redirectUri = 'epilepsytracker://fitbit/callback';
  static const String callbackScheme = 'epilepsytracker';

  // Fitbit API URLs
  static const String authorizationUrl = 'https://www.fitbit.com/oauth2/authorize';
  static const String tokenUrl = 'https://api.fitbit.com/oauth2/token';
  static const String apiBaseUrl = 'https://api.fitbit.com/1/user/-';

  // Secure Storage
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  // Storage Keys
  static const String _userIdKey = 'fitbit_user_id';
  static const String _accessTokenKey = 'fitbit_access_token';
  static const String _refreshTokenKey = 'fitbit_refresh_token';

  // Authorize and get tokens
  Future<bool> authorize() async {
    try {
      // Build authorization URL
      final authUrl = Uri.https('www.fitbit.com', '/oauth2/authorize', {
        'response_type': 'code',
        'client_id': clientId,
        'redirect_uri': redirectUri,
        'scope': 'activity heartrate sleep',
        'expires_in': '604800',
      });

      // Open browser and wait for callback
      final result = await FlutterWebAuth2.authenticate(
        url: authUrl.toString(),
        callbackUrlScheme: callbackScheme,
      );

      // Extract authorization code from callback
      final code = Uri.parse(result).queryParameters['code'];

      if (code == null || code.isEmpty) {
        print('No authorization code received');
        return false;
      }

      // Exchange code for tokens
      final tokenResponse = await http.post(
        Uri.parse(tokenUrl),
        headers: {
          'Authorization': 'Basic ${base64Encode(utf8.encode('$clientId:$clientSecret'))}',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'code': code,
          'grant_type': 'authorization_code',
          'redirect_uri': redirectUri,
        },
      );

      if (tokenResponse.statusCode == 200) {
        final data = json.decode(tokenResponse.body);

        // Save credentials
        await _storage.write(key: _userIdKey, value: data['user_id']);
        await _storage.write(key: _accessTokenKey, value: data['access_token']);
        await _storage.write(key: _refreshTokenKey, value: data['refresh_token']);

        print('Authorization successful! User ID: ${data['user_id']}');
        return true;
      } else {
        print('Token exchange failed: ${tokenResponse.statusCode} - ${tokenResponse.body}');
        return false;
      }
    } catch (e) {
      print('Error during authorization: $e');
      return false;
    }
  }

  // Check if authenticated
  Future<bool> isAuthenticated() async {
    try {
      final userId = await _storage.read(key: _userIdKey);
      final accessToken = await _storage.read(key: _accessTokenKey);
      return userId != null &&
             userId.isNotEmpty &&
             accessToken != null &&
             accessToken.isNotEmpty;
    } catch (e) {
      print('Error checking authentication: $e');
      return false;
    }
  }

  // Get access token
  Future<String?> getAccessToken() async {
    try {
      return await _storage.read(key: _accessTokenKey);
    } catch (e) {
      print('Error reading access token: $e');
      return null;
    }
  }

  // Get Steps for Today
  Future<int?> getStepsToday() async {
    try {
      final token = await getAccessToken();
      if (token == null) {
        print('Fitbit: No access token available');
        throw Exception('Nicht authentifiziert');
      }

      final today = DateTime.now();
      final dateString = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

      print('Fitbit: Fetching steps for $dateString');
      final response = await http.get(
        Uri.parse('$apiBaseUrl/activities/date/$dateString.json'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw Exception('Request timeout - bitte überprüfen Sie Ihre Internetverbindung');
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final steps = data['summary']?['steps'];
        print('Fitbit: Steps retrieved successfully: $steps');
        return steps is int ? steps : null;
      } else if (response.statusCode == 401) {
        // Token expired, try to refresh
        print('Fitbit: Token expired, attempting refresh...');
        final refreshed = await _refreshAccessToken();
        if (refreshed) {
          print('Fitbit: Token refreshed, retrying...');
          return await getStepsToday(); // Retry
        }
        throw Exception('Authentifizierung fehlgeschlagen');
      } else {
        print('Fitbit: Get steps failed: ${response.statusCode} - ${response.body}');
        throw Exception('Fehler beim Abrufen der Schritte (${response.statusCode})');
      }
    } catch (e) {
      print('Fitbit: Error getting steps: $e');
      rethrow;
    }
  }

  // Get Resting Heart Rate
  Future<int?> getRestingHeartRate() async {
    try {
      final token = await getAccessToken();
      if (token == null) {
        print('Fitbit: No access token available');
        throw Exception('Nicht authentifiziert');
      }

      final today = DateTime.now();
      final dateString = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

      print('Fitbit: Fetching heart rate for $dateString');
      final response = await http.get(
        Uri.parse('$apiBaseUrl/activities/heart/date/$dateString/1d.json'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw Exception('Request timeout - bitte überprüfen Sie Ihre Internetverbindung');
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final heartRateData = data['activities-heart'];
        if (heartRateData != null && heartRateData.isNotEmpty) {
          final restingHeartRate = heartRateData[0]?['value']?['restingHeartRate'];
          print('Fitbit: Heart rate retrieved successfully: $restingHeartRate');
          return restingHeartRate is int ? restingHeartRate : null;
        }
        print('Fitbit: No heart rate data available for today');
        return null;
      } else if (response.statusCode == 401) {
        // Token expired, try to refresh
        print('Fitbit: Token expired, attempting refresh...');
        final refreshed = await _refreshAccessToken();
        if (refreshed) {
          print('Fitbit: Token refreshed, retrying...');
          return await getRestingHeartRate(); // Retry
        }
        throw Exception('Authentifizierung fehlgeschlagen');
      } else {
        print('Fitbit: Get heart rate failed: ${response.statusCode} - ${response.body}');
        throw Exception('Fehler beim Abrufen der Herzfrequenz (${response.statusCode})');
      }
    } catch (e) {
      print('Fitbit: Error getting heart rate: $e');
      rethrow;
    }
  }

  // Refresh access token
  Future<bool> _refreshAccessToken() async {
    try {
      final refreshToken = await _storage.read(key: _refreshTokenKey);
      if (refreshToken == null) {
        return false;
      }

      final response = await http.post(
        Uri.parse(tokenUrl),
        headers: {
          'Authorization': 'Basic ${base64Encode(utf8.encode('$clientId:$clientSecret'))}',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'grant_type': 'refresh_token',
          'refresh_token': refreshToken,
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        await _storage.write(key: _accessTokenKey, value: data['access_token']);
        await _storage.write(key: _refreshTokenKey, value: data['refresh_token']);
        return true;
      } else {
        print('Token refresh failed: ${response.statusCode} - ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error refreshing token: $e');
      return false;
    }
  }

  // Delete tokens (disconnect)
  Future<void> deleteTokens() async {
    try {
      await _storage.delete(key: _userIdKey);
      await _storage.delete(key: _accessTokenKey);
      await _storage.delete(key: _refreshTokenKey);
    } catch (e) {
      print('Error deleting tokens: $e');
    }
  }
}
