import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:record/record.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class AudioLibraryWidget extends StatefulWidget {
  final Function(String) onSoundSelected;
  final Function(String) onVoiceoverRecorded;
  final String? selectedSound;

  const AudioLibraryWidget({
    Key? key,
    required this.onSoundSelected,
    required this.onVoiceoverRecorded,
    this.selectedSound,
  }) : super(key: key);

  @override
  State<AudioLibraryWidget> createState() => _AudioLibraryWidgetState();
}

class _AudioLibraryWidgetState extends State<AudioLibraryWidget> {
  final TextEditingController _searchController = TextEditingController();
  final AudioRecorder _audioRecorder = AudioRecorder();

  bool _isRecording = false;
  String _recordingPath = '';
  String _selectedCategory = "Trending";

  final List<String> _categories = [
    "Trending",
    "Afrobeats",
    "K-Pop",
    "Reggaeton",
    "Hip-Hop",
    "Pop",
    "Electronic"
  ];

  final List<Map<String, dynamic>> _soundLibrary = [
    {
      "id": "trending_1",
      "title": "Viral Dance Beat",
      "artist": "TrendMaster",
      "category": "Trending",
      "duration": "0:30",
      "plays": "2.5M",
      "thumbnail":
          "https://images.pexels.com/photos/1763075/pexels-photo-1763075.jpeg?auto=compress&cs=tinysrgb&w=300",
    },
    {
      "id": "afrobeats_1",
      "title": "Lagos Nights",
      "artist": "Afro King",
      "category": "Afrobeats",
      "duration": "0:45",
      "plays": "1.8M",
      "thumbnail":
          "https://images.pexels.com/photos/1190298/pexels-photo-1190298.jpeg?auto=compress&cs=tinysrgb&w=300",
    },
    {
      "id": "kpop_1",
      "title": "Seoul Vibes",
      "artist": "K-Wave",
      "category": "K-Pop",
      "duration": "0:35",
      "plays": "3.2M",
      "thumbnail":
          "https://images.pexels.com/photos/1105666/pexels-photo-1105666.jpeg?auto=compress&cs=tinysrgb&w=300",
    },
    {
      "id": "reggaeton_1",
      "title": "Fiesta Loca",
      "artist": "Latino Heat",
      "category": "Reggaeton",
      "duration": "0:40",
      "plays": "1.9M",
      "thumbnail":
          "https://images.pexels.com/photos/1540406/pexels-photo-1540406.jpeg?auto=compress&cs=tinysrgb&w=300",
    },
    {
      "id": "hiphop_1",
      "title": "Street Anthem",
      "artist": "Urban Flow",
      "category": "Hip-Hop",
      "duration": "0:38",
      "plays": "2.1M",
      "thumbnail":
          "https://images.pexels.com/photos/1699161/pexels-photo-1699161.jpeg?auto=compress&cs=tinysrgb&w=300",
    },
    {
      "id": "pop_1",
      "title": "Summer Breeze",
      "artist": "Pop Star",
      "category": "Pop",
      "duration": "0:42",
      "plays": "1.7M",
      "thumbnail":
          "https://images.pexels.com/photos/1105666/pexels-photo-1105666.jpeg?auto=compress&cs=tinysrgb&w=300",
    },
  ];

  final List<String> _voiceoverLanguages = [
    "English",
    "Spanish",
    "Portuguese",
    "French",
    "German",
    "Italian",
    "Japanese",
    "Korean",
    "Mandarin",
    "Hindi",
    "Arabic",
    "Russian",
    "Dutch",
    "Swedish",
    "Norwegian",
    "Danish"
  ];

  String _selectedLanguage = "English";
  String _searchQuery = "";

