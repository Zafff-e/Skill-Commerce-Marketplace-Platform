import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../../core/constants/asset_paths.dart';
import '../../../core/localization/app_strings.dart';
import '../../../core/network/skill_commerce_repository.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/models/polyglot_models.dart';

class MapBookingScreen extends StatefulWidget {
  final SkillModel? selectedSkill;
  final Function(ProviderGeoModel provider, bool isUrgent) onDirectBook;
  final VoidCallback? onBack;

  const MapBookingScreen({
    super.key,
    this.selectedSkill,
    required this.onDirectBook,
    this.onBack,
  });

  @override
  State<MapBookingScreen> createState() => _MapBookingScreenState();
}

class _MapBookingScreenState extends State<MapBookingScreen> {
  final MapController _mapController = MapController();
  final LatLng _initialCenter = const LatLng(
    23.8103,
    90.4125,
  ); // Banani / Gulshan, Dhaka
  List<ProviderGeoModel> _providers = [];
  List<AiProviderRecommendationModel> _aiRecommendations = [];
  ProviderGeoModel? _selectedProvider;
  bool _isLoading = true;
  bool _isUrgent = false;

  @override
  void initState() {
    super.initState();
    _loadProviders();
  }

  Future<void> _loadProviders() async {
    final repo = context.read<SkillCommerceRepository>();
    final list = await repo.searchNearbyProviders(
      skillId: widget.selectedSkill?.skillId,
      latitude: _initialCenter.latitude,
      longitude: _initialCenter.longitude,
    );

    final aiRecs = await repo.getAiProviderRecommendations(
      skillId: widget.selectedSkill?.skillId,
      skillName: widget.selectedSkill?.skillName,
      latitude: _initialCenter.latitude,
      longitude: _initialCenter.longitude,
    );

    if (mounted) {
      setState(() {
        _providers = list;
        _aiRecommendations = aiRecs;
        if (aiRecs.isNotEmpty) {
          final topId = aiRecs.first.profileId;
          _selectedProvider = list.firstWhere(
            (p) => p.profileId == topId,
            orElse: () => list.first,
          );
        } else {
          _selectedProvider = list.isNotEmpty ? list.first : null;
        }
        _isLoading = false;
      });
    }
  }

