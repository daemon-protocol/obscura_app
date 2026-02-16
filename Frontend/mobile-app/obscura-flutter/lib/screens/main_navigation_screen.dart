import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/theme.dart';
import 'home_screen.dart';
import 'dark_pool_screen.dart';
import 'dark_otc_screen.dart';
import 'portfolio_screen.dart';
import 'history_screen.dart';

/// Main Navigation Screen - Neo-Noir Edition
///
/// Redesigned with glass navigation bar, icon animations on selection,
/// active indicator with glow, and floating iOS-style design.
class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen>
    with TickerProviderStateMixin {
  int _currentIndex = 0;
  late List<AnimationController> _iconControllers;
  late List<Animation<double>> _iconAnimations;

  final List<NavigationItem> _navItems = const [
    NavigationItem(
      icon: Icons.home_outlined,
      activeIcon: Icons.home_rounded,
      label: 'Home',
    ),
    NavigationItem(
      icon: Icons.water_drop_outlined,
      activeIcon: Icons.water_drop_rounded,
      label: 'Dark Pool',
    ),
    NavigationItem(
      icon: Icons.request_quote_outlined,
      activeIcon: Icons.request_quote_rounded,
      label: 'OTC',
    ),
    NavigationItem(
      icon: Icons.account_balance_wallet_outlined,
      activeIcon: Icons.account_balance_wallet_rounded,
      label: 'Portfolio',
    ),
    NavigationItem(
      icon: Icons.history_outlined,
      activeIcon: Icons.history_rounded,
      label: 'History',
    ),
  ];

  final List<Widget> _screens = const [
    HomeScreen(),
    DarkPoolScreen(),
    DarkOTCScreen(),
    PortfolioScreen(),
    HistoryScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _iconControllers = List.generate(
      _navItems.length,
      (index) => AnimationController(
        duration: AppAnimations.fast,
        vsync: this,
      ),
    );

    _iconAnimations = _iconControllers
        .map((controller) => Tween<double>(begin: 0.0, end: 1.0).animate(
              CurvedAnimation(
                parent: controller,
                curve: Curves.easeOut,
              ),
            ))
        .toList();

    // Animate initial selection
    _iconControllers[_currentIndex].forward();
  }

  @override
  void dispose() {
    for (var controller in _iconControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      extendBody: true,
      bottomNavigationBar: _buildGlassNavigationBar(),
    );
  }

  Widget _buildGlassNavigationBar() {
    final screenHeight = MediaQuery.of(context).size.height;
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    const navBarHeight = 80.0;
    const bottomPadding = 20.0; // Safe area padding

    return AnimatedContainer(
      duration: AppAnimations.medium,
      height: keyboardHeight > 0 ? 0 : navBarHeight,
      margin: EdgeInsets.only(
        left: AppSpacing.lg,
        right: AppSpacing.lg,
        bottom: keyboardHeight > 0 ? 0 : bottomPadding,
      ),
      child: keyboardHeight > 0
          ? const SizedBox.shrink()
          : ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        AppColors.background.glass,
                        AppColors.background.glassLight,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: AppColors.border.glass,
                      width: 1,
                    ),
                    boxShadow: AppShadows.elevatedWithGlow,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: List.generate(_navItems.length, (index) {
                      final isSelected = index == _currentIndex;
                      return Expanded(
                        child: _buildNavItem(
                          _navItems[index],
                          isSelected,
                          index,
                        ),
                      );
                    }),
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildNavItem(NavigationItem item, bool isSelected, int index) {
    return GestureDetector(
      onTap: () => _onItemTapped(index),
      behavior: HitTestBehavior.opaque,
      child: Container(
        height: 60,
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon container with glow for active item
            AnimatedBuilder(
              animation: _iconAnimations[index],
              builder: (context, child) {
                return Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: isSelected
                        ? LinearGradient(
                            colors: [
                              AppColors.brandPrimary.withOpacity(0.2),
                              AppColors.brandPrimary.withOpacity(0.1),
                            ],
                          )
                        : null,
                  ),
                  child: Icon(
                    isSelected ? item.activeIcon : item.icon,
                    size: 22,
                    color: isSelected
                        ? AppColors.brandAccent
                        : AppColors.textMuted,
                  ),
                );
              },
            ),
            const SizedBox(height: 4),
            // Active indicator
            AnimatedContainer(
              duration: AppAnimations.fast,
              width: isSelected ? 20 : 0,
              height: 3,
              decoration: BoxDecoration(
                gradient: isSelected
                    ? LinearGradient(
                        colors: [
                          AppColors.brandAccent,
                          AppColors.brandPrimary,
                        ],
                      )
                    : null,
                borderRadius: BorderRadius.circular(2),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: AppColors.brandPrimary.withOpacity(0.5),
                          blurRadius: 4,
                          spreadRadius: 1,
                        ),
                      ]
                    : null,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onItemTapped(int index) {
    if (_currentIndex == index) return;

    // Animate out old selection
    _iconControllers[_currentIndex].reverse();

    setState(() {
      _currentIndex = index;
    });

    // Animate in new selection
    _iconControllers[index].forward();
  }
}

/// Navigation item data class
class NavigationItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;

  const NavigationItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
}

/// Alternative floating navigation bar style (iOS style)
class FloatingNavigationBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<NavigationItem> items;

  const FloatingNavigationBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.lg),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            height: 70,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.background.glass,
                  AppColors.background.glassLight,
                ],
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: AppColors.border.glass,
                width: 1,
              ),
              boxShadow: AppShadows.elevatedWithGlow,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: items.asMap().entries.map((entry) {
                final index = entry.key;
                final item = entry.value;
                final isSelected = index == currentIndex;

                return Expanded(
                  child: GestureDetector(
                    onTap: () => onTap(index),
                    behavior: HitTestBehavior.opaque,
                    child: AnimatedContainer(
                      duration: AppAnimations.fast,
                      height: 50,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.brandPrimary.withOpacity(0.15)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(
                        isSelected ? item.activeIcon : item.icon,
                        size: 24,
                        color: isSelected
                            ? AppColors.brandAccent
                            : AppColors.textMuted,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }
}

/// Minimal pill-style navigation bar
class PillNavigationBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<NavigationItem> items;

  const PillNavigationBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.lg),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(999),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Container(
            height: 60,
            decoration: BoxDecoration(
              color: AppColors.background.card.withOpacity(0.8),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(
                color: AppColors.border.glass,
                width: 1,
              ),
              boxShadow: [AppShadows.sm],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: items.asMap().entries.map((entry) {
                final index = entry.key;
                final item = entry.value;
                final isSelected = index == currentIndex;

                return Expanded(
                  child: GestureDetector(
                    onTap: () => onTap(index),
                    behavior: HitTestBehavior.opaque,
                    child: Container(
                      height: 40,
                      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.brandPrimary.withOpacity(0.2)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(999),
                        border: isSelected
                            ? Border.all(
                                color: AppColors.brandPrimary.withOpacity(0.3),
                                width: 1,
                              )
                            : null,
                      ),
                      child: Icon(
                        isSelected ? item.activeIcon : item.icon,
                        size: 20,
                        color: isSelected
                            ? AppColors.brandAccent
                            : AppColors.textMuted,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }
}
