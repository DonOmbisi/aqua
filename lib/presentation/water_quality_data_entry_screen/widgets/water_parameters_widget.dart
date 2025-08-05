import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../../core/app_export.dart';

class WaterParametersWidget extends StatefulWidget {
  final Function(Map<String, dynamic> parameters) onParametersUpdate;
  final Map<String, dynamic> initialParameters;

  const WaterParametersWidget({
    Key? key,
    required this.onParametersUpdate,
    this.initialParameters = const {},
  }) : super(key: key);

  @override
  State<WaterParametersWidget> createState() => _WaterParametersWidgetState();
}

class _WaterParametersWidgetState extends State<WaterParametersWidget> {
  double _phValue = 7.0;
  double _turbidityValue = 0.0;
  double _temperatureValue = 20.0;
  double _dissolvedOxygenValue = 8.0;
  double _waterLevelValue = 50.0;
  double _flowRateValue = 0.0;
  bool _isTemperatureCelsius = true;

  final TextEditingController _turbidityController = TextEditingController();
  final TextEditingController _dissolvedOxygenController =
      TextEditingController();
  final TextEditingController _waterLevelController = TextEditingController();
  final TextEditingController _flowRateController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initializeFromParameters();
  }

  void _initializeFromParameters() {
    final params = widget.initialParameters;
    _phValue = (params['ph'] as double?) ?? 7.0;
    _turbidityValue = (params['turbidity'] as double?) ?? 0.0;
    _temperatureValue = (params['temperature'] as double?) ?? 20.0;
    _dissolvedOxygenValue = (params['dissolved_oxygen'] as double?) ?? 8.0;
    _waterLevelValue = (params['water_level'] as double?) ?? 50.0;
    _flowRateValue = (params['flow_rate'] as double?) ?? 0.0;
    _isTemperatureCelsius = (params['temperature_unit'] as String?) == 'C';

    _turbidityController.text = _turbidityValue.toStringAsFixed(1);
    _dissolvedOxygenController.text = _dissolvedOxygenValue.toStringAsFixed(1);
    _waterLevelController.text = _waterLevelValue.toStringAsFixed(1);
    _flowRateController.text = _flowRateValue.toStringAsFixed(2);
  }

  void _updateParameters() {
    final parameters = {
      'ph': _phValue,
      'turbidity': _turbidityValue,
      'temperature': _temperatureValue,
      'temperature_unit': _isTemperatureCelsius ? 'C' : 'F',
      'dissolved_oxygen': _dissolvedOxygenValue,
      'water_level': _waterLevelValue,
      'flow_rate': _flowRateValue,
    };
    widget.onParametersUpdate(parameters);
  }

  Color _getPhColor(double ph) {
    if (ph >= 6.5 && ph <= 8.5) return AppTheme.lightTheme.colorScheme.tertiary;
    if (ph >= 6.0 && ph <= 9.0) return AppTheme.warningLight;
    return AppTheme.lightTheme.colorScheme.error;
  }

  Color _getTurbidityColor(double turbidity) {
    if (turbidity <= 1.0) return AppTheme.lightTheme.colorScheme.tertiary;
    if (turbidity <= 4.0) return AppTheme.warningLight;
    return AppTheme.lightTheme.colorScheme.error;
  }

  Color _getTemperatureColor(double temp) {
    if (temp >= 15 && temp <= 25)
      return AppTheme.lightTheme.colorScheme.tertiary;
    if (temp >= 10 && temp <= 30) return AppTheme.warningLight;
    return AppTheme.lightTheme.colorScheme.error;
  }

  Color _getDissolvedOxygenColor(double oxygen) {
    if (oxygen >= 6.0) return AppTheme.lightTheme.colorScheme.tertiary;
    if (oxygen >= 4.0) return AppTheme.warningLight;
    return AppTheme.lightTheme.colorScheme.error;
  }

  Widget _buildParameterCard({
    required String title,
    required String subtitle,
    required Widget content,
    required Color indicatorColor,
    String? helpText,
  }) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(bottom: 3.h),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: indicatorColor.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 4,
                height: 20,
                decoration: BoxDecoration(
                  color: indicatorColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTheme.lightTheme.textTheme.titleMedium,
                    ),
                    Text(
                      subtitle,
                      style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                        color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              if (helpText != null)
                GestureDetector(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text(title),
                        content: Text(helpText),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('OK'),
                          ),
                        ],
                      ),
                    );
                  },
                  child: CustomIconWidget(
                    iconName: 'help_outline',
                    color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                    size: 20,
                  ),
                ),
            ],
          ),
          SizedBox(height: 2.h),
          content,
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Water Quality Parameters',
          style: AppTheme.lightTheme.textTheme.headlineSmall,
        ),
        SizedBox(height: 2.h),

        // pH Level
        _buildParameterCard(
          title: 'pH Level',
          subtitle:
              'Current: ${_phValue.toStringAsFixed(1)} (${_phValue >= 6.5 && _phValue <= 8.5 ? 'Optimal' : _phValue >= 6.0 && _phValue <= 9.0 ? 'Acceptable' : 'Poor'})',
          indicatorColor: _getPhColor(_phValue),
          helpText:
              'pH measures water acidity/alkalinity. Optimal range: 6.5-8.5. Values outside 6.0-9.0 may indicate contamination.',
          content: Column(
            children: [
              Slider(
                value: _phValue,
                min: 0.0,
                max: 14.0,
                divisions: 140,
                onChanged: (value) {
                  setState(() => _phValue = value);
                  _updateParameters();
                },
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('0.0 (Acidic)',
                      style: AppTheme.lightTheme.textTheme.bodySmall),
                  Text('7.0 (Neutral)',
                      style: AppTheme.lightTheme.textTheme.bodySmall),
                  Text('14.0 (Basic)',
                      style: AppTheme.lightTheme.textTheme.bodySmall),
                ],
              ),
            ],
          ),
        ),

        // Turbidity
        _buildParameterCard(
          title: 'Turbidity',
          subtitle:
              'Current: ${_turbidityValue.toStringAsFixed(1)} NTU (${_turbidityValue <= 1.0 ? 'Excellent' : _turbidityValue <= 4.0 ? 'Good' : 'Poor'})',
          indicatorColor: _getTurbidityColor(_turbidityValue),
          helpText:
              'Turbidity measures water clarity. Lower values indicate cleaner water. Excellent: ≤1 NTU, Good: ≤4 NTU.',
          content: TextFormField(
            controller: _turbidityController,
            decoration: const InputDecoration(
              suffixText: 'NTU',
              hintText: '0.0',
            ),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            onChanged: (value) {
              final turbidity = double.tryParse(value) ?? 0.0;
              setState(() => _turbidityValue = turbidity);
              _updateParameters();
            },
          ),
        ),

        // Temperature
        _buildParameterCard(
          title: 'Temperature',
          subtitle:
              'Current: ${_temperatureValue.toStringAsFixed(1)}°${_isTemperatureCelsius ? 'C' : 'F'} (${_getTemperatureColor(_temperatureValue) == AppTheme.lightTheme.colorScheme.tertiary ? 'Optimal' : _getTemperatureColor(_temperatureValue) == AppTheme.warningLight ? 'Acceptable' : 'Concerning'})',
          indicatorColor: _getTemperatureColor(_temperatureValue),
          helpText:
              'Water temperature affects aquatic life and chemical processes. Optimal range: 15-25°C (59-77°F).',
          content: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Slider(
                      value: _temperatureValue,
                      min: _isTemperatureCelsius ? -5.0 : 23.0,
                      max: _isTemperatureCelsius ? 45.0 : 113.0,
                      divisions: _isTemperatureCelsius ? 50 : 90,
                      onChanged: (value) {
                        setState(() => _temperatureValue = value);
                        _updateParameters();
                      },
                    ),
                  ),
                  SizedBox(width: 4.w),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        if (_isTemperatureCelsius) {
                          _temperatureValue = (_temperatureValue * 9 / 5) + 32;
                        } else {
                          _temperatureValue = (_temperatureValue - 32) * 5 / 9;
                        }
                        _isTemperatureCelsius = !_isTemperatureCelsius;
                      });
                      _updateParameters();
                    },
                    child: Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
                      decoration: BoxDecoration(
                        color: AppTheme.lightTheme.colorScheme.primary,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '°${_isTemperatureCelsius ? 'C' : 'F'}',
                        style:
                            AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // Dissolved Oxygen
        _buildParameterCard(
          title: 'Dissolved Oxygen',
          subtitle:
              'Current: ${_dissolvedOxygenValue.toStringAsFixed(1)} mg/L (${_getDissolvedOxygenColor(_dissolvedOxygenValue) == AppTheme.lightTheme.colorScheme.tertiary ? 'Healthy' : _getDissolvedOxygenColor(_dissolvedOxygenValue) == AppTheme.warningLight ? 'Moderate' : 'Critical'})',
          indicatorColor: _getDissolvedOxygenColor(_dissolvedOxygenValue),
          helpText:
              'Dissolved oxygen is essential for aquatic life. Healthy: ≥6 mg/L, Moderate: 4-6 mg/L, Critical: <4 mg/L.',
          content: TextFormField(
            controller: _dissolvedOxygenController,
            decoration: const InputDecoration(
              suffixText: 'mg/L',
              hintText: '8.0',
            ),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            onChanged: (value) {
              final oxygen = double.tryParse(value) ?? 0.0;
              setState(() => _dissolvedOxygenValue = oxygen);
              _updateParameters();
            },
          ),
        ),

        // Water Level
        _buildParameterCard(
          title: 'Water Level',
          subtitle: 'Current: ${_waterLevelValue.toStringAsFixed(1)} cm',
          indicatorColor: AppTheme.lightTheme.colorScheme.primary,
          helpText:
              'Water level measurement from reference point. Record consistent measurement location.',
          content: TextFormField(
            controller: _waterLevelController,
            decoration: const InputDecoration(
              suffixText: 'cm',
              hintText: '50.0',
            ),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            onChanged: (value) {
              final level = double.tryParse(value) ?? 0.0;
              setState(() => _waterLevelValue = level);
              _updateParameters();
            },
          ),
        ),

        // Flow Rate
        _buildParameterCard(
          title: 'Flow Rate',
          subtitle: 'Current: ${_flowRateValue.toStringAsFixed(2)} m³/s',
          indicatorColor: AppTheme.lightTheme.colorScheme.secondary,
          helpText:
              'Water flow rate measurement. Use appropriate measurement method for water body type.',
          content: TextFormField(
            controller: _flowRateController,
            decoration: const InputDecoration(
              suffixText: 'm³/s',
              hintText: '0.00',
            ),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            onChanged: (value) {
              final flow = double.tryParse(value) ?? 0.0;
              setState(() => _flowRateValue = flow);
              _updateParameters();
            },
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _turbidityController.dispose();
    _dissolvedOxygenController.dispose();
    _waterLevelController.dispose();
    _flowRateController.dispose();
    super.dispose();
  }
}
