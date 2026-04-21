import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nervix_app/Core/localization/app_localizations.dart';
import 'package:nervix_app/Core/utils/const.dart';
import 'package:nervix_app/Core/utils/styles.dart';

bool _isOffline(List<ConnectivityResult>? results) {
  if (results == null || results.isEmpty) return false;
  return results.every((r) => r == ConnectivityResult.none);
}

class ConnectivityBanner extends StatefulWidget {
  const ConnectivityBanner({super.key});

  @override
  State<ConnectivityBanner> createState() => _ConnectivityBannerState();
}

class _ConnectivityBannerState extends State<ConnectivityBanner> {
  List<ConnectivityResult>? _results;
  StreamSubscription<List<ConnectivityResult>>? _sub;

  @override
  void initState() {
    super.initState();
    Connectivity().checkConnectivity().then((r) {
      if (mounted) setState(() => _results = r);
    });
    _sub = Connectivity().onConnectivityChanged.listen((r) {
      if (mounted) setState(() => _results = r);
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (_results == null || !_isOffline(_results)) {
      return const SizedBox.shrink();
    }
    return Padding(
      padding: EdgeInsets.fromLTRB(12.w, 4.h, 12.w, 8.h),
      child: Material(
        elevation: 2,
        borderRadius: BorderRadius.circular(12.r),
        color: kErrorColor.withValues(alpha: 0.35),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
          child: Row(
            children: [
              Icon(Icons.wifi_off_rounded, color: Colors.orange.shade200, size: 20.sp),
              SizedBox(width: 10.w),
              Expanded(
                child: Text(
                  l10n.noInternetBanner,
                  style: FontStyles.roboto12.copyWith(
                    color: Colors.white.withValues(alpha: 0.95),
                    height: 1.3,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
