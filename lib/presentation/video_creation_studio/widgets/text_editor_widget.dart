import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class TextEditorWidget extends StatefulWidget {
  final Function(Map<String, dynamic>) onTextAdded;
  final List<Map<String, dynamic>> textElements;
  final Function(int, Map<String, dynamic>) onTextUpdated;
  final Function(int) onTextRemoved;

  const TextEditorWidget({
    Key? key,
    required this.onTextAdded,
    required this.textElements,
    required this.onTextUpdated,
    required this.onTextRemoved,
  }) : super(key: key);

  @override
  State<TextEditorWidget> createState() => _TextEditorWidgetState();
}

class _TextEditorWidgetState extends State<TextEditorWidget> {
  final TextEditingController _textController = TextEditingController();

  String _selectedFont = "Inter";
  Color _selectedColor = Colors.white;
  double _fontSize = 18.0;
  String _selectedAnimation = "none";
  TextAlign _textAlignment = TextAlign.center;
  bool _isBold = false;
  bool _isItalic = false;
  bool _hasOutline = true;

  final List<String> _fonts = [
    "Inter",
    "Roboto",
    "Poppins",
    "Montserrat",
    "Open Sans",
    "Lato",
    "Nunito",
    "Source Sans Pro"
  ];

  final List<Color> _colors = [
    Colors.white,
    Colors.black,
    Colors.red,
    Colors.blue,
    Colors.green,
    Colors.yellow,
    Colors.purple,
    Colors.orange,
    Colors.pink,
    Colors.cyan
  ];

