import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../models/login_request.dart';
import '../models/login_response.dart';
import '../models/mat_partner_data.dart';
import '../models/partner_connection_data.dart';
import '../models/partner_agreement_data.dart';
import '../models/partner_contact_data.dart';

part 'api_service.g.dart';

@RestApi()
abstract class ApiService {
  factory ApiService(Dio dio, {String? baseUrl}) = _ApiService;

  // ----------------------------------------------------------
  // AUTHENTICATION
  // ----------------------------------------------------------

  @POST('api/Account/Login')
  Future<LoginResponse> login(@Body() LoginRequest request);

  // ----------------------------------------------------------
  // PARTNERS
  // ----------------------------------------------------------

  @GET('api/MobileIntra/GetPartners')
  Future<List<MatPartnerData>> getPartners();

  // ----------------------------------------------------------
  // PARTNER CONNECTIONS
  // ----------------------------------------------------------

  @GET('api/MobileIntra/GetPartnerConnections')
  Future<List<PartnerConnectionData>> getPartnerConnections(
    @Query('tp') int tp,
    @Query('p') int p,
  );

  // ----------------------------------------------------------
  // PARTNER AGREEMENTS
  // ----------------------------------------------------------

  @GET('api/MobileIntra/GetPartnerAgreements')
  Future<List<PartnerAgreementData>> getPartnerAgreements(
    @Query('tp') int tp,
    @Query('p') int p,
  );

  // ----------------------------------------------------------
  // PARTNER CONTACTS
  // ----------------------------------------------------------

  @GET('api/MobileIntra/GetPartnerContacts')
  Future<List<PartnerContactData>> getPartnerContacts(
    @Query('tp') int tp,
    @Query('p') int p,
  );
}
