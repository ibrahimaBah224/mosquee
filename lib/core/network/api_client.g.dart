// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'api_client.dart';

// **************************************************************************
// RetrofitGenerator
// **************************************************************************

// ignore_for_file: unnecessary_brace_in_string_interps,no_leading_underscores_for_local_identifiers,unused_element

class _ApiClient implements ApiClient {
  _ApiClient(this._dio, {this.baseUrl, this.errorLogger}) {
    baseUrl ??= 'https://api.mosquee-alnour.fr';
  }

  final Dio _dio;

  String? baseUrl;

  final ParseErrorLogger? errorLogger;

  @override
  Future<Map<String, dynamic>> login(Map<String, dynamic> body) async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _headers = <String, dynamic>{};
    final _data = <String, dynamic>{};
    _data.addAll(body);
    final _options = Options(
      method: 'POST',
      headers: _headers,
      extra: _extra,
    ).compose(
      _dio.options,
      '/auth/login',
      queryParameters: queryParameters,
      data: _data,
    );
    final _result = await _dio.fetch<Map<String, dynamic>>(_options);
    return _result.data!;
  }

  @override
  Future<Map<String, dynamic>> register(Map<String, dynamic> body) async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _headers = <String, dynamic>{};
    final _data = <String, dynamic>{};
    _data.addAll(body);
    final _options = Options(
      method: 'POST',
      headers: _headers,
      extra: _extra,
    ).compose(
      _dio.options,
      '/auth/register',
      queryParameters: queryParameters,
      data: _data,
    );
    final _result = await _dio.fetch<Map<String, dynamic>>(_options);
    return _result.data!;
  }

  @override
  Future<void> logout() async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _headers = <String, dynamic>{};
    const Map<String, dynamic>? _data = null;
    final _options = Options(
      method: 'POST',
      headers: _headers,
      extra: _extra,
    ).compose(
      _dio.options,
      '/auth/logout',
      queryParameters: queryParameters,
      data: _data,
    );
    await _dio.fetch<void>(_options);
  }

  @override
  Future<List<Map<String, dynamic>>> getEvents() async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _headers = <String, dynamic>{};
    const Map<String, dynamic>? _data = null;
    final _options = Options(
      method: 'GET',
      headers: _headers,
      extra: _extra,
    ).compose(
      _dio.options,
      '/events',
      queryParameters: queryParameters,
      data: _data,
    );
    final _result = await _dio.fetch<List<dynamic>>(_options);
    return _result.data!.map((dynamic i) => i as Map<String, dynamic>).toList();
  }

  @override
  Future<Map<String, dynamic>> getEvent(String id) async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _headers = <String, dynamic>{};
    const Map<String, dynamic>? _data = null;
    final _options = Options(
      method: 'GET',
      headers: _headers,
      extra: _extra,
    ).compose(
      _dio.options,
      '/events/$id',
      queryParameters: queryParameters,
      data: _data,
    );
    final _result = await _dio.fetch<Map<String, dynamic>>(_options);
    return _result.data!;
  }

  @override
  Future<Map<String, dynamic>> createDonation(Map<String, dynamic> body) async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _headers = <String, dynamic>{};
    final _data = <String, dynamic>{};
    _data.addAll(body);
    final _options = Options(
      method: 'POST',
      headers: _headers,
      extra: _extra,
    ).compose(
      _dio.options,
      '/donations',
      queryParameters: queryParameters,
      data: _data,
    );
    final _result = await _dio.fetch<Map<String, dynamic>>(_options);
    return _result.data!;
  }

  @override
  Future<Map<String, dynamic>> getDonationStats() async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _headers = <String, dynamic>{};
    const Map<String, dynamic>? _data = null;
    final _options = Options(
      method: 'GET',
      headers: _headers,
      extra: _extra,
    ).compose(
      _dio.options,
      '/donations/stats',
      queryParameters: queryParameters,
      data: _data,
    );
    final _result = await _dio.fetch<Map<String, dynamic>>(_options);
    return _result.data!;
  }

  @override
  Future<List<Map<String, dynamic>>> getNews() async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _headers = <String, dynamic>{};
    const Map<String, dynamic>? _data = null;
    final _options = Options(
      method: 'GET',
      headers: _headers,
      extra: _extra,
    ).compose(
      _dio.options,
      '/news',
      queryParameters: queryParameters,
      data: _data,
    );
    final _result = await _dio.fetch<List<dynamic>>(_options);
    return _result.data!.map((dynamic i) => i as Map<String, dynamic>).toList();
  }

  @override
  Future<Map<String, dynamic>> getNewsArticle(String id) async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _headers = <String, dynamic>{};
    const Map<String, dynamic>? _data = null;
    final _options = Options(
      method: 'GET',
      headers: _headers,
      extra: _extra,
    ).compose(
      _dio.options,
      '/news/$id',
      queryParameters: queryParameters,
      data: _data,
    );
    final _result = await _dio.fetch<Map<String, dynamic>>(_options);
    return _result.data!;
  }

  @override
  Future<List<Map<String, dynamic>>> getDonations() async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _headers = <String, dynamic>{};
    const Map<String, dynamic>? _data = null;
    final _options = Options(
      method: 'GET',
      headers: _headers,
      extra: _extra,
    ).compose(
      _dio.options,
      '/donations',
      queryParameters: queryParameters,
      data: _data,
    );
    final _result = await _dio.fetch<List<dynamic>>(_options);
    return _result.data!.map((dynamic i) => i as Map<String, dynamic>).toList();
  }

  @override
  Future<Map<String, dynamic>> getDonation(String id) async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _headers = <String, dynamic>{};
    const Map<String, dynamic>? _data = null;
    final _options = Options(
      method: 'GET',
      headers: _headers,
      extra: _extra,
    ).compose(
      _dio.options,
      '/donations/$id',
      queryParameters: queryParameters,
      data: _data,
    );
    final _result = await _dio.fetch<Map<String, dynamic>>(_options);
    return _result.data!;
  }
}
