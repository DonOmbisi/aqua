import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../theme/app_theme.dart';

class TermsPrivacyWidget extends StatelessWidget {
  final bool termsAccepted;
  final bool privacyAccepted;
  final Function(bool) onTermsChanged;
  final Function(bool) onPrivacyChanged;

  const TermsPrivacyWidget({
    super.key,
    required this.termsAccepted,
    required this.privacyAccepted,
    required this.onTermsChanged,
    required this.onPrivacyChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildCheckboxRow(
          value: termsAccepted,
          onChanged: onTermsChanged,
          text: 'I agree to the ',
          linkText: 'Terms of Service',
          onLinkTap: () => _showTermsDialog(context),
        ),
        SizedBox(height: 1.h),
        _buildCheckboxRow(
          value: privacyAccepted,
          onChanged: onPrivacyChanged,
          text: 'I agree to the ',
          linkText: 'Privacy Policy',
          onLinkTap: () => _showPrivacyDialog(context),
        ),
      ],
    );
  }

  Widget _buildCheckboxRow({
    required bool value,
    required Function(bool) onChanged,
    required String text,
    required String linkText,
    required VoidCallback onLinkTap,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Checkbox(
          value: value,
          onChanged: (bool? newValue) => onChanged(newValue ?? false),
          activeColor: AppTheme.lightTheme.primaryColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        Expanded(
          child: GestureDetector(
            onTap: () => onChanged(!value),
            child: Padding(
              padding: EdgeInsets.only(top: 3.w),
              child: RichText(
                text: TextSpan(
                  style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                    color: AppTheme.lightTheme.colorScheme.onSurface,
                  ),
                  children: [
                    TextSpan(text: text),
                    WidgetSpan(
                      child: GestureDetector(
                        onTap: onLinkTap,
                        child: Text(
                          linkText,
                          style:
                              AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                            color: AppTheme.lightTheme.primaryColor,
                            fontWeight: FontWeight.w500,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _showTermsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Terms of Service',
            style: AppTheme.lightTheme.textTheme.titleLarge,
          ),
          content: SizedBox(
            width: 80.w,
            height: 60.h,
            child: SingleChildScrollView(
              child: Text(
                '''Welcome to Aqua Horizon Water Monitoring Community.

By creating an account, you agree to:

1. DATA COLLECTION & REPORTING
• Provide accurate water quality data and reports
• Use GPS location services for data verification
• Submit photos and measurements responsibly

2. COMMUNITY GUIDELINES
• Respect other community members
• Share information for environmental benefit
• Report genuine water quality concerns only

3. PROFESSIONAL RESPONSIBILITIES
Water Professionals and Environmental Experts must:
• Verify data accuracy before publication
• Maintain professional standards in assessments
• Provide expert guidance to community members

4. DATA USAGE
• Your data helps improve water quality monitoring
• Anonymous data may be shared with environmental agencies
• Personal information remains protected

5. ACCOUNT SECURITY
• Keep login credentials secure
• Report suspicious activity immediately
• Update contact information for emergency alerts

6. LIMITATION OF LIABILITY
Aqua Horizon provides monitoring tools but is not responsible for water safety decisions based on app data.

Last updated: July 28, 2025''',
                style: AppTheme.lightTheme.textTheme.bodySmall,
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Close',
                style: TextStyle(color: AppTheme.lightTheme.primaryColor),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showPrivacyDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Privacy Policy',
            style: AppTheme.lightTheme.textTheme.titleLarge,
          ),
          content: SizedBox(
            width: 80.w,
            height: 60.h,
            child: SingleChildScrollView(
              child: Text(
                '''Aqua Horizon Privacy Policy

INFORMATION WE COLLECT:
• Account Information: Name, email, phone number, role selection
• Location Data: GPS coordinates for water source tagging
• Water Quality Data: pH, turbidity, temperature, dissolved oxygen measurements
• Photos: Images attached to water quality reports
• Device Information: For app functionality and security

HOW WE USE YOUR INFORMATION:
• Monitor and improve water quality in your community
• Send emergency alerts about water safety issues
• Enable collaboration between community members and experts
• Generate analytics and trends for environmental research
• Verify data accuracy through professional review

DATA SHARING:
• Anonymous water quality data with environmental agencies
• Community reports visible to other verified users
• Expert analysis shared with relevant authorities
• No personal information sold to third parties

DATA SECURITY:
• End-to-end encryption for sensitive data
• Secure servers with regular security audits
• Role-based access controls
• Regular data backups and recovery procedures

YOUR RIGHTS:
• Access your personal data anytime
• Request data correction or deletion
• Opt-out of non-essential communications
• Export your data in standard formats

LOCATION PRIVACY:
• GPS data used only for water source verification
• Precise coordinates visible only to verified professionals
• Community members see general area information only

CONTACT US:
For privacy concerns: privacy@aquahorizon.org

Last updated: July 28, 2025''',
                style: AppTheme.lightTheme.textTheme.bodySmall,
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Close',
                style: TextStyle(color: AppTheme.lightTheme.primaryColor),
              ),
            ),
          ],
        );
      },
    );
  }
}