  @override
  void dispose() {
    _searchController.dispose();
    _audioRecorder.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50.h,
      child: Column(
        children: [
          // Search bar
          Container(
            margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.toLowerCase();
                });
              },
              decoration: InputDecoration(
                hintText: 'Search sounds...',
                prefixIcon: Padding(
                  padding: EdgeInsets.all(3.w),
                  child: CustomIconWidget(
                    iconName: 'search',
                    size: 5.w,
                    color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                  ),
                ),
                suffixIcon: _searchQuery.isNotEmpty
                    ? GestureDetector(
                        onTap: () {
                          _searchController.clear();
                          setState(() {
                            _searchQuery = "";
                          });
                        },
                        child: Padding(
                          padding: EdgeInsets.all(3.w),
                          child: CustomIconWidget(
                            iconName: 'clear',
                            size: 5.w,
                            color: AppTheme
                                .lightTheme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      )
                    : null,
              ),
            ),
          ),

          // Category tabs
          Container(
            height: 6.h,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final category = _categories[index];
                final isSelected = category == _selectedCategory;

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedCategory = category;
                    });
                  },
                  child: Container(
                    margin: EdgeInsets.only(right: 3.w),
                    padding:
                        EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppTheme.lightTheme.colorScheme.primary
                          : AppTheme.lightTheme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected
                            ? AppTheme.lightTheme.colorScheme.primary
                            : AppTheme.lightTheme.colorScheme.outline
                                .withValues(alpha: 0.3),
                      ),
                    ),
                    child: Center(
                      child: Text(
                        category,
                        style:
                            AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
                          color: isSelected
                              ? AppTheme.lightTheme.colorScheme.onPrimary
                              : AppTheme.lightTheme.colorScheme.onSurface,
                          fontWeight:
                              isSelected ? FontWeight.w600 : FontWeight.w400,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          SizedBox(height: 2.h),

          // Voiceover recording section
          Container(
            margin: EdgeInsets.symmetric(horizontal: 4.w),
            padding: EdgeInsets.all(4.w),
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppTheme.lightTheme.colorScheme.outline
                    .withValues(alpha: 0.3),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CustomIconWidget(
                      iconName: 'mic',
                      size: 5.w,
                      color: AppTheme.lightTheme.colorScheme.primary,
                    ),
                    SizedBox(width: 2.w),
                    Text(
                      'Record Voiceover',
                      style:
                          AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 2.h),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _selectedLanguage,
                        decoration: const InputDecoration(
                          labelText: 'Language',
                          contentPadding:
                              EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                        items: _voiceoverLanguages.map((language) {
                          return DropdownMenuItem(
                            value: language,
                            child: Text(language),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              _selectedLanguage = value;
                            });
                          }
                        },
                      ),
                    ),
                    SizedBox(width: 4.w),
                    GestureDetector(
                      onTap: _isRecording ? _stopRecording : _startRecording,
                      child: Container(
                        width: 12.w,
                        height: 6.h,
                        decoration: BoxDecoration(
                          color: _isRecording
                              ? AppTheme.lightTheme.colorScheme.error
                              : AppTheme.lightTheme.colorScheme.primary,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: CustomIconWidget(
                            iconName: _isRecording ? 'stop' : 'mic',
                            size: 6.w,
                            color: AppTheme.lightTheme.colorScheme.onPrimary,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          SizedBox(height: 2.h),

          // Sound library
          Expanded(
            child: _buildSoundLibrary(),
          ),
        ],
      ),
    );
  }

  Widget _buildSoundLibrary() {
    final filteredSounds = _soundLibrary.where((sound) {
      final matchesCategory = _selectedCategory == "Trending" ||
          sound["category"] == _selectedCategory;
      final matchesSearch = _searchQuery.isEmpty ||
          (sound["title"] as String).toLowerCase().contains(_searchQuery) ||
          (sound["artist"] as String).toLowerCase().contains(_searchQuery);
      return matchesCategory && matchesSearch;
    }).toList();

    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 4.w),
      itemCount: filteredSounds.length,
      itemBuilder: (context, index) {
        final sound = filteredSounds[index];
        final isSelected = widget.selectedSound == sound["id"];

        return Container(
          margin: EdgeInsets.only(bottom: 2.h),
          decoration: BoxDecoration(
            color: AppTheme.lightTheme.colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected
                  ? AppTheme.lightTheme.colorScheme.primary
                  : AppTheme.lightTheme.colorScheme.outline
                      .withValues(alpha: 0.3),
              width: isSelected ? 2 : 1,
            ),
          ),
          child: ListTile(
            contentPadding: EdgeInsets.all(3.w),
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: CustomImageWidget(
                imageUrl: sound["thumbnail"] as String,
                width: 12.w,
                height: 12.w,
                fit: BoxFit.cover,
              ),
            ),
            title: Text(
              sound["title"] as String,
              style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  sound["artist"] as String,
                  style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                    color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                  ),
                ),
                SizedBox(height: 0.5.h),
                Row(
                  children: [
                    Text(
                      sound["duration"] as String,
                      style: AppTheme.lightTheme.textTheme.labelSmall,
                    ),
                    SizedBox(width: 2.w),
                    CustomIconWidget(
                      iconName: 'play_arrow',
                      size: 3.w,
                      color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                    ),
                    SizedBox(width: 1.w),
                    Text(
                      sound["plays"] as String,
                      style: AppTheme.lightTheme.textTheme.labelSmall,
                    ),
                  ],
                ),
              ],
            ),
            trailing: GestureDetector(
              onTap: () {
                widget.onSoundSelected(sound["id"] as String);
              },
              child: Container(
                width: 10.w,
                height: 5.h,
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppTheme.lightTheme.colorScheme.primary
                      : AppTheme.lightTheme.colorScheme.outline
                          .withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: CustomIconWidget(
                    iconName: isSelected ? 'check' : 'add',
                    size: 5.w,
                    color: isSelected
                        ? AppTheme.lightTheme.colorScheme.onPrimary
                        : AppTheme.lightTheme.colorScheme.onSurface,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _startRecording() async {
    try {
      if (await _audioRecorder.hasPermission()) {
        setState(() {
          _isRecording = true;
        });

        if (kIsWeb) {
          await _audioRecorder.start(
              const RecordConfig(encoder: AudioEncoder.wav),
              path: 'voiceover_recording.wav');
        } else {
          await _audioRecorder.start(const RecordConfig(),
              path: 'voiceover_recording.m4a');
        }
      }
    } catch (e) {
      setState(() {
        _isRecording = false;
      });
    }
  }

  Future<void> _stopRecording() async {
    try {
      final path = await _audioRecorder.stop();
      setState(() {
        _isRecording = false;
      });

      if (path != null) {
        widget.onVoiceoverRecorded(path);
      }
    } catch (e) {
      setState(() {
        _isRecording = false;
      });
    }
  }
}
