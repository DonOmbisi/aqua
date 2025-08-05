import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class FilterPanelWidget extends StatefulWidget {
  final Function(Map<String, dynamic>) onFiltersChanged;
  final Map<String, dynamic> currentFilters;

  const FilterPanelWidget({
    super.key,
    required this.onFiltersChanged,
    required this.currentFilters,
  });

  @override
  State<FilterPanelWidget> createState() => _FilterPanelWidgetState();
}

class _FilterPanelWidgetState extends State<FilterPanelWidget> {
  late Map<String, dynamic> _filters;

  final List<String> _parameters = [
    'pH Level',
    'Dissolved Oxygen',
    'Temperature',
    'Turbidity',
    'Flow Rate',
    'Conductivity'
  ];

  final List<String> _locations = [
    'All Locations',
    'Station A - Downtown',
    'Station B - Industrial',
    'Station C - Residential',
    'Station D - Rural',
    'Station E - Coastal'
  ];

  final List<String> _dataSources = [
    'All Sources',
    'Automated Sensors',
    'Manual Testing',
    'Community Reports',
    'Expert Verification'
  ];

  @override
  void initState() {
    super.initState();
    _filters = Map<String, dynamic>.from(widget.currentFilters);
  }

  void _showFilterBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          height: 80.h,
          decoration: BoxDecoration(
            color: AppTheme.lightTheme.colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.all(4.w),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: AppTheme.lightTheme.colorScheme.outline
                          .withValues(alpha: 0.2),
                    ),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Filter Analytics',
                      style:
                          AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Row(
                      children: [
                        TextButton(
                          onPressed: () {
                            setModalState(() {
                              _filters = {
                                'parameters': <String>[],
                                'locations': 'All Locations',
                                'dataSources': 'All Sources',
                                'qualityRange': RangeValues(0, 10),
                                'showOnlyIssues': false,
                              };
                            });
                          },
                          child: Text('Reset'),
                        ),
                        TextButton(
                          onPressed: () {
                            widget.onFiltersChanged(_filters);
                            Navigator.pop(context);
                          },
                          child: Text('Apply'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(4.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildParameterSection(setModalState),
                      SizedBox(height: 3.h),
                      _buildLocationSection(setModalState),
                      SizedBox(height: 3.h),
                      _buildDataSourceSection(setModalState),
                      SizedBox(height: 3.h),
                      _buildQualityRangeSection(setModalState),
                      SizedBox(height: 3.h),
                      _buildToggleSection(setModalState),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildParameterSection(StateSetter setModalState) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Parameters',
          style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 2.h),
        Wrap(
          spacing: 2.w,
          runSpacing: 1.h,
          children: _parameters.map((parameter) {
            final isSelected = (_filters['parameters'] as List<String>? ?? [])
                .contains(parameter);
            return GestureDetector(
              onTap: () {
                setModalState(() {
                  final selectedParams =
                      List<String>.from(_filters['parameters'] ?? []);
                  if (isSelected) {
                    selectedParams.remove(parameter);
                  } else {
                    selectedParams.add(parameter);
                  }
                  _filters['parameters'] = selectedParams;
                });
              },
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppTheme.lightTheme.primaryColor.withValues(alpha: 0.1)
                      : AppTheme.lightTheme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected
                        ? AppTheme.lightTheme.primaryColor
                        : AppTheme.lightTheme.colorScheme.outline
                            .withValues(alpha: 0.3),
                  ),
                ),
                child: Text(
                  parameter,
                  style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                    color: isSelected
                        ? AppTheme.lightTheme.primaryColor
                        : AppTheme.lightTheme.colorScheme.onSurface,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildLocationSection(StateSetter setModalState) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Location',
          style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 2.h),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 4.w),
          decoration: BoxDecoration(
            border: Border.all(
              color: AppTheme.lightTheme.colorScheme.outline
                  .withValues(alpha: 0.3),
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _filters['locations'] ?? 'All Locations',
              isExpanded: true,
              items: _locations.map((location) {
                return DropdownMenuItem<String>(
                  value: location,
                  child: Text(
                    location,
                    style: AppTheme.lightTheme.textTheme.bodyMedium,
                  ),
                );
              }).toList(),
              onChanged: (value) {
                setModalState(() {
                  _filters['locations'] = value;
                });
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDataSourceSection(StateSetter setModalState) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Data Source',
          style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 2.h),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 4.w),
          decoration: BoxDecoration(
            border: Border.all(
              color: AppTheme.lightTheme.colorScheme.outline
                  .withValues(alpha: 0.3),
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _filters['dataSources'] ?? 'All Sources',
              isExpanded: true,
              items: _dataSources.map((source) {
                return DropdownMenuItem<String>(
                  value: source,
                  child: Text(
                    source,
                    style: AppTheme.lightTheme.textTheme.bodyMedium,
                  ),
                );
              }).toList(),
              onChanged: (value) {
                setModalState(() {
                  _filters['dataSources'] = value;
                });
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQualityRangeSection(StateSetter setModalState) {
    final currentRange =
        _filters['qualityRange'] as RangeValues? ?? const RangeValues(0, 10);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quality Score Range',
          style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 1.h),
        Text(
          '${currentRange.start.toStringAsFixed(1)} - ${currentRange.end.toStringAsFixed(1)}',
          style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
            color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
          ),
        ),
        RangeSlider(
          values: currentRange,
          min: 0,
          max: 10,
          divisions: 20,
          labels: RangeLabels(
            currentRange.start.toStringAsFixed(1),
            currentRange.end.toStringAsFixed(1),
          ),
          onChanged: (values) {
            setModalState(() {
              _filters['qualityRange'] = values;
            });
          },
        ),
      ],
    );
  }

  Widget _buildToggleSection(StateSetter setModalState) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Display Options',
          style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 2.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Show only locations with issues',
              style: AppTheme.lightTheme.textTheme.bodyMedium,
            ),
            Switch(
              value: _filters['showOnlyIssues'] ?? false,
              onChanged: (value) {
                setModalState(() {
                  _filters['showOnlyIssues'] = value;
                });
              },
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final activeFiltersCount = _getActiveFiltersCount();

    return GestureDetector(
      onTap: () => _showFilterBottomSheet(context),
      child: Container(
        padding: EdgeInsets.all(3.w),
        decoration: BoxDecoration(
          color: activeFiltersCount > 0
              ? AppTheme.lightTheme.primaryColor
              : AppTheme.lightTheme.colorScheme.surface,
          borderRadius: BorderRadius.circular(8),
          border: activeFiltersCount == 0
              ? Border.all(
                  color: AppTheme.lightTheme.colorScheme.outline
                      .withValues(alpha: 0.3),
                )
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomIconWidget(
              iconName: 'filter_list',
              color: activeFiltersCount > 0
                  ? AppTheme.lightTheme.colorScheme.onPrimary
                  : AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              size: 5.w,
            ),
            if (activeFiltersCount > 0) ...[
              SizedBox(width: 1.w),
              Container(
                padding:
                    EdgeInsets.symmetric(horizontal: 1.5.w, vertical: 0.5.h),
                decoration: BoxDecoration(
                  color: AppTheme.lightTheme.colorScheme.onPrimary,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  activeFiltersCount.toString(),
                  style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                    color: AppTheme.lightTheme.primaryColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 10.sp,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  int _getActiveFiltersCount() {
    int count = 0;

    final parameters = _filters['parameters'] as List<String>? ?? [];
    if (parameters.isNotEmpty) count++;

    if (_filters['locations'] != null &&
        _filters['locations'] != 'All Locations') count++;
    if (_filters['dataSources'] != null &&
        _filters['dataSources'] != 'All Sources') count++;

    final range = _filters['qualityRange'] as RangeValues?;
    if (range != null && (range.start != 0 || range.end != 10)) count++;

    if (_filters['showOnlyIssues'] == true) count++;

    return count;
  }
}
