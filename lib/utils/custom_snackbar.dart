import 'package:flutter/material.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';

import 'package:samrudhi_delivery_agent_app/constant/app_color.dart';

class CustomSnackBar {
  static void showSuccess(BuildContext context, String message,
      {String title = 'Success',
      Color? color,
      SnackBarAction? action,
      bool centered = false}) {
    _show(
      context,
      title: title,
      message: message,
      contentType: ContentType.success,
      color: color,
      action: action,
      centered: centered,
    );
  }

  static void showError(BuildContext context, String message,
      {String title = 'Error', SnackBarAction? action, bool centered = false}) {
    _show(
      context,
      title: title,
      message: message,
      contentType: ContentType.failure,
      action: action,
      centered: centered,
    );
  }

  static void showWarning(BuildContext context, String message,
      {String title = 'Warning',
      SnackBarAction? action,
      bool centered = false}) {
    _show(
      context,
      title: title,
      message: message,
      contentType: ContentType.warning,
      action: action,
      centered: centered,
    );
  }

  static void showInfo(BuildContext context, String message,
      {String title = 'Help', SnackBarAction? action, bool centered = false}) {
    _show(
      context,
      title: title,
      message: message,
      contentType: ContentType.help,
      action: action,
      centered: centered,
    );
  }

  static void showSuccessBanner(BuildContext context, String message,
      {String title = 'Success'}) {
    _showBanner(
      context,
      title: title,
      message: message,
      contentType: ContentType.success,
    );
  }

  static void showErrorBanner(BuildContext context, String message,
      {String title = 'Error'}) {
    _showBanner(
      context,
      title: title,
      message: message,
      contentType: ContentType.failure,
    );
  }

  static void _show(
    BuildContext context, {
    required String title,
    required String message,
    required ContentType contentType,
    Color? color,
    SnackBarAction? action,
    bool centered = false,
  }) {
    if (!context.mounted) return;

    if (centered) {
      showDialog(
        context: context,
        barrierDismissible: true,
        barrierColor: Colors.black12,
        builder: (ctx) {
          Future.delayed(const Duration(seconds: 2), () {
            if (ctx.mounted && Navigator.canPop(ctx)) {
              Navigator.pop(ctx);
            }
          });
          return Material(
            color: Colors.transparent,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: AwesomeSnackbarContent(
                  title: title,
                  message: message,
                  contentType: contentType,
                  color: color ??
                      (contentType == ContentType.success
                          ? AppColors.primaryGreen
                          : null),
                ),
              ),
            ),
          );
        },
      );
    } else {
      final snackBar = SnackBar(
        elevation: 0,
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.transparent,
        margin: const EdgeInsets.all(20),
        duration: const Duration(seconds: 4),
        action: action,
        content: AwesomeSnackbarContent(
          title: title,
          message: message,
          contentType: contentType,
          color: color ??
              (contentType == ContentType.success
                  ? AppColors.primaryGreen
                  : null),
        ),
      );

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(snackBar);
    }
  }

  static void _showBanner(
    BuildContext context, {
    required String title,
    required String message,
    required ContentType contentType,
  }) {
    if (!context.mounted) return;

    final materialBanner = MaterialBanner(
      elevation: 0,
      backgroundColor: Colors.transparent,
      forceActionsBelow: true,
      content: AwesomeSnackbarContent(
        title: title,
        message: message,
        contentType: contentType,
        inMaterialBanner: true,
        color:
            contentType == ContentType.success ? AppColors.primaryGreen : null,
      ),
      actions: const [SizedBox.shrink()],
    );

    ScaffoldMessenger.of(context)
      ..hideCurrentMaterialBanner()
      ..showMaterialBanner(materialBanner);
  }
}
