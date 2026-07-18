import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:word_catcher/core/theme/theme.dart';

import '../../history/data/history_api_service.dart';
import '../../history/presentation/history_screen.dart';
import '../../scan/presentation/home_screen.dart';
import '../../settings/presentation/my_screen.dart';

class AppShell extends ConsumerStatefulWidget {
  const AppShell({super.key});

  @override
  ConsumerState<AppShell> createState() => _AppShellState();
}

class _AppShellState extends ConsumerState<AppShell> {
  static const _historyTabIndex = 1;
  static const _systemUiOverlayStyle = SystemUiOverlayStyle(
    systemNavigationBarColor: Colors.transparent,
    systemNavigationBarDividerColor: Colors.transparent,
    systemNavigationBarIconBrightness: Brightness.dark,
    systemNavigationBarContrastEnforced: false,
  );

  int _selectedIndex = 0;

  static const _pages = <Widget>[HomeScreen(), HistoryScreen(), MyScreen()];
  static const _destinations = <_ShellDestination>[
    _ShellDestination(
      icon: Icons.home_outlined,
      selectedIcon: Icons.home_rounded,
      label: '首页',
    ),
    _ShellDestination(
      icon: Icons.auto_stories_outlined,
      selectedIcon: Icons.auto_stories_rounded,
      label: '学习',
    ),
    _ShellDestination(
      icon: Icons.person_outline_rounded,
      selectedIcon: Icons.person_rounded,
      label: '我的',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: _systemUiOverlayStyle,
      child: Scaffold(
        body: Stack(
          fit: StackFit.expand,
          children: [
            IndexedStack(index: _selectedIndex, children: _pages),
            Positioned(
              left: AppSpacing.md,
              right: AppSpacing.md,
              bottom: AppBottomNavigationLayout.bottomOffset(context),
              child: DecoratedBox(
                decoration: const BoxDecoration(
                  color: AppColors.paper,
                  borderRadius: AppRadius.large,
                  boxShadow: AppShadows.card,
                ),
                child: _ShellNavigationBar(
                  selectedIndex: _selectedIndex,
                  destinations: _destinations,
                  onSelected: _selectDestination,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _selectDestination(int index) {
    if (index == _historyTabIndex) {
      ref.invalidate(historyProvider);
    }

    if (index == _selectedIndex) {
      return;
    }

    setState(() => _selectedIndex = index);
  }
}

class _ShellNavigationBar extends StatelessWidget {
  const _ShellNavigationBar({
    required this.selectedIndex,
    required this.destinations,
    required this.onSelected,
  });

  final int selectedIndex;
  final List<_ShellDestination> destinations;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: AppBottomNavigationLayout.height,
      child: Material(
        color: Colors.transparent,
        borderRadius: AppRadius.large,
        clipBehavior: Clip.antiAlias,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
          child: Row(
            children: [
              for (var index = 0; index < destinations.length; index++)
                Expanded(
                  child: _ShellTabButton(
                    destination: destinations[index],
                    selected: selectedIndex == index,
                    onTap: () => onSelected(index),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ShellTabButton extends StatelessWidget {
  const _ShellTabButton({
    required this.destination,
    required this.selected,
    required this.onTap,
  });

  final _ShellDestination destination;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected
        ? Theme.of(context).colorScheme.primary
        : AppColors.mutedInk;

    return Semantics(
      selected: selected,
      button: true,
      label: destination.label,
      child: InkWell(
        onTap: onTap,
        splashFactory: NoSplash.splashFactory,
        overlayColor: WidgetStateProperty.all(Colors.transparent),
        borderRadius: AppRadius.large,
        child: Align(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOutCubic,
            width: double.infinity,
            constraints: const BoxConstraints(minHeight: 48),
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: AppSpacing.xxs,
            ),
            decoration: BoxDecoration(
              color: selected
                  ? AppColors.tabActiveBackground
                  : Colors.transparent,
              borderRadius: AppRadius.pill,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  selected ? destination.selectedIcon : destination.icon,
                  color: color,
                  size: selected ? 24 : 22,
                ),
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  destination.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: color,
                    fontWeight: selected ? FontWeight.w900 : FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ShellDestination {
  const _ShellDestination({
    required this.icon,
    required this.selectedIcon,
    required this.label,
  });

  final IconData icon;
  final IconData selectedIcon;
  final String label;
}
