import 'package:flutter/material.dart';
import 'package:collection/collection.dart'; // Import for firstWhereOrNull

// Helper class to define filter options
class FilterOption<T> {
  final String label;
  final T value;

  const FilterOption({required this.label, required this.value});
}

// Placeholder for the "All" option to distinguish it from a null value
const String _kAllValuePlaceholder = '__ALL__';

class FilterPopupMenuButton<T> extends StatelessWidget {
  final T? initialValue;
  final List<FilterOption<T>> options;
  final ValueChanged<T?> onSelected;
  final String allOptionText;
  final String tooltip;
  final Widget? avatar;

  const FilterPopupMenuButton({
    super.key,
    required this.options,
    required this.onSelected,
    this.initialValue,
    this.allOptionText = 'Все',
    this.tooltip = 'Фильтр',
    this.avatar,
  });

  @override
  Widget build(BuildContext context) {
    // Determine the current label for the chip
    final selectedOption = options.firstWhereOrNull((option) => option.value == initialValue);
    final String currentLabel = selectedOption?.label ?? allOptionText;

    return PopupMenuButton<dynamic>(
      tooltip: tooltip,
      initialValue: initialValue ?? _kAllValuePlaceholder,
      onSelected: (dynamic value) {
        if (value == _kAllValuePlaceholder) {
          onSelected(null);
        } else {
          onSelected(value as T?); // Cast to T? to handle both nullable and non-nullable T
        }
      },
      itemBuilder: (BuildContext context) => <PopupMenuEntry<dynamic>>[
        // "All" option
        PopupMenuItem<dynamic>(
          value: _kAllValuePlaceholder,
          child: Text(allOptionText),
        ),
        // Other options
        ...options.map((option) => PopupMenuItem<dynamic>(
              value: option.value,
              child: Text(option.label),
            )),
      ],
      child: Chip(
        key: ValueKey('filter_chip_${initialValue ?? _kAllValuePlaceholder}'),
        label: Text(currentLabel),
        avatar: avatar,
      ),
    );
  }
}
