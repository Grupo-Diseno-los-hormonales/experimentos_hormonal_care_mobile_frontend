import 'package:flutter/material.dart';
import 'package:experimentos_hormonal_care_mobile_frontend/scr/shared/data/theme_service.dart';

class ProfileFieldWidget extends StatefulWidget {
  final String label;
  final String value;

  const ProfileFieldWidget({
    Key? key,
    required this.label,
    required this.value,
  }) : super(key: key);

  @override
  State<ProfileFieldWidget> createState() => _ProfileFieldWidgetState();
}

class _ProfileFieldWidgetState extends State<ProfileFieldWidget> {
  bool _isDarkMode = false;

  @override
  void initState() {
    super.initState();
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final isDark = await ThemeService.isDarkMode();
    setState(() {
      _isDarkMode = isDark;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.label,
            style: TextStyle(
              fontSize: 12,
              color: _isDarkMode ? Colors.white70 : Colors.grey[600],
            ),
          ),
          const SizedBox(height: 4),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: _isDarkMode ? Color(0xFF4A4A4A) : Colors.grey[200],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              widget.value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: _isDarkMode ? Colors.white : Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
