import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../models/location_result.dart';
import '../models/login_request.dart';
import '../models/login_response.dart';
import '../models/mat_partner_data.dart';

part 'api_service.g.dart';

@RestApi(baseUrl: 'http://10.20.1.100:5541/')
abstract class ApiService {
  factory ApiService(Dio dio, {String? baseUrl}) = _ApiService;

  @POST('api/Account/Login')
  Future<LoginResponse> login(@Body() LoginRequest request);

  @GET('api/MobileIntra/GetPartners')
  Future<List<MatPartnerData>> getPartners();
}
