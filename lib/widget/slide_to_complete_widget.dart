import 'package:flutter/material.dart';
import 'package:samrudhi_delivery_agent_app/constant/app_color.dart';
import 'package:samrudhi_delivery_agent_app/utils/responsive.dart';

class SlideToCompleteWidget extends StatefulWidget {
  final bool enabled;
  final VoidCallback onCompleted;

  const SlideToCompleteWidget({
    super.key,
    required this.enabled,
    required this.onCompleted,
  });

  @override
  State<SlideToCompleteWidget> createState() => _SlideToCompleteWidgetState();
}

class _SlideToCompleteWidgetState extends State<SlideToCompleteWidget> {
  double _dragX = 0;

  static const double _threshold = 0.65;

  @override
  Widget build(BuildContext context) {
    R.init(context);

    final double height = R.h(56);
    final double handleSize = R.w(44);
    final double padding = R.w(6);

    return LayoutBuilder(
      builder: (context, constraints) {
        final double maxWidth = constraints.maxWidth;
        final double maxDrag = maxWidth - handleSize - padding * 2;

        return GestureDetector(
          onHorizontalDragUpdate: widget.enabled
              ? (details) {
                  setState(() {
                    _dragX += details.delta.dx;
                    _dragX = _dragX.clamp(0, maxDrag);
                  });
                }
              : null,
          onHorizontalDragEnd: widget.enabled
              ? (_) {
                  if ((_dragX / maxDrag) >= _threshold) {
                    widget.onCompleted();
                  }
                  setState(() => _dragX = 0);
                }
              : null,
          child: Container(
            height: height,
            padding: EdgeInsets.all(padding),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F6F8),
              borderRadius: BorderRadius.circular(R.r(18)),
            ),
            child: Stack(
              alignment: Alignment.centerLeft,
              children: [
                // CENTER TEXT
                Center(
                  child: Text(
                    'Slide to Complete',
                    style: TextStyle(
                      fontSize: R.sp(16),
                      fontWeight: FontWeight.w600,
                      color:
                          widget.enabled ? AppColors.headingText : Colors.grey,
                    ),
                  ),
                ),

                // SLIDING HANDLE
                Positioned(
                  left: _dragX,
                  child: Container(
                    width: handleSize,
                    height: handleSize,
                    decoration: BoxDecoration(
                      color:
                          widget.enabled ? AppColors.primaryGreen : Colors.grey,
                      borderRadius: BorderRadius.circular(R.r(12)),
                    ),
                    child: Icon(
                      Icons.double_arrow,
                      color: Colors.white,
                      size: R.sp(20),
                    ),
                  ),
                ),

                // RIGHT CHEVRON
                Positioned(
                  right: R.w(6),
                  child: Icon(
                    Icons.chevron_right,
                    color: Colors.grey,
                    size: R.sp(22),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
