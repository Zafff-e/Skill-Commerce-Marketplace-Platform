import 'package:flutter/material.dart';

import '../../core/constants/asset_paths.dart';
import '../../core/theme/app_colors.dart';

class AvatarSelectorWidget extends StatefulWidget {
  final String? initialSelectedKey;
  final ValueChanged<SkillAvatarInfo> onAvatarSelected;

  const AvatarSelectorWidget({
    super.key,
    this.initialSelectedKey,
    required this.onAvatarSelected,
  });

  static Future<SkillAvatarInfo?> show(
    BuildContext context, {
    String? initialSelectedKey,
  }) {
    return showModalBottomSheet<SkillAvatarInfo>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => FractionallySizedBox(
        heightFactor: 0.85,
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: AvatarSelectorWidget(
            initialSelectedKey: initialSelectedKey,
            onAvatarSelected: (avatar) {
              Navigator.pop(ctx, avatar);
            },
          ),
        ),
      ),
    );
  }

  @override
  State<AvatarSelectorWidget> createState() => _AvatarSelectorWidgetState();
}

class _AvatarSelectorWidgetState extends State<AvatarSelectorWidget> {
  late String _selectedKey;
  String _selectedCategory = 'All';
  String _searchQuery = '';

  final List<String> _categories = [
    'All',
    'Home Maintenance',
    'Cleaning & Healthcare',
    'Tech & Electronics',
    'Logistics & Moving',
    'Personal & Care',
  ];

  @override
  void initState() {
    super.initState();
    _selectedKey = widget.initialSelectedKey ?? 'general_technician';
  }

  List<SkillAvatarInfo> get _filteredAvatars {
    return AssetPaths.allAvatars.where((avatar) {
      final matchesCategory =
          _selectedCategory == 'All' || avatar.category == _selectedCategory;
      final matchesQuery =
          _searchQuery.isEmpty ||
          avatar.englishName.toLowerCase().contains(
            _searchQuery.toLowerCase(),
          ) ||
          avatar.bengaliName.contains(_searchQuery);
      return matchesCategory && matchesQuery;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Top drag handle
        Container(
          margin: const EdgeInsets.only(top: 12, bottom: 8),
          width: 44,
          height: 4,
          decoration: BoxDecoration(
            color: Colors.grey.shade300,
            borderRadius: BorderRadius.circular(2),
          ),
        ),

        // Header Title
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'প্রোফাইল ছবি নির্বাচন করুন',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.slateNavy,
                    ),
                  ),
                  Text(
                    'Choose Avatar (No Storage Permission Needed)',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        ),

        // Search Input
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: TextField(
            onChanged: (val) => setState(() => _searchQuery = val),
            decoration: InputDecoration(
              hintText: 'খুঁজুন / Search avatar...',
              prefixIcon: const Icon(
                Icons.search,
                color: AppColors.forestGreen,
              ),
              filled: true,
              fillColor: AppColors.softOffWhite,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: Colors.grey.shade200),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: Colors.grey.shade200),
              ),
            ),
          ),
        ),

        // Category Filter Chips
        SizedBox(
          height: 44,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            itemCount: _categories.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final cat = _categories[index];
              final isSelected = _selectedCategory == cat;
              return ChoiceChip(
                label: Text(cat),
                selected: isSelected,
                selectedColor: AppColors.forestGreen,
                labelStyle: TextStyle(
                  color: isSelected ? Colors.white : AppColors.slateNavy,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  fontSize: 13,
                ),
                backgroundColor: AppColors.softOffWhite,
                onSelected: (selected) {
                  if (selected) {
                    setState(() => _selectedCategory = cat);
                  }
                },
              );
            },
          ),
        ),

        const Divider(height: 16),

        // Grid of Avatars
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.85,
            ),
            itemCount: _filteredAvatars.length,
            itemBuilder: (context, index) {
              final avatar = _filteredAvatars[index];
              final isSelected = avatar.key == _selectedKey;

              return InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () {
                  setState(() => _selectedKey = avatar.key);
                  widget.onAvatarSelected(avatar);
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.mintGreen.withValues(alpha: 0.12)
                        : AppColors.softOffWhite,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.forestGreen
                          : Colors.grey.shade200,
                      width: isSelected ? 2.5 : 1.0,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Stack(
                        children: [
                          Container(
                            width: 68,
                            height: 68,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              image: DecorationImage(
                                image: AssetImage(avatar.assetPath),
                                fit: BoxFit.cover,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.08),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                          ),
                          if (isSelected)
                            Positioned(
                              right: 0,
                              bottom: 0,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(
                                  color: AppColors.forestGreen,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.check,
                                  color: Colors.white,
                                  size: 14,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: Text(
                          avatar.bengaliName,
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow:
                              const TextTheme().bodySmall?.overflow ??
                              TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.w500,
                            color: isSelected
                                ? AppColors.forestGreen
                                : AppColors.slateNavy,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: Text(
                          avatar.englishName,
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
