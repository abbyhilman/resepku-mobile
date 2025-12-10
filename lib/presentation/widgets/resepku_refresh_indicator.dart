import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:custom_refresh_indicator/custom_refresh_indicator.dart';
import '../../core/theme/app_colors.dart';

/// Custom pull-to-refresh with water droplet effect
/// Water appears briefly then disappears, leaving only the spinning logo
class ResepkuRefreshIndicatorStateful extends StatefulWidget {
  final Widget child;
  final Future<void> Function() onRefresh;

  const ResepkuRefreshIndicatorStateful({
    super.key,
    required this.child,
    required this.onRefresh,
  });

  @override
  State<ResepkuRefreshIndicatorStateful> createState() =>
      _ResepkuRefreshIndicatorStatefulState();
}

class _ResepkuRefreshIndicatorStatefulState
    extends State<ResepkuRefreshIndicatorStateful>
    with SingleTickerProviderStateMixin {
  late AnimationController _rotationController;

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
  }

  @override
  void dispose() {
    _rotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomRefreshIndicator(
      onRefresh: widget.onRefresh,
      onStateChanged: (change) {
        if (change.didChange(to: IndicatorState.loading)) {
          _rotationController.repeat();
        }
        if (change.didChange(from: IndicatorState.loading)) {
          _rotationController.stop();
          _rotationController.reset();
        }
      },
      builder: (context, child, controller) {
        return Stack(
          clipBehavior: Clip.none,
          children: [
            // Main content with offset
            AnimatedBuilder(
              animation: controller,
              builder: (context, _) {
                final easedValue = Curves.easeOutCubic.transform(
                  math.min(controller.value, 1.0),
                );
                return Transform.translate(
                  offset: Offset(0, easedValue * 100), // Reduced offset
                  child: child,
                );
              },
            ),
            // Water effect - only visible in early stages
            AnimatedBuilder(
              animation: controller,
              builder: (context, _) {
                if (controller.value <= 0.01) {
                  return const SizedBox.shrink();
                }
                return _buildWaterEffect(controller);
              },
            ),
          ],
        );
      },
      child: widget.child,
    );
  }

  Widget _buildWaterEffect(IndicatorController controller) {
    final progress = math.min(controller.value, 1.0);
    final isLoading = controller.state.isLoading;

    // Water pool fades out after 60% progress
    final waterOpacity = progress < 0.6
        ? 1.0
        : math.max(0.0, 1.0 - ((progress - 0.6) / 0.2));

    // Thread fades out after 50%
    final threadOpacity = progress < 0.5
        ? 1.0
        : math.max(0.0, 1.0 - ((progress - 0.5) / 0.3));

    // Water height - stays small
    final waterHeight = 25.0 + (math.min(progress, 0.5) * 30);

    // Droplet position - stays near top with small space (around 70-80 from top)
    final dropletTop =
        20 + (math.min(progress, 0.6) * 60); // Max around 56 from top

    return SizedBox(
      width: double.infinity,
      height: 150,
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          // Water pool at top - disappears as progress increases
          if (waterOpacity > 0)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Opacity(
                opacity: waterOpacity,
                child: CustomPaint(
                  painter: _WaterPoolPainter(
                    progress: math.min(progress, 0.6),
                    color: AppColors.primary,
                  ),
                  size: Size(double.infinity, waterHeight),
                ),
              ),
            ),

          // Connection thread - disappears early
          if (progress > 0.1 && progress < 0.8 && threadOpacity > 0)
            Positioned(
              top: waterHeight - 5,
              child: Opacity(
                opacity: threadOpacity,
                child: CustomPaint(
                  painter: _WaterThreadPainter(
                    length: math.min(progress * 30, 20),
                    progress: progress,
                    color: AppColors.primary,
                  ),
                  size: Size(20, math.min(progress * 30, 20)),
                ),
              ),
            ),

          // Logo droplet - stays visible and near top
          Positioned(
            top: dropletTop,
            child: _buildWaterDroplet(controller, isLoading, progress),
          ),
        ],
      ),
    );
  }

  Widget _buildWaterDroplet(
    IndicatorController controller,
    bool isLoading,
    double progress,
  ) {
    final dropletScale = Curves.easeOutBack.transform(
      math.min(progress * 1.5, 1.0),
    );
    final dropletOpacity = Curves.easeIn.transform(
      math.min(progress * 2.5, 1.0),
    );

    return Opacity(
      opacity: dropletOpacity,
      child: Transform.scale(
        scale: dropletScale,
        child: Container(
          width: 54,
          height: 54,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.primary.withOpacity(0.95),
                AppColors.primary,
                Color.lerp(AppColors.primary, Colors.black, 0.15)!,
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.4),
                blurRadius: 16,
                offset: const Offset(0, 6),
                spreadRadius: 1,
              ),
            ],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Water highlight effect
              Positioned(
                top: 6,
                left: 8,
                child: Container(
                  width: 10,
                  height: 6,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.35),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              // Logo icon - rotates when loading
              AnimatedBuilder(
                animation: isLoading ? _rotationController : controller,
                builder: (context, _) {
                  final rotationValue = isLoading
                      ? _rotationController.value
                      : 0.0;
                  return Transform.rotate(
                    angle: rotationValue * math.pi * 2,
                    child: const Icon(
                      Icons.restaurant_menu,
                      color: Colors.white,
                      size: 28,
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Painter for the water pool at top
class _WaterPoolPainter extends CustomPainter {
  final double progress;
  final Color color;

  _WaterPoolPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [color, color.withOpacity(0.7), color.withOpacity(0.3)],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final path = Path();
    final centerX = size.width / 2;
    final bulgeDepth = 8 + (progress * 15);

    path.moveTo(0, 0);
    path.lineTo(size.width, 0);
    path.lineTo(size.width, size.height - bulgeDepth);

    // Create bulge at bottom center (where drop forms)
    path.quadraticBezierTo(
      size.width * 0.75,
      size.height - bulgeDepth,
      centerX + 25,
      size.height,
    );
    path.quadraticBezierTo(
      centerX,
      size.height + bulgeDepth * 0.4,
      centerX - 25,
      size.height,
    );
    path.quadraticBezierTo(
      size.width * 0.25,
      size.height - bulgeDepth,
      0,
      size.height - bulgeDepth,
    );

    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _WaterPoolPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

/// Painter for the thin water thread
class _WaterThreadPainter extends CustomPainter {
  final double length;
  final double progress;
  final Color color;

  _WaterThreadPainter({
    required this.length,
    required this.progress,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final thickness = math.max(2.0, 6.0 - (progress * 4));

    final paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          color.withOpacity(0.6),
          color.withOpacity(0.3),
          color.withOpacity(0.1),
        ],
      ).createShader(Rect.fromLTWH(0, 0, thickness, length))
      ..strokeWidth = thickness
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final path = Path();
    path.moveTo(size.width / 2, 0);
    path.lineTo(size.width / 2, length);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _WaterThreadPainter oldDelegate) {
    return oldDelegate.length != length || oldDelegate.progress != progress;
  }
}

/// Simple version without animation controller
class ResepkuRefreshIndicator extends StatelessWidget {
  final Widget child;
  final Future<void> Function() onRefresh;

  const ResepkuRefreshIndicator({
    super.key,
    required this.child,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return CustomRefreshIndicator(
      onRefresh: onRefresh,
      builder: (context, child, controller) {
        return Stack(
          clipBehavior: Clip.none,
          children: [
            AnimatedBuilder(
              animation: controller,
              builder: (context, _) {
                final easedValue = Curves.easeOutCubic.transform(
                  math.min(controller.value, 1.0),
                );
                return Transform.translate(
                  offset: Offset(0, easedValue * 100),
                  child: child,
                );
              },
            ),
            AnimatedBuilder(
              animation: controller,
              builder: (context, _) {
                if (controller.value <= 0.01) {
                  return const SizedBox.shrink();
                }
                return _buildWaterEffect(controller);
              },
            ),
          ],
        );
      },
      child: child,
    );
  }

  Widget _buildWaterEffect(IndicatorController controller) {
    final progress = math.min(controller.value, 1.0);
    final waterOpacity = progress < 0.6
        ? 1.0
        : math.max(0.0, 1.0 - ((progress - 0.6) / 0.2));
    final threadOpacity = progress < 0.5
        ? 1.0
        : math.max(0.0, 1.0 - ((progress - 0.5) / 0.3));
    final waterHeight = 25.0 + (math.min(progress, 0.5) * 30);
    final dropletTop = 20 + (math.min(progress, 0.6) * 60);

    return SizedBox(
      width: double.infinity,
      height: 150,
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          if (waterOpacity > 0)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Opacity(
                opacity: waterOpacity,
                child: CustomPaint(
                  painter: _WaterPoolPainter(
                    progress: math.min(progress, 0.6),
                    color: AppColors.primary,
                  ),
                  size: Size(double.infinity, waterHeight),
                ),
              ),
            ),
          if (progress > 0.1 && progress < 0.8 && threadOpacity > 0)
            Positioned(
              top: waterHeight - 5,
              child: Opacity(
                opacity: threadOpacity,
                child: CustomPaint(
                  painter: _WaterThreadPainter(
                    length: math.min(progress * 30, 20),
                    progress: progress,
                    color: AppColors.primary,
                  ),
                  size: Size(20, math.min(progress * 30, 20)),
                ),
              ),
            ),
          Positioned(top: dropletTop, child: _buildDroplet(progress)),
        ],
      ),
    );
  }

  Widget _buildDroplet(double progress) {
    final dropletScale = Curves.easeOutBack.transform(
      math.min(progress * 1.5, 1.0),
    );
    final dropletOpacity = Curves.easeIn.transform(
      math.min(progress * 2.5, 1.0),
    );

    return Opacity(
      opacity: dropletOpacity,
      child: Transform.scale(
        scale: dropletScale,
        child: Container(
          width: 54,
          height: 54,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.primary.withOpacity(0.95),
                AppColors.primary,
                Color.lerp(AppColors.primary, Colors.black, 0.15)!,
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.4),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Positioned(
                top: 6,
                left: 8,
                child: Container(
                  width: 10,
                  height: 6,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.35),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              const Icon(Icons.restaurant_menu, color: Colors.white, size: 28),
            ],
          ),
        ),
      ),
    );
  }
}