  final List<Map<String, dynamic>> _animations = [
    {"id": "none", "name": "None", "icon": "text_fields"},
    {"id": "fade_in", "name": "Fade In", "icon": "fade_in"},
    {"id": "slide_up", "name": "Slide Up", "icon": "keyboard_arrow_up"},
    {"id": "bounce", "name": "Bounce", "icon": "bounce"},
    {"id": "typewriter", "name": "Typewriter", "icon": "keyboard"},
    {"id": "zoom_in", "name": "Zoom In", "icon": "zoom_in"},
  ];

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 55.h,
      child: Column(
        children: [
          // Text input
          Container(
            margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
            child: TextField(
              controller: _textController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Enter your text...',
                suffixIcon: GestureDetector(
                  onTap: _addText,
                  child: Container(
                    margin: EdgeInsets.all(2.w),
                    decoration: BoxDecoration(
                      color: AppTheme.lightTheme.colorScheme.primary,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: CustomIconWidget(
                        iconName: 'add',
                        size: 5.w,
                        color: AppTheme.lightTheme.colorScheme.onPrimary,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Text styling options
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Font selection
                  _buildSectionTitle("Font"),
                  SizedBox(height: 1.h),
                  Container(
                    height: 6.h,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _fonts.length,
                      itemBuilder: (context, index) {
                        final font = _fonts[index];
                        final isSelected = font == _selectedFont;

                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedFont = font;
                            });
                          },
                          child: Container(
                            margin: EdgeInsets.only(right: 3.w),
                            padding: EdgeInsets.symmetric(
                                horizontal: 4.w, vertical: 1.h),
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
                            child: Center(
                              child: Text(
                                font,
                                style: AppTheme.lightTheme.textTheme.labelMedium
                                    ?.copyWith(
                                  color: isSelected
                                      ? AppTheme
                                          .lightTheme.colorScheme.onPrimary
                                      : AppTheme
                                          .lightTheme.colorScheme.onSurface,
                                  fontWeight: isSelected
                                      ? FontWeight.w600
                                      : FontWeight.w400,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  SizedBox(height: 3.h),

                  // Color selection
                  _buildSectionTitle("Color"),
                  SizedBox(height: 1.h),
                  Container(
                    height: 8.h,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _colors.length,
                      itemBuilder: (context, index) {
                        final color = _colors[index];
                        final isSelected = color == _selectedColor;

                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedColor = color;
                            });
                          },
                          child: Container(
                            width: 12.w,
                            height: 6.h,
                            margin: EdgeInsets.only(right: 3.w),
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isSelected
                                    ? AppTheme.lightTheme.colorScheme.primary
                                    : AppTheme.lightTheme.colorScheme.outline
                                        .withValues(alpha: 0.3),
                                width: isSelected ? 3 : 1,
                              ),
                            ),
                            child: isSelected
                                ? Center(
                                    child: CustomIconWidget(
                                      iconName: 'check',
                                      size: 4.w,
                                      color: color == Colors.white ||
                                              color == Colors.yellow
                                          ? Colors.black
                                          : Colors.white,
                                    ),
                                  )
                                : null,
                          ),
                        );
                      },
                    ),
                  ),

                  SizedBox(height: 3.h),

                  // Font size and style controls
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildSectionTitle("Size"),
                            SizedBox(height: 1.h),
                            Slider(
                              value: _fontSize,
                              min: 12.0,
                              max: 48.0,
                              divisions: 36,
                              label: _fontSize.round().toString(),
                              onChanged: (value) {
                                setState(() {
                                  _fontSize = value;
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 4.w),
                      Column(
                        children: [
                          _buildStyleButton(
                            icon: 'format_bold',
                            isActive: _isBold,
                            onTap: () {
                              setState(() {
                                _isBold = !_isBold;
                              });
                            },
                          ),
                          SizedBox(height: 1.h),
                          _buildStyleButton(
                            icon: 'format_italic',
                            isActive: _isItalic,
                            onTap: () {
                              setState(() {
                                _isItalic = !_isItalic;
                              });
                            },
                          ),
                        ],
                      ),
                    ],
                  ),

                  SizedBox(height: 3.h),

                  // Text alignment
                  _buildSectionTitle("Alignment"),
                  SizedBox(height: 1.h),
                  Row(
                    children: [
                      _buildAlignmentButton(
                          TextAlign.left, 'format_align_left'),
                      SizedBox(width: 2.w),
                      _buildAlignmentButton(
                          TextAlign.center, 'format_align_center'),
                      SizedBox(width: 2.w),
                      _buildAlignmentButton(
                          TextAlign.right, 'format_align_right'),
                      SizedBox(width: 4.w),
                      _buildStyleButton(
                        icon: 'border_outer',
                        isActive: _hasOutline,
                        onTap: () {
                          setState(() {
                            _hasOutline = !_hasOutline;
                          });
                        },
                      ),
                    ],
                  ),

                  SizedBox(height: 3.h),

                  // Animation selection
                  _buildSectionTitle("Animation"),
                  SizedBox(height: 1.h),
                  Container(
                    height: 8.h,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _animations.length,
                      itemBuilder: (context, index) {
                        final animation = _animations[index];
                        final isSelected =
                            animation["id"] == _selectedAnimation;

                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedAnimation = animation["id"] as String;
                            });
                          },
                          child: Container(
                            margin: EdgeInsets.only(right: 3.w),
                            padding: EdgeInsets.symmetric(
                                horizontal: 3.w, vertical: 1.h),
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
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CustomIconWidget(
                                  iconName: animation["icon"] as String,
                                  size: 5.w,
                                  color: isSelected
                                      ? AppTheme
                                          .lightTheme.colorScheme.onPrimary
                                      : AppTheme
                                          .lightTheme.colorScheme.onSurface,
                                ),
                                SizedBox(height: 0.5.h),
                                Text(
                                  animation["name"] as String,
                                  style: AppTheme
                                      .lightTheme.textTheme.labelSmall
                                      ?.copyWith(
                                    color: isSelected
                                        ? AppTheme
                                            .lightTheme.colorScheme.onPrimary
                                        : AppTheme
                                            .lightTheme.colorScheme.onSurface,
                                    fontSize: 8.sp,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  SizedBox(height: 3.h),

                  // Existing text elements
                  if (widget.textElements.isNotEmpty) ...[
                    _buildSectionTitle("Added Text"),
                    SizedBox(height: 1.h),
                    ...widget.textElements.asMap().entries.map((entry) {
                      final index = entry.key;
                      final element = entry.value;

                      return Container(
                        margin: EdgeInsets.only(bottom: 2.h),
                        padding: EdgeInsets.all(3.w),
                        decoration: BoxDecoration(
                          color: AppTheme.lightTheme.colorScheme.surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppTheme.lightTheme.colorScheme.outline
                                .withValues(alpha: 0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                element["text"] as String,
                                style: AppTheme.lightTheme.textTheme.bodyMedium,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                widget.onTextRemoved(index);
                              },
                              child: Container(
                                padding: EdgeInsets.all(2.w),
                                decoration: BoxDecoration(
                                  color: AppTheme.lightTheme.colorScheme.error
                                      .withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: CustomIconWidget(
                                  iconName: 'delete',
                                  size: 4.w,
                                  color: AppTheme.lightTheme.colorScheme.error,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _buildStyleButton({
    required String icon,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 10.w,
        height: 5.h,
        decoration: BoxDecoration(
          color: isActive
              ? AppTheme.lightTheme.colorScheme.primary
              : AppTheme.lightTheme.colorScheme.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isActive
                ? AppTheme.lightTheme.colorScheme.primary
                : AppTheme.lightTheme.colorScheme.outline
                    .withValues(alpha: 0.3),
          ),
        ),
        child: Center(
          child: CustomIconWidget(
            iconName: icon,
            size: 4.w,
            color: isActive
                ? AppTheme.lightTheme.colorScheme.onPrimary
                : AppTheme.lightTheme.colorScheme.onSurface,
          ),
        ),
      ),
    );
  }

  Widget _buildAlignmentButton(TextAlign alignment, String icon) {
    final isSelected = _textAlignment == alignment;

    return GestureDetector(
      onTap: () {
        setState(() {
          _textAlignment = alignment;
        });
      },
      child: Container(
        width: 10.w,
        height: 5.h,
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.lightTheme.colorScheme.primary
              : AppTheme.lightTheme.colorScheme.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected
                ? AppTheme.lightTheme.colorScheme.primary
                : AppTheme.lightTheme.colorScheme.outline
                    .withValues(alpha: 0.3),
          ),
        ),
        child: Center(
          child: CustomIconWidget(
            iconName: icon,
            size: 4.w,
            color: isSelected
                ? AppTheme.lightTheme.colorScheme.onPrimary
                : AppTheme.lightTheme.colorScheme.onSurface,
          ),
        ),
      ),
    );
  }

  void _addText() {
    if (_textController.text.trim().isNotEmpty) {
      final textElement = {
        "text": _textController.text.trim(),
        "font": _selectedFont,
        "color": _selectedColor.value,
        "fontSize": _fontSize,
        "animation": _selectedAnimation,
        "alignment": _textAlignment.index,
        "isBold": _isBold,
        "isItalic": _isItalic,
        "hasOutline": _hasOutline,
        "x": 0.5, // Center position
        "y": 0.5, // Center position
      };

      widget.onTextAdded(textElement);
      _textController.clear();
    }
  }
}
