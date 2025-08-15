import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';

import './supabase_service.dart';
import './auth_service.dart';

class VideoUploadService {
  static final VideoUploadService _instance = VideoUploadService._internal();
  factory VideoUploadService() => _instance;
  VideoUploadService._internal();

  static VideoUploadService get instance => _instance;

  final ImagePicker _picker = ImagePicker();

  // Pick video from gallery or camera
  Future<XFile?> pickVideo({bool fromCamera = false}) async {
    try {
      final XFile? video = await _picker.pickVideo(
        source: fromCamera ? ImageSource.camera : ImageSource.gallery,
        maxDuration: const Duration(minutes: 10), // Max 10 minutes
      );

      return video;
    } catch (e) {
      debugPrint('Error picking video: $e');
      return null;
    }
  }

  // Upload video to Supabase storage
  Future<String?> uploadVideo({
    required XFile videoFile,
    required String userId,
    String? title,
    String? description,
    List<String>? tags,
  }) async {
    try {
      final client = SupabaseService.instance.client;

      if (!AuthService.instance.isAuthenticated) {
        throw Exception('User must be authenticated to upload videos');
      }

      // Generate unique filename
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = '${userId}_${timestamp}.mp4';
      final filePath = '$userId/videos/$fileName';

      // Read video file bytes
      final bytes =
          kIsWeb ? videoFile.readAsBytes() : File(videoFile.path).readAsBytes();

      // Upload to Supabase storage
      final uploadPath = await client.storage
          .from('content-videos')
          .uploadBinary(filePath, await bytes);

      // Get public URL
      final videoUrl =
          client.storage.from('content-videos').getPublicUrl(filePath);

      // Create content entry in database
      final contentResponse = await client
          .from('content')
          .insert({
            'creator_id': userId,
            'type': 'video',
            'title': title ?? 'My Video',
            'description': description ?? '',
            'video_url': videoUrl,
            'thumbnail_url': await _generateThumbnail(videoUrl),
            'tags': tags ?? [],
            'is_public': true,
            'allows_comments': true,
            'allows_duets': true,
          })
          .select()
          .single();

      return contentResponse['id'];
    } catch (e) {
      debugPrint('Error uploading video: $e');
      throw Exception('Failed to upload video: ${e.toString()}');
    }
  }

  // Generate thumbnail for video (placeholder implementation)
  Future<String> _generateThumbnail(String videoUrl) async {
    // For now, return a placeholder thumbnail
    // In production, you might want to generate actual video thumbnails
    return 'https://picsum.photos/400/600?random=${DateTime.now().millisecondsSinceEpoch}';
  }

  // Get upload progress (for future enhancement)
  Stream<double> getUploadProgress() {
    // Placeholder for upload progress tracking
    return Stream.value(1.0);
  }

  // Validate video file
  bool validateVideoFile(XFile videoFile) {
    try {
      // Check file size (max 100MB)
      if (kIsWeb) {
        // Web validation would need to be handled differently
        return true;
      }

      final file = File(videoFile.path);
      final sizeInBytes = file.lengthSync();
      final sizeInMB = sizeInBytes / (1024 * 1024);

      if (sizeInMB > 100) {
        throw Exception('Video file too large (max 100MB)');
      }

      // Check file extension
      final validExtensions = ['.mp4', '.mov', '.avi', '.mkv'];
      final fileExtension = videoFile.path
          .toLowerCase()
          .substring(videoFile.path.lastIndexOf('.'));

      if (!validExtensions.contains(fileExtension)) {
        throw Exception('Invalid video format. Supported: MP4, MOV, AVI, MKV');
      }

      return true;
    } catch (e) {
      debugPrint('Video validation failed: $e');
      return false;
    }
  }

  // Delete video
  Future<void> deleteVideo(String contentId) async {
    try {
      final client = SupabaseService.instance.client;
      final user = client.auth.currentUser;

      if (user == null) {
        throw Exception('User must be authenticated to delete videos');
      }

      // Get content details
      final content = await client
          .from('content')
          .select('video_url, creator_id')
          .eq('id', contentId)
          .single();

      // Check if user owns the content
      if (content['creator_id'] != user.id) {
        throw Exception('You can only delete your own videos');
      }

      // Extract file path from URL
      final videoUrl = content['video_url'] as String;
      final uri = Uri.parse(videoUrl);
      final pathSegments = uri.pathSegments;
      final filePath = pathSegments
          .sublist(pathSegments.indexOf('content-videos') + 1)
          .join('/');

      // Delete from storage
      await client.storage.from('content-videos').remove([filePath]);

      // Delete from database
      await client.from('content').delete().eq('id', contentId);
    } catch (e) {
      debugPrint('Error deleting video: $e');
      throw Exception('Failed to delete video: ${e.toString()}');
    }
  }
}
