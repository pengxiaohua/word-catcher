import 'package:flutter/material.dart';
import 'package:word_catcher/core/theme/theme.dart';

import '../models/share_card_template.dart';

class TemplateSelector extends StatelessWidget {
  const TemplateSelector({
    required this.selected,
    required this.onChanged,
    super.key,
  });

  final ShareCardTemplate selected;
  final ValueChanged<ShareCardTemplate> onChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 116,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: ShareCardTemplate.values.length,
        separatorBuilder: (context, index) =>
            const SizedBox(width: AppSpacing.sm),
        itemBuilder: (context, index) {
          final template = ShareCardTemplate.values[index];
          final isSelected = template == selected;
          return _TemplateChoice(
            template: template,
            isSelected: isSelected,
            onTap: () => onChanged(template),
          );
        },
      ),
    );
  }
}

class _TemplateChoice extends StatelessWidget {
  const _TemplateChoice({
    required this.template,
    required this.isSelected,
    required this.onTap,
  });

  final ShareCardTemplate template;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SizedBox(
      width: 156,
      child: Material(
        color: isSelected
            ? colorScheme.primaryContainer
            : colorScheme.surfaceContainerLowest,
        borderRadius: AppRadius.medium,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: AppRadius.medium,
              border: Border.all(
                color: isSelected
                    ? colorScheme.primary
                    : colorScheme.outlineVariant,
                width: isSelected ? 1.5 : 1,
              ),
            ),
            child: Padding(
              padding: AppSpacing.compactCard,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    template.icon,
                    color: isSelected
                        ? colorScheme.onPrimaryContainer
                        : colorScheme.primary,
                  ),
                  const Spacer(),
                  Text(
                    template.chineseLabel,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: isSelected
                          ? colorScheme.onPrimaryContainer
                          : colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxs),
                  Text(
                    template.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: isSelected
                          ? colorScheme.onPrimaryContainer
                          : colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