  AiProviderRecommendationModel? _getRecommendation(int profileId) {
    try {
      return _aiRecommendations.firstWhere((r) => r.profileId == profileId);
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final isBn = strings.isBengali;

    return Scaffold(
      body: Stack(
        children: [
          // FlutterMap Canvas (OpenStreetMap)
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _initialCenter,
              initialZoom: 14.5,
              onTap: (_, __) {
                // Deselect provider if tapping empty map area
              },
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.skillcommerce.mobile_app',
              ),

              // Customer Location Marker
              MarkerLayer(
                markers: [
                  Marker(
                    point: _initialCenter,
                    width: 50,
                    height: 50,
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.forestGreen.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: AppColors.forestGreen,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 3),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.2),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.person,
                            color: Colors.white,
                            size: 12,
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Nearby Active Provider Markers
                  ..._providers.map((p) {
                    final isSelected =
                        _selectedProvider?.profileId == p.profileId;
                    final avatarPath = AssetPaths.getPath(p.avatarKey);
                    final rec = _getRecommendation(p.profileId);
                    final isTop = rec?.isTopRecommendation ?? false;

                    return Marker(
                      point: LatLng(p.latitude, p.longitude),
                      width: 60,
                      height: 60,
                      child: GestureDetector(
                        onTap: () {
                          setState(() => _selectedProvider = p);
                          _mapController.move(
                            LatLng(p.latitude, p.longitude),
                            15.0,
                          );
                        },
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            if (isSelected || isTop)
                              Container(
                                width: 58,
                                height: 58,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: (isTop ? AppColors.urgentAmber : AppColors.mintGreen).withValues(
                                    alpha: 0.35,
                                  ),
                                ),
                              ),
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: isSelected
                                      ? AppColors.forestGreen
                                      : (isTop ? AppColors.urgentAmber : Colors.white),
                                  width: isSelected ? 3 : (isTop ? 2.5 : 2),
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.25),
                                    blurRadius: 6,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                                image: DecorationImage(
                                  image: AssetImage(avatarPath),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            if (isTop)
                              Positioned(
                                top: 0,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                                  decoration: BoxDecoration(
                                    color: AppColors.forestGreen,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: const Text(
                                    '✨ AI',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 8,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            Positioned(
                              bottom: 0,
                              right: 4,
                              child: Container(
                                padding: const EdgeInsets.all(2),
                                decoration: const BoxDecoration(
                                  color: AppColors.forestGreen,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.check,
                                  color: Colors.white,
                                  size: 10,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ],
          ),

          // Top Header Bar
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            left: 16,
            right: 16,
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.white,
                  child: IconButton(
                    icon: const Icon(
                      Icons.arrow_back,
                      color: AppColors.slateNavy,
                    ),
                    onPressed: () {
                      if (widget.onBack != null) {
                        widget.onBack!();
                      } else if (Navigator.of(context).canPop()) {
                        Navigator.of(context).pop();
                      }
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.08),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.radar,
                          color: AppColors.forestGreen,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            widget.selectedSkill?.skillName ??
                                strings.nearbyTechnicians,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: AppColors.slateNavy,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Urgency Mode Floating Toggle
          Positioned(
            top: MediaQuery.of(context).padding.top + 70,
            right: 16,
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () => setState(() => _isUrgent = !_isUrgent),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: _isUrgent ? AppColors.urgentRed : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.12),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                  border: Border.all(
                    color: _isUrgent
                        ? AppColors.urgentRed
                        : Colors.grey.shade300,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.flash_on_rounded,
                      size: 16,
                      color: _isUrgent ? Colors.white : AppColors.urgentAmber,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _isUrgent
                          ? strings.urgentSurcharge
                          : strings.emergencyService,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: _isUrgent ? Colors.white : AppColors.slateNavy,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Provider Bottom Card (Uber / Pathao style)
          if (_selectedProvider != null)
            Positioned(
              left: 16,
              right: 16,
              bottom: MediaQuery.of(context).padding.bottom + 16,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.12),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Quick Provider Switcher Strip (Fix Issue 1: Easy selection of any provider)
                    if (_providers.length > 1) ...[
                      SizedBox(
                        height: 38,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: _providers.length,
                          separatorBuilder: (_, __) => const SizedBox(width: 8),
                          itemBuilder: (context, idx) {
                            final prov = _providers[idx];
                            final isSel = _selectedProvider?.profileId == prov.profileId;
                            final rec = _getRecommendation(prov.profileId);
                            final isTop = rec?.isTopRecommendation ?? false;

                            return InkWell(
                              onTap: () {
                                setState(() => _selectedProvider = prov);
                                _mapController.move(
                                  LatLng(prov.latitude, prov.longitude),
                                  15.0,
                                );
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: isSel ? AppColors.forestGreen : AppColors.softOffWhite,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: isSel ? AppColors.forestGreen : Colors.grey.shade300,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      isSel ? Icons.check_circle : Icons.person_pin_circle,
                                      size: 14,
                                      color: isSel ? Colors.white : AppColors.slateNavy,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      prov.fullName.split(' ').first,
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: isSel ? Colors.white : AppColors.slateNavy,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '(${prov.distanceKm}km)',
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: isSel ? Colors.white70 : AppColors.slateMuted,
                                      ),
                                    ),
                                    if (isTop) ...[
                                      const SizedBox(width: 4),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                                        decoration: BoxDecoration(
                                          color: Colors.amber.shade700,
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: const Text(
                                          '✨ AI',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 8,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Divider(height: 1),
                      const SizedBox(height: 10),
                    ],

                    // AI Explainable Matchmaker Reasoning Pill
                    if (_getRecommendation(_selectedProvider!.profileId) != null) ...[
                      Builder(
                        builder: (context) {
                          final rec = _getRecommendation(_selectedProvider!.profileId)!;
                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: rec.isTopRecommendation
                                  ? AppColors.forestGreen.withValues(alpha: 0.08)
                                  : AppColors.softOffWhite,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: rec.isTopRecommendation
                                    ? AppColors.forestGreen.withValues(alpha: 0.4)
                                    : AppColors.cardBorder,
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.auto_awesome,
                                  size: 15,
                                  color: rec.isTopRecommendation
                                      ? AppColors.forestGreen
                                      : AppColors.urgentAmber,
                                ),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    isBn ? rec.matchReasonBengali : rec.matchReasonEnglish,
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: rec.isTopRecommendation
                                          ? AppColors.forestGreen
                                          : AppColors.slateNavy,
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: rec.isTopRecommendation
                                        ? AppColors.forestGreen
                                        : AppColors.slateNavy,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    '${(rec.matchScore * 100).toInt()}% Match',
                                    style: const TextStyle(
                                      fontSize: 10,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                    Row(
                      children: [
                        Container(
                          width: 58,
                          height: 58,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            image: DecorationImage(
                              image: AssetImage(
                                AssetPaths.getPath(
                                  _selectedProvider!.avatarKey,
                                ),
                              ),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Flexible(
                                    child: Text(
                                      _selectedProvider!.fullName,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.slateNavy,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  const Icon(
                                    Icons.verified,
                                    color: AppColors.forestGreen,
                                    size: 16,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 2),
                              Text(
                                _selectedProvider!.primarySkill,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.slateMuted,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.star,
                                    color: Colors.amber,
                                    size: 14,
                                  ),
                                  const SizedBox(width: 2),
                                  Text(
                                    '${_selectedProvider!.overallRating} (${_selectedProvider!.ratingCount})',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  const Icon(
                                    Icons.directions_walk,
                                    color: AppColors.slateMuted,
                                    size: 14,
                                  ),
                                  Text(
                                    ' ${_selectedProvider!.distanceKm} km',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: AppColors.slateMuted,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 14),
                    const Divider(height: 1),
                    const SizedBox(height: 12),

                    // Price & Booking CTA
                    Row(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              strings.baseRate,
                              style: const TextStyle(
                                fontSize: 11,
                                color: AppColors.slateMuted,
                              ),
                            ),
                            Text(
                              '৳ ${strings.formatNumber((widget.selectedSkill?.basicPrice ?? 400).toInt())}',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppColors.forestGreen,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              widget.onDirectBook(
                                _selectedProvider!,
                                _isUrgent,
                              );
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.bolt, size: 18),
                                const SizedBox(width: 6),
                                Text(
                                  _isUrgent
                                      ? (isBn
                                            ? 'জরুরি বুকিং করুন'
                                            : 'Urgent Book')
                                      : strings.bookNow,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(color: AppColors.forestGreen),
            ),
        ],
      ),
    );
  }
}
