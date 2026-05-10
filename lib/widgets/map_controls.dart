import 'package:flutter/material.dart';

const Color _controlSurface = Color(0xF2000000);
const Color _controlText = Colors.white;
const Color _primarySurface = Color(0xFFF2FBFB);
const Color _primaryText = Color(0xFF09202A);

class MapFloatingButton extends StatelessWidget {
  const MapFloatingButton({
    super.key,
    required this.onPressed,
    required this.icon,
    required this.width,
    required this.height,
  });

  final VoidCallback onPressed;
  final IconData icon;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: _controlSurface,
      elevation: 12,
      shadowColor: Colors.black.withValues(alpha: 0.75),
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.82),
              width: 2.0,
            ),
          ),
          child: Icon(icon, color: _controlText),
        ),
      ),
    );
  }
}

class MapPrimaryButton extends StatelessWidget {
  const MapPrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    required this.height,
    required this.textStyle,
    this.icon,
  });

  final String label;
  final VoidCallback onPressed;
  final double height;
  final TextStyle textStyle;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.72),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
          BoxShadow(
            color: Colors.white.withValues(alpha: 0.08),
            blurRadius: 1,
            spreadRadius: 1,
          ),
        ],
      ),
      child: TextButton(
        style: TextButton.styleFrom(
          foregroundColor: _primaryText,
          backgroundColor: _primarySurface,
          disabledForegroundColor: Colors.black45,
          padding: const EdgeInsets.symmetric(horizontal: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        onPressed: onPressed,
        child: SizedBox(
          height: height,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 22),
                const SizedBox(width: 10),
              ],
              Flexible(
                child: Text(
                  label,
                  overflow: TextOverflow.ellipsis,
                  style: textStyle,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
