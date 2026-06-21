import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:savora_app/core/theme/app_colors.dart';
import 'package:savora_app/core/theme/app_spacing.dart';
import 'package:savora_app/core/theme/app_text_styles.dart';

import '../../widgets/chef_ui_kit.dart';

/// Step 2 of the verification wizard: confirm the kitchen's pickup
/// location on a real map.
class LocationSetupScreen extends StatefulWidget {
  const LocationSetupScreen({super.key});

  @override
  State<LocationSetupScreen> createState() => _LocationSetupScreenState();
}

class _LocationSetupScreenState extends State<LocationSetupScreen> {
  final MapController _mapController = MapController();
  final TextEditingController _searchController = TextEditingController();

  LatLng _currentCenter = const LatLng(24.0889, 32.8998); // Default to Aswan, Egypt
  String _addressName = 'Savora Kitchen';
  String _addressDetails = 'Aswan, Egypt';
  bool _isLoadingAddress = false;
  bool _isSearching = false;
  List<dynamic> _searchResults = [];
  Timer? _debounceTimer;
  Timer? _searchDebounceTimer;

  @override
  void initState() {
    super.initState();
    _fetchAddress(_currentCenter);
  }

  @override
  void dispose() {
    _mapController.dispose();
    _searchController.dispose();
    _debounceTimer?.cancel();
    _searchDebounceTimer?.cancel();
    super.dispose();
  }

  Future<void> _fetchAddress(LatLng position) async {
    if (!mounted) return;
    setState(() {
      _isLoadingAddress = true;
    });

    try {
      final url = Uri.parse(
        'https://nominatim.openstreetmap.org/reverse?format=json&lat=${position.latitude}&lon=${position.longitude}&zoom=18&addressdetails=1',
      );
      final response = await http.get(url, headers: {
        'User-Agent': 'SavoraChefApp/1.0 (contact: info@savora.com)',
      });

      if (!mounted) return;

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final displayName = data['display_name'] ?? 'Unknown location';
        final address = data['address'] ?? {};

        final road = address['road'] ??
            address['suburb'] ??
            address['neighbourhood'] ??
            address['city_district'] ??
            '';
        final city = address['city'] ?? address['town'] ?? address['state'] ?? '';
        final country = address['country'] ?? '';

        setState(() {
          if (road.isNotEmpty) {
            _addressName = road;
            _addressDetails = '$city, $country';
          } else {
            final parts = displayName.split(',');
            _addressName = parts.first.trim();
            _addressDetails = parts.skip(1).join(',').trim();
          }
          _isLoadingAddress = false;
        });
      } else {
        setState(() {
          _isLoadingAddress = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoadingAddress = false;
      });
    }
  }

