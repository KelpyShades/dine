import 'package:another_flushbar/flushbar.dart';
import 'package:dine/core/theme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

enum SnackType { warning, success, info, error }

void customSnackbar(
  String content, {
  SnackType type = SnackType.info,
  int duration = 4,
  bool isDismissible = true,
  required BuildContext? context,
}) {
  if (context == null) return;
  
  WidgetsBinding.instance.addPostFrameCallback((_) {
    if (context.mounted) {
      Flushbar(
        messageText: Text(
          content,
          textAlign: TextAlign.center,
          style: const TextStyle(color: AppColors.black),
        ),
        margin: const EdgeInsets.all(7),
        borderRadius: BorderRadius.circular(25),
        backgroundColor: AppColors.lightGreen,
        icon: Icon(
          type == SnackType.success
              ? CupertinoIcons.check_mark_circled
              : type == SnackType.warning
              ? CupertinoIcons.exclamationmark_circle
              : type == SnackType.info
              ? CupertinoIcons.exclamationmark_circle
              : CupertinoIcons.exclamationmark_circle,
          color: type == SnackType.success
              ? Colors.green
              : type == SnackType.warning
              ? Colors.yellow
              : type == SnackType.info
              ? Colors.blue
              : Colors.red,
        ),
        flushbarPosition: FlushbarPosition.TOP,
        duration: Duration(seconds: duration),
        isDismissible: isDismissible,
      ).show(context);
    }
  });
}
