import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:word_catcher/core/theme/theme.dart';
import 'package:word_catcher/core/widgets/widgets.dart';

import '../../scan/data/audio_playback_service.dart';
import '../../scan/domain/word_category.dart';
import '../../share_card/models/share_card_data.dart';
import '../../share_card/pages/share_card_editor_page.dart';
import '../data/history_api_service.dart';
import '../domain/scan_history_item.dart';
import 'dictation_screen.dart';

class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});

  static const _meaningLanguage = '中文';

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> {
  _HistoryGroupMode _groupMode = _HistoryGroupMode.time;
  _HistoryTimeFilter _timeFilter = _HistoryTimeFilter.today;
  DateTime? _olderSelectedDate;

  @override
  Widget build(BuildContext context) {
    final history = ref.watch(historyProvider);

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: history.when(
          loading: () => const Center(
            child: Padding(
              padding: AppSpacing.screen,
              child: LoadingStateView(
                title: '正在整理学习记录',
                message: '把最近捕捉到的单词带回来。',
                useCard: false,
              ),
            ),
          ),
          error: (error, _) => _HistoryError(
            message: error.toString(),
            onRetry: () => ref.invalidate(historyProvider),
          ),
          data: (items) {
            final filteredItems = _filteredItems(items);
            return RefreshIndicator(
              onRefresh: _reloadHistory,
              child: ListView(
                padding: AppBottomNavigationLayout.pageScrollPadding(context),
                children: [
                  Text(
                    '照片词汇历史',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    '复习拍过的单词，听一遍、写一遍，也可以再次做成分享卡。',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  if (items.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.lg),
                    _HistoryFilterPanel(
                      groupMode: _groupMode,
                      selectedTimeFilter: _timeFilter,
                      selectedOlderDate: _olderSelectedDate,
                      timeCounts: _timeCounts(items),
                      categoryCounts: _categoryCounts(items),
                      onModeChanged: _selectMode,
                      onTimeSelected: _selectTimeFilter,
                      onOlderSelected: () => _openOlderCalendar(items),
                      onCategorySelected: (category) {
                        _openCategoryDetail(category, items);
                      },
                    ),
                  ],
                  if (items.isEmpty)
                    const _EmptyHistory()
                  else if (_groupMode == _HistoryGroupMode.time) ...[
                    const SizedBox(height: AppSpacing.lg),
                    _DictationEntryCard(
                      count: filteredItems.length,
                      onStart: filteredItems.isEmpty
                          ? null
                          : () => _openDictation(context, filteredItems),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    if (filteredItems.isEmpty)
                      _EmptyFilteredHistory(groupMode: _groupMode)
                    else
                      for (final item in filteredItems)
                        _HistoryTile(item: item),
                  ],
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  void _selectMode(_HistoryGroupMode mode) {
    setState(() {
      _groupMode = mode;
    });
  }

  void _selectTimeFilter(_HistoryTimeFilter filter) {
    setState(() {
      _groupMode = _HistoryGroupMode.time;
      _timeFilter = filter;
      if (filter != _HistoryTimeFilter.older) {
        _olderSelectedDate = null;
      }
    });
  }

  Future<void> _reloadHistory() async {
    ref.invalidate(historyProvider);
    await ref.read(historyProvider.future);
  }

  Future<void> _openOlderCalendar(List<ScanHistoryItem> items) async {
    setState(() {
      _groupMode = _HistoryGroupMode.time;
      _timeFilter = _HistoryTimeFilter.older;
    });

    final dateCounts = _olderDateCounts(items);
    if (dateCounts.isEmpty) {
      return;
    }

    final result = await showModalBottomSheet<_OlderDatePickerResult>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return _OlderDatePickerSheet(
          dateCounts: dateCounts,
          selectedDate: _olderSelectedDate,
        );
      },
    );

    if (!mounted || result == null) {
      return;
    }

    setState(() => _olderSelectedDate = result.date);
  }

  void _openCategoryDetail(WordCategory category, List<ScanHistoryItem> items) {
    final categoryItems = items
        .where((item) => item.wordCategory == category)
        .toList(growable: false);
    if (categoryItems.isEmpty) {
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => _CategoryHistoryDetailPage(
          category: category,
          items: categoryItems,
        ),
      ),
    );
  }

  List<ScanHistoryItem> _filteredItems(List<ScanHistoryItem> items) {
    return _itemsForTime(items);
  }

  List<ScanHistoryItem> _itemsForTime(List<ScanHistoryItem> items) {
    final today = DateUtils.dateOnly(DateTime.now());
    final yesterday = today.subtract(const Duration(days: 1));
    final dayBeforeYesterday = today.subtract(const Duration(days: 2));

    return items
        .where((item) {
          final createdDate = DateUtils.dateOnly(item.createdAt);
          return switch (_timeFilter) {
            _HistoryTimeFilter.today => DateUtils.isSameDay(createdDate, today),
            _HistoryTimeFilter.yesterday => DateUtils.isSameDay(
              createdDate,
              yesterday,
            ),
            _HistoryTimeFilter.dayBeforeYesterday => DateUtils.isSameDay(
              createdDate,
              dayBeforeYesterday,
            ),
            _HistoryTimeFilter.older =>
              _olderSelectedDate == null
                  ? createdDate.isBefore(dayBeforeYesterday)
                  : DateUtils.isSameDay(createdDate, _olderSelectedDate),
          };
        })
        .toList(growable: false);
  }

  Map<_HistoryTimeFilter, int> _timeCounts(List<ScanHistoryItem> items) {
    final counts = <_HistoryTimeFilter, int>{
      for (final filter in _HistoryTimeFilter.values) filter: 0,
    };
    final today = DateUtils.dateOnly(DateTime.now());
    final yesterday = today.subtract(const Duration(days: 1));
    final dayBeforeYesterday = today.subtract(const Duration(days: 2));

    for (final item in items) {
      final createdDate = DateUtils.dateOnly(item.createdAt);
      final filter = DateUtils.isSameDay(createdDate, today)
          ? _HistoryTimeFilter.today
          : DateUtils.isSameDay(createdDate, yesterday)
          ? _HistoryTimeFilter.yesterday
          : DateUtils.isSameDay(createdDate, dayBeforeYesterday)
          ? _HistoryTimeFilter.dayBeforeYesterday
          : _HistoryTimeFilter.older;
      counts[filter] = (counts[filter] ?? 0) + 1;
    }

    return counts;
  }

  Map<WordCategory, int> _categoryCounts(List<ScanHistoryItem> items) {
    final counts = <WordCategory, int>{
      for (final category in WordCategory.values) category: 0,
    };
    for (final item in items) {
      counts[item.wordCategory] = (counts[item.wordCategory] ?? 0) + 1;
    }
    return counts;
  }

  Map<DateTime, int> _olderDateCounts(List<ScanHistoryItem> items) {
    final dayBeforeYesterday = DateUtils.dateOnly(
      DateTime.now(),
    ).subtract(const Duration(days: 2));
    final counts = <DateTime, int>{};
    for (final item in items) {
      final createdDate = DateUtils.dateOnly(item.createdAt);
      if (createdDate.isBefore(dayBeforeYesterday)) {
        counts[createdDate] = (counts[createdDate] ?? 0) + 1;
      }
    }
    return counts;
  }

  void _openDictation(BuildContext context, List<ScanHistoryItem> items) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => DictationScreen(items: items)),
    );
  }
}

enum _HistoryGroupMode { time, category }

enum _HistoryTimeFilter { today, yesterday, dayBeforeYesterday, older }

class _HistoryFilterPanel extends StatelessWidget {
  const _HistoryFilterPanel({
    required this.groupMode,
    required this.selectedTimeFilter,
    required this.selectedOlderDate,
    required this.timeCounts,
    required this.categoryCounts,
    required this.onModeChanged,
    required this.onTimeSelected,
    required this.onOlderSelected,
    required this.onCategorySelected,
  });

  final _HistoryGroupMode groupMode;
  final _HistoryTimeFilter selectedTimeFilter;
  final DateTime? selectedOlderDate;
  final Map<_HistoryTimeFilter, int> timeCounts;
  final Map<WordCategory, int> categoryCounts;
  final ValueChanged<_HistoryGroupMode> onModeChanged;
  final ValueChanged<_HistoryTimeFilter> onTimeSelected;
  final VoidCallback onOlderSelected;
  final ValueChanged<WordCategory> onCategorySelected;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      backgroundColor: AppColors.paper,
      padding: AppSpacing.compactCard,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _HistoryModeSwitch(selected: groupMode, onChanged: onModeChanged),
          const SizedBox(height: AppSpacing.md),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 180),
            child: groupMode == _HistoryGroupMode.time
                ? _TimeFilterWrap(
                    key: const ValueKey('time-filters'),
                    selected: selectedTimeFilter,
                    selectedOlderDate: selectedOlderDate,
                    counts: timeCounts,
                    onSelected: onTimeSelected,
                    onOlderSelected: onOlderSelected,
                  )
                : _CategoryFilterGrid(
                    key: const ValueKey('category-filters'),
                    counts: categoryCounts,
                    onSelected: onCategorySelected,
                  ),
          ),
        ],
      ),
    );
  }
}

