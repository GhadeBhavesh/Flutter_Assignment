import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class TaskLogo extends StatelessWidget {
  final double size;
  final IconData icon;
  final Color? backgroundColor;

  const TaskLogo({
    super.key,
    this.size = 86,
    this.icon = Icons.check_rounded,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final scale = size / 86.0;

    return SizedBox(
      width: 140 * scale,
      height: 140 * scale,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          // Background soft glow
          Positioned(
            child: Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                color: backgroundColor ?? AppColors.primary,
                borderRadius: BorderRadius.circular(22 * scale),
                boxShadow: [
                  BoxShadow(
                    color: (backgroundColor ?? AppColors.primary).withValues(alpha: 0.38),
                    blurRadius: 22 * scale,
                    offset: Offset(0, 10 * scale),
                  ),
                ],
              ),
              child: Center(
                child: Icon(
                  icon,
                  color: Colors.white,
                  size: 46 * scale,
                ),
              ),
            ),
          ),

          // Sparkle: Top Right Yellow Star/Dot
          Positioned(
            top: 18 * scale,
            right: 14 * scale,
            child: _buildSparkleDot(
              size: 8 * scale,
              color: const Color(0xFFFBBF24),
            ),
          ),

          // Top Left Warm Orange Dot
          Positioned(
            top: 26 * scale,
            left: 12 * scale,
            child: _buildSparkleDot(
              size: 7 * scale,
              color: AppColors.tagOrange,
            ),
          ),

          // Center Right Deep Navy Dot
          Positioned(
            top: 56 * scale,
            right: 8 * scale,
            child: _buildSparkleDot(
              size: 8 * scale,
              color: const Color(0xFF1E2438),
            ),
          ),

          // Bottom Right Indigo Dot
          Positioned(
            bottom: 24 * scale,
            right: 18 * scale,
            child: _buildSparkleDot(
              size: 9 * scale,
              color: AppColors.primary,
            ),
          ),

          // Bottom Left Mint/Teal Dot
          Positioned(
            bottom: 18 * scale,
            left: 20 * scale,
            child: _buildSparkleDot(
              size: 7 * scale,
              color: AppColors.tagGreen,
            ),
          ),

          // Subtle Silver/Lavender Star speck
          Positioned(
            top: 10 * scale,
            left: 48 * scale,
            child: _buildSparkleDot(
              size: 4 * scale,
              color: const Color(0xFFCBD5E1),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSparkleDot({required double size, required Color color}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }
}
