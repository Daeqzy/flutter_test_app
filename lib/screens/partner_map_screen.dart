import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class PartnerMapScreen extends StatelessWidget {
  final String partnerName;

  final String? city;
  final String? address;

  final double latitude;
  final double longitude;

  const PartnerMapScreen({
    super.key,
    required this.partnerName,
    required this.latitude,
    required this.longitude,
    this.city,
    this.address,
  });

  bool _hasText(String? value) {
    return value != null && value.trim().isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    final isDark = Theme.of(context).brightness == Brightness.dark;

    final location = LatLng(latitude, longitude);

    final locationText = [
      if (_hasText(address)) address!.trim(),
      if (_hasText(city)) city!.trim(),
    ].join(', ');

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,

      // ========================================================
      // APP BAR
      // ========================================================
      appBar: AppBar(
        toolbarHeight: 72,
        titleSpacing: 8,

        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            Text(
              partnerName,

              maxLines: 1,

              overflow: TextOverflow.ellipsis,

              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.3,
                color: colors.onSurface,
              ),
            ),

            const SizedBox(height: 2),

            Text(
              'Business location',

              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: colors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),

      // ========================================================
      // MAP
      // ========================================================
      body: Stack(
        children: [
          Positioned.fill(
            child: FlutterMap(
              options: MapOptions(
                initialCenter: location,
                initialZoom: 16,

                interactionOptions: const InteractionOptions(
                  flags: InteractiveFlag.all,
                ),
              ),

              children: [
                // =================================================
                // OPENSTREETMAP TILE LAYER
                // =================================================

                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',

                  // Replace this later with your real
                  // Android applicationId if different.
                  userAgentPackageName: 'com.example.flutter_application_1',
                ),

                // =================================================
                // BUSINESS MARKER
                // =================================================
                MarkerLayer(
                  markers: [
                    Marker(
                      point: location,

                      width: 56,
                      height: 56,

                      child: _BusinessMarker(isDark: isDark),
                    ),
                  ],
                ),

                // =================================================
                // OSM ATTRIBUTION
                // =================================================
                RichAttributionWidget(
                  attributions: [
                    TextSourceAttribution(
                      'OpenStreetMap contributors',

                      onTap: () {},
                    ),
                  ],
                ),
              ],
            ),
          ),

          // ======================================================
          // TOP LOCATION CARD
          // ======================================================
          Positioned(
            top: 16,
            left: 16,
            right: 16,

            child: _MapLocationHeader(
              partnerName: partnerName,

              locationText: locationText,

              isDark: isDark,
            ),
          ),

          // ======================================================
          // BOTTOM BUSINESS CARD
          // ======================================================
          Positioned(
            left: 16,
            right: 16,
            bottom: 16,

            child: SafeArea(
              top: false,

              child: _PartnerLocationCard(
                partnerName: partnerName,

                address: address,

                city: city,

                isDark: isDark,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// BUSINESS MAP MARKER
// ============================================================

class _BusinessMarker extends StatelessWidget {
  final bool isDark;

  const _BusinessMarker({required this.isDark});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,

        color: isDark ? colors.surfaceContainerHigh : colors.surface,

        border: Border.all(color: colors.primary, width: 2),

        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.32 : 0.18),

            blurRadius: 12,

            offset: const Offset(0, 4),
          ),
        ],
      ),

      child: Icon(Icons.location_on_rounded, color: colors.primary, size: 32),
    );
  }
}

// ============================================================
// TOP LOCATION CARD
// ============================================================

class _MapLocationHeader extends StatelessWidget {
  final String partnerName;

  final String locationText;

  final bool isDark;

  const _MapLocationHeader({
    required this.partnerName,
    required this.locationText,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),

      decoration: BoxDecoration(
        color: isDark
            ? colors.surfaceContainerHigh.withValues(alpha: 0.96)
            : colors.surface.withValues(alpha: 0.96),

        borderRadius: BorderRadius.circular(18),

        border: Border.all(color: colors.outlineVariant),

        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.28 : 0.12),

            blurRadius: 18,

            offset: const Offset(0, 6),
          ),
        ],
      ),

      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,

            decoration: BoxDecoration(
              color: colors.primary.withValues(alpha: isDark ? 0.18 : 0.10),

              borderRadius: BorderRadius.circular(12),

              border: Border.all(
                color: colors.primary.withValues(alpha: isDark ? 0.22 : 0.07),
              ),
            ),

            child: Icon(
              Icons.location_on_rounded,

              size: 21,

              color: colors.primary,
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                Text(
                  partnerName,

                  maxLines: 1,

                  overflow: TextOverflow.ellipsis,

                  style: TextStyle(
                    fontSize: 13,

                    fontWeight: FontWeight.w700,

                    color: colors.onSurface,
                  ),
                ),

                if (locationText.isNotEmpty) ...[
                  const SizedBox(height: 3),

                  Text(
                    locationText,

                    maxLines: 2,

                    overflow: TextOverflow.ellipsis,

                    style: TextStyle(
                      fontSize: 11,

                      height: 1.35,

                      color: colors.onSurfaceVariant,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// BOTTOM BUSINESS CARD
// ============================================================

class _PartnerLocationCard extends StatelessWidget {
  final String partnerName;

  final String? address;
  final String? city;

  final bool isDark;

  const _PartnerLocationCard({
    required this.partnerName,
    required this.address,
    required this.city,
    required this.isDark,
  });

  bool _hasText(String? value) {
    return value != null && value.trim().isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,

      padding: const EdgeInsets.all(16),

      decoration: BoxDecoration(
        color: isDark ? colors.surfaceContainerHigh : colors.surface,

        borderRadius: BorderRadius.circular(22),

        border: Border.all(color: colors.outlineVariant),

        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.30 : 0.14),

            blurRadius: 24,

            offset: const Offset(0, 8),
          ),
        ],
      ),

      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          Container(
            width: 50,
            height: 50,

            decoration: BoxDecoration(
              color: colors.primary.withValues(alpha: isDark ? 0.18 : 0.10),

              borderRadius: BorderRadius.circular(16),

              border: Border.all(
                color: colors.primary.withValues(alpha: isDark ? 0.22 : 0.07),
              ),
            ),

            child: Icon(
              Icons.business_rounded,

              size: 24,

              color: colors.primary,
            ),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                Text(
                  partnerName,

                  maxLines: 2,

                  overflow: TextOverflow.ellipsis,

                  style: TextStyle(
                    fontSize: 15,

                    fontWeight: FontWeight.w700,

                    color: colors.onSurface,
                  ),
                ),

                if (_hasText(address)) ...[
                  const SizedBox(height: 7),

                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,

                    children: [
                      Icon(
                        Icons.location_on_outlined,

                        size: 15,

                        color: colors.onSurfaceVariant,
                      ),

                      const SizedBox(width: 6),

                      Expanded(
                        child: Text(
                          address!.trim(),

                          style: TextStyle(
                            fontSize: 12,

                            color: colors.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],

                if (_hasText(city)) ...[
                  const SizedBox(height: 5),

                  Row(
                    children: [
                      Icon(
                        Icons.location_city_outlined,

                        size: 15,

                        color: colors.onSurfaceVariant,
                      ),

                      const SizedBox(width: 6),

                      Expanded(
                        child: Text(
                          city!.trim(),

                          style: TextStyle(
                            fontSize: 12,

                            color: colors.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
