import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../utils/app_colors.dart';
import 'dart:async';
import 'dart:math' as math;

class TrackingScreen extends StatefulWidget {
  const TrackingScreen({super.key});

  @override
  State<TrackingScreen> createState() => _TrackingScreenState();
}

class _TrackingScreenState extends State<TrackingScreen> {
  double _progress = 0.0;
  int _secondsLeft = 1440; // 24 mins
  late Timer _timer;
  bool _showDiscount = false;

  @override
  void initState() {
    super.initState();
    _startSimulation();
  }

  void _startSimulation() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_secondsLeft > 0) {
          _secondsLeft--;
          _progress += 0.0005; // Simulate movement
        } else {
          _showDiscount = true;
          _timer.cancel();
        }
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  String get _timeString {
    int mins = _secondsLeft ~/ 60;
    int secs = _secondsLeft % 60;
    return "${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.offWhite,
      body: Stack(
        children: [
          // Simulated 3D Map (Stylized)
          Positioned.fill(
            child: Container(
              color: AppColors.softGrey,
              child: CustomPaint(
                painter: _MapGridPainter(),
              ),
            ),
          ),

          // 3D Scooter Icon (Simulated with animation)
          AnimatedPositioned(
            duration: const Duration(seconds: 1),
            left: 50 + (MediaQuery.of(context).size.width - 100) * _progress,
            top: 200 + 50 * math.sin(_progress * 10),
            child: Column(
              children: [
                const Icon(
                  Icons.moped,
                  color: AppColors.sunsetOrange,
                  size: 40,
                ).animate(onPlay: (controller) => controller.repeat())
                 .shimmer(duration: 1.seconds)
                 .moveY(begin: -5, end: 5, curve: Curves.easeInOut),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primaryDark,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.sunsetOrange.withOpacity(0.5)),
                  ),
                  child: const Text(
                    "YOUR RIDER",
                    style: TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),

          // Header
          Positioned(
            top: 60,
            left: 20,
            right: 20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.close, color: AppColors.primaryDark),
                  onPressed: () => Navigator.pop(context),
                ),
                const Column(
                  children: [
                    Text(
                      "ZIPPY DELIVERY",
                      style: TextStyle(color: AppColors.primaryDark, fontWeight: FontWeight.bold, letterSpacing: 2),
                    ),
                    Text(
                      "ORDER #4921",
                      style: TextStyle(color: AppColors.primaryDark, fontSize: 10),
                    ),
                  ],
                ),
                const SizedBox(width: 48), // Spacer
              ],
            ),
          ),

          // Bottom Tracking Card
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(30),
              decoration: const BoxDecoration(
                color: AppColors.pureWhite,
                borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 20,
                    offset: Offset(0, -5),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "ESTIMATED ARRIVAL",
                            style: TextStyle(color: AppColors.primaryDark.withOpacity(0.5), fontSize: 10, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _timeString,
                            style: TextStyle(
                              color: Theme.of(context).primaryColor,
                              fontSize: 40,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Courier', // Digital clock feel
                            ),
                          ).animate(onPlay: (controller) => controller.repeat())
                           .shimmer(delay: 500.ms, duration: 2.seconds),
                        ],
                      ),
                      if (_showDiscount)
                        ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.errorRed,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const Text("GET DISCOUNT", style: TextStyle(fontWeight: FontWeight.bold)),
                        ).animate().shake().scale(),
                    ],
                  ),
                  const SizedBox(height: 30),
                  
                  // Progress Timeline
                  Row(
                    children: [
                      _buildTimelineStep("Accepted", true),
                      _buildTimelineDivider(true),
                      _buildTimelineStep("Packed", true),
                      _buildTimelineDivider(_progress > 0.3),
                      _buildTimelineStep("On Way", _progress > 0.3),
                    ],
                  ),
                  
                  const SizedBox(height: 40),
                  
                  // Rider Info
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const CircleAvatar(
                      radius: 25,
                      backgroundImage: NetworkImage('https://images.unsplash.com/photo-1500648767791-00dcc994a43e'),
                    ),
                    title: const Text("Rohan Sharma", style: TextStyle(color: AppColors.primaryDark, fontWeight: FontWeight.bold)),
                    subtitle: Text("Hero Splendor • 4.9 ★", style: TextStyle(color: AppColors.primaryDark.withOpacity(0.5), fontSize: 12)),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildActionButton(Icons.phone, () {}),
                        const SizedBox(width: 12),
                        _buildActionButton(Icons.chat_bubble, () {}),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineStep(String label, bool isDone) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: isDone ? theme.primaryColor : Colors.grey.shade300,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            color: isDone ? AppColors.primaryDark : AppColors.primaryDark.withOpacity(0.3),
            fontSize: 10,
            fontWeight: isDone ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  Widget _buildTimelineDivider(bool isDone) {
    final theme = Theme.of(context);
    return Expanded(
      child: Container(
        height: 2,
        margin: const EdgeInsets.only(bottom: 18),
        color: isDone ? theme.primaryColor.withOpacity(0.5) : Colors.grey.shade200,
      ),
    );
  }

  Widget _buildActionButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white10),
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }
}

class _MapGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.05)
      ..strokeWidth = 1.0;

    for (double i = 0; i < size.width; i += 40) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), paint);
    }
    for (double i = 0; i < size.height; i += 40) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), paint);
    }
    
    // Draw some "buildings" (simplified rectangles)
    final rectPaint = Paint()..color = Colors.white.withOpacity(0.02);
    canvas.drawRect(const Rect.fromLTWH(100, 100, 60, 80), rectPaint);
    canvas.drawRect(const Rect.fromLTWH(250, 300, 40, 100), rectPaint);
    canvas.drawRect(const Rect.fromLTWH(50, 500, 80, 40), rectPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