  Future<void> _performSearch(String query) async {
    if (query.trim().isEmpty) return;
    if (!mounted) return;

    setState(() {
      _isSearching = true;
    });

    try {
      final url = Uri.parse(
        'https://nominatim.openstreetmap.org/search?format=json&q=${Uri.encodeComponent(query)}&limit=5',
      );
      final response = await http.get(url, headers: {
        'User-Agent': 'SavoraChefApp/1.0 (contact: info@savora.com)',
      });

      if (!mounted) return;

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          _searchResults = data;
          _isSearching = false;
        });
      } else {
        setState(() {
          _isSearching = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isSearching = false;
      });
    }
  }

  void _onSearchChanged(String query) {
    _searchDebounceTimer?.cancel();
    if (query.trim().isEmpty) {
      setState(() {
        _searchResults = [];
      });
      return;
    }
    _searchDebounceTimer = Timer(const Duration(milliseconds: 600), () {
      _performSearch(query);
    });
  }

  void _onMapPositionChanged(MapCamera camera, bool hasGesture) {
    if (hasGesture) {
      setState(() {
        _currentCenter = camera.center;
        _isLoadingAddress = true;
      });
      _debounceTimer?.cancel();
      _debounceTimer = Timer(const Duration(milliseconds: 800), () {
        _fetchAddress(camera.center);
      });
    } else {
      _currentCenter = camera.center;
    }
  }

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;

    return Scaffold(
      backgroundColor: AppColors.surfaceSunkenOf(brightness),
      appBar: AppBar(
        backgroundColor: AppColors.surfaceOf(brightness),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded,
              color: AppColors.textOf(brightness)),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.help_outline_rounded,
                color: AppColors.textOf(brightness)),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(
                horizontal: AppSpacing.screenPadding, vertical: AppSpacing.sm),
            child: LinearStepHeader(
              stepLabel: 'Step 2 of 3',
              title: 'Kitchen Location',
              progress: 2 / 3,
            ),
          ),
          Expanded(
            child: Stack(
              children: [
                Positioned.fill(
                  child: FlutterMap(
                    mapController: _mapController,
                    options: MapOptions(
                      initialCenter: _currentCenter,
                      initialZoom: 15.0,
                      minZoom: 3.0,
                      maxZoom: 19.0,
                      onPositionChanged: _onMapPositionChanged,
                    ),
                    children: [
                      TileLayer(
                        urlTemplate: brightness == Brightness.dark
                            ? 'https://a.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}.png'
                            : 'https://a.basemaps.cartocdn.com/light_all/{z}/{x}/{y}.png',
                        userAgentPackageName: 'com.savora.chef',
                      ),
                    ],
                  ),
                ),
                // Fixed center marker overlay
                Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.sm, vertical: 6),
                        decoration: const BoxDecoration(
                            color: AppColors.clay,
                            borderRadius: AppSpacing.borderRadiusSm),
                        child: Text(
                          _isLoadingAddress ? 'Locating...' : 'Savora Kitchen',
                          style: AppTextStyles.labelMd
                              .copyWith(color: AppColors.white),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.gold, width: 3),
                          color: AppColors.surfaceOf(brightness),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.15),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Icon(Icons.restaurant_rounded,
                            color: AppColors.amber, size: 18),
                      ),
                    ],
                  ),
                ),
                // Search Bar Overlay
                Positioned(
                  left: AppSpacing.screenPadding,
                  right: AppSpacing.screenPadding,
                  top: AppSpacing.sm,
                  child: Container(
                    height: 48,
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceOf(brightness),
                      borderRadius: AppSpacing.borderRadiusFull,
                      border: Border.all(color: AppColors.gold),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.08),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        )
                      ],
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.search_rounded,
                            color: AppColors.amber, size: 20),
                        const SizedBox(width: AppSpacing.xs),
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            style: AppTextStyles.bodyMd
                                .copyWith(color: AppColors.textOf(brightness)),
                            decoration: InputDecoration(
                              hintText: 'Search kitchen address...',
                              hintStyle: AppTextStyles.bodyMd
                                  .copyWith(color: AppColors.textMutedOf(brightness)),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            onChanged: _onSearchChanged,
                            onSubmitted: _performSearch,
                          ),
                        ),
                        if (_isSearching)
                          const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation(AppColors.amber),
                            ),
                          )
                        else if (_searchController.text.isNotEmpty)
                          IconButton(
                            icon: const Icon(Icons.close_rounded, size: 20),
                            color: AppColors.textMutedOf(brightness),
                            onPressed: () {
                              setState(() {
                                _searchController.clear();
                                _searchResults = [];
                              });
                            },
                          )
                        else
                          Icon(Icons.my_location_rounded,
                              color: AppColors.textMutedOf(brightness), size: 20),
                      ],
                    ),
                  ),
                ),
                // Search Results Overlay
                if (_searchResults.isNotEmpty)
                  Positioned(
                    left: AppSpacing.screenPadding,
                    right: AppSpacing.screenPadding,
                    top: AppSpacing.sm + 48 + 8,
                    child: Container(
                      constraints: const BoxConstraints(maxHeight: 220),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceOf(brightness),
                        borderRadius: AppSpacing.borderRadiusMd,
                        border: Border.all(color: AppColors.borderOf(brightness)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.12),
                            blurRadius: 12,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: AppSpacing.borderRadiusMd,
                        child: ListView.separated(
                          padding: EdgeInsets.zero,
                          shrinkWrap: true,
                          itemCount: _searchResults.length,
                          separatorBuilder: (context, index) => Divider(
                            height: 1,
                            color: AppColors.borderOf(brightness),
                          ),
                          itemBuilder: (context, index) {
                            final item = _searchResults[index];
                            final title = item['display_name'] ?? '';
                            return ListTile(
                              leading: const Icon(Icons.location_on_outlined,
                                  color: AppColors.amber),
                              title: Text(
                                title,
                                style: AppTextStyles.bodyMd
                                    .copyWith(color: AppColors.textOf(brightness)),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              dense: true,
                              onTap: () {
                                final lat = double.tryParse(item['lat'] ?? '');
                                final lon = double.tryParse(item['lon'] ?? '');
                                if (lat != null && lon != null) {
                                  final newPos = LatLng(lat, lon);
                                  _mapController.move(newPos, 16.0);
                                  setState(() {
                                    _currentCenter = newPos;
                                    _searchResults = [];
                                    _searchController.text =
                                        title.split(',').first.trim();
                                    _addressName = _searchController.text;
                                    _addressDetails = title;
                                  });
                                  FocusScope.of(context).unfocus();
                                }
                              },
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                // Zoom & Locate Controls
                Positioned(
                  right: AppSpacing.screenPadding,
                  bottom: AppSpacing.sm,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      FloatingActionButton.small(
                        heroTag: 'zoom_in',
                        onPressed: () {
                          final currentZoom = _mapController.camera.zoom;
                          _mapController.move(_currentCenter, currentZoom + 1);
                        },
                        backgroundColor: AppColors.surfaceOf(brightness),
                        foregroundColor: AppColors.textOf(brightness),
                        child: const Icon(Icons.add_rounded),
                      ),
                      const SizedBox(height: 8),
                      FloatingActionButton.small(
                        heroTag: 'zoom_out',
                        onPressed: () {
                          final currentZoom = _mapController.camera.zoom;
                          _mapController.move(_currentCenter, currentZoom - 1);
                        },
                        backgroundColor: AppColors.surfaceOf(brightness),
                        foregroundColor: AppColors.textOf(brightness),
                        child: const Icon(Icons.remove_rounded),
                      ),
                      const SizedBox(height: 8),
                      FloatingActionButton.small(
                        heroTag: 'locate_me',
                        onPressed: () {
                          const defaultLoc = LatLng(24.0889, 32.8998);
                          _mapController.move(defaultLoc, 15.0);
                          _fetchAddress(defaultLoc);
                        },
                        backgroundColor: AppColors.surfaceOf(brightness),
                        foregroundColor: AppColors.amber,
                        child: const Icon(Icons.my_location_rounded),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(AppSpacing.screenPadding,
                AppSpacing.sm, AppSpacing.screenPadding, AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.surfaceOf(brightness),
              borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(AppSpacing.radiusXl)),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 16,
                    offset: const Offset(0, -4))
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                    decoration: BoxDecoration(
                        color: AppColors.borderOf(brightness),
                        borderRadius: AppSpacing.borderRadiusFull),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Set Kitchen Site',
                              style: AppTextStyles.titleLg.copyWith(
                                  color: AppColors.textOf(brightness))),
                          Text(
                            'Verify the pinpoint for delivery pickup.',
                            style: AppTextStyles.bodySm.copyWith(
                                color: AppColors.textMutedOf(brightness)),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: 44,
                      height: 44,
                      alignment: Alignment.center,
                      decoration: const BoxDecoration(
                          color: AppColors.gold,
                          borderRadius: AppSpacing.borderRadiusSm),
                      child: const Icon(Icons.storefront_rounded,
                          color: AppColors.clay),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                SectionCard(
                  backgroundColor: AppColors.surfaceSunkenOf(brightness),
                  child: Row(
                    children: [
                      const Icon(Icons.location_on_outlined, color: AppColors.amber),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _isLoadingAddress ? 'Updating location...' : _addressName,
                              style: AppTextStyles.titleMd.copyWith(
                                  color: AppColors.textOf(brightness)),
                            ),
                            Text(
                              _isLoadingAddress ? 'Please wait...' : _addressDetails,
                              style: AppTextStyles.bodySm.copyWith(
                                  color: AppColors.textMutedOf(brightness)),
                            ),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _searchController.text = _addressName;
                          });
                        },
                        child: Text('Edit',
                            style: AppTextStyles.labelLg.copyWith(
                                color: AppColors.amber,
                                decoration: TextDecoration.underline)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                ChefPrimaryButton(
                  label: 'Confirm Location',
                  icon: Icons.arrow_forward_rounded,
                  onPressed: () {
                    Navigator.of(context).maybePop({
                      'addressName': _addressName,
                      'addressDetails': _addressDetails,
                      'latitude': _currentCenter.latitude,
                      'longitude': _currentCenter.longitude,
                    });
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
