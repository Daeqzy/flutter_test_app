import 'package:geocoding/geocoding.dart';

class PartnerCoordinates {
  final double latitude;
  final double longitude;
  final String resolvedFrom;

  const PartnerCoordinates({
    required this.latitude,
    required this.longitude,
    required this.resolvedFrom,
  });
}

class PartnerLocationService {
  final Geocoding _geocoding;

  PartnerLocationService({Geocoding? geocoding})
    : _geocoding = geocoding ?? Geocoding();

  Future<PartnerCoordinates> resolvePartnerLocation({
    required String partnerName,
    String? address,
    String? city,
  }) async {
    final cleanName = partnerName.trim();
    final cleanAddress = _clean(address);
    final cleanCity = _clean(city);

    if (cleanAddress == null && cleanCity == null) {
      throw Exception(
        'This partner does not have enough location information.',
      );
    }

    final queries = <String>[];

    // ========================================================
    // BEST QUERY
    // ========================================================
    //
    // Prefer the actual address first.
    //

    if (cleanAddress != null) {
      queries.add(
        [
          cleanAddress,
          if (cleanCity != null) cleanCity,
          'North Macedonia',
        ].join(', '),
      );
    }

    // ========================================================
    // SECOND ATTEMPT
    // ========================================================
    //
    // Include the business name as extra context.
    //

    if (cleanAddress != null && cleanName.isNotEmpty) {
      queries.add(
        [
          cleanName,
          cleanAddress,
          if (cleanCity != null) cleanCity,
          'North Macedonia',
        ].join(', '),
      );
    }

    // ========================================================
    // FALLBACK
    // ========================================================
    //
    // Useful if the backend has a company + city but no
    // street address.
    //

    if (cleanAddress == null && cleanCity != null && cleanName.isNotEmpty) {
      queries.add([cleanName, cleanCity, 'North Macedonia'].join(', '));
    }

    final uniqueQueries = queries.toSet();

    for (final query in uniqueQueries) {
      try {
        final locations = await _geocoding.locationFromAddress(query);

        if (locations.isNotEmpty) {
          final location = locations.first;

          return PartnerCoordinates(
            latitude: location.latitude,
            longitude: location.longitude,
            resolvedFrom: query,
          );
        }
      } catch (_) {
        // Try the next query variation.
      }
    }

    throw Exception('The location for this partner could not be found.');
  }

  String? _clean(String? value) {
    if (value == null) {
      return null;
    }

    final cleaned = value.trim();

    return cleaned.isEmpty ? null : cleaned;
  }
}
