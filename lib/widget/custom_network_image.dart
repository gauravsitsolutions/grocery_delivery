import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:samrudhi_delivery_agent_app/utils/shared_prefs_util.dart';
import 'package:shimmer/shimmer.dart';
import 'package:samrudhi_delivery_agent_app/constant/app_color.dart';

class CustomNetworkImage extends StatelessWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Widget? placeholder;
  final Widget? errorWidget;

  const CustomNetworkImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.placeholder,
    this.errorWidget,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: SharedPrefsUtil.getToken(),
      builder: (context, snapshot) {
        final token = snapshot.data;
        Map<String, String>? headers;

        if (token != null && token.isNotEmpty) {
          headers = {
            'Authorization': token.startsWith('Bearer ') ? token : 'Bearer $token',
            'Accept': 'application/json',
          };
        }

        return CachedNetworkImage(
          imageUrl: imageUrl,
          width: width,
          height: height,
          fit: fit,
          httpHeaders: headers,
          placeholder: placeholder != null
              ? (context, url) => placeholder!
              : (context, url) => Shimmer.fromColors(
                    baseColor: AppColors.shimmerBase,
                    highlightColor: AppColors.shimmerHighlight,
                    child: Container(
                      width: width,
                      height: height,
                      color: AppColors.white,
                    ),
                  ),
          errorWidget: errorWidget != null
              ? (context, url, error) => errorWidget!
              : (context, url, error) => Container(
                    width: width,
                    height: height,
                    color: AppColors.shimmerBase,
                    child: const Icon(Icons.image_not_supported_outlined, color: AppColors.grey),
                  ),
        );
      },
    );
  }
}
