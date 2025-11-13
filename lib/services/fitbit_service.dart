import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class FitbitService {
  // Fitbit OAuth Credentials
  static const String clientId = 'YOUR_CLIENT_ID';
  static const String clientSecret = 'YOUR_CLIENT_SECRET';
  static const String redirectUri = 'YOUR_REDIRECT_URI';

  // Fitbit API Endpoints
  static const String authorizationUrl = 'https://www.fitbit.com/oauth2/authorize';
  static const String tokenUrl = 'https://api.fitbit.com/oauth2/token';
  static const String apiBaseUrl = 'https://api.fitbit.com/1/user/-';

  // Secure Storage
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  // Storage Keys
  static const String _accessTokenKey = 'fitbit_access_token';
  static const String _refreshTokenKey = 'fitbit_refresh_token';

  // OAuth: Generate Authorization URL
  String getAuthorizationUrl() {
    final params = {
      'response_type': 'code',
      'client_id': clientId,
      'redirect_uri': redirectUri,
      'scope': 'activity heartrate sleep',
      'expires_in': '604800', // 7 days
    };

    final queryString = params.entries
        .map((e) => '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
        .join('&');

    return '$authorizationUrl?$queryString';
  }

  // OAuth: Exchange Authorization Code for Tokens
  Future<bool> exchangeAuthorizationCode(String code) async {
    try {
      final response = await http.post(
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

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        await _storage.write(key: _accessTokenKey, value: data['access_token']);
        await _storage.write(key: _refreshTokenKey, value: data['refresh_token']);
        return true;
      } else {
        print('Token exchange failed: ${response.statusCode} - ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error exchanging authorization code: $e');
      return false;
    }
  }

  // Token Management: Get Access Token
  Future<String?> getAccessToken() async {
    try {
      return await _storage.read(key: _accessTokenKey);
    } catch (e) {
      print('Error reading access token: $e');
      return null;
    }
  }

  // Token Management: Check if authenticated
  Future<bool> isAuthenticated() async {
    final token = await getAccessToken();
    return token != null && token.isNotEmpty;
  }

  // Token Management: Delete tokens (disconnect)
  Future<void> deleteTokens() async {
    try {
      await _storage.delete(key: _accessTokenKey);
      await _storage.delete(key: _refreshTokenKey);
    } catch (e) {
      print('Error deleting tokens: $e');
    }
  }

  // API Call: Get Steps for Today
  Future<int?> getStepsToday() async {
    try {
      final token = await getAccessToken();
      if (token == null) {
        throw Exception('Nicht authentifiziert');
      }

      final today = DateTime.now();
      final dateString = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

      final response = await http.get(
        Uri.parse('$apiBaseUrl/activities/date/$dateString.json'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final steps = data['summary']?['steps'];
        return steps is int ? steps : null;
      } else if (response.statusCode == 401) {
        // Token expired, try to refresh
        final refreshed = await _refreshAccessToken();
        if (refreshed) {
          return await getStepsToday(); // Retry
        }
        throw Exception('Authentifizierung fehlgeschlagen');
      } else {
        print('Get steps failed: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error getting steps: $e');
      rethrow;
    }
  }

  // API Call: Get Resting Heart Rate
  Future<int?> getRestingHeartRate() async {
    try {
      final token = await getAccessToken();
      if (token == null) {
        throw Exception('Nicht authentifiziert');
      }

      final today = DateTime.now();
      final dateString = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

      final response = await http.get(
        Uri.parse('$apiBaseUrl/activities/heart/date/$dateString/1d.json'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final heartRateData = data['activities-heart'];
        if (heartRateData != null && heartRateData.isNotEmpty) {
          final restingHeartRate = heartRateData[0]?['value']?['restingHeartRate'];
          return restingHeartRate is int ? restingHeartRate : null;
        }
        return null;
      } else if (response.statusCode == 401) {
        // Token expired, try to refresh
        final refreshed = await _refreshAccessToken();
        if (refreshed) {
          return await getRestingHeartRate(); // Retry
        }
        throw Exception('Authentifizierung fehlgeschlagen');
      } else {
        print('Get heart rate failed: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error getting heart rate: $e');
      rethrow;
    }
  }

  // Token Refresh
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
}
