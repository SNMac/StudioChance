import 'package:flutter/cupertino.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SocialSignInButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String iconPath;
  final String label;
  final String? fontFamily;
  final Color backgroundColor;
  final Color textColor;
  final Color? borderColor;
  final Color? logoColor;

  const SocialSignInButton({
    super.key,
    required this.onPressed,
    required this.iconPath,
    required this.label,
    this.fontFamily,
    required this.backgroundColor,
    required this.textColor,
    this.borderColor,
    this.logoColor,
  });

  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      minimumSize: Size.zero,
      onPressed: onPressed,
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(12),
          border: borderColor != null
              ? Border.all(color: borderColor!, width: 1)
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              iconPath,
              width: 48,
              height: 48,
              colorFilter: logoColor != null
                  ? ColorFilter.mode(logoColor!, BlendMode.srcIn)
                  : null,
            ),
            Text(
              label,
              style: TextStyle(
                color: textColor,
                fontSize: 17,
                fontWeight: FontWeight.w600,
                fontFamily: fontFamily,
              ),
            ),
          ],
        ),
      ),
    );
  }
}