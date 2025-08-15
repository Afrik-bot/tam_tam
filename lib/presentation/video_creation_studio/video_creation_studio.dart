import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../services/auth_service.dart';
import '../../services/video_upload_service.dart';
import './widgets/audio_library_widget.dart';
import './widgets/camera_controls_widget.dart';
import './widgets/effects_grid_widget.dart';
import './widgets/stickers_widget.dart';
import './widgets/text_editor_widget.dart';
import './widgets/video_timeline_widget.dart';

class VideoCreationStudio extends StatefulWidget {
  const VideoCreationStudio({Key? key}) : super(key: key);

  @override
  State<VideoCreationStudio> createState() => _VideoCreationStudioState();
}

class _VideoCreationStudioState extends State<VideoCreationStudio>
    with TickerProviderStateMixin {
  // Camera related
  List<CameraDescription> _cameras = [];
  CameraController? _cameraController;
  bool _isCameraInitialized = false;
  bool _isFlashOn = false;
  int _timerSeconds = 0;
  bool _isCollaborationMode = false;

  // Video upload related
  XFile? _selectedVideo;
  bool _isUploading = false;
  double _uploadProgress = 0.0;

  // Video editing state
  double _videoDuration = 60.0; // Default 60 seconds
  double _currentPosition = 0.0;
  String? _selectedEffect;
  String? _selectedSound;
  List<Map<String, dynamic>> _textElements = [];
  List<Map<String, dynamic>> _selectedStickers = [];

  // UI state
  TabController? _tabController;
  int _selectedTabIndex = 0;
  bool _isRecording = false;
  bool _canUndo = false;
  bool _canRedo = false;

  final List<String> _tabLabels = [
    "Record",
    "Effects",
    "Audio",
    "Text",
    "Stickers"
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabLabels.length, vsync: this);
    _tabController!.addListener(() {
      if (_tabController!.indexIsChanging) {
        setState(() {
          _selectedTabIndex = _tabController!.index;
        });
      }
    });
    _initializeCamera();
  }

  @override
  void dispose() {
    _tabController?.dispose();
    _cameraController?.dispose();
    super.dispose();
  }

  Future<void> _initializeCamera() async {
    try {
      // Request camera permission
      if (!kIsWeb) {
        final cameraPermission = await Permission.camera.request();
        final microphonePermission = await Permission.microphone.request();

        if (!cameraPermission.isGranted || !microphonePermission.isGranted) {
          return;
        }
      }

      // Get available cameras
      _cameras = await availableCameras();
      if (_cameras.isEmpty) return;

      // Initialize camera controller
      final camera = kIsWeb
          ? _cameras.firstWhere(
              (c) => c.lensDirection == CameraLensDirection.front,
              orElse: () => _cameras.first)
          : _cameras.firstWhere(
              (c) => c.lensDirection == CameraLensDirection.back,
              orElse: () => _cameras.first);

      _cameraController = CameraController(
        camera,
        kIsWeb ? ResolutionPreset.medium : ResolutionPreset.high,
        enableAudio: true,
      );

      await _cameraController!.initialize();

      // Apply camera settings (skip unsupported features on web)
      try {
        await _cameraController!.setFocusMode(FocusMode.auto);
        if (!kIsWeb) {
          await _cameraController!.setFlashMode(FlashMode.auto);
        }
      } catch (e) {
        // Silently handle unsupported features
      }

      if (mounted) {
        setState(() {
          _isCameraInitialized = true;
        });
      }
    } catch (e) {
      // Handle camera initialization errors gracefully
      if (mounted) {
        setState(() {
          _isCameraInitialized = false;
        });
      }
    }
  }

  // Pick video from gallery
  Future<void> _pickVideoFromGallery() async {
    try {
      final video =
          await VideoUploadService.instance.pickVideo(fromCamera: false);
      if (video != null) {
        setState(() {
          _selectedVideo = video;
        });

        // Validate video file
        if (!VideoUploadService.instance.validateVideoFile(video)) {
          Fluttertoast.showToast(
            msg: "Invalid video file. Please select a valid video.",
            backgroundColor: Colors.red,
          );
          setState(() {
            _selectedVideo = null;
          });
          return;
        }

        Fluttertoast.showToast(
          msg: "Video selected successfully!",
          backgroundColor: Colors.green,
        );
      }
    } catch (e) {
      Fluttertoast.showToast(
        msg: "Failed to select video: ${e.toString()}",
        backgroundColor: Colors.red,
      );
    }
  }

  // Record video with camera
  Future<void> _recordVideo() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      Fluttertoast.showToast(
        msg: "Camera not ready",
        backgroundColor: Colors.red,
      );
      return;
    }

    try {
      if (_isRecording) {
        // Stop recording
        final video = await _cameraController!.stopVideoRecording();
        setState(() {
          _isRecording = false;
          _selectedVideo = video;
        });

        Fluttertoast.showToast(
          msg: "Video recorded successfully!",
          backgroundColor: Colors.green,
        );
      } else {
        // Start recording
        await _cameraController!.startVideoRecording();
        setState(() {
          _isRecording = true;
        });

        Fluttertoast.showToast(
          msg: "Recording started...",
          backgroundColor: Colors.blue,
        );
      }
    } catch (e) {
      setState(() {
        _isRecording = false;
      });

      Fluttertoast.showToast(
        msg: "Recording failed: ${e.toString()}",
        backgroundColor: Colors.red,
      );
    }
  }

  void _publishVideo() async {
    if (!AuthService.instance.isAuthenticated) {
      Fluttertoast.showToast(
        msg: "Please sign in to upload videos",
        backgroundColor: Colors.red,
      );
      return;
    }

    if (_selectedVideo == null) {
      Fluttertoast.showToast(
        msg: "Please record or select a video first",
        backgroundColor: Colors.red,
      );
      return;
    }

    // Show upload dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text('Upload Video'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: InputDecoration(
                labelText: 'Title',
                hintText: 'Enter video title...',
              ),
              onChanged: (value) => _videoTitle = value,
            ),
            SizedBox(height: 2.h),
            TextField(
              decoration: InputDecoration(
                labelText: 'Description',
                hintText: 'Enter video description...',
              ),
              maxLines: 3,
              onChanged: (value) => _videoDescription = value,
            ),
            SizedBox(height: 2.h),
            TextField(
              decoration: InputDecoration(
                labelText: 'Tags (comma separated)',
                hintText: 'fun, dance, trending...',
              ),
              onChanged: (value) => _videoTags = value,
            ),
            if (_isUploading) ...[
              SizedBox(height: 2.h),
              LinearProgressIndicator(value: _uploadProgress),
              Text('Uploading... ${(_uploadProgress * 100).toInt()}%'),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: _isUploading ? null : () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: _isUploading ? null : _handleVideoUpload,
            child: Text(_isUploading ? 'Uploading...' : 'Upload'),
          ),
        ],
      ),
    );
  }

  String _videoTitle = '';
  String _videoDescription = '';
  String _videoTags = '';

  Future<void> _handleVideoUpload() async {
    if (_selectedVideo == null) return;

    setState(() {
      _isUploading = true;
      _uploadProgress = 0.0;
    });

    try {
      final user = AuthService.instance.user;
      if (user == null) throw Exception('User not authenticated');

      // Parse tags
      List<String> tags = _videoTags
          .split(',')
          .map((tag) => tag.trim())
          .where((tag) => tag.isNotEmpty)
          .toList();

      // Upload video
      final contentId = await VideoUploadService.instance.uploadVideo(
        videoFile: _selectedVideo!,
        userId: user.id,
        title: _videoTitle.isEmpty ? 'My Video' : _videoTitle,
        description: _videoDescription,
        tags: tags,
      );

      setState(() {
        _isUploading = false;
        _uploadProgress = 1.0;
      });

      Navigator.pop(context); // Close upload dialog

      Fluttertoast.showToast(
        msg: "Video uploaded successfully! It will appear in the main feed.",
        backgroundColor: Colors.green,
        toastLength: Toast.LENGTH_LONG,
      );

      // Navigate back to main feed
      Navigator.pushReplacementNamed(context, '/main-video-feed');
    } catch (e) {
      setState(() {
        _isUploading = false;
        _uploadProgress = 0.0;
      });

      Fluttertoast.showToast(
        msg: "Upload failed: ${e.toString()}",
        backgroundColor: Colors.red,
        toastLength: Toast.LENGTH_LONG,
      );
    }
  }

  Future<void> _flipCamera() async {
    if (_cameras.length < 2 || _cameraController == null) return;

    try {
      final currentLensDirection = _cameraController!.description.lensDirection;
      final newCamera = _cameras.firstWhere(
        (camera) => camera.lensDirection != currentLensDirection,
        orElse: () => _cameras.first,
      );

      await _cameraController!.dispose();
      _cameraController = CameraController(
        newCamera,
        kIsWeb ? ResolutionPreset.medium : ResolutionPreset.high,
        enableAudio: true,
      );

      await _cameraController!.initialize();

      try {
        await _cameraController!.setFocusMode(FocusMode.auto);
        if (!kIsWeb) {
          await _cameraController!
              .setFlashMode(_isFlashOn ? FlashMode.torch : FlashMode.off);
        }
      } catch (e) {
        // Handle unsupported features
      }

      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      // Handle camera flip errors
    }
  }

  Future<void> _toggleFlash() async {
    if (kIsWeb || _cameraController == null) return;

    try {
      setState(() {
        _isFlashOn = !_isFlashOn;
      });

      await _cameraController!
          .setFlashMode(_isFlashOn ? FlashMode.torch : FlashMode.off);
    } catch (e) {
      // Handle flash toggle errors
      setState(() {
        _isFlashOn = false;
      });
    }
  }

  void _setTimer() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        height: 30.h,
        padding: EdgeInsets.all(4.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Set Timer',
              style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 3.h),
            Wrap(
              spacing: 3.w,
              runSpacing: 2.h,
              children: [0, 3, 5, 10, 15].map((seconds) {
                final isSelected = _timerSeconds == seconds;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _timerSeconds = seconds;
                    });
                    Navigator.pop(context);
                  },
                  child: Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppTheme.lightTheme.colorScheme.primary
                          : AppTheme.lightTheme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected
                            ? AppTheme.lightTheme.colorScheme.primary
                            : AppTheme.lightTheme.colorScheme.outline
                                .withValues(alpha: 0.3),
                      ),
                    ),
                    child: Text(
                      seconds == 0 ? 'Off' : '${seconds}s',
                      style: AppTheme.lightTheme.textTheme.labelLarge?.copyWith(
                        color: isSelected
                            ? AppTheme.lightTheme.colorScheme.onPrimary
                            : AppTheme.lightTheme.colorScheme.onSurface,
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.w400,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  void _startCollaboration() {
    setState(() {
      _isCollaborationMode = !_isCollaborationMode;
    });

    if (_isCollaborationMode) {
      // Show collaboration setup dialog
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Multi-Creator Mode'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Enable split-screen collaboration with other creators.'),
              SizedBox(height: 2.h),
              Text(
                'Features:',
                style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 1.h),
              Text('• Split-screen video recording'),
              Text('• Revenue sharing setup'),
              Text('• Real-time collaboration'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  _isCollaborationMode = false;
                });
                Navigator.pop(context);
              },
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                // Handle collaboration setup
              },
              child: Text('Start Collaboration'),
            ),
          ],
        ),
      );
    }
  }

  void _onEffectSelected(String effectId) {
    setState(() {
      _selectedEffect = _selectedEffect == effectId ? null : effectId;
    });
  }

  void _onSoundSelected(String soundId) {
    setState(() {
      _selectedSound = _selectedSound == soundId ? null : soundId;
    });
  }

  void _onVoiceoverRecorded(String path) {
    // Handle voiceover recording
    setState(() {
      _selectedSound = 'voiceover_$path';
    });
  }

  void _onTextAdded(Map<String, dynamic> textElement) {
    setState(() {
      _textElements.add(textElement);
      _canUndo = true;
    });
  }

  void _onTextUpdated(int index, Map<String, dynamic> updatedElement) {
    if (index >= 0 && index < _textElements.length) {
      setState(() {
        _textElements[index] = updatedElement;
        _canUndo = true;
      });
    }
  }

  void _onTextRemoved(int index) {
    if (index >= 0 && index < _textElements.length) {
      setState(() {
        _textElements.removeAt(index);
        _canUndo = true;
      });
    }
  }

  void _onStickerSelected(Map<String, dynamic> sticker) {
    final existingIndex =
        _selectedStickers.indexWhere((s) => s["id"] == sticker["id"]);

    setState(() {
      if (existingIndex >= 0) {
        _selectedStickers.removeAt(existingIndex);
      } else {
        _selectedStickers.add(sticker);
      }
      _canUndo = true;
    });
  }

  void _onPositionChanged(double position) {
    setState(() {
      _currentPosition = position.clamp(0.0, _videoDuration);
    });
  }

  void _undo() {
    // Implement undo functionality
    setState(() {
      _canUndo = false;
      _canRedo = true;
    });
  }

  void _redo() {
    // Implement redo functionality
    setState(() {
      _canRedo = false;
      _canUndo = true;
    });
  }

  void _viralize() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            CustomIconWidget(
              iconName: 'auto_awesome',
              size: 6.w,
              color: AppTheme.lightTheme.colorScheme.primary,
            ),
            SizedBox(width: 2.w),
            Text('AI Viralize'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
                'AI will analyze your video and suggest trending edits to maximize viral potential.'),
            SizedBox(height: 2.h),
            Text(
              'Suggestions include:',
              style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 1.h),
            Text('• Trending effects and filters'),
            Text('• Popular music matches'),
            Text('• Optimal cut timing'),
            Text('• Viral text overlays'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Apply AI suggestions
            },
            child: Text('Apply Suggestions'),
          ),
        ],
      ),
    );
  }

  void _openSettings() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        height: 40.h,
        padding: EdgeInsets.all(4.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Video Settings',
              style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 3.h),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'high_quality',
                size: 6.w,
                color: AppTheme.lightTheme.colorScheme.primary,
              ),
              title: Text('Video Quality'),
              subtitle: Text('High (1080p)'),
              trailing: CustomIconWidget(
                iconName: 'chevron_right',
                size: 5.w,
                color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              ),
              onTap: () {
                // Handle quality settings
              },
            ),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'aspect_ratio',
                size: 6.w,
                color: AppTheme.lightTheme.colorScheme.primary,
              ),
              title: Text('Aspect Ratio'),
              subtitle: Text('9:16 (Vertical)'),
              trailing: CustomIconWidget(
                iconName: 'chevron_right',
                size: 5.w,
                color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              ),
              onTap: () {
                // Handle aspect ratio settings
              },
            ),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'save',
                size: 6.w,
                color: AppTheme.lightTheme.colorScheme.primary,
              ),
              title: Text('Auto-Save'),
              subtitle: Text('Save progress automatically'),
              trailing: Switch(
                value: true,
                onChanged: (value) {
                  // Handle auto-save toggle
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Top toolbar
            Container(
              height: 8.h,
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.surface,
                border: Border(
                  bottom: BorderSide(
                    color: AppTheme.lightTheme.colorScheme.outline
                        .withValues(alpha: 0.2),
                  ),
                ),
              ),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 10.w,
                      height: 5.h,
                      decoration: BoxDecoration(
                        color: AppTheme.lightTheme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppTheme.lightTheme.colorScheme.outline
                              .withValues(alpha: 0.3),
                        ),
                      ),
                      child: Center(
                        child: CustomIconWidget(
                          iconName: 'close',
                          size: 5.w,
                          color: AppTheme.lightTheme.colorScheme.onSurface,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 4.w),
                  GestureDetector(
                    onTap: _canUndo ? _undo : null,
                    child: Container(
                      width: 10.w,
                      height: 5.h,
                      decoration: BoxDecoration(
                        color: _canUndo
                            ? AppTheme.lightTheme.colorScheme.surface
                            : AppTheme.lightTheme.colorScheme.surface
                                .withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppTheme.lightTheme.colorScheme.outline
                              .withValues(alpha: 0.3),
                        ),
                      ),
                      child: Center(
                        child: CustomIconWidget(
                          iconName: 'undo',
                          size: 5.w,
                          color: _canUndo
                              ? AppTheme.lightTheme.colorScheme.onSurface
                              : AppTheme.lightTheme.colorScheme.onSurface
                                  .withValues(alpha: 0.5),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 2.w),
                  GestureDetector(
                    onTap: _canRedo ? _redo : null,
                    child: Container(
                      width: 10.w,
                      height: 5.h,
                      decoration: BoxDecoration(
                        color: _canRedo
                            ? AppTheme.lightTheme.colorScheme.surface
                            : AppTheme.lightTheme.colorScheme.surface
                                .withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppTheme.lightTheme.colorScheme.outline
                              .withValues(alpha: 0.3),
                        ),
                      ),
                      child: Center(
                        child: CustomIconWidget(
                          iconName: 'redo',
                          size: 5.w,
                          color: _canRedo
                              ? AppTheme.lightTheme.colorScheme.onSurface
                              : AppTheme.lightTheme.colorScheme.onSurface
                                  .withValues(alpha: 0.5),
                        ),
                      ),
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: _viralize,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 4.w, vertical: 1.5.h),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppTheme.lightTheme.colorScheme.primary,
                            AppTheme.lightTheme.colorScheme.secondary,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          CustomIconWidget(
                            iconName: 'auto_awesome',
                            size: 4.w,
                            color: AppTheme.lightTheme.colorScheme.onPrimary,
                          ),
                          SizedBox(width: 2.w),
                          Text(
                            'Viralize',
                            style: AppTheme.lightTheme.textTheme.labelMedium
                                ?.copyWith(
                              color: AppTheme.lightTheme.colorScheme.onPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(width: 3.w),
                  GestureDetector(
                    onTap: _openSettings,
                    child: Container(
                      width: 10.w,
                      height: 5.h,
                      decoration: BoxDecoration(
                        color: AppTheme.lightTheme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppTheme.lightTheme.colorScheme.outline
                              .withValues(alpha: 0.3),
                        ),
                      ),
                      child: Center(
                        child: CustomIconWidget(
                          iconName: 'settings',
                          size: 5.w,
                          color: AppTheme.lightTheme.colorScheme.onSurface,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Main content area
            Expanded(
              child: Column(
                children: [
                  // Video preview and timeline
                  Expanded(
                    flex: 3,
                    child: Container(
                      margin: EdgeInsets.all(4.w),
                      child: Column(
                        children: [
                          // Video preview
                          Expanded(
                            child: Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: Colors.black,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: _selectedVideo != null
                                    ? Stack(
                                        children: [
                                          Container(
                                            color: Colors.black,
                                            child: Center(
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  CustomIconWidget(
                                                    iconName: 'video_file',
                                                    size: 15.w,
                                                    color: Colors.white
                                                        .withValues(alpha: 0.7),
                                                  ),
                                                  SizedBox(height: 2.h),
                                                  Text(
                                                    'Video Selected',
                                                    style: AppTheme.lightTheme
                                                        .textTheme.titleMedium
                                                        ?.copyWith(
                                                      color: Colors.white
                                                          .withValues(
                                                              alpha: 0.7),
                                                    ),
                                                  ),
                                                  SizedBox(height: 1.h),
                                                  Text(
                                                    'Ready to upload!',
                                                    style: AppTheme.lightTheme
                                                        .textTheme.bodyMedium
                                                        ?.copyWith(
                                                      color: Colors.white
                                                          .withValues(
                                                              alpha: 0.5),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      )
                                    : _selectedTabIndex == 0 &&
                                            _isCameraInitialized &&
                                            _cameraController != null
                                        ? Stack(
                                            children: [
                                              AspectRatio(
                                                aspectRatio: 9 /
                                                    16, // Vertical video aspect ratio
                                                child: CameraPreview(
                                                    _cameraController!),
                                              ),
                                              if (_isRecording)
                                                Positioned(
                                                  top: 2.h,
                                                  left: 4.w,
                                                  child: Container(
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                      horizontal: 3.w,
                                                      vertical: 1.h,
                                                    ),
                                                    decoration: BoxDecoration(
                                                      color: Colors.red,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              20),
                                                    ),
                                                    child: Row(
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      children: [
                                                        Container(
                                                          width: 2.w,
                                                          height: 2.w,
                                                          decoration:
                                                              BoxDecoration(
                                                            color: Colors.white,
                                                            shape:
                                                                BoxShape.circle,
                                                          ),
                                                        ),
                                                        SizedBox(width: 2.w),
                                                        Text(
                                                          'REC',
                                                          style: TextStyle(
                                                            color: Colors.white,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontSize: 12.sp,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                            ],
                                          )
                                        : Container(
                                            color: Colors.black,
                                            child: Center(
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  CustomIconWidget(
                                                    iconName: 'videocam',
                                                    size: 15.w,
                                                    color: Colors.white
                                                        .withValues(alpha: 0.7),
                                                  ),
                                                  SizedBox(height: 2.h),
                                                  Text(
                                                    'Video Preview',
                                                    style: AppTheme.lightTheme
                                                        .textTheme.titleMedium
                                                        ?.copyWith(
                                                      color: Colors.white
                                                          .withValues(
                                                              alpha: 0.7),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                              ),
                            ),
                          ),

                          SizedBox(height: 2.h),

                          // Timeline scrubber
                          VideoTimelineWidget(
                            videoDuration: _videoDuration,
                            currentPosition: _currentPosition,
                            onPositionChanged: _onPositionChanged,
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Bottom editing interface
                  Expanded(
                    flex: 2,
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppTheme.lightTheme.colorScheme.surface,
                        borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(20)),
                        border: Border(
                          top: BorderSide(
                            color: AppTheme.lightTheme.colorScheme.outline
                                .withValues(alpha: 0.2),
                          ),
                        ),
                      ),
                      child: Column(
                        children: [
                          // Tab bar
                          Container(
                            height: 8.h,
                            child: TabBar(
                              controller: _tabController,
                              tabs: _tabLabels
                                  .map((label) => Tab(text: label))
                                  .toList(),
                            ),
                          ),

                          // Tab content
                          Expanded(
                            child: TabBarView(
                              controller: _tabController,
                              children: [
                                // Record tab
                                CameraControlsWidget(
                                  cameraController: _cameraController,
                                  onFlipCamera: _flipCamera,
                                  onToggleFlash: _toggleFlash,
                                  onSetTimer: _setTimer,
                                  onStartCollaboration: _startCollaboration,
                                  isFlashOn: _isFlashOn,
                                  timerSeconds: _timerSeconds,
                                  isCollaborationMode: _isCollaborationMode,
                                ),

                                // Effects tab
                                EffectsGridWidget(
                                  onEffectSelected: _onEffectSelected,
                                  selectedEffect: _selectedEffect,
                                ),

                                // Audio tab
                                AudioLibraryWidget(
                                  onSoundSelected: _onSoundSelected,
                                  onVoiceoverRecorded: _onVoiceoverRecorded,
                                  selectedSound: _selectedSound,
                                ),

                                // Text tab
                                TextEditorWidget(
                                  onTextAdded: _onTextAdded,
                                  textElements: _textElements,
                                  onTextUpdated: _onTextUpdated,
                                  onTextRemoved: _onTextRemoved,
                                ),

                                // Stickers tab
                                StickersWidget(
                                  onStickerSelected: _onStickerSelected,
                                  selectedStickers: _selectedStickers,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Bottom action bar with enhanced options
            Container(
              height: 12.h,
              padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.surface,
                border: Border(
                  top: BorderSide(
                    color: AppTheme.lightTheme.colorScheme.outline
                        .withValues(alpha: 0.2),
                  ),
                ),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      // Gallery button
                      Expanded(
                        child: GestureDetector(
                          onTap: _pickVideoFromGallery,
                          child: Container(
                            height: 5.h,
                            decoration: BoxDecoration(
                              color: AppTheme.lightTheme.colorScheme.outline
                                  .withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CustomIconWidget(
                                  iconName: 'photo_library',
                                  size: 4.w,
                                  color:
                                      AppTheme.lightTheme.colorScheme.primary,
                                ),
                                SizedBox(width: 2.w),
                                Text(
                                  'Gallery',
                                  style: AppTheme
                                      .lightTheme.textTheme.labelMedium
                                      ?.copyWith(
                                    color:
                                        AppTheme.lightTheme.colorScheme.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 2.w),
                      // Record button
                      Expanded(
                        child: GestureDetector(
                          onTap: _recordVideo,
                          child: Container(
                            height: 5.h,
                            decoration: BoxDecoration(
                              color: _isRecording
                                  ? Colors.red
                                  : AppTheme.lightTheme.colorScheme.secondary,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CustomIconWidget(
                                  iconName: _isRecording ? 'stop' : 'videocam',
                                  size: 4.w,
                                  color: Colors.white,
                                ),
                                SizedBox(width: 2.w),
                                Text(
                                  _isRecording ? 'Stop' : 'Record',
                                  style: AppTheme
                                      .lightTheme.textTheme.labelMedium
                                      ?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 4.w),
                      // Upload button
                      GestureDetector(
                        onTap: _publishVideo,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 8.w, vertical: 2.h),
                          decoration: BoxDecoration(
                            color: AppTheme.lightTheme.colorScheme.primary,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Text(
                                'Upload',
                                style: AppTheme.lightTheme.textTheme.labelLarge
                                    ?.copyWith(
                                  color:
                                      AppTheme.lightTheme.colorScheme.onPrimary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              SizedBox(width: 2.w),
                              CustomIconWidget(
                                iconName: 'cloud_upload',
                                size: 4.w,
                                color:
                                    AppTheme.lightTheme.colorScheme.onPrimary,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDuration(double seconds) {
    final int minutes = (seconds / 60).floor();
    final int remainingSeconds = (seconds % 60).floor();
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }
}
