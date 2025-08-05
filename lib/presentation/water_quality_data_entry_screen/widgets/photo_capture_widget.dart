import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../../core/app_export.dart';

class PhotoCaptureWidget extends StatefulWidget {
  final Function(List<String> photos) onPhotosUpdate;
  final List<String> initialPhotos;
  final double? latitude;
  final double? longitude;

  const PhotoCaptureWidget({
    Key? key,
    required this.onPhotosUpdate,
    this.initialPhotos = const [],
    this.latitude,
    this.longitude,
  }) : super(key: key);

  @override
  State<PhotoCaptureWidget> createState() => _PhotoCaptureWidgetState();
}

class _PhotoCaptureWidgetState extends State<PhotoCaptureWidget> {
  List<String> _capturedPhotos = [];
  bool _isCapturing = false;

  @override
  void initState() {
    super.initState();
    _capturedPhotos = List.from(widget.initialPhotos);
  }

  Future<void> _capturePhoto() async {
    setState(() => _isCapturing = true);

    try {
      // Simulate photo capture - in real app would use camera package
      await Future.delayed(const Duration(seconds: 1));

      // Mock photo URL for demonstration
      final mockPhotoUrl =
          'https://images.unsplash.com/photo-1544551763-46a013bb70d5?w=400&h=300&fit=crop';

      setState(() {
        _capturedPhotos.add(mockPhotoUrl);
      });

      widget.onPhotosUpdate(_capturedPhotos);
    } catch (e) {
      // Handle camera error gracefully
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to capture photo')),
        );
      }
    } finally {
      setState(() => _isCapturing = false);
    }
  }

  Future<void> _selectFromGallery() async {
    setState(() => _isCapturing = true);

    try {
      // Simulate gallery selection - in real app would use image_picker
      await Future.delayed(const Duration(milliseconds: 500));

      // Mock selected photos for demonstration
      final mockPhotos = [
        'https://images.unsplash.com/photo-1559827260-dc66d52bef19?w=400&h=300&fit=crop',
        'https://images.unsplash.com/photo-1582408921715-18e7806365c1?w=400&h=300&fit=crop',
      ];

      setState(() {
        _capturedPhotos.addAll(mockPhotos);
      });

      widget.onPhotosUpdate(_capturedPhotos);
    } catch (e) {
      // Handle gallery error gracefully
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to select photos')),
        );
      }
    } finally {
      setState(() => _isCapturing = false);
    }
  }

  void _removePhoto(int index) {
    setState(() {
      _capturedPhotos.removeAt(index);
    });
    widget.onPhotosUpdate(_capturedPhotos);
  }

  Widget _buildPhotoThumbnail(String photoUrl, int index) {
    return Container(
      width: 20.w,
      height: 20.w,
      margin: EdgeInsets.only(right: 2.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.3),
        ),
      ),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(7),
            child: CustomImageWidget(
              imageUrl: photoUrl,
              width: 20.w,
              height: 20.w,
              fit: BoxFit.cover,
            ),
          ),
          Positioned(
            top: 1.w,
            right: 1.w,
            child: GestureDetector(
              onTap: () => _removePhoto(index),
              child: Container(
                width: 6.w,
                height: 6.w,
                decoration: BoxDecoration(
                  color: AppTheme.lightTheme.colorScheme.error,
                  shape: BoxShape.circle,
                ),
                child: CustomIconWidget(
                  iconName: 'close',
                  color: Colors.white,
                  size: 12,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCameraPreview() {
    return Container(
      width: double.infinity,
      height: 25.h,
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.3),
        ),
      ),
      child: Stack(
        children: [
          // Mock camera preview
          ClipRRect(
            borderRadius: BorderRadius.circular(11),
            child: CustomImageWidget(
              imageUrl:
                  'https://images.unsplash.com/photo-1441974231531-c6227db76b6e?w=800&h=600&fit=crop',
              width: double.infinity,
              height: 25.h,
              fit: BoxFit.cover,
            ),
          ),

          // GPS overlay
          if (widget.latitude != null && widget.longitude != null)
            Positioned(
              top: 2.h,
              left: 4.w,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.7),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'GPS: ${widget.latitude!.toStringAsFixed(4)}, ${widget.longitude!.toStringAsFixed(4)}',
                      style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                        color: Colors.white,
                        fontSize: 10.sp,
                      ),
                    ),
                    Text(
                      DateTime.now().toString().substring(0, 19),
                      style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                        color: Colors.white,
                        fontSize: 10.sp,
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // Capture button
          Positioned(
            bottom: 2.h,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: _selectFromGallery,
                  child: Container(
                    width: 12.w,
                    height: 12.w,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.9),
                      shape: BoxShape.circle,
                    ),
                    child: CustomIconWidget(
                      iconName: 'photo_library',
                      color: AppTheme.lightTheme.colorScheme.primary,
                      size: 24,
                    ),
                  ),
                ),
                SizedBox(width: 8.w),
                GestureDetector(
                  onTap: _isCapturing ? null : _capturePhoto,
                  child: Container(
                    width: 16.w,
                    height: 16.w,
                    decoration: BoxDecoration(
                      color: _isCapturing ? Colors.grey : Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppTheme.lightTheme.colorScheme.primary,
                        width: 3,
                      ),
                    ),
                    child: _isCapturing
                        ? Center(
                            child: SizedBox(
                              width: 6.w,
                              height: 6.w,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppTheme.lightTheme.colorScheme.primary,
                              ),
                            ),
                          )
                        : CustomIconWidget(
                            iconName: 'camera_alt',
                            color: AppTheme.lightTheme.colorScheme.primary,
                            size: 28,
                          ),
                  ),
                ),
                SizedBox(width: 8.w),
                Container(
                  width: 12.w,
                  height: 12.w,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.9),
                    shape: BoxShape.circle,
                  ),
                  child: CustomIconWidget(
                    iconName: 'flip_camera_ios',
                    color: AppTheme.lightTheme.colorScheme.primary,
                    size: 24,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
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
          Row(
            children: [
              CustomIconWidget(
                iconName: 'camera_alt',
                color: AppTheme.lightTheme.colorScheme.primary,
                size: 20,
              ),
              SizedBox(width: 2.w),
              Text(
                'Photo Documentation',
                style: AppTheme.lightTheme.textTheme.titleMedium,
              ),
              const Spacer(),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
                decoration: BoxDecoration(
                  color: AppTheme.lightTheme.colorScheme.primary
                      .withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${_capturedPhotos.length}/5',
                  style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                    color: AppTheme.lightTheme.colorScheme.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 3.h),

          // Camera preview
          _buildCameraPreview(),

          if (_capturedPhotos.isNotEmpty) ...[
            SizedBox(height: 3.h),
            Text(
              'Captured Photos',
              style: AppTheme.lightTheme.textTheme.titleSmall,
            ),
            SizedBox(height: 1.h),
            SizedBox(
              height: 20.w,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _capturedPhotos.length,
                itemBuilder: (context, index) {
                  return _buildPhotoThumbnail(_capturedPhotos[index], index);
                },
              ),
            ),
          ],

          SizedBox(height: 2.h),
          Text(
            'Tip: Photos will include GPS coordinates and timestamp automatically',
            style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
              color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }
}
