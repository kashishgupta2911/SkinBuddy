import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';

class TipCategory {
  const TipCategory({
    required this.title,
    required this.icon,
    required this.iconColor,
    required this.tips,
  });

  final String title;
  final IconData icon;
  final Color iconColor;
  final List<TipItem> tips;
}

class TipItem {
  const TipItem({required this.heading, required this.body});

  final String heading;
  final String body;
}

const Map<String, TipCategory> tipCategories = {
  'UV Protection': TipCategory(
    title: 'UV Protection',
    icon: Icons.wb_sunny_outlined,
    iconColor: AppColors.primary,
    tips: [
      TipItem(
        heading: 'Apply sunscreen daily',
        body:
            'Use a broad-spectrum SPF 30+ sunscreen every morning, even on cloudy days. '
            'UV rays can penetrate clouds and windows, so make it a non-negotiable step.',
      ),
      TipItem(
        heading: 'Reapply every 2 hours',
        body:
            'Sunscreen breaks down over time and with sweat or water exposure. '
            'Set a reminder to reapply, especially when you\'re outdoors.',
      ),
      TipItem(
        heading: 'Wear protective clothing',
        body:
            'Wide-brimmed hats, UV-blocking sunglasses, and long sleeves provide an extra '
            'layer of defense against harmful UV radiation.',
      ),
      TipItem(
        heading: 'Seek shade during peak hours',
        body:
            'The sun\'s rays are strongest between 10 AM and 4 PM. '
            'Try to stay in the shade during this window to reduce exposure.',
      ),
      TipItem(
        heading: 'Check the UV index',
        body:
            'Before heading out, check your local UV index. A rating of 6 or above '
            'means you should take extra precautions to protect your skin.',
      ),
    ],
  ),
  'Hydration': TipCategory(
    title: 'Hydration',
    icon: Icons.water_drop_outlined,
    iconColor: AppColors.greenText,
    tips: [
      TipItem(
        heading: 'Drink plenty of water',
        body:
            'Aim for at least 8 glasses of water per day. Staying hydrated from the inside '
            'helps your skin maintain its natural moisture barrier.',
      ),
      TipItem(
        heading: 'Use a hydrating moisturizer',
        body:
            'Look for ingredients like hyaluronic acid, glycerin, and ceramides. '
            'Apply on damp skin after cleansing to lock in moisture.',
      ),
      TipItem(
        heading: 'Avoid hot showers',
        body:
            'Hot water strips your skin of natural oils, leaving it dry and tight. '
            'Use lukewarm water instead, especially on your face.',
      ),
      TipItem(
        heading: 'Try a hydrating serum',
        body:
            'Serums with hyaluronic acid can hold up to 1000x their weight in water. '
            'Layer one under your moisturizer for an extra hydration boost.',
      ),
      TipItem(
        heading: 'Eat water-rich foods',
        body:
            'Cucumbers, watermelon, oranges, and strawberries are great for keeping '
            'your skin hydrated. Include them in your daily diet.',
      ),
    ],
  ),
  'Self-Care': TipCategory(
    title: 'Self-Care',
    icon: Icons.favorite_outline,
    iconColor: Colors.redAccent,
    tips: [
      TipItem(
        heading: 'Get enough sleep',
        body:
            'Your skin repairs itself while you sleep. Aim for 7–9 hours each night '
            'to wake up with refreshed, glowing skin.',
      ),
      TipItem(
        heading: 'Manage stress levels',
        body:
            'Chronic stress triggers cortisol, which can cause breakouts and dullness. '
            'Try meditation, yoga, or deep breathing exercises.',
      ),
      TipItem(
        heading: 'Don\'t skip your nighttime routine',
        body:
            'Always remove makeup and cleanse before bed. Sleeping with makeup on '
            'clogs pores and accelerates skin aging.',
      ),
      TipItem(
        heading: 'Exercise regularly',
        body:
            'Physical activity boosts blood circulation, delivering oxygen and nutrients '
            'to your skin cells. Even a 20-minute walk makes a difference.',
      ),
      TipItem(
        heading: 'Treat yourself to a weekly mask',
        body:
            'A hydrating or detox face mask once a week gives your skin a deeper treatment. '
            'Choose one that matches your skin type for best results.',
      ),
    ],
  ),
};

class QuickTipDetailScreen extends StatelessWidget {
  const QuickTipDetailScreen({super.key, required this.categoryKey});

  final String categoryKey;

  @override
  Widget build(BuildContext context) {
    final category = tipCategories[categoryKey]!;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context),
              const SizedBox(height: AppSpacing.md),
              _buildTitleSection(category),
              const SizedBox(height: AppSpacing.xl),
              ...category.tips.asMap().entries.map(
                    (entry) => _buildTipCard(entry.key + 1, entry.value),
                  ),
              const SizedBox(height: AppSpacing.xl),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.sm),
      child: GestureDetector(
        onTap: () => Navigator.of(context).pop(),
        child: const Row(
          children: [
            Icon(Icons.chevron_left, color: AppColors.primary, size: 22),
            Text(
              'Back',
              style: TextStyle(
                fontSize: 15,
                color: AppColors.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTitleSection(TipCategory category) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: category.iconColor.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(category.icon, color: category.iconColor, size: 28),
        ),
        const SizedBox(width: AppSpacing.md),
        Text(
          category.title,
          style: const TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildTipCard(int index, TipItem tip) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.iconBg.withValues(alpha: 0.5)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '$index',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    tip.heading,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              tip.body,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
