import 'dart:ui' as ui;
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gal/gal.dart';
import 'package:nervix_app/Core/utils/patient_card_info.dart';
import 'package:nervix_app/Features/Doctor_Info/Presentation/view/Widget/dynamic_line_chart.dart';
import 'package:nervix_app/Features/Home_view/logic/home_cubit.dart';
import 'package:nervix_app/Core/localization/translation_extension.dart';
import 'package:nervix_app/Core/utils/theme_extensions.dart';

class PatientInfoSection extends StatelessWidget {
  const PatientInfoSection({super.key, required this.state});
  final HomeLoaded state;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: PatientsCardInfo(
            patientName: state.user.name ?? context.t('Guest', 'ضيف'),
            age: state.user.age ?? 25,
            condition: state.user.condition,
            imageUrl: state.user.profileImageUrl ?? '',
            profileImageBase64: state.user.profileImageBase64 ?? '',
            signalValue: state.latestSignal,
            gender: state.user.gender ?? context.t('Male', 'ذكر'),
            currentState: state.currentState,
          ),
        ),
        SizedBox(height: 24.h),
        ScreenshotableGraph(state: state),
      ],
    );
  }
}

class ScreenshotableGraph extends StatefulWidget {
  final HomeLoaded state;
  const ScreenshotableGraph({super.key, required this.state});

  @override
  State<ScreenshotableGraph> createState() => _ScreenshotableGraphState();
}

class _ScreenshotableGraphState extends State<ScreenshotableGraph> {
  final GlobalKey _globalKey = GlobalKey();
  bool _isCapturing = false;

  Future<void> _captureAndSaveScreenshot() async {
    if (_isCapturing) return;
    setState(() {
      _isCapturing = true;
    });

    try {
      final hasAccess = await Gal.hasAccess();
      if (!hasAccess) {
        final request = await Gal.requestAccess();
        if (!request) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(context.t('Permission denied to save image', 'تم رفض الإذن لحفظ الصورة'))),
            );
          }
          setState(() {
            _isCapturing = false;
          });
          return;
        }
      }

      final RenderRepaintBoundary boundary = _globalKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      // Wait a short moment to ensure the UI is fully rendered
      await Future.delayed(const Duration(milliseconds: 20));
      final ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      final ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      
      if (byteData != null) {
        final Uint8List pngBytes = byteData.buffer.asUint8List();
        try {
          await Gal.putImageBytes(pngBytes);
        } catch (e) {
          await Gal.putImageBytes(pngBytes, name: 'graph_screenshot_${DateTime.now().millisecondsSinceEpoch}');
        }
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(context.t('Screenshot saved to gallery', 'تم حفظ لقطة الشاشة في المعرض')),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.t('Failed to save screenshot', 'فشل حفظ لقطة الشاشة')),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isCapturing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        RepaintBoundary(
          key: _globalKey,
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: 16.w),
            height: 260.h,
            padding: EdgeInsets.only(top: 20.h, bottom: 12.h, left: 12.w, right: 20.w),
            decoration: BoxDecoration(
              color: context.colorScheme.surface,
              borderRadius: BorderRadius.circular(20.r),
              border: Border.all(
                color: (widget.state.currentState != 'Normal' ? Colors.red : Colors.green).withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: DynamicLineChart(
              dataPoints: widget.state.streamingHistory,
              currentState: widget.state.currentState,
            ),
          ),
        ),
        Positioned(
          top: 12.h,
          right: 28.w,
          child: Container(
            width: 36.w,
            height: 36.w,
            decoration: BoxDecoration(
              color: context.colorScheme.surface,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: IconButton(
              padding: EdgeInsets.zero,
              iconSize: 18.w,
              onPressed: _isCapturing ? null : _captureAndSaveScreenshot,
              icon: _isCapturing 
                  ? SizedBox(width: 18.w, height: 18.w, child: const CircularProgressIndicator(strokeWidth: 2))
                  : Icon(Icons.camera_alt_outlined, color: context.colorScheme.primary),
              tooltip: context.t('Capture Graph', 'تصوير الجراف'),
            ),
          ),
        ),
      ],
    );
  }
}
