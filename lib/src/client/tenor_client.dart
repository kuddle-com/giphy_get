import 'dart:async';
import 'dart:convert';

import 'package:giphy_get/src/client/models/gif.dart';
import 'package:giphy_get/src/client/models/languages.dart';
import 'package:giphy_get/src/client/models/rating.dart';
import 'package:giphy_get/src/client/models/type.dart';
import 'package:http/http.dart';

import 'models/collection.dart';

class TenorClient {
  static final baseUri = Uri(scheme: 'https', host: 'tenor.googleapis.com');

  final String _apiKey;
  final String _clientKey;
  final Client _client = Client();
  final String _apiVersion = 'v2';

  TenorClient({required String apiKey, required String clientKey})
      : _apiKey = apiKey,
        _clientKey = clientKey;

  Future<TenorCollection> trending(
      {int limit = 30,
      String rating = TenorRating.high,
      String lang = 'en_IN',
      String country = 'IN',
      String type = TenorType.tinyGif,
      String? next}) async {
    return _fetchCollection(
      baseUri.replace(
        path: '$_apiVersion/featured',
        queryParameters: <String, String>{
          'limit': '$limit',
          'contentfilter': rating,
          'country': country,
          'locale': lang,
          'media_filter': type,
          if (next != null) 'pos': next,
        },
      ),
    );
  }

  Future<TenorCollection> search(String query,
      {int limit = 30,
      String rating = TenorRating.high,
      String lang = 'en_IN',
      String country = 'IN',
      String type = TenorType.tinyGif,
      String? next}) async {
    return _fetchCollection(
      baseUri.replace(
        path: '$_apiVersion/search',
        queryParameters: <String, String>{
          'q': query,
          'limit': '$limit',
          'contentfilter': rating,
          'country': country,
          'locale': lang,
          'media_filter': type,
          if (next != null) 'pos': next,
        },
      ),
    );
  }

  Future<TenorCollection> _fetchCollection(Uri uri) async {
    final response = await _getWithAuthorization(uri);
    return TenorCollection.fromJson(
        json.decode(response.body) as Map<String, dynamic>);
  }

  Future<Response> _getWithAuthorization(Uri uri) async {
    Map<String, String> queryParams = Map.from(uri.queryParameters)
      ..putIfAbsent('key', () => _apiKey)
      ..putIfAbsent('client_key', () => _clientKey);

    final response =
        await _client.get(uri.replace(queryParameters: queryParams));

    if (response.statusCode == 200) {
      return response;
    } else {
      throw TenorClientError(response.statusCode, response.body);
    }
  }
}

class TenorClientError {
  final int statusCode;
  final String exception;

  TenorClientError(this.statusCode, this.exception);

  @override
  String toString() {
    return 'TenorClientError{statusCode: $statusCode, exception: $exception}';
  }
}
