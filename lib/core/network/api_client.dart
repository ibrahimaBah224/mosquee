import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import '../config/app_config.dart';

part 'api_client.g.dart';

@RestApi(baseUrl: AppConfig.baseUrl)
abstract class ApiClient {
  factory ApiClient(Dio dio, {String baseUrl}) = _ApiClient;

  // Auth endpoints
  @POST('/auth/login')
  Future<Map<String, dynamic>> login(@Body() Map<String, dynamic> body);

  @POST('/auth/register')
  Future<Map<String, dynamic>> register(@Body() Map<String, dynamic> body);

  @POST('/auth/logout')
  Future<void> logout();

  // Events endpoints
  @GET('/events')
  Future<List<Map<String, dynamic>>> getEvents();

  @GET('/events/{id}')
  Future<Map<String, dynamic>> getEvent(@Path() String id);

  // Donations endpoints
  @POST('/donations')
  Future<Map<String, dynamic>> createDonation(
    @Body() Map<String, dynamic> body,
  );

  @GET('/donations/stats')
  Future<Map<String, dynamic>> getDonationStats();

  // News endpoints
  @GET('/news')
  Future<List<Map<String, dynamic>>> getNews();

  @GET('/news/{id}')
  Future<Map<String, dynamic>> getNewsArticle(@Path() String id);
}
