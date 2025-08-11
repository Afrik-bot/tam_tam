import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class QRScannerWidget extends StatefulWidget {
  final Function(String) onQRScanned;
  final VoidCallback onClose;

  const QRScannerWidget({
    super.key,
    required this.onQRScanned,
    required this.onClose,
  });

  @override
  State<QRScannerWidget> createState() => _QRScannerWidgetState();
}

class _QRScannerWidgetState extends State<QRScannerWidget> {
  CameraController? _cameraController;
  List<CameraDescription> _cameras = [];
  bool _isInitialized = false;
  bool _isScanning = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  Future<bool> _requestCameraPermission() async {
    if (kIsWeb) return true;
    final status = await Permission.camera.request();
    return status.isGranted;
  }

  Future<void> _initializeCamera() async {
    try {
      final hasPermission = await _requestCameraPermission();
      if (!hasPermission) {
        setState(() {
          _errorMessage = 'Camera permission is required to scan QR codes';
        });
        return;
      }

      _cameras = await availableCameras();
      if (_cameras.isEmpty) {
        setState(() {
          _errorMessage = 'No cameras available on this device';
        });
        return;
      }

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
      );

      await _cameraController!.initialize();

      if (!kIsWeb) {
        try {
          await _cameraController!.setFocusMode(FocusMode.auto);
          await _cameraController!.setFlashMode(FlashMode.auto);
        } catch (e) {
          // Ignore focus/flash errors on unsupported devices
        }
      }

      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to initialize camera: ${e.toString()}';
        });
      }
    }
  }

  void _simulateQRScan() {
    if (_isScanning) return;

    setState(() {
      _isScanning = true;
    });

    // Simulate QR code detection after 2 seconds
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        // Mock wallet addresses for different currencies
        final mockAddresses = [
          '1A1zP1eP5QGefi2DMPTfTL5SLmv7DivfNa', // Bitcoin
          '0x742d35Cc6634C0532925a3b8D8C0532925a3b8D8', // Ethereum
          '@johndoe', // Username
          'john.doe@email.com', // Email
        ];

        final randomAddress =
            mockAddresses[DateTime.now().millisecond % mockAddresses.length];
        widget.onQRScanned(randomAddress);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      child: SafeArea(
        child: Stack(
          children: [
            // Camera preview or error message
            if (_errorMessage != null)
              _buildErrorView()
            else if (_isInitialized && _cameraController != null)
              _buildCameraView()
            else
              _buildLoadingView(),

            // Overlay UI
            _buildOverlay(),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorView() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Colors.black,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomIconWidget(
              iconName: 'error_outline',
              color: Colors.white,
              size: 48,
            ),
            SizedBox(height: 4.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.w),
              child: Text(
                _errorMessage!,
                style: AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(height: 4.h),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _errorMessage = null;
                });
                _initializeCamera();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.lightTheme.colorScheme.primary,
                foregroundColor: Colors.white,
              ),
              child: Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingView() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Colors.black,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              color: AppTheme.lightTheme.colorScheme.primary,
            ),
            SizedBox(height: 4.h),
            Text(
              'Initializing camera...',
              style: AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCameraView() {
    return SizedBox(
      width: double.infinity,
      height: double.infinity,
      child: CameraPreview(_cameraController!),
    );
  }

  Widget _buildOverlay() {
    return Column(
      children: [
        // Top bar
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
          child: Row(
            children: [
              GestureDetector(
                onTap: widget.onClose,
                child: Container(
                  padding: EdgeInsets.all(2.w),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.5),
                    shape: BoxShape.circle,
                  ),
                  child: CustomIconWidget(
                    iconName: 'close',
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ),
              const Spacer(),
              if (!kIsWeb && _cameraController != null) ...[
                GestureDetector(
                  onTap: () async {
                    try {
                      final currentFlashMode =
                          _cameraController!.value.flashMode;
                      final newFlashMode = currentFlashMode == FlashMode.off
                          ? FlashMode.torch
                          : FlashMode.off;
                      await _cameraController!.setFlashMode(newFlashMode);
                      setState(() {});
                    } catch (e) {
                      // Ignore flash errors
                    }
                  },
                  child: Container(
                    padding: EdgeInsets.all(2.w),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.5),
                      shape: BoxShape.circle,
                    ),
                    child: CustomIconWidget(
                      iconName:
                          _cameraController?.value.flashMode == FlashMode.torch
                              ? 'flash_on'
                              : 'flash_off',
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),

        const Spacer(),

        // Scanning area
        Container(
          width: 60.w,
          height: 60.w,
          decoration: BoxDecoration(
            border: Border.all(
              color: AppTheme.lightTheme.colorScheme.primary,
              width: 2,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Stack(
            children: [
              // Corner indicators
              Positioned(
                top: -2,
                left: -2,
                child: Container(
                  width: 6.w,
                  height: 6.w,
                  decoration: BoxDecoration(
                    color: AppTheme.lightTheme.colorScheme.primary,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                    ),
                  ),
                ),
              ),
              Positioned(
                top: -2,
                right: -2,
                child: Container(
                  width: 6.w,
                  height: 6.w,
                  decoration: BoxDecoration(
                    color: AppTheme.lightTheme.colorScheme.primary,
                    borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(16),
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: -2,
                left: -2,
                child: Container(
                  width: 6.w,
                  height: 6.w,
                  decoration: BoxDecoration(
                    color: AppTheme.lightTheme.colorScheme.primary,
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(16),
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: -2,
                right: -2,
                child: Container(
                  width: 6.w,
                  height: 6.w,
                  decoration: BoxDecoration(
                    color: AppTheme.lightTheme.colorScheme.primary,
                    borderRadius: const BorderRadius.only(
                      bottomRight: Radius.circular(16),
                    ),
                  ),
                ),
              ),

              // Scanning animation
              if (_isScanning)
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppTheme.lightTheme.colorScheme.primary
                          .withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Center(
                      child: CircularProgressIndicator(
                        color: AppTheme.lightTheme.colorScheme.primary,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),

        SizedBox(height: 4.h),

        // Instructions
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 8.w),
          child: Column(
            children: [
              Text(
                'Position QR code within the frame',
                style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 1.h),
              Text(
                'The QR code will be scanned automatically',
                style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                  color: Colors.white.withValues(alpha: 0.8),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),

        SizedBox(height: 4.h),

        // Manual scan button (for demo purposes)
        if (_isInitialized && !_isScanning)
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.w),
            child: ElevatedButton(
              onPressed: _simulateQRScan,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.lightTheme.colorScheme.primary,
                foregroundColor: Colors.white,
                minimumSize: Size(double.infinity, 6.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Tap to Simulate Scan',
                style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),

        SizedBox(height: 4.h),
      ],
    );
  }
}
