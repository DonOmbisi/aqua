import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../../core/app_export.dart';

class NotesSectionWidget extends StatefulWidget {
  final Function(String notes) onNotesUpdate;
  final String initialNotes;

  const NotesSectionWidget({
    Key? key,
    required this.onNotesUpdate,
    this.initialNotes = '',
  }) : super(key: key);

  @override
  State<NotesSectionWidget> createState() => _NotesSectionWidgetState();
}

class _NotesSectionWidgetState extends State<NotesSectionWidget> {
  final TextEditingController _notesController = TextEditingController();
  bool _isExpanded = false;
  int _characterCount = 0;
  final int _maxCharacters = 500;

  @override
  void initState() {
    super.initState();
    _notesController.text = widget.initialNotes;
    _characterCount = widget.initialNotes.length;
    _isExpanded = widget.initialNotes.isNotEmpty;
  }

  void _onNotesChanged(String value) {
    setState(() {
      _characterCount = value.length;
    });
    widget.onNotesUpdate(value);
  }

  void _toggleExpanded() {
    setState(() {
      _isExpanded = !_isExpanded;
    });
  }

  List<String> _getSuggestions() {
    return [
      'Water appears clear with no visible debris',
      'Slight algae growth observed on surface',
      'Strong chemical odor detected',
      'Water source appears contaminated',
      'Normal flow rate for this location',
      'Recent rainfall may have affected readings',
      'Construction activity nearby',
      'Wildlife activity observed in area',
      'Seasonal variation noted',
      'Equipment calibrated before measurement',
    ];
  }

  void _addSuggestion(String suggestion) {
    final currentText = _notesController.text;
    final newText =
        currentText.isEmpty ? suggestion : '$currentText. $suggestion';

    if (newText.length <= _maxCharacters) {
      _notesController.text = newText;
      _onNotesChanged(newText);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: _toggleExpanded,
            child: Row(
              children: [
                CustomIconWidget(
                  iconName: 'notes',
                  color: AppTheme.lightTheme.colorScheme.primary,
                  size: 20,
                ),
                SizedBox(width: 2.w),
                Expanded(
                  child: Text(
                    'Additional Notes & Observations',
                    style: AppTheme.lightTheme.textTheme.titleMedium,
                  ),
                ),
                CustomIconWidget(
                  iconName: _isExpanded ? 'expand_less' : 'expand_more',
                  color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                  size: 24,
                ),
              ],
            ),
          ),
          if (_isExpanded) ...[
            SizedBox(height: 3.h),

            // Notes input field
            TextFormField(
              controller: _notesController,
              maxLines: 5,
              maxLength: _maxCharacters,
              decoration: InputDecoration(
                hintText:
                    'Record any additional observations, environmental conditions, or relevant details about the water sample...',
                counterText: '$_characterCount/$_maxCharacters',
                counterStyle: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                  color: _characterCount > _maxCharacters * 0.9
                      ? AppTheme.lightTheme.colorScheme.error
                      : AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                ),
              ),
              onChanged: _onNotesChanged,
            ),

            SizedBox(height: 2.h),

            // Quick suggestions
            Text(
              'Quick Suggestions',
              style: AppTheme.lightTheme.textTheme.titleSmall,
            ),
            SizedBox(height: 1.h),

            Wrap(
              spacing: 2.w,
              runSpacing: 1.h,
              children: _getSuggestions().map((suggestion) {
                return GestureDetector(
                  onTap: () => _addSuggestion(suggestion),
                  child: Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
                    decoration: BoxDecoration(
                      color: AppTheme.lightTheme.colorScheme.primary
                          .withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppTheme.lightTheme.colorScheme.primary
                            .withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CustomIconWidget(
                          iconName: 'add',
                          color: AppTheme.lightTheme.colorScheme.primary,
                          size: 14,
                        ),
                        SizedBox(width: 1.w),
                        Flexible(
                          child: Text(
                            suggestion,
                            style: AppTheme.lightTheme.textTheme.bodySmall
                                ?.copyWith(
                              color: AppTheme.lightTheme.colorScheme.primary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),

            SizedBox(height: 2.h),

            // Tips section
            Container(
              padding: EdgeInsets.all(3.w),
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.tertiary
                    .withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppTheme.lightTheme.colorScheme.tertiary
                      .withValues(alpha: 0.3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CustomIconWidget(
                        iconName: 'lightbulb_outline',
                        color: AppTheme.lightTheme.colorScheme.tertiary,
                        size: 16,
                      ),
                      SizedBox(width: 2.w),
                      Text(
                        'Tips for Better Documentation',
                        style:
                            AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                          color: AppTheme.lightTheme.colorScheme.tertiary,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 1.h),
                  Text(
                    '• Note weather conditions and recent events\n'
                    '• Describe water appearance, odor, and color\n'
                    '• Record any nearby pollution sources\n'
                    '• Mention equipment calibration status\n'
                    '• Include time of day and seasonal factors',
                    style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                      color: AppTheme.lightTheme.colorScheme.tertiary,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ] else ...[
            SizedBox(height: 1.h),
            Text(
              _notesController.text.isEmpty
                  ? 'Tap to add observations and notes'
                  : '${_notesController.text.substring(0, _notesController.text.length > 50 ? 50 : _notesController.text.length)}${_notesController.text.length > 50 ? '...' : ''}',
              style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                fontStyle: _notesController.text.isEmpty
                    ? FontStyle.italic
                    : FontStyle.normal,
              ),
            ),
          ],
        ],
      ),
    );
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }
}