class _HistoryModeSwitch extends StatelessWidget {
  const _HistoryModeSwitch({required this.selected, required this.onChanged});

  final _HistoryGroupMode selected;
  final ValueChanged<_HistoryGroupMode> onChanged;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: AppColors.macaronMintSoft,
        borderRadius: AppRadius.pill,
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxs),
        child: Row(
          children: [
            Expanded(
              child: _ModeSwitchButton(
                label: '按时间',
                icon: Icons.calendar_month_rounded,
                selected: selected == _HistoryGroupMode.time,
                onTap: () => onChanged(_HistoryGroupMode.time),
              ),
            ),
            Expanded(
              child: _ModeSwitchButton(
                label: '按分类',
                icon: Icons.category_rounded,
                selected: selected == _HistoryGroupMode.category,
                onTap: () => onChanged(_HistoryGroupMode.category),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ModeSwitchButton extends StatelessWidget {
  const _ModeSwitchButton({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected
        ? Theme.of(context).colorScheme.primary
        : AppColors.mutedInk;

    return Material(
      color: selected ? AppColors.paper : Colors.transparent,
      borderRadius: AppRadius.pill,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.xs,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 18, color: color),
              const SizedBox(width: AppSpacing.xxs),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: color,
                    fontWeight: selected ? FontWeight.w900 : FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TimeFilterWrap extends StatelessWidget {
  const _TimeFilterWrap({
    required super.key,
    required this.selected,
    required this.selectedOlderDate,
    required this.counts,
    required this.onSelected,
    required this.onOlderSelected,
  });

  final _HistoryTimeFilter selected;
  final DateTime? selectedOlderDate;
  final Map<_HistoryTimeFilter, int> counts;
  final ValueChanged<_HistoryTimeFilter> onSelected;
  final VoidCallback onOlderSelected;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.xs,
      runSpacing: AppSpacing.xs,
      children: [
        _TimeFilterChip(
          label: '今天',
          count: counts[_HistoryTimeFilter.today] ?? 0,
          selected: selected == _HistoryTimeFilter.today,
          onTap: () => onSelected(_HistoryTimeFilter.today),
        ),
        _TimeFilterChip(
          label: '昨天',
          count: counts[_HistoryTimeFilter.yesterday] ?? 0,
          selected: selected == _HistoryTimeFilter.yesterday,
          onTap: () => onSelected(_HistoryTimeFilter.yesterday),
        ),
        _TimeFilterChip(
          label: '前天',
          count: counts[_HistoryTimeFilter.dayBeforeYesterday] ?? 0,
          selected: selected == _HistoryTimeFilter.dayBeforeYesterday,
          onTap: () => onSelected(_HistoryTimeFilter.dayBeforeYesterday),
        ),
        _TimeFilterChip(
          label: selectedOlderDate == null
              ? '更早'
              : '更早 ${_formatShortDate(selectedOlderDate!)}',
          icon: Icons.event_available_rounded,
          count: counts[_HistoryTimeFilter.older] ?? 0,
          selected: selected == _HistoryTimeFilter.older,
          onTap: onOlderSelected,
        ),
      ],
    );
  }
}

class _TimeFilterChip extends StatelessWidget {
  const _TimeFilterChip({
    required this.label,
    required this.count,
    required this.selected,
    required this.onTap,
    this.icon,
  });

  final String label;
  final IconData? icon;
  final int count;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final enabled = count > 0;
    final foreground = selected
        ? Theme.of(context).colorScheme.primary
        : enabled
        ? AppColors.photoInk
        : AppColors.mutedInk;

    return Material(
      color: selected
          ? AppColors.tabActiveBackground
          : AppColors.macaronSkySoft,
      borderRadius: AppRadius.pill,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: enabled ? onTap : null,
        child: Opacity(
          opacity: enabled ? 1 : 0.52,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: AppSpacing.xs,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icon != null) ...[
                  Icon(icon, size: 16, color: foreground),
                  const SizedBox(width: AppSpacing.xxs),
                ],
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: foreground,
                    fontWeight: selected ? FontWeight.w900 : FontWeight.w700,
                  ),
                ),
                const SizedBox(width: AppSpacing.xxs),
                Text(
                  '$count',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: foreground,
                    fontWeight: FontWeight.w900,
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

class _CategoryFilterGrid extends StatelessWidget {
  const _CategoryFilterGrid({
    required super.key,
    required this.counts,
    required this.onSelected,
  });

  final Map<WordCategory, int> counts;
  final ValueChanged<WordCategory> onSelected;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: AppSpacing.xs,
        crossAxisSpacing: AppSpacing.xs,
        mainAxisExtent: 116,
      ),
      itemCount: WordCategory.values.length,
      itemBuilder: (context, index) {
        final category = WordCategory.values[index];
        final count = counts[category] ?? 0;
        return _CategoryFilterCard(
          icon: _categoryIcon(category),
          label: category.label,
          count: count,
          enabled: count > 0,
          onTap: () => onSelected(category),
        );
      },
    );
  }
}

class _CategoryFilterCard extends StatelessWidget {
  const _CategoryFilterCard({
    required this.icon,
    required this.label,
    required this.count,
    required this.enabled,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final int count;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final foreground = enabled ? AppColors.photoInk : AppColors.mutedInk;

    return Material(
      color: AppColors.macaronMintSoft,
      borderRadius: AppRadius.medium,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: enabled ? onTap : null,
        child: Opacity(
          opacity: enabled ? 1 : 0.52,
          child: Stack(
            children: [
              Positioned(
                top: AppSpacing.xs,
                right: AppSpacing.xs,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '$count',
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: foreground,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.xxs),
                    Icon(
                      Icons.chevron_right_rounded,
                      size: 16,
                      color: foreground,
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.xs,
                  AppSpacing.lg,
                  AppSpacing.xs,
                  AppSpacing.xs,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    DecoratedBox(
                      decoration: const BoxDecoration(
                        color: AppColors.paper,
                        borderRadius: AppRadius.medium,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(AppSpacing.xs),
                        child: Icon(icon, color: foreground, size: 22),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      label,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: foreground,
                        fontWeight: FontWeight.w800,
                        height: 1.12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OlderDatePickerSheet extends StatefulWidget {
  const _OlderDatePickerSheet({
    required this.dateCounts,
    required this.selectedDate,
  });

  final Map<DateTime, int> dateCounts;
  final DateTime? selectedDate;

  @override
  State<_OlderDatePickerSheet> createState() => _OlderDatePickerSheetState();
}

class _OlderDatePickerSheetState extends State<_OlderDatePickerSheet> {
  late DateTime _visibleMonth;

  DateTime get _firstDate => widget.dateCounts.keys.reduce(
    (first, date) => date.isBefore(first) ? date : first,
  );

  DateTime get _lastDate => widget.dateCounts.keys.reduce(
    (last, date) => date.isAfter(last) ? date : last,
  );

  @override
  void initState() {
    super.initState();
    final initialDate = widget.selectedDate ?? _lastDate;
    _visibleMonth = DateTime(initialDate.year, initialDate.month);
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).viewPadding.bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.md,
        AppSpacing.md,
        AppSpacing.md + bottomPadding,
      ),
      child: DecoratedBox(
        decoration: const BoxDecoration(
          color: AppColors.paper,
          borderRadius: AppRadius.large,
          boxShadow: AppShadows.floating,
        ),
        child: Padding(
          padding: AppSpacing.card,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '选择更早的日期',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: AppSpacing.xxs),
                        Text(
                          '有学习记录的日期已经用颜色标出来。',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: AppColors.mutedInk),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: '关闭',
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  IconButton(
                    tooltip: '上个月',
                    onPressed: _canShowPreviousMonth
                        ? _showPreviousMonth
                        : null,
                    icon: const Icon(Icons.chevron_left_rounded),
                  ),
                  Expanded(
                    child: Text(
                      '${_visibleMonth.year} 年 ${_visibleMonth.month} 月',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                  ),
                  IconButton(
                    tooltip: '下个月',
                    onPressed: _canShowNextMonth ? _showNextMonth : null,
                    icon: const Icon(Icons.chevron_right_rounded),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xs),
              const _WeekdayHeader(),
              const SizedBox(height: AppSpacing.xs),
              _CalendarMonthGrid(
                visibleMonth: _visibleMonth,
                selectedDate: widget.selectedDate,
                dateCounts: widget.dateCounts,
                onDateSelected: (date) {
                  Navigator.of(context).pop(_OlderDatePickerResult(date));
                },
              ),
              const SizedBox(height: AppSpacing.md),
              AppButton.tonal(
                label: '查看全部更早记录',
                icon: Icons.history_rounded,
                onPressed: () {
                  Navigator.of(context).pop(const _OlderDatePickerResult(null));
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool get _canShowPreviousMonth {
    final previous = DateTime(_visibleMonth.year, _visibleMonth.month - 1);
    return !previous.isBefore(DateTime(_firstDate.year, _firstDate.month));
  }

  bool get _canShowNextMonth {
    final next = DateTime(_visibleMonth.year, _visibleMonth.month + 1);
    return !next.isAfter(DateTime(_lastDate.year, _lastDate.month));
  }

  void _showPreviousMonth() {
    setState(() {
      _visibleMonth = DateTime(_visibleMonth.year, _visibleMonth.month - 1);
    });
  }

  void _showNextMonth() {
    setState(() {
      _visibleMonth = DateTime(_visibleMonth.year, _visibleMonth.month + 1);
    });
  }
}

class _WeekdayHeader extends StatelessWidget {
  const _WeekdayHeader();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (final weekday in const ['一', '二', '三', '四', '五', '六', '日'])
          Expanded(
            child: Text(
              weekday,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: AppColors.mutedInk,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
      ],
    );
  }
}

class _CalendarMonthGrid extends StatelessWidget {
  const _CalendarMonthGrid({
    required this.visibleMonth,
    required this.selectedDate,
    required this.dateCounts,
    required this.onDateSelected,
  });

  final DateTime visibleMonth;
  final DateTime? selectedDate;
  final Map<DateTime, int> dateCounts;
  final ValueChanged<DateTime> onDateSelected;

  @override
  Widget build(BuildContext context) {
    final firstDay = DateTime(visibleMonth.year, visibleMonth.month);
    final dayCount = DateUtils.getDaysInMonth(
      visibleMonth.year,
      visibleMonth.month,
    );
    final leadingEmptyCells = firstDay.weekday - 1;
    final cellCount = leadingEmptyCells + dayCount;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        mainAxisSpacing: AppSpacing.xxs,
        crossAxisSpacing: AppSpacing.xxs,
      ),
      itemCount: cellCount,
      itemBuilder: (context, index) {
        if (index < leadingEmptyCells) {
          return const SizedBox.shrink();
        }
        final day = index - leadingEmptyCells + 1;
        final date = DateTime(visibleMonth.year, visibleMonth.month, day);
        return _CalendarDayCell(
          date: date,
          count: dateCounts[date] ?? 0,
          selected: DateUtils.isSameDay(date, selectedDate),
          onTap: () => onDateSelected(date),
        );
      },
    );
  }
}

class _CalendarDayCell extends StatelessWidget {
  const _CalendarDayCell({
    required this.date,
    required this.count,
    required this.selected,
    required this.onTap,
  });

  final DateTime date;
  final int count;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final hasData = count > 0;
    final foreground = selected
        ? Theme.of(context).colorScheme.primary
        : hasData
        ? AppColors.photoInk
        : AppColors.mutedInk;

    return Material(
      color: selected
          ? AppColors.tabActiveBackground
          : hasData
          ? AppColors.macaronMintSoft
          : Colors.transparent,
      borderRadius: AppRadius.medium,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: hasData ? onTap : null,
        child: Opacity(
          opacity: hasData ? 1 : 0.42,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '${date.day}',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: foreground,
                  fontWeight: FontWeight.w900,
                ),
              ),
              if (hasData)
                Text(
                  '$count',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: foreground,
                    fontWeight: FontWeight.w800,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OlderDatePickerResult {
  const _OlderDatePickerResult(this.date);

  final DateTime? date;
}

IconData _categoryIcon(WordCategory category) {
  return switch (category) {
    WordCategory.homeLiving => Icons.chair_alt_rounded,
    WordCategory.foodDrink => Icons.restaurant_rounded,
    WordCategory.clothingAccessories => Icons.checkroom_rounded,
    WordCategory.schoolOffice => Icons.edit_note_rounded,
    WordCategory.digitalDevices => Icons.devices_rounded,
    WordCategory.transportation => Icons.directions_bus_rounded,
    WordCategory.naturePlants => Icons.local_florist_rounded,
    WordCategory.animals => Icons.pets_rounded,
    WordCategory.sportsToys => Icons.sports_basketball_rounded,
    WordCategory.personalCare => Icons.spa_rounded,
    WordCategory.publicPlaces => Icons.storefront_rounded,
    WordCategory.otherObjects => Icons.category_rounded,
  };
}

String _formatShortDate(DateTime date) {
  return '${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')}';
}

class _CategoryHistoryDetailPage extends StatelessWidget {
  const _CategoryHistoryDetailPage({
    required this.category,
    required this.items,
  });

  final WordCategory category;
  final List<ScanHistoryItem> items;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(category.label)),
      body: SafeArea(
        child: ListView(
          padding: AppSpacing.screen,
          children: [
            _DictationEntryCard(
              count: items.length,
              onStart: items.isEmpty ? null : () => _openDictation(context),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              '${category.label}词汇',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: AppSpacing.xxs),
            Text(
              '${items.length} 个照片词汇，听一遍、看一句，也可以再次做成分享卡。',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            for (final item in items) _HistoryTile(item: item),
          ],
        ),
      ),
    );
  }

  void _openDictation(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => DictationScreen(items: items)),
    );
  }
}

class _HistoryTile extends ConsumerWidget {
  const _HistoryTile({required this.item});

  final ScanHistoryItem item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final meaning = item.translationFor(HistoryScreen._meaningLanguage);
    final sentence = item.sentences.isEmpty ? null : item.sentences.first;

    return AppCard(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: AppSpacing.compactCard,
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: AppRadius.medium,
                child: Image.network(
                  item.imageUrl,
                  width: 76,
                  height: 76,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => ColoredBox(
                    color: Theme.of(
                      context,
                    ).colorScheme.surfaceContainerHighest,
                    child: const SizedBox(
                      width: 76,
                      height: 76,
                      child: Icon(Icons.image_not_supported_outlined),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.sourceWord,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    if (meaning.isNotEmpty) ...[
                      const SizedBox(height: AppSpacing.xxs),
                      Text(
                        meaning,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ],
                    const SizedBox(height: AppSpacing.xs),
                    Wrap(
                      spacing: AppSpacing.xs,
                      runSpacing: AppSpacing.xxs,
                      children: [
                        _MiniChip(
                          icon: Icons.calendar_today_rounded,
                          label: _formatDate(item.createdAt),
                        ),
                        _MiniChip(
                          icon: Icons.category_rounded,
                          label: item.wordCategory.label,
                        ),
                        if (item.phoneticText.isNotEmpty)
                          _MiniChip(
                            icon: Icons.graphic_eq_rounded,
                            label: item.phoneticText,
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (sentence != null) ...[
            const SizedBox(height: AppSpacing.sm),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                sentence.english,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.mutedInk,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: AudioPlayButton(
                  label: '播放',
                  tooltip: '播放单词音频',
                  onPressed: () => _playAudio(context, ref),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: AppButton.tonal(
                  icon: Icons.ios_share_rounded,
                  label: '分享',
                  onPressed: () => _openShareCardEditor(context),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _playAudio(BuildContext context, WidgetRef ref) async {
    try {
      await ref
          .read(audioPlaybackServiceProvider)
          .playUrl(item.audioLinks.preferred);
    } catch (error) {
      if (!context.mounted) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('这个单词音频暂不可用：$error')));
    }
  }

  String _formatDate(DateTime value) {
    return '${value.year}-${value.month.toString().padLeft(2, '0')}-${value.day.toString().padLeft(2, '0')}';
  }

  void _openShareCardEditor(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ShareCardEditorPage(
          initialData: ShareCardData(
            imageUrl: item.imageUrl,
            englishWord: item.sourceWord,
            phoneticText: item.phoneticText,
            chineseMeaning: item.translationFor(HistoryScreen._meaningLanguage),
            sentences: item.sentences
                .map(
                  (sentence) => ShareCardSentence(
                    english: sentence.english,
                    translation: sentence.translation,
                  ),
                )
                .toList(growable: false),
            createdAt: item.createdAt,
          ),
        ),
      ),
    );
  }
}

class _DictationEntryCard extends StatelessWidget {
  const _DictationEntryCard({required this.count, required this.onStart});

  final int count;
  final VoidCallback? onStart;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      backgroundColor: AppColors.macaronLavenderSoft,
      borderColor: AppColors.macaronLavenderSoft,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              DecoratedBox(
                decoration: const BoxDecoration(
                  color: AppColors.paper,
                  borderRadius: AppRadius.large,
                ),
                child: Padding(
                  padding: AppSpacing.compactCard,
                  child: Icon(
                    Icons.hearing_rounded,
                    color: Theme.of(context).colorScheme.tertiary,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '听写小练习',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: AppSpacing.xxs),
                    Text(
                      count == 0 ? '有历史词汇后就能开始。' : '$count 个照片词汇等你复习。',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.mutedInk,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          AppButton.primary(
            icon: Icons.play_arrow_rounded,
            label: '开始听写测试',
            onPressed: onStart,
            expand: true,
          ),
        ],
      ),
    );
  }
}

class _MiniChip extends StatelessWidget {
  const _MiniChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: AppColors.macaronButterSoft,
        borderRadius: AppRadius.pill,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xs,
          vertical: AppSpacing.xxs,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 13, color: AppColors.mutedInk),
            const SizedBox(width: AppSpacing.xxs),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 200),
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(
                  context,
                ).textTheme.labelMedium?.copyWith(color: AppColors.photoInk),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyHistory extends StatelessWidget {
  const _EmptyHistory();

  @override
  Widget build(BuildContext context) {
    return const EmptyStateView(
      title: '还没有识别记录',
      message: '拍下一张照片后，它会变成你的第一张生词卡。',
      useCard: false,
    );
  }
}

class _EmptyFilteredHistory extends StatelessWidget {
  const _EmptyFilteredHistory({required this.groupMode});

  final _HistoryGroupMode groupMode;

  @override
  Widget build(BuildContext context) {
    return EmptyStateView(
      title: '这个范围还没有词汇',
      message: groupMode == _HistoryGroupMode.time
          ? '换个日期看看，或者今天再捕捉一个新单词。'
          : '这个分类还空着，下一次拍到相关物品时会自动归进来。',
      icon: groupMode == _HistoryGroupMode.time
          ? Icons.event_note_rounded
          : Icons.category_outlined,
      useCard: false,
    );
  }
}

class _HistoryError extends StatelessWidget {
  const _HistoryError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: AppSpacing.screen,
      child: Center(
        child: ErrorStateView(
          title: '学习记录暂时打不开',
          message: message,
          onRetry: onRetry,
          useCard: false,
        ),
      ),
    );
  }
}
