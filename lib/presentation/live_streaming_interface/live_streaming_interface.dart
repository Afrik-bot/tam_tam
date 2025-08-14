import 'dart:async';
import 'dart:math';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../services/content_service.dart';
import '../../services/supabase_service.dart';
import './widgets/battle_mode_widget.dart';
import './widgets/comment_input_widget.dart';
import './widgets/comment_stream_widget.dart';
import './widgets/hearts_animation_widget.dart';
import './widgets/shopping_overlay_widget.dart';
import './widgets/stream_controls_widget.dart';
import './widgets/stream_overlay_widget.dart';

class LiveStreamingInterface extends StatefulWidget {
  const LiveStreamingInterface({super.key});

  @override
  State<LiveStreamingInterface> createState() => _LiveStreamingInterfaceState();
}

class _LiveStreamingInterfaceState extends State<LiveStreamingInterface>
    with TickerProviderStateMixin {
  // Camera and streaming
  CameraController? _cameraController;
  List<CameraDescription> _cameras = [];
  bool _isStreaming = false;
  bool _isInitialized = false;
  bool _isScreenSharing = false;
  bool _isBeautyFilterOn = false;
  bool _isBattleMode = false;
  bool _showHearts = false;
  bool _isAnonymous = true;

  // Stream data
  int _viewerCount = 1247;
  String _streamDuration = '15:32';
  Timer? _streamTimer;
  DateTime? _streamStartTime;

  // Comments and interactions
  final TextEditingController _commentController = TextEditingController();
  final ScrollController _commentScrollController = ScrollController();
  List<Map<String, dynamic>> _comments = [];
  Timer? _commentTimer;
  StreamSubscription? _commentSubscription;

  // Shopping
  bool _showShoppingOverlay = false;
  List<Map<String, dynamic>> _products = [];

  // Battle mode
  Map<String, dynamic> _battleData = {};

  // Current live stream content
  Map<String, dynamic>? _currentLiveContent;

  @override
  void initState() {
    super.initState();
    _initializeServices();
    _initializeMockData();
    _initializeCamera();
    _startStreamSimulation();
    _loadLiveStreamData();
  }

  void _initializeServices() {
    // Check if Supabase is properly initialized
    if (SupabaseService.instance.isInitialized) {
      debugPrint('Supabase service is ready for live streaming');
    } else {
      debugPrint('Using fallback mode for live streaming preview');
    }
  }

  Future<void> _loadLiveStreamData() async {
    try {
      // Load current live stream content
      final liveContent =
          await ContentService.instance.getLiveStreamContent(limit: 1);
      if (liveContent.isNotEmpty) {
        setState(() {
          _currentLiveContent = liveContent.first;
          _viewerCount = _currentLiveContent!['view_count'] ?? 1247;
        });
      }

      // Load comments for the current stream
      _loadComments();

      // Load battle data
      final battles = await ContentService.instance.getActiveBattles(limit: 1);
      if (battles.isNotEmpty) {
        setState(() {
          _battleData = battles.first;
        });
      }
    } catch (error) {
      debugPrint('Error loading live stream data: $error');
      // Continue with fallback data - app won't crash
    }
  }

  Future<void> _loadComments() async {
    try {
      final comments = await ContentService.instance.getLiveStreamComments(
        _currentLiveContent?['id'],
        limit: 20,
      );

      setState(() {
        _comments = comments;
      });

      // Subscribe to real-time comments if we have content
      if (_currentLiveContent != null) {
        _commentSubscription?.cancel();
        _commentSubscription = ContentService.instance
            .subscribeToLiveComments(_currentLiveContent!['id'])
            .listen((comments) {
          if (mounted) {
            setState(() {
              _comments = comments;
            });
            _scrollToBottom();
          }
        });
      }
    } catch (error) {
      debugPrint('Error loading comments: $error');
    }
  }

  void _initializeMockData() {
    _products = [
      {
        "id": 1,
        "name": "Wireless Earbuds Pro",
        "description":
            "Premium sound quality with noise cancellation and 24-hour battery life",
        "price": "\$149.99",
        "image":
            "https://images.pexels.com/photos/3780681/pexels-photo-3780681.jpeg?auto=compress&cs=tinysrgb&w=300",
        "inStock": true,
      },
      {
        "id": 2,
        "name": "Smart Fitness Watch",
        "description":
            "Track your health and fitness with advanced sensors and GPS",
        "price": "\$299.99",
        "image":
            "https://images.pexels.com/photos/437037/pexels-photo-437037.jpeg?auto=compress&cs=tinysrgb&w=300",
        "inStock": true,
      },
      {
        "id": 3,
        "name": "Portable Phone Stand",
        "description": "Adjustable stand perfect for streaming and video calls",
        "price": "\$24.99",
        "image":
            "https://images.pexels.com/photos/4219654/pexels-photo-4219654.jpeg?auto=compress&cs=tinysrgb&w=300",
        "inStock": true,
      },
    ];
  }

  Future<void> _initializeCamera() async {
    try {
      final permission = await Permission.camera.request();
      if (!permission.isGranted) {
        _showToast('Camera permission required for streaming');
        return;
      }

      _cameras = await availableCameras();
      if (_cameras.isEmpty) {
        _showToast('No cameras available');
        return;
      }

      final frontCamera = _cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.front,
        orElse: () => _cameras.first,
      );

      _cameraController = CameraController(
        frontCamera,
        ResolutionPreset.high,
        enableAudio: true,
      );

      await _cameraController!.initialize();

      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
      }
    } catch (e) {
      _showToast('Failed to initialize camera');
      debugPrint('Camera initialization error: $e');
    }
  }

  void _startStreamSimulation() {
    _streamStartTime = DateTime.now();
    _streamTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (mounted) {
        final elapsed = DateTime.now().difference(_streamStartTime!);
        final minutes = elapsed.inMinutes;
        final seconds = elapsed.inSeconds % 60;

        setState(() {
          _streamDuration =
              '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
          _viewerCount += Random().nextInt(3) - 1;
          if (_viewerCount < 100) _viewerCount = 100;
        });
      }
    });

    setState(() {
      _isStreaming = true;
    });
  }

  void _scrollToBottom() {
    if (_commentScrollController.hasClients) {
      _commentScrollController.animateTo(
        _commentScrollController.position.maxScrollExtent,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _onCameraFlip() async {
    if (_cameraController == null || !_isInitialized) return;

    try {
      final currentCamera = _cameraController!.description;
      final newCamera = _cameras.firstWhere(
        (camera) => camera.lensDirection != currentCamera.lensDirection,
        orElse: () => currentCamera,
      );

      await _cameraController!.dispose();
      _cameraController = CameraController(newCamera, ResolutionPreset.high);
      await _cameraController!.initialize();

      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      _showToast('Failed to flip camera');
    }
  }

  void _onBeautyFilter() {
    setState(() {
      _isBeautyFilterOn = !_isBeautyFilterOn;
    });
    _showToast(
        _isBeautyFilterOn ? 'Beauty filter enabled' : 'Beauty filter disabled');
  }

  void _onScreenShare() {
    setState(() {
      _isScreenSharing = !_isScreenSharing;
    });
    _showToast(
        _isScreenSharing ? 'Screen sharing started' : 'Screen sharing stopped');
  }

  void _onEndStream() {
    _showEndStreamDialog();
  }

  void _showEndStreamDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('End Stream'),
        content: Text('Are you sure you want to end your live stream?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _endStream();
            },
            child: Text('End Stream'),
          ),
        ],
      ),
    );
  }

  void _endStream() {
    _streamTimer?.cancel();
    _commentTimer?.cancel();
    _commentSubscription?.cancel();
    Navigator.pushReplacementNamed(context, '/creator-analytics-dashboard');
  }

  Future<void> _onSendComment() async {
    if (_commentController.text.trim().isEmpty) return;

    final message = _commentController.text.trim();
    _commentController.clear();

    try {
      // Try to add comment to Supabase
      await ContentService.instance.addLiveStreamComment(
        _currentLiveContent?['id'],
        message,
      );

      // Add optimistic update for better UX
      final newComment = {
        "id": DateTime.now().millisecondsSinceEpoch.toString(),
        "username": "You",
        "full_name": "You",
        "avatar":
            "https://images.pexels.com/photos/1239291/pexels-photo-1239291.jpeg?auto=compress&cs=tinysrgb&w=150",
        "message": message,
        "type": "comment",
        "verified": false,
        "timestamp": DateTime.now(),
      };

      setState(() {
        _comments.add(newComment);
      });

      _scrollToBottom();
    } catch (error) {
      debugPrint('Error sending comment: $error');
      _showToast('Failed to send comment');
    }
  }

  void _onGiftTap() {
    _showGiftBottomSheet();
  }

  void _showGiftBottomSheet() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        height: 30.h,
        padding: EdgeInsets.all(4.w),
        child: Column(
          children: [
            Text(
              'Send Gift',
              style: AppTheme.lightTheme.textTheme.titleLarge,
            ),
            SizedBox(height: 2.h),
            Expanded(
              child: GridView.count(
                crossAxisCount: 4,
                children: [
                  _buildGiftItem('🎁', '\$5'),
                  _buildGiftItem('💎', '\$10'),
                  _buildGiftItem('🌟', '\$25'),
                  _buildGiftItem('👑', '\$50'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGiftItem(String emoji, String price) {
    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
        _sendGift(price);
      },
      child: Container(
        margin: EdgeInsets.all(1.w),
        decoration: BoxDecoration(
          color: AppTheme.lightTheme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.lightTheme.dividerColor),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(emoji, style: TextStyle(fontSize: 24)),
            SizedBox(height: 0.5.h),
            Text(price, style: AppTheme.lightTheme.textTheme.labelSmall),
          ],
        ),
      ),
    );
  }

  void _sendGift(String amount) {
    final tipComment = {
      "id": DateTime.now().millisecondsSinceEpoch.toString(),
      "username": "You",
      "full_name": "You",
      "avatar":
          "https://images.pexels.com/photos/1239291/pexels-photo-1239291.jpeg?auto=compress&cs=tinysrgb&w=150",
      "message": "Sent a gift!",
      "type": "tip",
      "amount": amount,
      "verified": false,
      "timestamp": DateTime.now(),
    };

    setState(() {
      _comments.add(tipComment);
    });

    _showToast('Gift sent successfully!');
    _scrollToBottom();
  }

  void _onShoppingTap() {
    setState(() {
      _showShoppingOverlay = true;
    });
  }

  void _onProductTap(Map<String, dynamic> product) {
    _showPurchaseDialog(product);
  }

  void _showPurchaseDialog(Map<String, dynamic> product) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Purchase ${product['name']}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: CustomImageWidget(
                imageUrl: product['image'] as String,
                width: 30.w,
                height: 30.w,
                fit: BoxFit.cover,
              ),
            ),
            SizedBox(height: 2.h),
            Text(
              product['price'] as String,
              style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                color: AppTheme.lightTheme.colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
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
              _purchaseProduct(product);
            },
            child: Text('Buy Now'),
          ),
        ],
      ),
    );
  }

  void _purchaseProduct(Map<String, dynamic> product) {
    _showToast('Purchase successful! ${product['name']} will be shipped soon.');
    setState(() {
      _showShoppingOverlay = false;
    });
  }

  void _onDoubleTap() {
    setState(() {
      _showHearts = true;
    });

    // Try to like the current content
    if (_currentLiveContent != null) {
      ContentService.instance.toggleContentLike(_currentLiveContent!['id']);
    }

    Future.delayed(Duration(milliseconds: 100), () {
      if (mounted) {
        setState(() {
          _showHearts = false;
        });
      }
    });
  }

  void _toggleBattleMode() {
    setState(() {
      _isBattleMode = !_isBattleMode;
    });
  }

  void _showToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            // Camera preview or battle mode
            _buildMainContent(),

            // Stream overlay (viewer count, duration, close button)
            StreamOverlayWidget(
              viewerCount: _viewerCount,
              streamDuration: _streamDuration,
              onClose: _onEndStream,
              isStreaming: _isStreaming,
            ),

            // Comment stream
            CommentStreamWidget(
              comments: _comments,
              scrollController: _commentScrollController,
            ),

            // Stream controls
            StreamControlsWidget(
              onCameraFlip: _onCameraFlip,
              onBeautyFilter: _onBeautyFilter,
              onScreenShare: _onScreenShare,
              onEndStream: _onEndStream,
              isScreenSharing: _isScreenSharing,
              isBeautyFilterOn: _isBeautyFilterOn,
            ),

            // Comment input
            CommentInputWidget(
              commentController: _commentController,
              onSendComment: _onSendComment,
              onGiftTap: _onGiftTap,
              onShoppingTap: _onShoppingTap,
              hasProducts: _products.isNotEmpty,
            ),

            // Hearts animation
            HeartsAnimationWidget(showAnimation: _showHearts),

            // Shopping overlay
            if (_showShoppingOverlay)
              Positioned.fill(
                child: Container(
                  color: Colors.black.withValues(alpha: 0.5),
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: ShoppingOverlayWidget(
                      products: _products,
                      onProductTap: _onProductTap,
                      onClose: () =>
                          setState(() => _showShoppingOverlay = false),
                    ),
                  ),
                ),
              ),

            // Battle mode toggle button
            Positioned(
              top: 15.h,
              right: 4.w,
              child: GestureDetector(
                onTap: _toggleBattleMode,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
                  decoration: BoxDecoration(
                    color: _isBattleMode
                        ? AppTheme.lightTheme.colorScheme.primary
                        : Colors.black.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'BATTLE',
                    style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainContent() {
    return GestureDetector(
      onDoubleTap: _onDoubleTap,
      child: Container(
        width: double.infinity,
        height: double.infinity,
        child: _isBattleMode
            ? BattleModeWidget(
                creator1: _battleData['creator1'] as Map<String, dynamic>? ??
                    {"name": "Creator1", "avatar": "", "score": 0.0},
                creator2: _battleData['creator2'] as Map<String, dynamic>? ??
                    {"name": "Creator2", "avatar": "", "score": 0.0},
                tipPool: (_battleData['tipPool'] as num?)?.toDouble() ?? 0.0,
                timeRemaining:
                    _battleData['timeRemaining'] as String? ?? "00:00",
              )
            : _buildCameraPreview(),
      ),
    );
  }

  Widget _buildCameraPreview() {
    if (!_isInitialized || _cameraController == null) {
      return Container(
        color: Colors.black,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                color: AppTheme.lightTheme.colorScheme.primary,
              ),
              SizedBox(height: 2.h),
              Text(
                'Initializing camera...',
                style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ClipRect(
      child: Transform.scale(
        scale: _cameraController!.value.aspectRatio / (9 / 16),
        child: Center(
          child: AspectRatio(
            aspectRatio: _cameraController!.value.aspectRatio,
            child: CameraPreview(_cameraController!),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _streamTimer?.cancel();
    _commentTimer?.cancel();
    _commentSubscription?.cancel();
    _cameraController?.dispose();
    _commentController.dispose();
    _commentScrollController.dispose();
    super.dispose();
  }
}
